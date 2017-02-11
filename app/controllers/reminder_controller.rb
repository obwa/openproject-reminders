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

class remindersController < ApplicationController
  around_action :set_time_zone
  before_action :find_project, only: [:index, :new, :create]
  before_action :find_reminder, except: [:index, :new, :create]
  before_action :convert_params, only: [:create, :update]
  before_action :authorize

  helper :watchers
  helper :reminder_contents
  include WatchersHelper
  include PaginationHelper

  menu_item :new_reminder, only: [:new, :create]

  def index
    scope = @project.reminders

    # from params => today's page otherwise => first page as fallback
    tomorrows_reminders_count = scope.from_tomorrow.count
    @page_of_today = 1 + tomorrows_reminders_count / per_page_param

    page = params['page'] ?
             page_param :
             @page_of_today

    @reminders = scope.with_users_by_date
                .page(page)
                .per_page(per_page_param)

    @reminders_by_start_year_month_date = reminder.group_by_time(@reminders)
  end

  def show
    params[:tab] ||= 'minutes' if @reminder.agenda.present? && @reminder.agenda.locked?
  end

  def create
    @reminder.participants.clear # Start with a clean set of participants
    @reminder.participants_attributes = @converted_params.delete(:participants_attributes)
    @reminder.attributes = @converted_params
    if params[:copied_from_reminder_id].present? && params[:copied_reminder_agenda_text].present?
      @reminder.agenda = reminderAgenda.new(
        text: params[:copied_reminder_agenda_text],
        comment: "Copied from reminder ##{params[:copied_from_reminder_id]}")
      @reminder.agenda.author = User.current
    end
    if @reminder.save
      text = l(:notice_successful_create)
      if User.current.time_zone.nil?
        link = l(:notice_timezone_missing, zone: Time.zone)
        text += " #{view_context.link_to(link, { controller: '/my', action: :account }, class: 'link_to_profile')}"
      end
      flash[:notice] = text.html_safe

      redirect_to action: 'show', id: @reminder
    else
      render template: 'reminders/new', project_id: @project
    end
  end

  def new
  end

  current_menu_item :new do
    :reminders
  end

  def copy
    params[:copied_from_reminder_id] = @reminder.id
    params[:copied_reminder_agenda_text] = @reminder.agenda.text if @reminder.agenda.present?
    @reminder = @reminder.copy(author: User.current)
    render action: 'new', project_id: @project
  end

  def destroy
    @reminder.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: 'index', project_id: @project
  end

  def edit
  end

  def update
    @reminder.participants_attributes = @converted_params.delete(:participants_attributes)
    @reminder.attributes = @converted_params
    if @reminder.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to action: 'show', id: @reminder
    else
      render action: 'edit'
    end
  end

  private

  def set_time_zone
    old_time_zone = Time.zone
    zone = User.current.time_zone
    if zone.nil?
      localzone = Time.now.utc_offset
      localzone -= 3600 if Time.now.dst?
      zone = ::ActiveSupport::TimeZone[localzone]
    end
    Time.zone = zone
    yield
  ensure
    Time.zone = old_time_zone
  end

  def find_project
    @project = Project.find(params[:project_id])
    @reminder = reminder.new
    @reminder.project = @project
    @reminder.author = User.current
  end

  def find_reminder
    @reminder = reminder
               .includes([:project, :author, { participants: :user }, :agenda, :minutes])
               .find(params[:id])
    @project = @reminder.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def convert_params
    # We do some preprocessing of `reminder_params` that we will store in this
    # instance variable.
    @converted_params = reminder_params

    @converted_params[:duration] = @converted_params[:duration].to_hours
    # Force defaults on participants
    @converted_params[:participants_attributes] ||= {}
    @converted_params[:participants_attributes].each { |p| p.reverse_merge! attended: false, invited: false }
  end

private
  def reminder_params
    params.require(:reminder).permit(:title, :location, :start_time, :duration, :start_date, :start_time_hour,
      participants_attributes: [:email, :name, :invited, :attended, :user, :user_id, :reminder, :id])
  end
end
