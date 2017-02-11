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

Feature: Create new reminders

  Background:
        Given there is 1 project with the following:
              | identifier | dingens |
              | name       | dingens |
          And the project "dingens" uses the following modules:
              | reminders |
          And there is 1 user with:
              | login    | alice |
              | language | en    |
          And there is a role "user"
          And the user "alice" is a "user" in the project "dingens"

  Scenario: Navigate to the reminder index page with no permission to create new reminders
      Given the role "user" may have the following rights:
            | view_reminders   |
       When I am already logged in as "alice"
        And I go to the reminders page for the project called "dingens"
       Then I should not see "reminder" within ".toolbar-items"

  Scenario: Navigate to the reminder index page with permission to create new reminders
      Given the role "user" may have the following rights:
            | view_reminders   |
            | create_reminders |
       When I am already logged in as "alice"
        And I go to the reminders page for the project called "dingens"
       Then I should see "reminder" within ".toolbar-items"

  Scenario: Create a new reminder with no title
      Given the role "user" may have the following rights:
            | view_reminders   |
            | create_reminders |
       When I am already logged in as "alice"
        And I go to the reminders page for the project called "dingens"
        And I click on "New reminder"
        And I click on "Create"
       Then I should see "Title can't be blank"

  Scenario Outline: Create a new reminder with a title and a date, time, and duration with no and different time zones set
      Given the role "user" may have the following rights:
            | view_reminders   |
            | create_reminders |
       When I am already logged in as "alice"
       And the user "alice" has the following preferences
              | time_zone | <t_zone> |
        And I go to the reminders page for the project called "dingens"
        And I click on "New reminder"
        And I fill in the following:
            | reminder_title           | FSR Sitzung 123 |
            | reminder-form-start-date | 2013-03-28      |
            | reminder-form-start-time | 13:30           |
            | reminder-form-duration   | 1.5             |
        And I click on "Create"
       Then I should see "Successful creation."
        And I should see "FSR Sitzung 123"
        And I should see "03/28/2013 01:30 PM - 03:00 PM"

  Examples:
    | t_zone                     |
    | CET                        |
    | UTC                        |
    |                            |
    | Pacific Time (US & Canada) |

  Scenario: Visit the new reminder page to make sure the author is selected as invited
      Given the role "user" may have the following rights:
            | view_reminders   |
            | create_reminders |
       When I am already logged in as "alice"
        And I go to the reminders page for the project called "dingens"
        And I click on "New reminder"
       Then the "reminder[participants_attributes][][invited]" checkbox should be checked

  Scenario: Create a reminder in a project without members shouldn't error out
    Given there is 1 project with the following:
      | identifier | foreverempty |
      | name       | foreverempty |
    And the project "foreverempty" uses the following modules:
      | reminders |
    When I am already admin
    And I go to the reminders page for the project called "foreverempty"
    And I click on "New reminder"
    And I fill in the following:
      | reminder_title | Emtpy reminders |
    And I press "Create"
    Then I should see "Successful creation."
