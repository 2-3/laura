require_relative "plugin"

module Laura
  class Admin < Plugin
  
    def matchers 
      return [
        match({
          'match' => /raw (?<cmd>.*)/,
          'proc' => lambda {|msg| @bot.irc.raw(msg.captures[:cmd])},
          'is_restricted' => true
        }),
        match({
          'match' => /privmsg (?<target>\S*) (?<msg>.*)/,
          'proc' => lambda {|msg| @bot.irc.privmsg(msg.captures[:target], msg.captures[:msg])},
          'is_restricted' => true
        }),
        match({
          'match' => /part (?<channel>.*)/,
          'proc' => lambda {|msg| @bot.irc.part(msg.captures[:channel])},
          'is_restricted' => true
        }),
        match({
          'match' => /join (?<channel>.*)/,
          'proc' => lambda {|msg| @bot.irc.join(msg.captures[:channel])},
          'is_restricted' => true
        }),
        match({
          'match' => /quit/,
          'proc' => lambda {|msg| @bot.irc.quit},
          'is_restricted' => true
        }),
        match({
          'match' => /kick (?<user>.*) (?<reason>.*)/,
          'proc' => lambda {|msg| @bot.irc.kick(msg[:target], msg.captures[:user], msg.captures[:reason])},
          'is_restricted' => true
        })
      ]
    end
  end
end
