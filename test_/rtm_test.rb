#
# tests for rtm.rb
#
# see http://d.hatena.ne.jp/secondlife/20060927/1159334813
#
# $Id: test_rtm.rb 10 2006-12-30 06:37:24Z takayama $
#

require File.dirname(__FILE__) + '/test_helper.rb'

class RTMTest < Test::Unit::TestCase
   CONFIG = File.dirname(__FILE__) + '/../config.dat' # config data file

   KEY   = 'aaa' # XXX specify API key
   SEC   = 'bbb' # XXX specify shared secret
   FROB  = 'ccc' # XXX enter some frob
   TOKEN = 'ddd' # XXX enter some token

   def setup
      conf = begin
         Marshal.load(open(CONFIG))
      rescue
         { 
            :key => KEY,
            :secret => SEC,
            :frob => FROB,
            :token => TOKEN }
      end

      RTM::API.init(conf)
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

   # -----------------------------------------------------------------
   # Lists
   #
   def test_lists0
      assert_not_nil(@list)
      assert_not_nil(@lists)
   end

   def test_lists_add
      l = RTM::Lists.add('rtmilk test')
      assert_not_nil(l)
   end

   # -----------------------------------------------------------------
   # Tasks
   #
   def test_tasks_add
      t = RTM::Tasks.add('rtmilk test task to add', @lists[0].id)
      assert_not_nil(t)
   end

   def test_tasks_delete
      t = RTM::Tasks.add('rtmilk test task to delete', @lists[0].id)
      assert_not_nil(t)

      deleted = RTM::Tasks.delete(t.id, t.task.first.id, @lists[0].id)
      assert_not_nil(deleted)
   end

   # -----------------------------------------------------------------
   # TimeLine
   #
   def test_get_timeline
      timeline = RTM.get_timeline
      assert_not_nil(timeline)
   end
end
