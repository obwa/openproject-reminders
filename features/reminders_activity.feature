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

Feature: Show reminder activity

  Background:
        Given there is 1 project with the following:
              | identifier | dingens |
              | name       | dingens |
          And the project "dingens" uses the following modules:
              | reminders |
              | activity |
          And there is 1 user with:
              | login    | alice |
              | language | en    |
              | admin    | true  |
          And there is a role "user"
          And the role "user" may have the following rights:
              | view_reminders |
              | edit_reminders |
          And the user "alice" is a "user" in the project "dingens"
          And the user "alice" has the following preferences
              | time_zone | UTC |
          And there is 1 user with:
              | login    | bob |
          And there is 1 reminder in project "dingens" created by "bob" with:
              | title      | Bobs reminder        |
              | location   | Room 2              |
              | duration   | 2.5                 |
              | start_time | 2011-02-10 11:00:00 |
          And the reminder "Bobs reminder" has 1 agenda with:
              | locked | true   |
              | text   | foobaz |
          And the reminder "Bobs reminder" has minutes with:
              | text   | barbaz |
          And I am already logged in as "alice"

  Scenario: Navigate to the project's activity page and see the reminder activity
       When I go to the reminders activity page for the project "dingens"
        And I activate activity filter "reminders"
       When I click "Apply"
       Then I should see "reminder: Bobs reminder (02/10/2011 11:00 AM-01:30 PM)" within "li.reminder a"
        And I should see "Agenda: Bobs reminder" within ".reminder-agenda"
        And I should see "Minutes: Bobs reminder" within ".reminder-minutes"

  Scenario: Change a metadata on a reminder and see the activity on the project's activity page
       When I go to the edit page for the reminder called "Bobs reminder"
        And I fill in the following:
            | reminder_location | Geheimer Ort! |
        And I press "Save"
        And I go to the reminders activity page for the project "dingens"
        And I activate activity filter "reminders"
       When I click "Apply"
       Then I should see "reminder: Bobs reminder (02/10/2011 11:00 AM-01:30 PM)" within ".reminder.me"
