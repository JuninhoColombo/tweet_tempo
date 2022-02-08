# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
envs_file = File.join(Rails.root, "config", "envs.rb")
load(envs_file) if File.exist?(envs_file)
Rails.application.initialize!