# encoding: utf-8

#  Copyright (c) 2012-2014, CEVI Regionalverband ZH-SH-GL. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

module Cevi
  module Event
    module ParticipationsController
      extend ActiveSupport::Concern

      included do
        alias_method_chain :assign_attributes, :check
        alias_method_chain :exporter, :check
      end

      private

      def exporter_with_check
        check? ? ::Export::Csv::People::ParticipationsComplete : exporter_without_check
      end

      # only roles with update permission are allowed to set those attributes
      def assign_attributes_with_check
        if model_params.present? && check?
          entry.payed = model_params.delete(:payed)
          entry.internal_comment = model_params.delete(:internal_comment)
        end

        assign_attributes_without_check
      end

      def check?
        can?(:update, entry.event)
      end
    end
  end
end
