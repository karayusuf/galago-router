require 'galago'
require 'rack/test'
require 'pry'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = :documentation

  config.include Rack::Test::Methods

  def application(&block)
    let(:app) do
      klass = Class.new(Galago::Application)
      klass.class_eval(&block)
      klass
    end
  end
end
