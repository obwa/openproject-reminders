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

Feature: Show reminders

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
        Given I am already logged in as "alice"

  Scenario: Navigate to a reminder page
      Given the role "user" may have the following rights:
            | view_reminders |
       When I go to the reminders page for the project called "dingens"
        And I follow "Bobs reminder"
       Then I should be on the show page for the reminder called "Bobs reminder"

  Scenario: Navigate to a reminder page with an open agenda
      Given the role "user" may have the following rights:
            | view_reminders |

       When I go to the show page for the reminder called "Bobs reminder"

       Then I should see "Agenda" within ".reminder_agenda"
        And I should see "There is currently nothing to display." within ".reminder_agenda"

  Scenario: Navigate to a reminder page with a closed agenda
      Given the role "user" may have the following rights:
            | view_reminders |
        And the reminder "Bobs reminder" has 1 agenda with:
            | locked | true |

       When I go to the show page for the reminder called "Bobs reminder"

       Then I should see "Minutes" within ".reminder_minutes"
        And I should see "There is currently nothing to display." within ".reminder_minutes"

  @javascript
  Scenario: Navigate to a reminder page with an open agenda and the permission to edit the agenda
      Given the role "user" may have the following rights:
            | view_reminders          |
            | create_reminder_agendas |

       When I go to the show page for the reminder called "Bobs reminder"

       Then I should see "Agenda" within ".reminder_agenda"
        And I should not see "There is currently nothing to display." within "#reminder_agenda_text"
        And there should be a text edit toolbar for the "#reminder_agenda_text" field

  @javascript
  Scenario: Navigate to a reminder page with a closed agenda and the permission to edit the minutes
      Given the role "user" may have the following rights:
            | view_reminders          |
            | create_reminder_minutes |
        And the reminder "Bobs reminder" has 1 agenda with:
            | locked | true |

       When I go to the show page of the reminder called "Bobs reminder"

       Then I should see "Minutes" within ".reminder_minutes"
        And I should not see "No data to display" within "#reminder_minutes_text"
        And there should be a text edit toolbar for the "#reminder_minutes_text" field

  @javascript
  Scenario: Navigate to a reminder page with an open agenda and the permission to edit the minutes
      Given the role "user" may have the following rights:
            | view_reminders          |
            | create_reminder_minutes |

       When I go to the show page for the reminder called "Bobs reminder"
            # Make sure we're on the right tab
        And I click on "Minutes"

       Then I should not see "Edit" within ".reminder_minutes"

  @javascript
  Scenario: Navigate to a reminder page with a closed agenda and the permission to edit the agenda
      Given the role "user" may have the following rights:
            | view_reminders          |
            | create_reminder_agendas |
        And the reminder "Bobs reminder" has 1 agenda with:
            | locked | true |

       When I go to the show page for the reminder called "Bobs reminder"
            # Make sure we're on the right tab
        And I click on "Agenda"

       Then I should not see "Edit" within ".reminder_agenda"

  Scenario: Navigate to a reminder page with a closed agenda and the permission to edit the minutes and save minutes
      Given the role "user" may have the following rights:
            | view_reminders          |
            | create_reminder_minutes |
        And the reminder "Bobs reminder" has 1 agenda with:
            | locked | true |

       When I go to the show page for the reminder called "Bobs reminder"
        And I fill in "reminder_minutes[text]" with "Some minutes!"
        And I click on "Save"

       Then I should see "Minutes" within ".reminder_minutes"
        And I should see "Some minutes!" within "#reminder_minutes_text"

  Scenario: Navigate to a reminder page and view an older version of an agenda
      Given the role "user" may have the following rights:
            | view_reminders |
        And the reminder "Bobs reminder" has 1 agenda with:
            | text | blah |
        And the reminder "Bobs reminder" has 1 agenda with:
            | text | foo  |

       When I go to the show page for the reminder called "Bobs reminder"
        And I follow "History" within ".reminder_agenda"
        And I follow "1" within "table"
       Then I should see "Agenda" within ".reminder_agenda"
        And I should see "blah" within ".reminder_agenda"
