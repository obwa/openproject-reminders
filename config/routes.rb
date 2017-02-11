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

OpenProject::Application.routes.draw do

  scope 'projects/:project_id' do
    resources :reminders, only: [:new, :create, :index]
  end

  resources :reminders, except: [:new, :create, :index] do

    resource :agenda, controller: 'reminder_agendas', only: [:update] do
      member do
        get :history
        get :diff
        put :close
        put :open
        put :notify
        put :icalendar
        post :preview
      end

      resources :versions, only: [:show],
                           controller: 'reminder_agendas'
    end

    resource :minutes, controller: 'reminder_minutes', only: [:update] do
      member do
        get :history
        get :diff
        put :notify
        post :preview
      end

      resources :versions, only: [:show],
                           controller: 'reminder_minutes'
    end

    member do
      get :copy
      match '/:tab' => 'reminders#show', :constraints => { tab: /(agenda|minutes)/ },
            :via => :get,
            :as => 'tab'
    end
  end
end
