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

Given /^there is (\d+) [Mm]eetings? in project "(.+)" created by "(.+)" with:$/ do |count, project, user, table|
  count.to_i.times do
    m = FactoryGirl.build(:reminder)
    m.project = Project.find_by_name(project)
    m.author  = User.find_by_login(user)
    send_table_to_object(m, table)
  end
end

Given /^there is (\d+) [Mm]eetings? in project "(.+)" that start (.*) days? from now with:$/ do |count, project, time, table|
  count.to_i.times do
    m = FactoryGirl.build(:reminder, start_time: Time.now + time.to_i.days)
    m.project = Project.find_by_name(project)
    send_table_to_object(m, table)
  end
end

Given /^the [Mm]eeting "(.+)" has 1 agenda with:$/ do |reminder, table|
  m = reminder.find_by_title(reminder)
  ma = reminderAgenda.find_by_reminder_id(m.id) || FactoryGirl.build(:reminder_agenda, reminder: m)
  send_table_to_object(ma, table)
end

Given /^the [Mm]eeting "(.+)" has 1 agenda$/ do |reminder|
  m = reminder.find_by_title(reminder)
  m.agenda ||= FactoryGirl.build(:reminder_agenda)
  m.save!
end

Given /^the [Mm]eeting "(.+)" has minutes with:$/ do |reminder, table|
  m = reminder.find_by_title(reminder)
  mm = reminderMinutes.find_by_reminder_id(m.id) || FactoryGirl.build(:reminder_minutes, reminder: m)
  send_table_to_object(mm, table)
end

Given /^"(.+)" is invited to the [Mm]eeting "(.+)"$/ do |user, reminder|
  m = reminder.find_by_title(reminder)
  p = m.participants.detect { |p| p.user_id = User.find_by_login(user).id } || FactoryGirl.build(:reminder_participant, reminder: m)
  p.invited = true
  p.save
end

Given /^"(.+)" attended the [Mm]eeting "(.+)"$/ do |user, reminder|
  m = reminder.find_by_title(reminder)
  p = m.participants.detect { |p| p.user_id = User.find_by_login(user).id } || FactoryGirl.build(:reminder_participant, reminder: m)
  p.attended = true
  p.save
end

When /the agenda of the reminder "(.+)" changes meanwhile/ do |reminder|
  m = reminder.find_by_title(reminder)
  m.agenda.text = 'oder oder?'
  m.agenda.save!
end

Then /^the minutes should contain the following text:$/ do |table|
  step %{I should see "#{table.raw.first.first}" within "#reminder_minutes-text"}
end

Then /^there should be a text edit toolbar for the "(.+)" field$/ do |field_id|
  # second parent up
  ancestor = find(:xpath, "//*[@id='#{field_id.gsub('#','')}']/../..")

  expect(ancestor).to have_selector('.jstElements')
end
