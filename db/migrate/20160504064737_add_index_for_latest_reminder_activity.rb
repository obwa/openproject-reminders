class AddIndexForLatestreminderActivity < ActiveRecord::Migration
  def change
    add_index :reminders, [:project_id, :updated_at]
  end
end
