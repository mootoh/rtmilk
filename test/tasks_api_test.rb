#
# tests for RTM::Tasks API.
#

require File.dirname(__FILE__) + '/test_helper.rb'

class RTMTasksAPITest < Test::Unit::TestCase
   CONFIG = File.dirname(__FILE__) + '/../config.dat' # config data file

   def setup
      conf = begin
         Marshal.load(open(CONFIG))
      rescue
         puts 'please run make_config.rb first.'
         exit
      end

      RTM::API.init(conf[:key], conf[:sec], conf)
      @perms = 'delete'
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
   def not_test_getList
      lists, err = RTM::Tasks::GetList.new(@token).invoke
      assert_equal('ok', err)
      assert_instance_of(Array, lists)
   end

   def not_test_add
      timeline = RTM::Timelines::Create.new(@token).invoke
      assert_equal(7, timeline.length)

      lists, err = RTM::Lists::GetList.new(@token).invoke
      assert_equal('ok', err)
      assert_instance_of(Array, lists)

      list, err, transaction = RTM::Tasks::Add.new(
         @token, timeline, lists.first['id'], 'testTaskAdd').invoke
      assert_equal('ok', err)
   end

   def not_test_delete
      timeline = RTM::Timelines::Create.new(@token).invoke
      assert_equal(7, timeline.length)

      lists, err = RTM::Lists::GetList.new(@token).invoke
      assert_equal('ok', err)
      assert_instance_of(Array, lists)

      taskseries = '2855723' # XXX
      task = '4001630' # XXX

      list, err, transaction = RTM::Tasks::Delete.new(
         @token, timeline, lists.first['id'], taskseries, task).invoke
      assert_equal('ok', err)
   end

   def test_add_delete
      timeline = RTM::Timelines::Create.new(@token).invoke
      assert_equal(7, timeline.length)

      lists = RTM::Lists::GetList.new(@token).invoke
      assert_instance_of(Array, lists)
      list = lists.first['id']

      list_a, transaction_add = RTM::Tasks::Add.new(
         @token, timeline, list, 'testTaskAdd').invoke

      taskseries = list_a['taskseries'].first['id']
      task = list_a['taskseries'].first['task'].first['id']

      list_d, transaction = RTM::Tasks::Delete.new(
         @token, timeline, lists.first['id'], taskseries, task).invoke
      assert_equal(list_a['id'], list_d['id'])
   end
end

# vim:fdm=indent
