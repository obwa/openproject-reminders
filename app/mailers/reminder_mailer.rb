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

require 'icalendar'

class reminderMailer < UserMailer
  def content_for_review(content, content_type, address)
    @reminder = content.reminder
    @content_type = content_type

    open_project_headers 'Project' => @reminder.project.identifier,
                         'reminder-Id' => @reminder.id

    subject = "[#{@reminder.project.name}] #{I18n.t(:"label_#{content_type}")}: #{@reminder.title}"
    mail to: address, subject: subject
  end
  
  def icalendar_notification(content, content_type, address)
    @reminder = content.reminder
    @content_type = content_type
    
    open_project_headers 'Project' => @reminder.project.identifier,
                         'reminder-Id' => @reminder.id
    headers['Content-Type'] = 'text/calendar; charset=utf-8; method="PUBLISH"; name="reminder.ics"'
    headers['Content-Transfer-Encoding'] = '8bit'
    subject = "[#{@reminder.project.name}] #{I18n.t(:"label_#{content_type}")}: #{@reminder.title}"
    author = Icalendar::Values::CalAddress.new("mailto:#{@reminder.author.mail}",
                                               cn: @reminder.author.name)

    # Create a calendar with an event (standard method)
    entry = ::Icalendar::Calendar.new
    entry.event do |e|
      e.dtstart     = @reminder.start_time
      e.dtend       = @reminder.end_time
      e.url         = reminder_url(@reminder)
      e.summary     = "[#{@reminder.project.name}] #{@reminder.title}"
      e.description = subject
      e.uid         = "#{@reminder.id}@#{@reminder.project.identifier}"
      e.organizer   = author
    end

    attachments['reminder.ics'] = entry.to_ical
    mail(to: address, subject: subject)
  end
end
