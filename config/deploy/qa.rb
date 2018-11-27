# frozen_string_literal: true
server 'geniza-qa.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
set :deploy_to, ENV.fetch('TARGET', '/opt/geniza')