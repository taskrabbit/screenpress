require 'fileutils'

module Screenpress
  class Saver
    attr_reader :capybara, :page, :filename

    def initialize(filename, capybara = nil, page = nil)
      @capybara = capybara || Capybara
      @page     = page || @capybara.page
      @filename = build_filename(filename)
    end

    def save
      # if current_path empty then nothing to screen shot as browser has not loaded any URL
      return false if capybara.current_path.to_s.empty?
      save_screenshot
    end

    def save_screenshot
      # settings to nil because of issues in some version of capybara
      old_path = Capybara.save_and_open_page_path
      Capybara.save_and_open_page_path = nil

      ensure_directory

      if Screenpress::Saver::Proxy.respond_to?(capybara.current_driver)
        val = Screenpress::Saver::Proxy.send(capybara.current_driver, page.driver, filename)
      else
        warn "Screenpress could not detect a screenshot driver for '#{capybara.current_driver}'. Saving with default with unknown results."
        val = Screenpress::Saver::Proxy.send(:default, page.driver, filename)
      end

      Capybara.save_and_open_page_path = old_path

      val
    end

    def build_filename(filename)
      # TODO: see if have extension
      "#{filename}.png"
    end

    def ensure_directory
      folder = File.dirname(filename)
      return if File.directory?(folder)
      FileUtils.mkdir_p(folder)
    end

    class Proxy
      class << self
        def default(driver, path)
          driver.render(path)
          true
        end

        def rack_test(driver, path)
          warn "Rack::Test capybara driver has no ability to output screen shots. Skipping."
          false
        end

        def mechanize(driver, path)
          warn "Mechanize capybara driver has no ability to output screen shots. Skipping."
          false
        end

        def selenium(driver, path)
          driver.browser.save_screenshot(path)
          true
        end

        def poltergeist(driver, path)
          driver.render(path, :full => true)
          true
        end

        def webkit(driver, path)
          if driver.respond_to?(:save_screenshot)
            driver.save_screenshot(path)
          else
            driver.render(path)
          end
          true
        end

        def webkit_debug(driver, path)
          driver.render(path)
          true
        end

        def terminus(driver, path)
          if driver.respond_to?(:save_screenshot)
            driver.save_screenshot(path)
            true
          else
            warn "Terminus capybara driver has no ability to output screen shots. Skipping."
            false
          end
        end
      end
    end
  end
end
