#
# tests for rtm.rb
#
# see http://d.hatena.ne.jp/secondlife/20060927/1159334813
#
# $Id: test_rtm.rb 565 2006-12-29 16:06:13Z takayama $
#

$LOAD_PATH << File.dirname(__FILE__) + '/..'

require 'test/unit'
require 'rtm'

class RTMTest < Test::Unit::TestCase
   KEY = 'aaa'   # XXX specify API key
   SEC = 'bbb'   # XXX specify shared secret
   FROB = 'ccc'  # XXX enter some frob
   TOKEN = 'ddd' # XXX enter some token

   def setup
      RTM::API.init(:key=>KEY, :secret=>SEC, :token=>TOKEN)
      @contact  = RTM::Contact.new(0)
      @group    = RTM::Group.new
      @list     = RTM::List.new(:id => 0)
      @lists    = RTM::Lists.new
   end

   def test_instance
      assert_instance_of RTM::Contact, @contact
      assert_instance_of RTM::Group, @group
      assert_instance_of RTM::List, @list
      assert_instance_of RTM::Lists, @lists
   end

   def test_lists0
      assert_not_nil(@list)
      assert_not_nil(@lists)
   end
end
