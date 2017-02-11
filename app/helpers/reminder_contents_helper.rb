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

module ReminderContentsHelper
  def can_edit_reminder_content?(content, content_type)
    authorize_for(content_type.pluralize, 'update') && content.editable?
  end

  def saved_reminder_content_text_present?(content)
    !content.new_record? && content.text.present? && !content.text.empty?
  end

  def show_reminder_content_editor?(content, content_type)
    can_edit_reminder_content?(content, content_type) && (!saved_reminder_content_text_present?(content) || content.changed?)
  end

  def reminder_content_context_menu(content, content_type)
    menu = []
    menu << reminder_agenda_toggle_status_link(content, content_type)
    menu << reminder_content_edit_link(content_type) if can_edit_reminder_content?(content, content_type)
    menu << reminder_content_history_link(content_type, content.reminder)

    if saved_reminder_content_text_present?(content)
      menu << reminder_content_notify_link(content_type, content.reminder)
      menu << reminder_content_icalendar_link(content_type, content.reminder)
    end

    menu.join(' ')
  end

  def reminder_agenda_toggle_status_link(content, content_type)
    content.reminder.agenda.present? && content.reminder.agenda.locked? ?
      open_reminder_agenda_link(content_type, content.reminder) :
      close_reminder_agenda_link(content_type, content.reminder)
  end

  def close_reminder_agenda_link(content_type, reminder)
    case content_type
    when 'reminder_agenda'
      content_tag :li, '', class: 'toolbar-item' do
        link_to_if_authorized l(:label_reminder_close),
                              { controller: '/reminder_agendas',
                                action: 'close',
                                reminder_id: reminder },
                              method: :put,
                              class: 'button icon-context icon-locked'
      end
    when 'reminder_minutes'
      content_tag :li, '', class: 'toolbar-item' do
        link_to_if_authorized l(:label_reminder_agenda_close),
                              { controller: '/reminder_agendas',
                                action: 'close',
                                reminder_id: reminder },
                              method: :put,
                              class: 'button icon-context icon-locked'
      end
    end
  end

  def open_reminder_agenda_link(content_type, reminder)
    case content_type
    when 'reminder_agenda'
      content_tag :li, '', class: 'toolbar-item' do
        link_to_if_authorized l(:label_reminder_open),
                              { controller: '/reminder_agendas',
                                action: 'open',
                                reminder_id: reminder },
                              method: :put,
                              class: 'button icon-context icon-unlocked',
                              confirm: l(:text_reminder_agenda_open_are_you_sure)
      end
    when 'reminder_minutes'
    end
  end

  def reminder_content_edit_link(content_type)
    content_tag :li, '', class: 'toolbar-item' do
      content_tag :button,
                  '',
                  class: 'button button--edit-agenda',
                  onclick: "jQuery('.edit-#{content_type}').show();
                            jQuery('.show-#{content_type}').hide();
                            jQuery('.button--edit-agenda').addClass('-active');
                            jQuery('.button--edit-agenda').attr('disabled', true);
                  return false;" do
        link_to l(:button_edit),
                '',
                class: 'icon-context icon-edit',
                accesskey: accesskey(:edit)
      end
    end
  end

  def reminder_content_history_link(content_type, reminder)
    content_tag :li, '', class: 'toolbar-item' do
      link_to_if_authorized l(:label_history),
                            { controller: '/' + content_type.pluralize,
                              action: 'history',
                              reminder_id: reminder },
                            class: 'button icon-context icon-wiki'
    end
  end

  def reminder_content_notify_link(content_type, reminder)
    content_tag :li, '', class: 'toolbar-item' do
      link_to_if_authorized l(:label_notify),
                            { controller: '/' + content_type.pluralize,
                              action: 'notify', reminder_id: reminder },
                            method: :put,
                            class: 'button icon-context icon-mail1'
    end
  end

  def reminder_content_icalendar_link(content_type, reminder)
    content_tag :li, '', class: 'toolbar-item' do
      link_to_if_authorized l(:label_icalendar),
                            { controller: '/' + content_type.pluralize,
                              action: 'icalendar', reminder_id: reminder },
                            method: :put,
                            class: 'button icon-context icon-calendar2'
    end
  end
end
