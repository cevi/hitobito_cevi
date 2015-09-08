# encoding: utf-8

#  Copyright (c) 2012-2015, CEVI Regionalverband ZH-SH-GL. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

class AddPersonOrtsgruppe < ActiveRecord::Migration
  def change
    add_column(:people, :ortsgruppe_id, :integer)

    reversible do |dir|
      dir.up do
        update_persons_ortsgruppe
      end
    end
  end

  private

  def update_persons_ortsgruppe
    Person.all.each do |person|
      ortsgruppen = person.possible_ortsgruppen
      if ortsgruppen.length == 1
        person.update_column(:ortsgruppe_id, ortsgruppen.first.id)
      end
    end
  end
end
