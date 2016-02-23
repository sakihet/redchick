require 'redchick/version'
require 'redchick/layout'
require 'readline'
require 'yaml'
require 'oauth'
require 'twitter'
require 'pry'
require 'colorize'

module Redchick
  CONSUMER_KEY = '6vSPn8nvt62lIXlmQ0f6JSI7O'
  CONSUMER_SECRET = 'PYZQYeIm0ca6Jc6DMdlrMx0hfDyPKZPsksA1WvMWKtgzjeihSO'
  CONFIG_FILE = '.redchick.yml'

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

      @timeline_opts = {
        count: @config[:count]
      }
    end

    def start
      puts "redchick version: #{Redchick::VERSION}"
      client_methods = Redchick::Cli.instance_methods(false)
      while buf = Readline.readline("\e[31m>\e[0m ", true)
        begin
          cmd, *vals = buf.split(' ')
          if cmd
            cmd = cmd.to_sym
            if client_methods.include?(cmd)
              if vals.empty?
                send(cmd)
              else
                send(cmd, vals)
              end
            else
              puts 'no command'
              puts 'please use help'
            end
          end
        rescue
          puts 'error'
        end
      end
    end

    def config
      puts @config
    end

    def layout
      puts @config[:layout]
    end

    def version
      puts Redchick::VERSION
    end

    def help
      puts 'commands:'
      puts Redchick::Cli.instance_methods(false)
    end
    alias_method :h, :help

    def tweet(vals)
      @client.update(vals.join(' '))
    end
    alias_method :t, :tweet

    def reply(id_and_str)
      id = id_and_str[0]
      str = id_and_str[1]
      target = @client.status(id)
      @client.update("@#{target.user.screen_name} #{str}", in_reply_to_status: target)
    end
    alias_method :rep, :reply

    def delete(ids)
      ids.each { |id| @client.destroy_status id }
    end
    alias_method :del, :delete

    def like(ids)
      ids.each { |i| @client.favorite i }
    end

    def retweet(ids)
      ids.each { |i| @client.retweet i }
    end

    def open(ids)
      ids.each { |id| system "open #{@client.status(id).uri}" }
    end
    alias_method :o, :open

    def home
      @client.home_timeline(@timeline_opts).each do |t|
        show_tweet(t)
      end
    end

    def mentions
      @client.mentions_timeline(@timeline_opts).each do |t|
        show_tweet(t)
      end
    end

    def likes
      @client.favorites(count: @config[:count]).each do |t|
        show_tweet(t)
      end
    end

    def view(username)
      @client.user_timeline(username, @timeline_opts).each do |t|
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
      @client.search("#{query}").take(@config[:count]).each do |t|
        show_tweet(t)
      end
    end
    alias_method :s, :search

    def ls(arg)
      case arg[0]
      when 'fl'
        @client.followers.each { |user| puts user.screen_name }
      when 'fr'
        @client.friends.each { |user| puts user.screen_name }
      else
        puts 'error'
      end
    end

    def follow(users)
      users.each { |u| @client.follow u }
    end
    alias_method :f, :follow

    def unfollow(users)
      users.each { |u| @client.unfollow u }
    end
    alias_method :uf, :unfollow

    def block(users)
      users.each { |u| @client.block u }
    end
    alias_method :bl, :block

    def lists
      @client.owned_lists.each do |l|
        puts l.name
      end
    end

    def list(arg)
      @client.list_timeline(arg[0]).each do |t|
        show_tweet(t)
      end
    end

    def show_tweet(t)
      puts Redchick::Layout.send(@config[:layout], t)
    end
  end

  def self.start
    generate_config_file unless File.exist? File.join(Dir.home, CONFIG_FILE)
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
      count: 15,
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
