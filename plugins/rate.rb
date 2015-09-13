require_relative "Plugin"

module Laura
  class Rate < Plugin
  
    #add special strings for a bit of extra spice here.
    def specials
      [
        'worst',
        'the best ever'
      ]
    end
  
    def matchers 
      return [
        match({
          'match' => /rate (?<string>.*)/,
          'proc' => lambda {|msg|
              rating = rand(10).to_s()+'/10'
              if 15 > rand(100)
                rating = specials.sample()
              end
              return "#{msg.captures[:string]} is #{rating}"
              }
        })
      ]
    end
    
  end
end
