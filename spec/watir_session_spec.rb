require 'spec_helper'

describe WatirSession do

  before(:each) { WatirSession.reset_config! }

  describe "#watir_config=" do
    it "stores provided configuration" do
      watir_config = WatirConfig.new(browser: 'firefox')
      WatirSession.watir_config = watir_config
      expect(WatirSession.watir_config).to_not eql(WatirConfig.new)
      expect(WatirSession.watir_config).to eql(watir_config)
    end
  end

  describe "#start" do
    it "starts a session with default configuration" do
      WatirSession.start
      expect(WatirSession.watir_config).to eql(WatirConfig.new)
    end

    it "starts a session with previously set configuration" do
      watir_config = WatirConfig.new(browser: 'firefox')
      WatirSession.watir_config = watir_config
      WatirSession.start
      expect(WatirSession.watir_config).to_not eql(WatirConfig.new)
      expect(WatirSession.watir_config).to eql(watir_config)
    end

    it "starts a session with provided configuration" do
      watir_config = WatirConfig.new(browser: 'firefox')
      WatirSession.watir_config = watir_config
      expect(WatirSession.watir_config).to_not eql(WatirConfig.new)
      expect(WatirSession.watir_config).to eql(watir_config)
    end
  end

  describe "#create_browser" do
    after(:each) { WatirSession.quit_browser }

    it "creates a local browser" do
      WatirSession.start
      WatirSession.create_browser
      expect(WatirSession.browser).to be_a(Watir::Browser)
    end
  end

  describe "#quit_browser" do

    it "quits a local browser" do
      WatirSession.start
      WatirSession.create_browser
      WatirSession.quit_browser
      expect(WatirSession.browser).to be_nil
    end
  end

  describe "#restart_browser!" do
    after(:each) { WatirSession.browser.quit }

    it "resets a local browser" do
      WatirSession.start
      browser = WatirSession.create_browser
      WatirSession.restart_browser!
      expect(WatirSession.browser).to be_a(Watir::Browser)
      expect(WatirSession.browser).to_not be == browser
    end
  end

  describe "#reset_config!" do

    it "resets the configuration" do
      watir_config = WatirConfig.new(browser: 'firefox')
      WatirSession.watir_config = watir_config
      WatirSession.reset_config!
      expect(WatirSession.watir_config).to_not eql(watir_config)
      expect(WatirSession.watir_config).to eql(WatirConfig.new)
    end
  end

  context 'with hooks' do
    before(:each) { WatirSession.reset_registered_sessions! }
    after(:each) { WatirSession.after_each }

    class SampleConfig < WatirModel
      key(:browser) { :firefox }
    end

    class SampleSession
      def initialize(config = nil)
        @config = config || SampleConfig.new
      end

      def start(*args)
        WatirSession.watir_config.always_locate = false
      end

      def create_browser(*args)
        Watir::Browser.new :firefox
      end
    end

    describe "#register_session" do
      it "registers a session" do
        WatirSession.start
        WatirSession.register_session(SampleSession)
        expect(WatirSession.registered_sessions).to include(SampleSession)
      end
    end

    describe "#create_browser" do
      it "creates a browser from hook" do
        WatirSession.start
        WatirSession.register_session(SampleSession)
        WatirSession.before_each
        expect(WatirSession.browser.name).to be :firefox
      end
    end
  end

end
