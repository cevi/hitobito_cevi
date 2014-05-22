# encoding: utf-8

#  Copyright (c) 2012-2014, CEVI Regionalverband ZH-SH-GL. This file is part of
#  hitobito_cevi and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cevi.

require 'spec_helper'

describe PopulationController, type: :controller do

  render_views

  let(:dom) { Capybara::Node::Simple.new(response.body) }

  before { sign_in(people(:bulei)) }

  describe 'GET index' do

    before { get :index, id: group.id }

    context 'with existing census' do
      let(:group) { groups(:jungschar_zh10) }

      it 'does not show any approveable content if there is no current census' do
        dom.all('#content h2').count.should eq 2
        dom.should have_no_selector('a', text: 'Bestand bestätigen')
        dom.should have_no_selector('.alert.alert-info.approveable')
        dom.should have_no_selector('.alert.alert-alert.approveable')
        dom.find('a', text: 'Bestand').should have_no_selector('span', text: '!')
      end
    end

    context 'without existing census' do
      let(:group) { groups(:tensing) }

      it 'does show all approveable content if there is a current census' do
        dom.all('#content h2').count.should eq 0
        dom.should have_selector('a', text: 'Bestand bestätigen')
        dom.should have_content('Bitte ergänze')
        dom.all('a', text: 'Bestand').first.should have_selector('span', text: '!')
      end
    end
  end
end
