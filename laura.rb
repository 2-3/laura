require "imouto"
require_relative "config"

module Laura

  Matcher = Struct.new(
    :match,
    :use_prefix,
    :is_restricted,
    :proc
  )

  BotConfig = Struct.new(
    :prefix,
    :master,
    :plugins,
    :escape_chars
  )
  
  class Bot < Imouto::Bot
    attr_reader :config, :plugins
  
    def initialize
      con = Imouto::Irc.new(Laura::Config::Connection, Laura::Config::User)
      super(con)
      @config = BotConfig.new()
      Laura::Config::Laura.each {|k, v| @config[k] = v;}
      @plugins = Hash.new
      @config.plugins.each {|p| register_plugin(p)}
      [Matcher.new(
          /reload-plugin (?<name>.*)/,
          true,
          true,
          lambda {|msg|
            reload_plugin(msg.captures[:name])
            return "reloaded #{msg.captures[:name]}!"}
        ),
        Matcher.new(
          /register-plugin (?<name>.*)/,
          true,
          true,
          lambda {|msg|
            register_plugin(msg.captures[:name])
            return "registered #{msg.captures[:name]}!"}
        ),
        Matcher.new(
          /unregister-plugin (?<name>.*)/,
          true,
          true,
          lambda {|msg|
            unregister_plugin(msg.captures[:name])
            return "unregistered #{msg.captures[:name]}!"}
        )].each {|m| register_matcher(m)}
    end
  
    def register_plugin(name)
      load("plugins/#{name}.rb")
      plugin = Laura.const_get(name).new(self)
      plugin.matchers.each {|m| register_matcher(m)}
      @plugins[name] = plugin
    end
  
    def unregister_plugin(name)
      plugin = @plugins[name]
      plugin.matchers.each {|m| unregister_matcher(m)}
      @plugins.delete(name)
    end
  
    def reload_plugin(name)
      unregister_plugin(name)
      register_plugin(name)
    end
    
    def make_matcher_regex(matcher)
      match = matcher.match
      if matcher.use_prefix == true
        match = Regexp.new @config.prefix.to_s + match.to_s
      end
    end
    
    def register_matcher(matcher)
      proc = lambda {|msg|
        if matcher.is_restricted == true && msg.raw[:nick]+"!"+msg.raw[:mask] != @config.master then return end
        reply = matcher.proc.call(msg)
        @config.escape_chars.each{|s| if reply.start_with?(s) then reply.prepend('\'') end}
        reply
      }
      super(make_matcher_regex(matcher), proc)
    end
    
    def unregister_matcher(matcher)
      super(make_matcher_regex(matcher))
    end
    
    end
end

laura = Laura::Bot.new
laura.start