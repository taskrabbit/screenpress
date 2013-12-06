require 'spec_helper'

describe Screenpress::Saver do
  before do
    Screenpress.config.path = image_dir
  end

  let(:image_dir) { '/tmp' }
  let(:file_basename) { "my_screenshot" }
  let(:screenshot_path) { "#{Dir.pwd}#{image_dir}/#{file_basename}.png" }

  let(:driver_mock) { double('Capybara driver') }
  let(:page_mock) { double('Capybara session page', :body => 'body', :driver => driver_mock) }
  let(:capybara_mock) {
    double(Capybara).as_null_object.tap do |m|
      m.stub(:current_driver).and_return(:default)
      m.stub(:current_path).and_return('/')
    end
  }

  let(:saver) { Screenpress::Saver.new(screenshot_path, capybara_mock, page_mock) }

  context "default" do
    it 'should be in capybara root output' do
      driver_mock.should_receive(:render).with(screenshot_path)
      saver.save
    end


    it 'should save if current_path is empty' do
      capybara_mock.stub(:current_path).and_return(nil)
      capybara_mock.should_not_receive(:save_page)
      driver_mock.should_not_receive(:render)

      saver.save
    end
  end

  context "selenium" do
    before do
      capybara_mock.stub(:current_driver).and_return(:selenium)
    end
    it 'should save via browser' do
      browser_mock = double('browser')
      driver_mock.should_receive(:browser).and_return(browser_mock)
      browser_mock.should_receive(:save_screenshot).with(screenshot_path)

      saver.save
    end
  end

  context "poltergeist" do
    before do
      capybara_mock.stub(:current_driver).and_return(:poltergeist)
    end
    it 'should save driver render with :full => true' do
      driver_mock.should_receive(:render).with(screenshot_path, {:full => true})

      saver.save
    end
  end

  describe "webkit" do
    before do
      capybara_mock.stub(:current_driver).and_return(:webkit)
    end

    context 'has render method' do
      before do
        driver_mock.stub(:respond_to?).with(:'save_screenshot').and_return(false)
      end

      it 'should save driver render' do
        driver_mock.should_receive(:render).with(screenshot_path)

        saver.save
      end
    end

    context 'has save_screenshot method' do
      before do
        driver_mock.stub(:respond_to?).with(:'save_screenshot').and_return(true)
      end

      it 'should save driver render' do
        driver_mock.should_receive(:save_screenshot).with(screenshot_path)

        saver.save
      end
    end
  end

  describe "webkit debug" do
    before do
      capybara_mock.stub(:current_driver).and_return(:webkit_debug)
    end

    it 'should save driver render' do
      driver_mock.should_receive(:render).with(screenshot_path)

      saver.save
    end
  end

  describe "with unknown driver" do
    before do
      capybara_mock.stub(:current_driver).and_return(:unknown)
      Screenpress::Saver::Proxy.stub(:warn).and_return(nil)
    end

    it 'should save driver render' do
      driver_mock.should_receive(:render).with(screenshot_path)

      saver.save
    end

    it 'should output warning about unknown results' do
      # Not pure mock testing 
      Screenpress::Saver::Proxy.should_receive(:warn).with(/screenshot driver for 'unknown'.*unknown results/).and_return(nil)
      driver_mock.should_receive(:render)
      saver.save
    end
  end
end
