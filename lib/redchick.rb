require "redchick/version"
require "readline"

module Redchick

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

end
