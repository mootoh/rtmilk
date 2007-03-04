#
# tests for rtm.rb
#
# see http://d.hatena.ne.jp/secondlife/20060927/1159334813
#
# $Id: test_rtm_api.rb 10 2006-12-30 06:37:24Z takayama $
#

require File.dirname(__FILE__) + '/test_helper.rb'

class RTMAPITest < Test::Unit::TestCase
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
            :token => TOKEN
         }
      end

      RTM::API.init(conf)
   end

   def test_init
      assert_equal(1, RTM::API.params.size)
   end

   def test_instance
   end

# -------------------------------------------------------------------
# test Helper
#
   def test_sign
     sign = RTM::API.sign(RTM::API.params)
     assert_equal(32, sign.length)
   end

   def test_uri_req
     assert_equal(1, RTM::API.params.keys.size)
     ur = RTM::API.uri_req(RTM::API.params)
     assert_not_nil(ur)
     assert_equal(1, RTM::API.params.keys.size)
   end

   def test_uri_auth
     assert_equal(1, RTM::API.params.keys.size)
     ra = RTM::API.uri_auth(RTM::API.params, 'read')
     assert_not_nil(ra)
     assert_equal(1, RTM::API.params.keys.size)
   end

   def test_auth_uri
      au = RTM::API.auth_uri(RTM::API.params, 'read')
      assert_not_nil(au)
   end

   def test_uri_auth_frob
      frob = RTM::API::Auth.getFrob
      assert_not_nil(frob)
      assert_equal(40, frob.length)

      RTM::API::PERMS.each do |p|
         ra = RTM::API.uri_auth(RTM::API.params, {'perm'=>p, 'frob'=>frob})
         assert_not_nil(ra)
         assert_equal(1, RTM::API::params.keys.size)
      end
   end

# -------------------------------------------------------------------
# Auth
#
   def test_authGetFrob
      frob = RTM::API::Auth.getFrob
      assert_not_nil(frob)
      assert_equal(40, frob.length)
   end

=begin
   def test_authGetToken
      frob = @auth.getFrob
      assert_not_nil(frob)
      assert_equal(40, frob.length)

      ra = @base.uri_auth('read', frob)
      assert_not_nil(ra)

      puts 'auth this url : ' + 'http://' + RTM::RTM_URI + ra
      # @base.auth(ra)
      gets

      token = @auth.getToken(frob)
      assert_not_nil(token)
      p token
      assert_equal(40, token.length)
   end
=end

   def test_authCheckToken
      assert_raise(RTM::API::Error) {
         RTM::API::Auth.checkToken(TOKEN + 'a')
      }
      assert_nothing_raised {
         checked = RTM::API::Auth.checkToken(RTM::API.token)
         assert_not_nil(checked)
      }
   end

   def test_taskGetList
      tasks = RTM::API::Tasks.getList
      assert_not_nil(tasks)
   end

   # -----------------------------------------------------------------
   # Task.Notes
   #
   def test_taskNotesAdd
      list = RTM::API::Lists.getList.first
      taskSeries = RTM::Tasks.new(list['id'])[0]
      result = RTM::API::Tasks::Notes.add(
         timeline = RTM::API::TimeLines.create,
         list['id'],
         taskSeries.id,
         taskSeries.task.first.id,
         'testing Note title',
         'testing Note body')

      assert_equal('ok', result['stat'])
      note_id = result['transaction'].first['id']
   end

   def test_taskNotesEdit
      list = RTM::API::Lists.getList.first
      taskSeries = RTM::Tasks.new(list['id'])[0]
      RTM::API::Tasks::Notes.add(
         timeline = RTM::API::TimeLines.create,
         'testing Note title',
         'testing Note body')
   end

=begin
   def test_testEcho
      @test.echo
   end

   def test_testLogin
      @test.login
   end

   def test_getList
      @lists.get
   end
=end

# -------------------------------------------------------------------
# API test
#
   def test_api_init
      RTM::API.init(:key => KEY)

      assert_equal(KEY, RTM::API.key)
   end

# -------------------------------------------------------------------
# TimeLines API test
#
   def test_timelines_create
      timeline = RTM::API::TimeLines.create
      assert_not_nil(timeline)
   end
end
