require 'model'
require 'yaml'

class WatirConfig < Model

  ## --Browser Options-- ##

  # Supported browsers:
  # chrome, firefox, safari, phantomjs, edge, internet_explorer
  key(:browser) { (ENV['BROWSER'] || 'chrome').to_sym }

  # Time in seconds to wait to hear back from the browser after sending a command
  key(:http_timeout) { (ENV['HTTP_TIMEOUT'] || '60').to_i }


  ## --Watir Options-- ##

  # Time in seconds to wait to interact with an element
  key(:watir_timeout) { (ENV['WATIR_TIMEOUT'] || '30').to_i }

  # true means that when an element goes stale it is relocated
  # false means that when an element goes stale, an exception is thrown
  # Note: As currently implemented, this setting would be better named relocate_when_necessary
  key(:always_locate) { ENV['ALWAYS_LOCATE'] != 'true' }

  # true means elements will be located with CSS instead of XPATH when possible
  # false means that elements will be located by XPATH instead of CSS when possible
  key(:prefer_css) { ENV['PREFER_CSS'] == 'true' }


  ## --Test Options-- ##

  # true means the browser does not automatically close between session start and exit
  # false means the browser quits and restarts after each test
  key(:reuse_browser) { ENV['REUSE_BROWSER'] == 'true' }

  # 'always' means the test takes a screenshot after the end of each test
  # 'failing' means the test takes a screenshot after the end of each failing test
  # 'never' means the test never takes a screenshot automatically
  key(:take_screenshots) { (ENV['TAKE_SCREENSHOTS'] || 'never').to_sym }

  # TODO - implement this, look at Watirmark code
  # true means the browser quits as expected at the end of a session
  # false means the browser remains open after teh session has ended
  # Note: reuse_browser must be true for this setting to matter
  key(:close_browser_on_exit) { ENV['CLOSE_BROWSER_ON_EXIT'] != 'true' }

  # true means the browser is set to maximize after starting
  # false means the size of the browser is not automatically changed after browser is started
  key(:maximize_browser) { ENV['MAXIMIZE_BROWSER'] == 'true' }

  # TODO - Implement Logs
  # 'UNKNOWN'- An unknown message that should always be logged.
  # 'FATAL' - An unhandleable error that results in a program crash.
  # 'ERROR' - A handleable error condition.
  # 'WARN' - A warning.
  # 'INFO' - Generic (useful) information about system operation.
  # 'DEBUG' - Low-level information for developers.
  key(:log_level) { ENV['LOG_LEVEL'] || 'INFO' }

  # true means the browser will run in xvfb
  # false means the browser will run in the normal window
  # Note: This setting will be ignored if platform is not Linux, and will raise error if xvfb is not installed
  key(:headless) { ENV['HEADLESS'] == 'true' }

end
