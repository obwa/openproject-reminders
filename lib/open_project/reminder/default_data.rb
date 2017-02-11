module OpenProject
  module Reminder
    module DefaultData
      module_function

      def load!
        add_permissions! (member_role || raise('Member role not found')), member_permissions
        add_permissions! (reader_role || raise('Reader role not found')), reader_permissions
      end

      def add_permissions!(role, permissions)
        role.add_permission! *permissions
      end

      def member_role
        Role.find_by name: I18n.t(:default_role_member)
      end

      def member_permissions
        [
          :create_reminders,
          :edit_reminders,
          :delete_reminders,
          :view_reminders,
          :create_reminder_agendas,
          :close_reminder_agendas,
          :send_reminder_agendas_notification,
          :send_reminder_agendas_icalendar,
          :create_reminder_minutes,
          :send_reminder_minutes_notification
        ]
      end

      def reader_role
        Role.find_by name: I18n.t(:default_role_reader)
      end

      def reader_permissions
        [:view_reminders]
      end
    end
  end
end
