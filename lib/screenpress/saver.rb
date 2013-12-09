require 'fileutils'

module Screenpress
  class Saver
    attr_reader :capybara, :page, :filename

    def initialize(filename, capybara = nil, page = nil)
      @capybara = capybara || Capybara
      @page     = page || @capybara.page
      @filename = filename
    end

    def save
      # if current_path empty then nothing to screen shot as browser has not loaded any URL
      return false if capybara.current_path.to_s.empty?
      save_screenshot
    end

    def save_screenshot
      tmp_file = self.tmp_filename

      # settings to nil because of issues in some version of capybara
      old_path = Capybara.save_and_open_page_path
      Capybara.save_and_open_page_path = nil

      ensure_directory

      return false unless Screenpress::Saver::Proxy.save!(capybara.current_driver, page.driver, tmp_file)

      # is it different?
      compare = Screenpress::Compare.new(filename, tmp_file, Screenpress.config.threshold)
      if compare.same?
        File.delete(tmp_file)
      else
        FileUtils.mv(tmp_file, filename)
      end
      return true

    rescue Exception => e
      File.delete(tmp_file) if tmp_file && File.exists?(tmp_file)
      raise e
    end

    def ensure_directory
      folder = File.dirname(filename)
      return if File.directory?(folder)
      FileUtils.mkdir_p(folder)
    end

    def tmp_filename
      tmp_dir  = Screenpress.config.full_tmp_path.to_s
      tmp_file = "#{tmp_dir}/screenpress_#{File.basename(filename)}"
      tmp_file
    end

    class Proxy
      class << self
        def save!(name, driver, filename)
          return send(name, driver, filename) if self.respond_to?(name)
          
          klass = driver.class.name
          if klass =~ /Selenium/
            return send(:selenium, driver, filename)
          elsif klass =~ /Mechanize/
            return send(:mechanize, driver, filename)
          elsif klass =~ /RackTest/
            return send(:rack_test, driver, filename)
          elsif klass =~ /Poltergeist/
            return send(:poltergeist, driver, filename)
          elsif klass =~ /Webkit/
            return send(:webkit, driver, filename)
          else
            warn "Screenpress could not detect a screenshot driver for '#{name}'. Saving with default with unknown results."
            return send(:default, driver, filename)
          end
        end

        def default(driver, path)
          if driver.respond_to?(:save_screenshot)
            driver.save_screenshot(path)
          else
            driver.render(path)
          end
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
