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

Feature: reminder has participants

  Background:
    Given there is 1 project with the following:
          | identifier | dingens |
          | name       | dingens |
      And the project "dingens" uses the following modules:
          | reminders |
      And there is 1 user with:
          | login     | alice |
          | firstname | Alice |
          | lastname  | Alice |
          | language  | en    |
      And there is 1 user with:
          | login     | bob    |
          | firstname | Bob    |
          | lastname  | Bobbit |
          | language  | en     |
      And there is a role "reminder_viewer"
      And there is a role "reminder_editor"
      And the role "reminder_viewer" may have the following rights:
          | view_reminders |
      And the role "reminder_editor" may have the following rights:
          | view_reminders |
          | edit_reminders |
      And the user "bob" is a "reminder_editor" in the project "dingens"
      And there is 1 reminder in project "dingens" created by "bob" with:
          | title | Bobs reminder |
    Given I am already logged in as "bob"

  Scenario: Users not allowed to view reminders are no valid participants
     When I go to the edit page of the reminder called "Bobs reminder"
     Then the user "alice" should not be available as a participant

  Scenario: Users allowed to view reminders are valid participants
    Given the user "alice" is a "reminder_viewer" in the project "dingens"
     When I go to the edit page of the reminder called "Bobs reminder"
     Then the user "alice" should be available as a participant
