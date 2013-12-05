module Screenpress
  class Config
    def path=val
      self.full_path = root.join(val)
    end

    def full_path=val
      @full_path = Pathname.new(val).expand_path
    end

    def full_path
      self.path = "screenpress" unless @full_path
      @full_path
    end

    def enabled=val
      @enabled = val
    end

    def enabled?
      return !!@enabled if defined?(@enabled)
      @enabled = calc_enabled
    end

    protected

    def root
      @root ||= Pathname.new(calc_root_string).expand_path
    end

    def calc_enabled
      # TODO env variables or something?
      true
    end

    def calc_root_string
      return Rails.root.to_s                if defined?(Rails)
      return Padrino.root.to_s              if defined?(Padrino)
      return Sinatra::Application.root.to_s if defined?(Sinatra)
      return RAILS_ROOT                     if defined?(RAILS_ROOT)
      return RACK_ROOT                      if defined?(RACK_ROOT)
      return ENV['RAILS_ROOT']              if ENV['RAILS_ROOT']
      return ENV['RACK_ROOT']               if ENV['RACK_ROOT']
      return Dir.pwd
    end
  end
end