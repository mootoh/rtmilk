#
# tests for RTM::Lists API.
#

require File.dirname(__FILE__) + '/test_helper.rb'

class RTMListsAPITest < Test::Unit::TestCase
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
   def test_getList
      lists = RTM::Lists::GetList.new(@token).invoke
      assert_instance_of(Array, lists)
      lists.each do |list|
         assert_instance_of(Hash, list)
         assert_equal(true, list.has_key?('name'))
         assert_equal(true, list.has_key?('id'))
         assert_equal(true, list.has_key?('deleted'))
         assert_equal(true, list.has_key?('smart'))
      end
   end

   def not_test_add
      name = 'testAddList'
      added = RTM::Lists::Add.new(@token, name).invoke
      assert_equal(added['name'], name)

      # TODO: do filter test
   end # add

   def not_test_delete
      name = 'testAddList'
      added = RTM::Lists::Add.new(@token, name).invoke
      assert_equal(added['name'], name)

      deleted = RTM::Lists::Delete.new(@token, added['id']).invoke
      assert_equal(added['name'], deleted['name'])
      assert_equal(added['id'], deleted['id'])
      assert_equal('1', deleted['deleted'])
   end # delete

   def test_setName
      # add
      name = 'testSetName'
      new_name = 'testSetNameNew'
      added = RTM::Lists::Add.new(@token, name).invoke
      assert_equal(added['name'], name)

      # setName
      named = RTM::Lists::SetName.new(@token, added['id'], new_name).invoke
      assert_equal(new_name, named['name'])

      # delete
      deleted = RTM::Lists::Delete.new(@token, added['id']).invoke
      assert_equal(named['name'], deleted['name'])
      assert_equal(named['id'], deleted['id'])
      assert_equal('1', deleted['deleted'])
   end
end
# vim:fdm=indent
