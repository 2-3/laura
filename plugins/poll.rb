require_relative "Plugin"

module Laura

  class Poll < Plugin
  
  Poll = Struct.new(
    :subject,
    :options
  )

  PollOption = Struct.new(
    :key,
    :description,
    :votes
  )
  
    attr_reader :current_poll, :voted
  
    def initialize(bot)
      super(bot)
      @voted = Array.new
    end
    
    def print_poll(poll)
      if poll == nil
        return "No poll is open currently. You can create one with new-poll"
      end
      poll.subject + poll.options.reduce("") {|memo, opt|
        memo += " | (#{opt.key}) #{opt.description}: #{opt.votes.to_s}"
      }
    end

    def matchers 
      return [
        match({
          'match' => /poll new (?<poll>.*)/,
          'proc' => lambda {|msg|
            poll = msg.captures[:poll].split(', ').delete_if {|n| n.empty?}
            if poll.count < 3 then return "No, that's wrong." end
            keys = ('a'...'z').to_a
            @current_poll = Poll.new(
              poll.shift,
              poll.map {|poll_option| PollOption.new(keys.shift, poll_option, 0)} 
            )
            "New poll: " + print_poll(@current_poll)
          }
        }),
        match({
          'match' => /poll vote (?<key>.*)/,
          'proc' => lambda {|msg|
            user = msg.raw[:nick] + msg.raw[:mask]
            if @voted.include?(user) then return "You already voted!" end
            @current_poll.options.each {|opt|
              if opt.key == msg.captures[:key] 
                  opt.votes += 1
                  @voted << user
                  return "#{msg.raw[:nick]} voted for #{msg.captures[:key]}"
              end
            }
            return "No, that's wrong."
          }
        }),
        match({
          'match' => /poll close/,
          'proc' => lambda {|msg|
            poll_result = print_poll(@current_poll)
            @voted = Array.new
            @current_poll = nil
            "Results: " + poll_result
          }
        }),
        match({
          'match' => /poll$/,
          'proc' => lambda {|msg| "Current poll: " + print_poll(@current_poll)}
        })
      ]
    end
    
  end
end
