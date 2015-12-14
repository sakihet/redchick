require "redchick/version"
require "redchick/layout"
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

    def initialize(config)
      @config = config
      current_user = @config[:current_user]
      token = @config[:users][current_user.to_sym][:oauth_token]
      secret = @config[:users][current_user.to_sym][:oauth_token_secret]

      @client = Twitter::REST::Client.new do |conf|
        conf.consumer_key = CONSUMER_KEY
        conf.consumer_secret = CONSUMER_SECRET
        conf.access_token = token
        conf.access_token_secret = secret
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

    def config
      puts @config
    end

    def tweet(vals)
      @client.update(vals.join(' '))
    end

    def delete(ids)
      ids.each { |id| @client.destroy_status id }
    end

    def like(ids)
      ids.each { |i| @client.favorite i }
    end

    def retweet(ids)
      ids.each { |i| @client.retweet i }
    end

    def home
      @client.home_timeline.each do |t|
        show_tweet(t)
      end
    end

    def mentions
      @client.mentions_timeline.each do |t|
        show_tweet(t)
      end
    end

    def view(username)
      @client.user_timeline(username).each do |t|
        show_tweet(t)
      end
    end

    def whois(username)
      user = @client.user(username)
      puts "name: #{user.name}"
      puts "description: #{user.description}"
      puts "tweets: #{user.statuses_count}"
      puts "followers: #{user.followers_count}"
      puts "friends: #{user.friends_count}"
      puts "location: #{user.location}"
    end

    def search(query)
      @client.search("#{query}").take(20).each do |t|
        show_tweet(t)
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

    def show_tweet(t)
      puts Redchick::Layout.send(@config[:layout], t)
    end
  end

  def self.start
    generate_config_file unless File.exists? File.join(Dir.home, CONFIG_FILE)
    config = YAML.load_file(File.join(Dir.home, CONFIG_FILE))
    cli = Redchick::Cli.new(config)
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
      layout: 'basic',
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
