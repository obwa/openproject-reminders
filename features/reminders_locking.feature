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

Feature: Locking reminders

  Background:
        Given there is 1 project with the following:
              | identifier | dingens |
              | name       | dingens |
          And the project "dingens" uses the following modules:
              | reminders |
          And there is 1 user with:
              | login | bob |
          And there is a role "user"
          And the user "bob" is a "user" in the project "dingens"
          And there is 1 reminder in project "dingens" created by "bob" with:
              | title | Bobs reminder |
          And the reminder "Bobs reminder" has 1 agenda with:
              | text  | awesome! |

  @javascript
  Scenario: Save a reminder after it has changed while editing
      Given the role "user" may have the following rights:
            | view_reminders |
            | create_reminders |
            | create_reminder_agendas |
            | edit_reminders |
       When I am already logged in as "bob"
        And I go to the reminders page for the project called "dingens"
        And I click on "Bobs reminder"
        And I follow "Edit" within ".reminder_agenda"
            # Change the text of the agenda to create an editing conflict
        And the reminder "Bobs reminder" has 1 agenda with:
            | text | and now for something completely different |
        And I fill in "Blabla oder?" for "reminder_agenda_text"
        And I click on "Save"
       Then I should see "Information has been updated by at least one other user in the meantime."
            # Prüfen, ob die Editbox noch sichtbar ist
       #And I should see "Text formatting" within "#tab-content-agenda"
