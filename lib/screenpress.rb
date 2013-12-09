require "screenpress/version"
require "capybara"

module Screenpress
  autoload :Config,    'screenpress/config'
  autoload :Compare,   'screenpress/compare'
  autoload :DSL,       'screenpress/dsl'
  autoload :Saver,     'screenpress/saver'

  class << self
    def config
      @config ||= Screenpress::Config.new
    end

    protected

    def reset
      # mostly for tests, resets eveything
      @config = nil
    end
  end
end
