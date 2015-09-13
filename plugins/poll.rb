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
  
    attr_reader :current_polls, :voted
  
    def initialize(bot)
      super(bot)
      @voted = Hash.new
      @current_polls = Hash.new
    end
    
    def print_poll(poll)
      if poll == nil
        return "No poll is open currently. You can create one with 'poll new'"
      end
      poll.subject + poll.options.reduce("") {|memo, opt|
        memo += " | (#{opt.key}) #{opt.description}: #{opt.votes.to_s}"
      }
    end
    
    def set_poll_for_channel(msg, poll, voted)
      if ! msg.raw[:target].start_with?('#') then return end
      @current_polls[msg.raw[:target]] = poll
      @voted[msg.raw[:target]] = voted
    end
    
    def with_channel(msg, proc)
      if ! msg.raw[:target].start_with?('#') then return end
      poll = @current_polls[msg.raw[:target]]
      voted = @voted[msg.raw[:target]] || @voted[msg.raw[:target]] = Array.new
      proc.call(poll, voted)
    end
    
    def matchers 
      return [
        match({
          'match' => /poll new (?<poll>.*)/,
          'proc' => lambda {|msg|
            with_channel(msg, lambda {|poll, voted|
              if poll != nil then return "There's already a poll open!" end
              poll = msg.captures[:poll].split(', ').delete_if {|n| n.empty?}
              if poll.count < 3 then return "No, that's wrong." end
              option_keys = ('a'...'z').to_a
              new_poll = Poll.new(
                poll.shift,
                poll.map {|poll_option| PollOption.new(option_keys.shift, poll_option, 0)} 
              )
              set_poll_for_channel(msg, new_poll, Array.new)
              "New poll: " + print_poll(new_poll)
            })
          }
        }),
        match({
          'match' => /poll vote (?<key>.*)/,
          'proc' => lambda {|msg|
            with_channel(msg, lambda {|poll, voted|
              user = msg.raw[:nick] + msg.raw[:mask]
              if voted.include?(user) then return "You already voted!" end
              poll.options.each {|opt|
                if opt.key == msg.captures[:key] 
                  opt.votes += 1
                  voted << user
                  set_poll_for_channel(msg, poll, voted)
                  return "#{msg.raw[:nick]} voted for #{msg.captures[:key]}"
                end
              }
            return "No, that's wrong."
            })
          }
        }),
        match({
          'match' => /poll close/,
          'proc' => lambda {|msg|
            with_channel(msg, lambda {|poll, voted|
              poll_result = print_poll(poll)
              set_poll_for_channel(msg, nil, Array.new)
              "Results: " + poll_result
            })
          }
        }),
        match({
          'match' => /poll$/,
          'proc' => lambda {|msg| with_channel(msg, lambda {|poll, voted| "Current poll: " + print_poll(poll)})}
        })
      ]
    end
    
  end
end
