#
# rtm.timelines : Timelines API
#
module RTM
module Timelines

class Create < RTM::API
   def parse_result(result)
      super
      result['timeline'].first
   end

   def initialize(token)
      super 'rtm.timelines.create', token
   end
end # Create

end # Timelines

class Timeline
   def initialize(token)
      @timeline = RTM::Timelines::Create.new(token).invoke
   end

   def to_s
      @timeline
   end

   def length
      @timeline.length
   end
end # Timeline
end # RTM
# vim:fdm=indent
