module WatirSession

  extend self

  attr_reader :browser

  def config
    @config ||= Config.new
  end

  def create_configurations
    spec_path = $LOAD_PATH.select { |path| path =~ /\/spec$/ }.first
    config_path = spec_path.gsub('spec', 'config')
    return unless Dir.exist?(config_path)
    yamls = Dir.entries(config_path).select { |file| file =~ /\.yml$/ }

    yamls.each do |yaml|
      config_name = yaml.gsub('.yml', '')
      next unless Object.const_defined?("#{config_name.singularize.capitalize}Config")
      load_yml(config_path, config_name)
    end
  end

  def load_yml(config_path, config_name)
    yaml = YAML.load_file("#{config_path}/#{config_name}.yml")
    if yaml.values.all? { |v| v.is_a? Hash } && config.respond_to?(config_name.singularize)
      value = config.send(config_name.singularize)
      yaml = yaml[value]
      config.send("#{config_name.singularize}_key=", value)
    end
    config_list[config_name.singularize] = yaml
  end

  def config_list
    @config_list ||= {}
  end

  def load_configs
    config_list.each do |k, v|
      obj = Object.const_get("#{k.capitalize}Config").new(v)
      config.send("#{k.singularize}=", obj) if config.respond_to? k.singularize.to_sym
    end
  end

  def registered_sessions
    @registered_sessions ||= []
  end

  def register_sessions
#    WatirSession.register_session(RSpecSession.new)
#    WatirSession.register_session(TestrailSession.new) if WatirSession.config.use_testrail
#    WatirSession.register_session(SauceSession.new) if WatirSession.config.use_sauce
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

  def start
    configure_watir
    create_configurations
    load_configs
  end

  def before_suite(*args)
    create_browser if config.reuse_browser

    execute_hook :before_suite, *args
  end

  def before_browser(*args)
    execute_hook :before_browser, *args
  end

  def create_browser(*args)
    raise StandardError, "Multiple Browsers not currently supported" if @browser
    use_headless_display if config.headless

    @browser = execute_hook(:create_browser, *args).compact.first
    return @browser if @browser

    if args.empty?
      http_client = Selenium::WebDriver::Remote::Http::Default.new
      http_client.timeout = config.http_timeout
      @browser = Watir::Browser.new(config.browser,
                                    http_client: http_client)
    else
      @browser = Watir::Browser.new *args
    end
  end

  def before_each(*args)
    if config.reuse_browser && browser.nil
      raise StandardError, "#before_tests method must be set in order to use
the #reuse_browser configuration setting"
    end

    before_browser(*args)

    @browser = create_browser unless config.reuse_browser
    @browser.window.maximize if config.maximize_browser

    execute_hook :before_each, *args

    @browser
  end

  def after_each(*args)
    execute_hook :after_each, *args

    take_screenshot(*args) unless config.take_screenshots == :never

    quit_browser unless config.reuse_browser

    after_browser(*args)
  end

  def after_browser(*args)
    execute_hook :after_browser, *args
  end

  def take_screenshot(*args)
    screenshot = execute_hook(:take_screenshot, *args).compact
    browser.screenshot.save("screenshot.png") if screenshot.nil?
  end

  def after_suite(*args)
    quit_browser if config.reuse_browser

    execute_hook :after_suite, *args
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
    @config = nil
  end

  def reset_registered_sessions!
    @registered_sessions = nil
  end

  def configure_watir
    Watir.default_timeout = config.watir_timeout
    Watir.prefer_css = config.prefer_css
    Watir.always_locate = config.always_locate
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

RSpec.configure do |config|
  WatirSession.start

  if WatirSession.config.retries > 0
    require 'rspec/retry'
    config.verbose_retry = true
    config.exceptions_to_retry = [Net::ReadTimeout, Net::OpenTimeout]
    config.display_try_failure_messages = true
    config.default_retry_count = config.retries + 1
  end

  config.before(:suite) do |example|
    WatirSession.before_suite(example)
  end

  config.before(:each) do |example|
    WatirSession.before_each(example)
  end

  config.after(:each) do |example|
    WatirSession.after_each(example)
  end

  config.after(:suite) do |example|
    WatirSession.after_suite(example)
  end
end
