module Redchick
  module Layout
    def self.simple(t)
      "#{t.user.screen_name.rjust(15)}: #{t.text}"
    end
  end
end
