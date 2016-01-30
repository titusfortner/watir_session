module WatirSession

  extend self

  attr_reader :browser
  attr_writer :watir_config

  def watir_config
    @watir_config ||= WatirConfig.new
  end

  def custom_config
    @custom_config ||= CustomConfig.new
  end

  def create_configurations
    spec_path = $LOAD_PATH.select { |path| path =~ /\/spec$/ }.first
    config_path = spec_path.gsub('spec', 'config')

    return unless Dir.exist?(config_path)
    Dir.entries(config_path).select { |file| file =~ /\.yml$/ }.each do |yaml|
      config_name = yaml.gsub('.yml', '')
      next unless Object.const_defined?("#{config_name.capitalize}Config")
      load_yml(config_path, config_name)
    end
  end

  def load_yml(config_path, config_name)
    config = YAML.load_file("#{config_path}/#{config_name}.yml")
    if config.values.all? { |v| v.is_a? Hash } && custom_config.respond_to?(config_name.singularize)
      config = config[custom_config.send(config_name.singularize)]
    end
    obj = Object.const_get("#{config_name.capitalize}Config").new(config)
    custom_config.send("#{config_name.singularize}=", obj)
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

  def start
    configure_watir
    create_configurations
  end

  def before_suite(*args)
    create_browser if watir_config.reuse_browser

    execute_hook :before_suite, *args
  end

  def before_browser(*args)
    execute_hook :before_browser, *args
  end

  def create_browser(*args)
    use_headless_display if watir_config.headless

    @browser = execute_hook(:create_browser, *args).compact.first

    unless @browser
      http_client = Selenium::WebDriver::Remote::Http::Default.new
      http_client.timeout = watir_config.http_timeout
      @browser = Watir::Browser.new(watir_config.browser,
                                    http_client: http_client)
    end
    @browser
  end

  def before_each(*args)
    if watir_config.reuse_browser && browser.nil
      raise StandardError, "#before_tests method must be set in order to use
the #reuse_browser configuration setting"
    end

    before_browser(*args)

    @browser = create_browser(*args) unless watir_config.reuse_browser
    @browser.window.maximize if watir_config.maximize_browser

    execute_hook :before_each, *args

    @browser
  end

  def after_each(*args)
    execute_hook :after_each, *args

    take_screenshot(*args) unless watir_config.take_screenshots == :never

    quit_browser unless watir_config.reuse_browser

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
    quit_browser if watir_config.reuse_browser

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
    @watir_config = nil
    @custom_config = nil
  end

  def reset_registered_sessions!
    @registered_sessions = nil
  end

  def configure_watir
    Watir.default_timeout = watir_config.watir_timeout
    Watir.prefer_css = watir_config.prefer_css
    Watir.always_locate = watir_config.always_locate
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
