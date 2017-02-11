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

describe Project::Activity, type: :model do
  let(:project) do
    FactoryGirl.create(:project)
  end

  let(:initial_time) { Time.now }

  let(:reminder) do
    FactoryGirl.create(:reminder,
                       project: project)
  end

  let(:reminder2) do
    FactoryGirl.create(:reminder,
                       project: project)
  end

  let(:work_package) do
    FactoryGirl.create(:work_package,
                       project: project)
  end

  def latest_activity
    Project.with_latest_activity.find(project.id).latest_activity_at
  end

  describe '.with_latest_activity' do
    it 'is the latest reminder update' do
      reminder.update_attribute(:updated_at, initial_time - 10.seconds)
      reminder2.update_attribute(:updated_at, initial_time - 20.seconds)
      reminder.reload
      reminder2.reload

      expect(latest_activity).to eql reminder.updated_at
    end

    it 'takes the time stamp of the latest activity across models' do
      work_package.update_attribute(:updated_at, initial_time - 10.seconds)
      reminder.update_attribute(:updated_at, initial_time - 20.seconds)

      work_package.reload
      reminder.reload

      # Order:
      # work_package
      # reminder

      expect(latest_activity).to eql work_package.updated_at

      work_package.update_attribute(:updated_at, reminder.updated_at - 10.seconds)

      # Order:
      # reminder
      # work_package

      expect(latest_activity).to eql reminder.updated_at
    end
  end
end
