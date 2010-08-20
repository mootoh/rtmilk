#
# tests for RTM::Tasks::Notes API.
#

require File.dirname(__FILE__) + '/test_helper.rb'

class RTMTasksNotesAPITest < Test::Unit::TestCase
   CONFIG = File.dirname(__FILE__) + '/../config.dat' # config data file

   def setup
      conf = begin
         Marshal.load(open(CONFIG))
      rescue
         puts 'please run make_config.rb first.'
         exit
      end

      RTM::API.init(conf[:key], conf[:sec], conf)
      @perms = 'read'
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
   def not_test_add
      timeline, err = RTM::Timelines::Create.new(@token).invoke
      assert_equal('ok', err)
      assert_equal(7, timeline.length)

      lists, err = RTM::Lists::GetList.new(@token).invoke
      assert_equal('ok', err)
      assert_instance_of(Array, lists)
      list = lists.first['id']

      list_a, err, transaction_add = RTM::Tasks::Add.new(
         @token, timeline, list, 'testTaskAdd').invoke
      assert_equal('ok', err)

      taskseries = list_a['taskseries'].first['id']
      task = list_a['taskseries'].first['task'].first['id']

      puts 'creating Note with ' +
         'timeline=' + timeline +
         ', list=' + list +
         ', taskseries=' + taskseries +
         ', task=' + task
      note, err, transaction = RTM::Tasks::Notes::Add.new(
         @token, timeline, list, taskseries, task, 'testNote', 'testNote body.').invoke
      assert_equal('ok', err)
      assert_instance_of(Hash, note)
      assert_not_equal('', note['id'])
   end

   def not_test_add_delete
      timeline, err = RTM::Timelines::Create.new(@token).invoke
      assert_equal('ok', err)
      assert_equal(7, timeline.length)

      lists, err = RTM::Lists::GetList.new(@token).invoke
      assert_equal('ok', err)
      assert_instance_of(Array, lists)
      list = lists.first['id']

      list_a, err, transaction_add = RTM::Tasks::Add.new(
         @token, timeline, list, 'testTaskAdd').invoke
      assert_equal('ok', err)

      taskseries = list_a['taskseries'].first['id']
      task = list_a['taskseries'].first['task'].first['id']

      note, err, transaction = RTM::Tasks::Notes::Add.new(
         @token, timeline, list, taskseries, task, 'testNote', 'testNote body.').invoke
      assert_equal('ok', err)
      assert_instance_of(Array, lists)

      raise Error if note['id'] == ''

      err = RTM::Tasks::Notes::Delete.new(@token, timeline, note['id']).invoke
      assert_equal('ok', err.first)

      list_d, err, transaction = RTM::Tasks::Delete.new(
         @token, timeline, lists.first['id'], taskseries, task).invoke
      assert_equal('ok', err)
      assert_equal(list_a['id'], list_d['id'])
   end

   def test_edit
      timeline = RTM::Timelines::Create.new(@token).invoke
      assert_equal(7, timeline.length)

      lists = RTM::Lists::GetList.new(@token).invoke
      assert_instance_of(Array, lists)
      list = lists.first['id']

      list_a, transaction_add = RTM::Tasks::Add.new(
         @token, timeline, list, 'testTaskAdd').invoke

      taskseries = list_a['taskseries'].first['id']
      task = list_a['taskseries'].first['task'].first['id']

      note, transaction = RTM::Tasks::Notes::Add.new(
         @token, timeline, list, taskseries, task, 'testNote', 'testNote body.').invoke

      raise Error if note['id'] == ''

      editted, transaction = RTM::Tasks::Notes::Edit.new(
         @token, timeline, note['id'], 'testNote editted', 'testNote body edditted.').invoke
      assert_equal(note['id'], editted['id'])

      RTM::Tasks::Notes::Delete.new(@token, timeline, note['id']).invoke

      list_d, transaction = RTM::Tasks::Delete.new(
         @token, timeline, lists.first['id'], taskseries, task).invoke
      assert_equal(list_a['id'], list_d['id'])
   end
end
# vim:fdm=indent
