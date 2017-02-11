#-- copyright
# OpenProject reminder Plugin
#
# Copyright (C) 2011-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.md for more details.
#++

require File.dirname(__FILE__) + '/../spec_helper'

describe reminder, type: :model do
  it { is_expected.to belong_to :project }
  it { is_expected.to belong_to :author }
  it { is_expected.to validate_presence_of :title }

  let(:project) { FactoryGirl.create(:project) }
  let(:user1) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:reminder) { FactoryGirl.create(:reminder, project: project, author: user1) }
  let(:agenda) do
    reminder.create_agenda text: 'reminder Agenda text'
    reminder.agenda(true) # avoiding stale object errors
  end

  let(:role) { FactoryGirl.create(:role, permissions: [:view_reminders]) }

  before do
    @m = FactoryGirl.build :reminder, title: 'dingens'
  end

  describe 'to_s' do
    it { expect(@m.to_s).to eq('dingens') }
  end

  describe 'start_date' do
    it { expect(@m.start_date).to eq(Date.tomorrow.iso8601) }
  end

  describe 'start_month' do
    it { expect(@m.start_month).to eq(Date.tomorrow.month) }
  end

  describe 'start_year' do
    it { expect(@m.start_year).to eq(Date.tomorrow.year) }
  end

  describe 'end_time' do
    it { expect(@m.end_time).to eq(Date.tomorrow + 11.hours) }
  end

  describe 'date validations' do
    it 'marks invalid start dates' do
      @m.start_date = '-'
      expect(@m.start_date).to eq('-')
      expect { @m.start_time }.to raise_error(ArgumentError)
      expect(@m).not_to be_valid
      expect(@m.errors.count).to eq(1)
    end

    it 'marks invalid start hours' do
      @m.start_time_hour = '-'
      expect(@m.start_time_hour).to eq('-')
      expect { @m.start_time }.to raise_error(ArgumentError)
      expect(@m).not_to be_valid
      expect(@m.errors.count).to eq(1)
    end

    it 'is not invalid when setting date_time explicitly' do
      @m.start_time = DateTime.now
      expect(@m).to be_valid
    end

    it 'is invalid when setting date_time wrong' do
      @m.start_time = '-'
      expect(@m).not_to be_valid
    end

    it 'accepts changes after invalid dates' do
      @m.start_date = '-'
      expect { @m.start_time }.to raise_error(ArgumentError)
      expect(@m).not_to be_valid

      @m.start_date = Date.today.iso8601
      expect(@m).to be_valid

      @m.save!
      expect(@m.start_time).to eq(Date.today + 10.hours)
    end
  end

  describe 'Journalized Objects' do
    before(:each) do
      @project ||= FactoryGirl.create(:project_with_types)
      @current = FactoryGirl.create(:user, login: 'user1', mail: 'user1@users.com')
      allow(User).to receive(:current).and_return(@current)
    end

    it 'should work with reminder' do
      @reminder ||= FactoryGirl.create(:reminder, title: 'Test', project: @project, author: @current)

      initial_journal = @reminder.journals.first
      recreated_journal = @reminder.recreate_initial_journal!
      expect(initial_journal.identical?(recreated_journal)).to be true
    end
  end

  describe 'all_changeable_participants' do
    describe 'WITH a user having the view_reminders permission' do
      before do
        project.add_member user1, [role]
        project.save!
      end

      it 'should contain the user' do
        expect(reminder.all_changeable_participants).to eq([user1])
      end
    end

    describe 'WITH a user not having the view_reminders permission' do
      let(:role2) { FactoryGirl.create(:role, permissions: []) }

      before do
        # adding both users so that the author is valid
        project.add_member user1, [role]
        project.add_member user2, [role2]

        project.save!
      end

      it 'should not contain the user' do
        expect(reminder.all_changeable_participants.include?(user2)).to be_falsey
      end
    end

    describe 'WITH a user being locked but invited' do
      let(:locked_user) { FactoryGirl.create(:locked_user) }
      before do
        reminder.participants_attributes = [{ 'user_id' => locked_user.id, 'invited' => 1 }]
      end

      it 'should contain the user' do
        expect(reminder.all_changeable_participants.include?(locked_user)).to be_truthy
      end
    end
  end

  describe 'participants and author as watchers' do
    before do
      project.add_member user1, [role]
      project.add_member user2, [role]

      project.save!

      reminder.participants.build(user: user2)
      reminder.save!
    end

    it { expect(reminder.watchers.collect(&:user)).to match_array([user1, user2]) }
  end

  describe '#close_agenda_and_copy_to_minutes' do
    before do
      agenda # creating it

      reminder.close_agenda_and_copy_to_minutes!
    end

    it "should create a reminder with the agenda's text" do
      expect(reminder.minutes.text).to eq(reminder.agenda.text)
    end

    it 'should close the agenda' do
      expect(reminder.agenda.locked?).to be_truthy
    end
  end

  describe 'Timezones' do
    shared_examples 'uses that zone' do |zone|
      it do
        @m.start_date = '2016-07-01'
        expect(@m.start_time.zone).to eq(zone)
      end
    end

    context 'default zone' do
      it_behaves_like 'uses that zone', 'UTC'
    end

    context 'other timezone set' do
      before do
        Time.zone = 'EST'
      end

      it_behaves_like 'uses that zone', 'EST'
    end
  end

  describe 'Copied reminders' do
    before do
      project.add_member user1, [role]
      project.add_member user2, [role]

      project.save!

      reminder.start_date = '2013-03-27'
      reminder.start_time_hour = '15:35'
      reminder.participants.build(user: user2)
      reminder.save!
    end

    it 'should have the same start_time as the original reminder' do
      copy = reminder.copy({})
      expect(copy.start_time).to eq(reminder.start_time)
    end

    it 'should delete the copied reminder author if no author is given as parameter' do
      copy = reminder.copy({})
      expect(copy.author).to be_nil
    end

    it 'should set the author to the provided author if one is given' do
      copy = reminder.copy author: user2
      expect(copy.author).to eq(user2)
    end

    it 'should clear participant ids and attended flags for all copied attendees' do
      copy = reminder.copy({})
      expect(copy.participants.all? { |p| p.id.nil? && !p.attended }).to be_truthy
    end
  end
end
