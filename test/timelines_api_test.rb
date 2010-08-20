#
# tests for RTM::Timelines API.
#

require File.dirname(__FILE__) + '/test_helper.rb'

class RTMTimelinesAPITest < Test::Unit::TestCase
   CONFIG = File.dirname(__FILE__) + '/../config.dat' # config data file

   def setup
      conf = begin
         Marshal.load(open(CONFIG))
      rescue
         puts 'please run make_config.rb first.'
         exit
      end

      RTM::API.init(conf[:key], conf[:sec], conf)
      @token = conf[:token]
   end

   def teardown
   end

   # -----------------------------------------------------------------
   # helper
   #

   # -----------------------------------------------------------------
   # tests
   #
   def test_create
      timeline = RTM::Timelines::Create.new(@token).invoke
      assert_equal(7, timeline.length)
   end

   def test_instance
      timeline = RTM::Timeline.new(@token)
      assert_equal(7, timeline.length)
   end
end

# vim:fdm=indent

