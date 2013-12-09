module Screenpress
  class Config
    attr_accessor :enabled

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

    def tmp_path=val
      self.full_tmp_path=root.join(val)
    end

    def full_tmp_path=val
      @full_tmp_path = Pathname.new(val).expand_path
    end

    def full_tmp_path
      self.tmp_path = "tmp" unless @full_tmp_path
      @full_tmp_path
    end

    def enabled?
      return !!@calc_enabled if defined?(@calc_enabled)
      @calc_enabled = calc_enabled
    end

    def threshold=val
      # number between 0.0 and 100.0 for percentage of image that can change
      @threshold = val.to_f
    end

    def threshold
      @threshold ||= 0.1
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