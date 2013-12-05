require 'spec_helper'

describe Screenpress::Config do
  it "should be returned from the module" do
    Screenpress.config.class.name.should == "Screenpress::Config"
  end

  describe ".path" do
    it "should default to /screenpress" do
      Screenpress.config.full_path.to_s.should == "#{Dir.pwd}/screenpress"
    end

    it "should use the rails root if it was there" do
      rails = Object.new
      rails.should_receive(:root).and_return("/my/rails/")
      stub_const("Rails", rails)
      Screenpress.config.full_path.to_s.should == "/my/rails/screenpress"
    end
  end

end