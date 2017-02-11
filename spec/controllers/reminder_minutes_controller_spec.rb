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

require File.dirname(__FILE__) + '/../spec_helper'

describe reminderMinutesController, type: :controller do
  let(:reminder) { FactoryGirl.create(:reminder) }
  let(:user) { FactoryGirl.create(:admin) }

  before { allow(User).to receive(:current).and_return(user) }

  describe 'preview' do
    let(:text) { 'reminder minutes content' }

    before { allow_any_instance_of(reminderMinutes).to receive(:editable?).and_return(true) }

    it_behaves_like 'valid preview' do
      let(:preview_texts) { [text] }
      let(:preview_params) { { reminder_id: reminder.id, reminder_minutes: { text: text } } }
    end

    it_behaves_like 'authorizes object access' do
      let(:preview_params) { { reminder_id: reminder.id, reminder_minutes: {} } }
    end
  end
end
