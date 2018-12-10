require 'rails_helper'

RSpec.describe Spotlight::AddUploadsFromCSV do
  subject(:job) { described_class.new(data, exhibit, user) }

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_curator, exhibit: exhibit) }
  let(:data) do
    [
      { 'url' => 'x' },
      { 'url' => 'y' },
    ]
  end

  let(:resource_x) { instance_double(Spotlight::Resource) }
  let(:resource_y) { instance_double(Spotlight::Resource) }

  before do
    allow(Spotlight::IndexingCompleteMailer).to receive(:documents_indexed).and_return(double(deliver_now: true))
  end

  context 'with empty data' do
    let(:data) { [] }

    it 'sends the user an email after the indexing job is complete' do
      expect(Spotlight::IndexingCompleteMailer).to receive(:documents_indexed).and_return(double(deliver_now: true))
      job.perform_now
    end
  end

  it 'creates uploaded resources for each row of data' do
    upload = FactoryBot.create(:uploaded_resource)
    expect(Spotlight::Resources::Upload).to receive(:new).at_least(:once).and_return(upload)

    expect(upload).to receive(:build_upload).with(remote_image_url: 'x').and_call_original
    expect(upload).to receive(:build_upload).with(remote_image_url: 'y').and_call_original
    expect(upload).to receive(:save_and_index).at_least(:once)

    job.perform_now
  end

  # UCSB CSV uploads with local files instead of urls
  # The CSV contains a 'file' value, which gets transformed into a url string that
  # will fetch the image from the local filesystem
  context 'with files in the CSV instead of URLs' do
    let(:filename) { 'cusb-uarch112-g01579-1-m.tif' }
    let(:data) do
      [
        { 'file' => filename, 'full_title_tesim' => 'Ednah A. Rich' },
      ]
    end

    it 'creates uploaded resources for each row of data' do
      upload = FactoryBot.create(:uploaded_resource)
      expect(Spotlight::Resources::Upload).to receive(:new).at_least(:once).and_return(upload)

      expect(upload).to receive(:build_upload).with(remote_image_url: "#{ENV["RAILS_HOST"]}/#{filename}").and_call_original
      expect(upload).to receive(:save_and_index).at_least(:once)

      job.perform_now
    end
  end
end
