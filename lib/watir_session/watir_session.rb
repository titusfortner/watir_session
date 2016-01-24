module WatirSession

  extend self

  attr_reader :browser
  attr_accessor :watir_config

  def watir_config
    @watir_config ||= WatirConfig.new
  end

  def registered_sessions
    @registered_sessions ||= []
  end

  def register_session(session)
    registered_sessions << session
  end

  def execute_hook(method, *args)
    sessions = registered_sessions.select do |session|
      session.public_methods(false).include? method
    end

    sessions.each_with_object([]) do |session, array|
      array << session.send(method, *args)
    end
  end

  def create_browser(*args)
    use_headless_display if @watir_config.headless

    @browser = execute_hook(:create_browser, *args).compact.first

    unless @browser
      http_client = Selenium::WebDriver::Remote::Http::Default.new
      http_client.timeout = @watir_config.http_timeout
      @browser = Watir::Browser.new(@watir_config.browser,
                                    http_client: http_client)
    end
    @browser
  end

  def before_tests(config = nil, *args)
    @watir_config = config || watir_config

    configure_watir

    create_browser if @watir_config.reuse_browser

    execute_hook :before_tests, *args
    execute_hook :start, *args
  end
  alias_method :start, :before_tests

  def start_test(*args)
    if @watir_config.reuse_browser && browser.nil
      raise StandardError, "#before_tests method must be set in order to use
the #reuse_browser configuration setting"
    end

    before_test(*args)

    @browser = create_browser(*args) unless @watir_config.reuse_browser
    @browser.window.maximize if @watir_config.maximize_browser

    execute_hook :start_test, *args

    @browser
  end

  def end_test(*args)
    execute_hook :end_test, *args

    take_screenshot(*args) unless watir_config.take_screenshots == :never

    quit_browser unless watir_config.reuse_browser

    after_test(*args)
  end

  def after_tests(*args)
    quit_browser if @watir_config.reuse_browser

    execute_hook :after_tests, *args
    execute_hook :end, *args
  end
  alias_method :end, :after_tests

  def take_screenshot(*args)
    screenshot = execute_hook(:take_screenshot, *args).compact
    browser.screenshot.save("screenshot.png") if screenshot.nil?
  end

  def before_test(*args)
    execute_hook :before_test, *args
  end

  def after_test(*args)
    execute_hook :after_test, *args
  end

  def quit_browser
    if @headless
      @headless.destroy
      @headless = nil
    end

    return if @browser.nil?

    @browser.quit
    @browser = nil
  end

  def restart_browser!
    quit_browser
    create_browser
  end

  def reset_config!
    @watir_config = nil
  end

  def reset_registered_sessions!
    @registered_sessions = nil
  end

  def configure_watir
    Watir.default_timeout = @watir_config.watir_timeout
    Watir.prefer_css = @watir_config.prefer_css
    Watir.always_locate = @watir_config.always_locate
  end

  def use_headless_display
    unless RbConfig::CONFIG['host_os'].match('linux')
      warn "Headless only supported on Linux"
      return
    end
    require 'headless'
    @headless = Headless.new
    @headless.start
  end

end
