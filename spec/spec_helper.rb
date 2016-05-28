require 'capybara/rspec'
require 'selenium-webdriver'
require 'pry'
require 'ffaker'
require 'faker'

RSpec.configure do |config|
  config.include Capybara::DSL
end

Capybara.default_driver = :selenium
Capybara.app_host = 'https://console.idcfcloud.com'
