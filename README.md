# WatirSession

This gem leverages the Watir test library to allow for easy access
to configurarion and session data so they do not need to be passed around as 
parameters throughout your tests.
The intention is to provide a solution that is easy to use and maintain, 
while still providing power and flexibility.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'watir_session'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install watir_session

## Usage

The default WatirConfig class uses the recommended settings without needing  
any modifications.  The hooks into the WatirSession class are designed to work 
with your  test harness (RSpec, Cucumber, etc) for maximum flexibility. 
 At a minimum, you'll need to call:

``` ruby
WatirSession.start 
WatirSession.start_test  
WatirSession.end_test  
```

## Example

Here's an example for how you can add a session for Saucelabs

```ruby
class SauceSession
  def initialize
    @sauce_config = SuaceConfig.new
  end
  def create_browser)
    @browser = Watir::Browser.new(:remote, url: @sauce_config.endpoint)
  end
end
```
```ruby
require 'model'

class SauceConfig < Model
  key(:sauce_username) { ENV['SAUCE_USERNAME'] }
  key(:sauce_access_key) { ENV['SAUCE_ACCESS_KEY'] }
  key(:endpoint) {"http://#{sauce_username}:#{sauce_access_key}@ondemand.saucelabs.com:80/wd/hub"}
end
```
```ruby
RSpec.configure do |config|
  WatirSession.start
  WatirSession.register_session(SauceSession.new)

  config.before(:each) do
    @browser = WatirSession.start_test
  end
  config.after(:each) do
    WatirSession.end_test
  end
end
```

## Development

Run `rake spec` to run the tests
To install this gem onto your local machine, run `bundle exec rake install`. 


## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/titusfortner/watir_session.


## License

The gem is available as open source under the terms of the 
[MIT License](http://opensource.org/licenses/MIT).

