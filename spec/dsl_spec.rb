require 'spec_helper'

class MyDslTest
  include Screenpress::DSL
end

describe "Screenpress::DSL" do 
  it "should provide screenpress method" do
    obj = MyDslTest.new
    obj.should respond_to(:screenpress)
  end

  it "should be in rspec because it's included in my spec helper" do
    Screenpress::Config.any_instance.stub(:enabled?).and_return(false)
    lambda {
      screenpress("here")
    }.should_not raise_error
  end

end