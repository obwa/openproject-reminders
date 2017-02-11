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

module ReminderNavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    when /^the (\w+?) activity page for the [pP]roject "(.+?)"$/
      project = get_project($2)
      "/projects/#{project.identifier}/activity?show_#{$1}=1"

    when /^the show page (?:of|for) the reminder called "(.+?)"$/
      reminder = reminder.find_by_title($1)

      "/reminders/#{reminder.id}"
    when /^the edit page (?:of|for) the reminder called "(.+?)"$/
      reminder = reminder.find_by_title($1)

      "/reminders/#{reminder.id}/edit"
    else
      super
    end
  end
end

World(reminderNavigationHelpers)
