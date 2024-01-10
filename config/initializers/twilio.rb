# config/initializers/twilio.rb

require 'twilio-ruby'

Twilio.configure do |config|
  config.account_sid = 'ACe1296916733ff8ce775cb1c89dddb845'
  config.auth_token = '67587d13fb597f63f2bdb8018c0a35e3'
end

$twilio_client = Twilio::REST::Client.new
