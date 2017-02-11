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

require 'spec_helper'

describe reminderContentsController do
  let(:role) { FactoryGirl.create(:role, permissions: [:view_reminders]) }
  let(:project) { FactoryGirl.create(:project) }
  let(:author) { FactoryGirl.create(:user, member_in_project: project, member_through_role: role) }
  let(:watcher1) { FactoryGirl.create(:user, member_in_project: project, member_through_role: role) }
  let(:watcher2) { FactoryGirl.create(:user, member_in_project: project, member_through_role: role) }
  let(:reminder) { FactoryGirl.create(:reminder, author: author, project: project) }
  let(:reminder_agenda) do
    FactoryGirl.create(:reminder_agenda, reminder: reminder)
  end

  before(:each) do
    ActionMailer::Base.deliveries = []
    allow_any_instance_of(reminderContentsController).to receive(:find_content)
    allow(controller).to receive(:authorize)
    reminder.participants.merge([reminder.participants.build(user: watcher1, invited: true, attended: false),
                                reminder.participants.build(user: watcher2, invited: true, attended: false)])
    reminder.save!
    controller.instance_variable_set(:@content, reminder_agenda.reminder.agenda)
    controller.instance_variable_set(:@content_type, 'reminder_agenda')
  end

  shared_examples_for 'delivered by mail' do
    before { put 'notify', reminder_id: reminder.id }

    it { expect(ActionMailer::Base.deliveries.count).to eql(mail_count) }
  end

  describe 'PUT' do
    describe 'notify' do
      context 'when author no_self_notified property is true' do
        before do
          author.pref[:no_self_notified] = true
          author.save!
        end

        it_behaves_like 'delivered by mail' do
          let(:mail_count) { 2 }
        end
      end

      context 'when author no_self_notified property is false' do
        before do
          author.pref[:no_self_notified] = false
          author.save!
        end

        it_behaves_like 'delivered by mail' do
          let(:mail_count) { 3 }
        end
      end

      context 'with an error during deliver' do
        before do
          author.pref[:no_self_notified] = false
          author.save!
          allow(reminderMailer).to receive(:content_for_review).and_raise(Net::SMTPError)
        end

        it 'does not raise an error' do
          expect { put 'notify', reminder_id: reminder.id }.to_not raise_error
        end

        it 'produces a flash message containing the mail addresses raising the error' do
          put 'notify', reminder_id: reminder.id
          reminder.participants.each do |participant|
            expect(flash[:error]).to include(participant.name)
          end
        end
      end
    end
  end
end
