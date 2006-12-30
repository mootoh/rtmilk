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

class RTMAPITest < Test::Unit::TestCase
   KEY = 'aaa'   # XXX specify API key
   SEC = 'bbb'   # XXX specify shared secret
   FROB = 'ccc'  # XXX enter some frob
   TOKEN = 'ddd' # XXX enter some token

   def setup
      RTM::API.init(:key=>KEY, :secret=>SEC, :frob=>FROB, :token=>TOKEN)
      # @base  = RTM::API.new(KEY, SIG)
      # @test  = RTM::TestAPI.new(KEY, SIG)
      # @auth  = RTM::AuthAPI.new(KEY, SIG)
      # @lists = RTM::ListsAPI.new(KEY, SIG)
      # @tasks = RTM::TasksAPI.new(KEY, SIG)
   end

   def test_init
      assert_equal(KEY, RTM::API.key)
      assert_equal(SEC, RTM::API.sec)
      assert_equal(FROB, RTM::API.frob)
      assert_equal(TOKEN, RTM::API.token)
      assert_equal(1, RTM::API.params.size)
   end

   def test_instance
      # assert_instance_of RTM::API, @base
      # assert_instance_of RTM::TestAPI, @test
      # assert_instance_of RTM::AuthAPI, @auth
      # assert_instance_of RTM::ListsAPI, @lists
      # assert_instance_of RTM::TasksAPI, @tasks
   end

# -------------------------------------------------------------------
# API
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
   end

   def test_uri_auth_frob
      frob = RTM::API::Auth.getFrob(RTM::API.params)
      assert_not_nil(frob)
      assert_equal(40, frob.length)

      ra = RTM::API.uri_auth(RTM::API.params, 'read', frob)
      assert_not_nil(ra)
      assert_equal(1, RTM::API.params.keys.size)
   end

# -------------------------------------------------------------------
# Auth
#
   def test_authGetFrob
      frob = RTM::API::Auth.getFrob(RTM::API.params)
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
         RTM::API::Auth.checkToken(RTM::API.params, TOKEN + 'a')
      }
      assert_nothing_raised {
         checked = RTM::API::Auth.checkToken(RTM::API.params, TOKEN)
      }
   end

   def test_taskGetList
      tasks = RTM::API::Tasks.get(RTM::API.params, TOKEN)
      p tasks
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
end
