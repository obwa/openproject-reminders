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

class reminderAgendasController < reminderContentsController
  menu_item :reminders

  def close
    @reminder.close_agenda_and_copy_to_minutes!

    redirect_back_or_default controller: '/reminders', action: 'show', id: @reminder
  end

  def open
    @content.unlock!
    redirect_back_or_default controller: '/reminders', action: 'show', id: @reminder
  end

  private

  def find_content
    @content = @reminder.agenda || @reminder.build_agenda
    @content_type = 'reminder_agenda'
  end
end
