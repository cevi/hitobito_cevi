# encoding: utf-8

#  Copyright (c) 2012-2014, CEVI Regionalverband ZH-SH-GL. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

module PeopleCeviHelper

  def format_person_canton(person)
    person.canton_value
  end

  def possible_person_cantons
    candidates_from_i18n(:cantons)
  end

  def format_person_confession(person)
    person.confession_value
  end

  def possible_person_confessions
    candidates_from_i18n(:confessions)
  end

  def format_person_salutation(person)
    person.salutation_value
  end

  def possible_person_salutations
    candidates_from_i18n(:salutations)
  end

  def existing_person_correspondence_languages
    Person.where('correspondence_language IS NOT NULL').pluck(:correspondence_language).uniq
  end

  def existing_person_nationalities
    Person.where('nationality IS NOT NULL').pluck(:nationality).uniq
  end

  private

  def candidates_from_i18n(collection_attr)
    t("activerecord.attributes.person.#{collection_attr}").map do |key, value|
      Struct.new(:id, :to_s).new(key, value)
    end
  end

  def format_from_settings_hash(value, key)
    if value
      Settings.application.send(value).to_hash.with_indifferent_access[key]
    end
  end
end
