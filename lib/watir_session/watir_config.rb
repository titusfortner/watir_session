class WatirConfig < WatirModel

  ## --Browser Options-- ##

  # Supported browsers:
  # chrome, firefox, safari, phantomjs, edge, internet_explorer
  symbol(:browser) { (:chrome) }

  # Time in seconds to wait to hear back from the browser after sending a command
  integer(:http_timeout) { 60 }


  ## --Watir Options-- ##

  # Time in seconds to wait to interact with an element
  integer(:watir_timeout) { 30 }

  # true means that when an element goes stale it is relocated
  # false means that when an element goes stale, an exception is thrown
  # Note: As currently implemented, this setting would be better named relocate_when_necessary
  boolean(:always_locate) { true }

  # true means elements will be located with CSS instead of XPATH when possible
  # false means that elements will be located by XPATH instead of CSS when possible
  boolean(:prefer_css) { false }


  ## --Test Options-- ##

  # true means the browser does not automatically close between session start and exit
  # false means the browser quits and restarts after each test
  boolean(:reuse_browser) { false }

  # 'always' means the test takes a screenshot after the end of each test
  # 'failing' means the test takes a screenshot after the end of each failing test
  # 'never' means the test never takes a screenshot automatically
  symbol(:take_screenshots) { :never }

  # TODO - implement this, look at Watirmark code
  # true means the browser quits as expected at the end of a session
  # false means the browser remains open after teh session has ended
  # Note: reuse_browser must be true for this setting to matter
  boolean(:close_browser_on_exit) { true }

  # true means the browser is set to maximize after starting
  # false means the size of the browser is not automatically changed after browser is started
  boolean(:maximize_browser) { false }

  # TODO - Implement Logs
  # 'UNKNOWN'- An unknown message that should always be logged.
  # 'FATAL' - An unhandleable error that results in a program crash.
  # 'ERROR' - A handleable error condition.
  # 'WARN' - A warning.
  # 'INFO' - Generic (useful) information about system operation.
  # 'DEBUG' - Low-level information for developers.
  string(:log_level) { 'INFO' }

  # true means the browser will run in xvfb
  # false means the browser will run in the normal window
  # Note: This setting will be ignored if platform is not Linux, and will raise error if xvfb is not installed
  boolean(:headless) { true }

  # true means the browser will run in xvfb
  # false means the browser will run in the normal window
  # Note: This setting will be ignored if platform is not Linux, and will raise error if xvfb is not installed
  integer(:retries) { 0 }

end
