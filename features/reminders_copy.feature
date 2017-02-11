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

Feature: Copy reminders

  Background:
        Given there is 1 project with the following:
              | identifier | dingens |
              | name       | dingens |
          And the project "dingens" uses the following modules:
              | reminders |
          And there is 1 user with:
              | login     | alice  |
              | language  | en     |
              | firstname | Alice  |
              | lastname  | Alice  |
          And the user "alice" has the following preferences
              | time_zone | UTC    |
          And there is 1 user with:
              | login     | bob    |
          And there is 1 user with:
              | login     | charly |
          And there is 1 user with:
              | login     | dave   |
          And there is a role "user"
          And the user "alice" is a "user" in the project "dingens"
          And there is 1 reminder in project "dingens" created by "alice" with:
              | title      | Alices reminder      |
              | location   | CZI                 |
              | duration   | 1.5                 |
              | start_time | 2013-03-27 18:55:00 |

  Scenario: Navigate to a reminder page with permission to create reminders
      Given the role "user" may have the following rights:
            | view_reminders   |
            | create_reminders |
       When I am already logged in as "alice"
        And I go to the reminders page for the project called "dingens"
        And I click on "Alices reminder"
       Then I should see "Copy" within ".reminder--main-toolbar"

  Scenario: Navigate to a reminder copy page
      Given the role "user" may have the following rights:
            | view_reminders   |
            | create_reminders |
       When I am already logged in as "alice"
        And I go to the reminders page for the project called "dingens"
        And I click on "Alices reminder"
        And I click on "Copy"
       Then the "reminder[title]" field should contain "Alices reminder"
        And the "reminder[location]" field should contain "CZI"
        And the "reminder[duration]" field should contain "1.5"
        And the "reminder[start_date]" field should contain "2013-03-27"
        And the "reminder[start_time_hour]" field should contain "18:55"
       #And no participant should be selected as attendee
       #And only invited participants should be selected as invitees

  Scenario: Navigate to a reminder copy page to make sure the author is selected as invited but not as attendee
      Given the role "user" may have the following rights:
            | view_reminders   |
            | create_reminders |
        And "alice" attended the reminder "Alices reminder"
       When I am already logged in as "alice"
        And I go to the reminders page for the project called "dingens"
        And I click on "Alices reminder"
        And I click on "Copy"
       Then the "reminder[participants_attributes][][invited]" checkbox should be checked
        And the "reminder[participants_attributes][][attended]" checkbox should not be checked

  Scenario: Copy a reminder and make sure the author isn''t copied over
      Given the role "user" may have the following rights:
            | view_reminders   |
            | create_reminders |
       When I am already logged in as "alice"
        And I go to the reminders page for the project called "dingens"
        And I click on "Alices reminder"
        And I click on "Copy"
        And I click on "Create"
       Then I should not see "Alice Alice; Alice Alice"
        And I should see "Alice Alice"

  Scenario: Copy a reminder and make sure the agenda is copied over
      Given the role "user" may have the following rights:
            | view_reminders   |
            | create_reminders |
        And the reminder "Alices reminder" has 1 agenda with:
            | text | "blubber" |
       When I am already logged in as "alice"
        And I go to the reminders page for the project called "dingens"
        And I click on "Alices reminder"
        And I follow "Copy"
        And I press "Create"
        And I follow "Agenda"
        And I follow "History" within ".reminder_agenda"
       Then I should see "Copied from reminder #"
