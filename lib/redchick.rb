require "redchick/version"
require "readline"
require "yaml"
require "oauth"
require "twitter"
require "pry"

module Redchick
  CONSUMER_KEY = "6vSPn8nvt62lIXlmQ0f6JSI7O"
  CONSUMER_SECRET = "PYZQYeIm0ca6Jc6DMdlrMx0hfDyPKZPsksA1WvMWKtgzjeihSO"
  CONFIG_FILE = ".redchick.yml"

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
      client_methods = Redchick::Cli.instance_methods(false)
      while buf = Readline.readline("> ", true)
        cmd, *vals = buf.split(' ')
        if client_methods.include?(cmd.to_sym)
          if vals.empty?
            self.send(cmd)
          else
            self.send(cmd, vals)
          end
        end
      end
    end

    def tweet(vals)
      @client.update(vals.join(' '))
    end

    def home
      @client.home_timeline.each do |t|
        puts t.text
      end
    end

    def follow(users)
      users.each { |u| @client.follow u }
    end

    def unfollow(users)
      users.each { |u| @client.unfollow u }
    end

    def block(users)
      users.each { |u| @client.block u }
    end
  end

  def self.start
    generate_config_file unless File.exists? File.join(Dir.home, CONFIG_FILE)
    @config = YAML.load_file(File.join(Dir.home, CONFIG_FILE))
    current_user = @config[:current_user]
    token = @config[:users][current_user.to_sym][:oauth_token]
    secret = @config[:users][current_user.to_sym][:oauth_token_secret]
    cli = Redchick::Cli.new(token, secret)
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

  def self.generate_config_file
    access_token = get_access_token
    screen_name = access_token.params[:screen_name]
    config = {
      current_user: screen_name,
      users: {
        "#{screen_name}": {
                            oauth_token: access_token.token,
                            oauth_token_secret: access_token.secret
                          }
      }
    }
    f = File.new(File.join(Dir.home, CONFIG_FILE), 'w')
    f.write config.to_yaml
  end
end
