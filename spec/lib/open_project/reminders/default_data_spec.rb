#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
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
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe OpenProject::reminder::DefaultData do
  let(:seeder) { BasicData::RoleSeeder.new }

  let(:roles) { [member, reader] }
  let(:member) { OpenProject::reminder::DefaultData.member_role }
  let(:reader) { OpenProject::reminder::DefaultData.reader_role }

  let(:member_permissions) { OpenProject::reminder::DefaultData.member_permissions }
  let(:reader_permissions) { OpenProject::reminder::DefaultData.reader_permissions }

  before do
    allow(seeder).to receive(:builtin_roles).and_return([])

    seeder.seed!
  end

  it 'adds permissions to the roles' do
    expect(member.permissions).to include *member_permissions
    expect(reader.permissions).to include *reader_permissions
  end

  it 'is not loaded again on existing data' do
    roles.each do |role|
      role.permissions = []
      role.save!
    end

    seeder.seed!
    roles.each(&:reload)

    expect(member.permissions).to be_empty
    expect(reader.permissions).to be_empty
  end
end
