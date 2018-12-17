# frozen_string_literal: true

require 'rails_helper'

# These fields should be searchable per https://help.library.ucsb.edu/browse/DIGREPO-926:
# Title
# Description
# Attribution
# Date
# Contributors
# Coverage
# Creator
# Format
# Identifier
# Publisher
# Subject

RSpec.feature 'Search for expected fields', :clean, js: true do
  include Warden::Test::Helpers

  let(:csv_file_path)   { File.join(fixture_path, csv_file_name) }
  let(:csv_file_name)   { 'blake_search_test.csv' }
  let(:site_admin)      { FactoryBot.create(:site_admin) }
  let(:exhibit_slug)    { 'the-anna-s-c-blake-manual-training-school' }
  let(:search_url)      { "/spotlight/#{exhibit_slug}/catalog?utf8=%E2%9C%93&exhibit_id=#{exhibit_slug}&search_field=all_fields&q=" }
  let(:exact_title)     { "Ednah A. Rich" }
  let(:partial_title)   { "Ednah" }

  before do
    ENV['IMPORT_DIR'] = Rails.root.join('spec', 'fixtures', 'images').to_s
    allow(Spotlight::DefaultThumbnailJob).to receive(:perform_later)
    login_as site_admin
  end

  context 'Create an exhibit' do
    it 'creates and populates an exhibit via the UI' do
      expect(Spotlight::Exhibit.count).to eq 0
      visit '/'
      exhibit = Spotlight::Exhibit.create!(title: "The Anna S. C. Blake Manual Training School")
      exhibit.import(JSON.parse(Rails.root.join('spec','fixtures','the-anna-s-c-blake-manual-training-school-export.json').read))
      exhibit.save
      exhibit.reindex_later
      expect(Spotlight::Exhibit.count).to eq 1
      visit('/spotlight/the-anna-s-c-blake-manual-training-school/resources/new')
      click_link 'Upload multiple items'
      expect(page).to have_content 'CSV File'
      page.attach_file('resources_csv_upload[url]', csv_file_path)
      click_button 'Add item'
      visit search_url
      expect(page).to have_content 'Miss Anna S.C. Blake'
      click_link 'Miss Anna S.C. Blake'
      expect(page).to have_content "uarch112-g01650"

      ## Exact title search
      visit "#{search_url}#{exact_title}"
      click_link exact_title
      expect(page).to have_content "uarch112-g01579"

      ## Partial title search
      visit "#{search_url}#{partial_title}"
      click_link exact_title
      expect(page).to have_content "uarch112-g01579"

      ## Description search


    end
  end
end
