##
# Process a CSV upload into new Spotlight::Resource::Upload objects
class Spotlight::AddUploadsFromCSV < ApplicationJob
  queue_as :default
  after_perform do |job|
    csv_data, exhibit, user = job.arguments
    Spotlight::IndexingCompleteMailer.documents_indexed(csv_data, exhibit, user).deliver_now
  end

  def perform(csv_data, exhibit, _user)
    encoded_csv(csv_data).each do |row|
      # The CSV row must have either a url or a file
      url = row.delete('url')
      file = row.delete('file')
      next unless url.present? || file.present?

      resource = Spotlight::Resources::Upload.new(
        data: row,
        exhibit: exhibit
      )

      url = "http://localhost:3000/#{file}" if file
      resource.build_upload(remote_image_url: url)
      resource.save_and_index
    end
  end

  private

    def encoded_csv(csv)
      csv.map do |row|
        row.map do |label, column|
          [label, column.encode('UTF-8', invalid: :replace, undef: :replace, replace: "\uFFFD")] if column.present?
        end.compact.to_h
      end.compact
    end
end
