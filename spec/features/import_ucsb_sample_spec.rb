# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Import local files in a CSV via the UI', :clean, js: true do
  include Warden::Test::Helpers

  let(:csv_file_path)   { File.join(fixture_path, csv_file_name) }
  let(:csv_file_name)   { 'blake.csv' }
  let(:exhibit_json)    { 'the-anna-s-c-blake-manual-training-school-export.json' }
  let(:exhibit_path)    { File.join(fixture_path, exhibit_json) }
  let(:site_admin)      { FactoryBot.create(:site_admin) }

  before do
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    login_as site_admin
  end

  context 'when a CSV file contains files instead of URLs' do
    it 'fetches the files from local disk' do
      expect(Spotlight::Exhibit.count).to eq 0
      visit '/'
      click_link site_admin.user_key.to_s
      click_link 'Create new exhibit'
      fill_in('Title', with: 'Test Exhibit')
      fill_in('Tag list', with: 'testing')
      click_button 'Save'
      expect(page).to have_content 'The exhibit was created.'
      expect(Spotlight::Exhibit.count).to eq 1
      visit('/spotlight/test-exhibit/edit')
      click_link 'Import data'
      page.attach_file('file', exhibit_path)
      click_button 'Import data'

      exhibit = Spotlight::Exhibit.first
      expect(exhibit.title).to eq "The Anna S. C. Blake Manual Training School"
      visit('/spotlight/test-exhibit/resources/new')
      click_link 'Upload multiple items'
      expect(page).to have_content 'CSV File'
      page.attach_file('resources_csv_upload[url]', csv_file_path)
      click_button 'Add item'
      visit '/spotlight/test-exhibit/catalog?exhibit_id=test-exhibit&search_field=all_fields&q='
      expect(page).to have_content 'Ednah A. Rich'
    end
  end
end
