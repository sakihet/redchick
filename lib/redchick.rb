require "redchick/version"
require "readline"
require "oauth"
require "twitter"

module Redchick
  CONSUMER_KEY = "6vSPn8nvt62lIXlmQ0f6JSI7O"
  CONSUMER_SECRET = "PYZQYeIm0ca6Jc6DMdlrMx0hfDyPKZPsksA1WvMWKtgzjeihSO"

  class Cli
    @client = nil

    def initialize(oauth_token, oauth_token_secret)
      @client = Twitter::REST::Client.new do |conf|
        conf.consumer_key = CONSUMER_KEY
        conf.consumer_secret = CONSUMER_SECRET
        conf.access_token = oauth_token
        conf.access_token_secret = oauth_token_secret
      end
    end

    def start
      puts "redchick version: #{Redchick::VERSION}"
      while buf = Readline.readline("> ", true)
        p buf
        tweet(buf)
      end
    end

    def tweet(str)
      @client.update(str)
    end
  end

  def self.start
    access_token = get_access_token
    cli = Redchick::Cli.new(access_token.token, access_token.secret)
    cli.start
  end

  def self.get_access_token
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
