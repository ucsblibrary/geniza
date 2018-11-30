desc 'Run tests with test solr instance running'
task ci: [:environment] do
  require 'solr_wrapper'
  ENV['environment'] = 'test'
  solr_params = {
    port: 8985,
    verbose: true,
    managed: true
  }
  SolrWrapper.wrap(solr_params) do |solr|
    solr.with_collection(name: 'blacklight-core', persist: false, dir: Rails.root.join('solr', 'config')) do
      # run the tests
      # Rake::Task['spotlight:seed'].invoke
      Rake::Task['spec'].invoke
    end
  end
end
