module Redchick
  module Layout
    @colors = [:red, :green, :yellow, :blue, :magenta, :cyan]
    def self.simple(t)
      "#{t.user.screen_name.rjust(15)}: #{t.text}"
    end

    def self.basic(t)
      "#{t.user.name} @#{t.user.screen_name} #{t.created_at}\n"\
      "#{t.text}\n"\
      "rt: #{t.retweet_count}, like: #{t.favorite_count}, id: #{t.id}\n"\
      '--'.colorize(@colors[t.user.screen_name.sum % @colors.size])
    end
  end
end
