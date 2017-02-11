#-- encoding: UTF-8
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

class Activity::reminderActivityProvider < Activity::BaseActivityProvider
  acts_as_activity_provider type: 'reminders',
                            activities: [:reminder, :reminder_content],
                            permission: :view_reminders

  def extend_event_query(query, activity)
    case activity
    when :reminder_content
      query.join(reminders_table).on(activity_journals_table(activity)[:reminder_id].eq(reminders_table[:id]))
      join_cond = journal_table[:journable_type].eq('reminderContent')
      query.join(reminder_contents_table).on(journal_table[:journable_id].eq(reminder_contents_table[:id]).and(join_cond))
    end
  end

  def event_query_projection(activity)
    case activity
    when :reminder
      [
        activity_journal_projection_statement(:title, 'reminder_title', activity),
        activity_journal_projection_statement(:start_time, 'reminder_start_time', activity),
        activity_journal_projection_statement(:duration, 'reminder_duration', activity),
        activity_journal_projection_statement(:project_id, 'project_id', activity)
      ]
    else
      [
        projection_statement(reminder_contents_table, :type, 'reminder_content_type'),
        projection_statement(reminders_table, :id, 'reminder_id'),
        projection_statement(reminders_table, :title, 'reminder_title'),
        projection_statement(reminders_table, :project_id, 'project_id'),
      ]
    end
  end

  def activitied_type(activity)
    (activity == :reminder) ? reminder : reminderContent
  end

  def projects_reference_table(activity)
    case activity
    when :reminder
      activity_journals_table(activity)
    else
      reminders_table
    end
  end

  def activity_journals_table(activity)
    case activity
    when :reminder
      @activity_journals_table = JournalManager.journal_class(reminder).arel_table
    else
      @activity_journals_table = JournalManager.journal_class(reminderContent).arel_table
    end
  end

  protected

  def event_name(event, activity)
    case event['event_description']
    when 'Agenda closed'
      I18n.t('reminder_agenda_closed', scope: 'events')
    when 'Agenda opened'
      I18n.t('reminder_agenda_opened', scope: 'events')
    when 'Minutes created'
      I18n.t('reminder_minutes_created', scope: 'events')
    else
      super
    end
  end

  def event_title(event, activity)
    case activity
    when :reminder
      start_time = event['reminder_start_time'].is_a?(String) ? DateTime.parse(event['reminder_start_time'])
                                                             : event['reminder_start_time']
      end_time = start_time + event['reminder_duration'].to_f.hours

      "#{l :label_reminder}: #{event['reminder_title']} (#{format_date start_time} #{format_time start_time, false}-#{format_time end_time, false})"
    else
      "#{event['reminder_content_type'].constantize.model_name.human}: #{event['reminder_title']}"
    end
  end

  def event_type(event, activity)
    case activity
    when :reminder
      'reminder'
    else
      (event['reminder_content_type'].include?('Agenda')) ? 'reminder-agenda' : 'reminder-minutes'
    end
  end

  def event_path(event, activity)
    id = activity_id(event, activity)

    url_helpers.reminder_path(id)
  end

  def event_url(event, activity)
    id = activity_id(event, activity)

    url_helpers.reminder_url(id)
  end

  private

  def reminders_table
    @reminders_table ||= reminder.arel_table
  end

  def reminder_contents_table
    @reminder_contents_table ||= reminderContent.arel_table
  end

  def activity_id(event, activity)
    (activity == :reminder) ? event['journable_id'] : event['reminder_id']
  end
end
