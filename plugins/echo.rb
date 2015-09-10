require_relative "Plugin"

module Laura
  class Echo < Plugin
  
    def matchers 
      return [
        match({
          'match' => /echo (?<string>.*)/,
          'proc' => lambda {|msg| return "#{msg.captures[:string]}"}
        })
      ]
    end
    
  end
end
