module Screenpress
  module DSL
    def screenpress(relative_filename)
      return true unless Screenpress.config.enabled?
      
      relative_filename << ".png"
      filename = Screenpress.config.full_path.join(relative_filename)

      saver = Screenpress::Saver.new(filename.to_s, Capybara, Capybara.page)
      saver.save
    end
  end
end