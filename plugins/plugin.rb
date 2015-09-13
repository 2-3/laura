module Laura

  class Plugin
    attr_reader :bot
  
    def initialize(bot)
      @bot = bot
    end

    def matchers
      {}
    end
    
    protected
    
    def match(conf)
      prefix_status = conf.key?('use_prefix') ? conf['use_prefix'] : true
      Matcher.new(
        conf['match'],
        prefix_status,
        conf['is_restricted'] || false,
        conf['proc']
      )
    end
  end
end
