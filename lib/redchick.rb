require "redchick/version"
require "readline"

module Redchick
  CONSUMER_KEY = "6vSPn8nvt62lIXlmQ0f6JSI7O"
  CONSUMER_SECRET = "PYZQYeIm0ca6Jc6DMdlrMx0hfDyPKZPsksA1WvMWKtgzjeihSO"

  class Cli
    def start
      puts "redchick version: #{Redchick::VERSION}"
      while buf = Readline.readline("> ", true)
        p buf
      end
    end
  end

  def self.start
    cli = Redchick::Cli.new()
    cli.start
  end

  def get_access_token
    consumer = OAuth::Consumer.new(
      CONSUMER_KEY,
      CONSUMER_SECRET,
      site: 'https://api.twitter.com'
    )
    request_token = consumer.get_request_token
    puts 'open following url and authorize it', request_token.authorize_url
    puts 'enter PIN: '
    pin = STDIN.gets.chomp
    access_token = request_token.get_access_token(oauth_verifier: pin)
  end

end
