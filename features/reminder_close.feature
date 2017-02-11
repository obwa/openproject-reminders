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

Feature: Close and open reminder agendas

  Background:
        Given there is 1 project with the following:
              | identifier | dingens |
              | name       | dingens |
          And the project "dingens" uses the following modules:
              | reminders |
          And there is 1 user with:
              | login    | alice |
              | language | en    |
          And there is 1 user with:
              | login | bob |
          And there is a role "user"
          And the user "alice" is a "user" in the project "dingens"
          And there is 1 reminder in project "dingens" created by "bob" with:
              | title | Bobs reminder |

  @javascript
  Scenario: Navigate to a reminder page with no permission to close reminder agendas
      Given the role "user" may have the following rights:
            | view_reminders |
       When I am already logged in as "alice"
        And I go to the show page of the reminder called "Bobs reminder"
        And I follow "Agenda"
       Then I should not see "Close" within ".reminder_agenda"

  @javascript
  Scenario: Navigate to a reminder page with permission to close the reminder agenda and go to the minutes
      Given the role "user" may have the following rights:
            | view_reminders         |
            | close_reminder_agendas |
       When I am already logged in as "alice"
        And I go to the show page of the reminder called "Bobs reminder"
        And I follow "Minutes" within ".tabs"
       Then I should not see "Edit" within ".reminder_minutes"
        And I should see "Close the agenda to begin the Minutes" within ".reminder_minutes"

  @javascript
  Scenario: Navigate to a reminder page with permission to close and close the reminder agenda copies the text and shows the reminder
      Given the role "user" may have the following rights:
            | view_reminders         |
            | close_reminder_agendas |
        And the reminder "Bobs reminder" has 1 agenda with:
            | text | "blubber" |
       When I am already logged in as "alice"
        And I go to the show page of the reminder called "Bobs reminder"
        And I follow "Close" within ".reminder_agenda"

       Then I should be on the show page of the reminder called "Bobs reminder"
        And the minutes should contain the following text:
            | blubber |

       When I follow "Agenda"
       Then I should not see "Close" within ".reminder_agenda"
        And I should see "Open" within ".reminder_agenda"

  @javascript
  Scenario: Navigate to a reminder page with permission to close and open the reminder agenda
      Given the role "user" may have the following rights:
            | view_reminders         |
            | close_reminder_agendas |
            # This won't work because the needed "click on open" has a confirm() which cucumber doesn't seem to handle
      # And the reminder "Bobs reminder" has 1 agenda with:
      #     | locked | true |
       When I am already logged in as "alice"
        And I go to the show page of the reminder called "Bobs reminder"
        And I follow "Agenda"
      # And I click on "Open"
       Then I should not see "Open" within ".reminder_agenda"
        And I should see "Close" within ".reminder_agenda"

  @javascript
  Scenario: Navigate to a reminder page with a closed reminder agenda and permission to edit reminder agendas
      Given the role "user" may have the following rights:
            | view_reminders          |
            | create_reminder_agendas |
        And the reminder "Bobs reminder" has 1 agenda with:
            | locked | true |
       When I am already logged in as "alice"
        And I go to the show page of the reminder called "Bobs reminder"
        And I follow "Agenda"
       Then I should not see "Edit" within ".reminder_agenda"
