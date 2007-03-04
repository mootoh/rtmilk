#
# tests for RTM::Auth API.
#
# see http://d.hatena.ne.jp/secondlife/20060927/1159334813
#

require File.dirname(__FILE__) + '/test_helper.rb'

class RTMAuthAPITest < Test::Unit::TestCase
   CONFIG = File.dirname(__FILE__) + '/../config.dat' # config data file

   KEY   = 'aaa' # XXX specify API key
   SEC   = 'bbb' # XXX specify shared secret
   TOKEN = 'ccc' # XXX specify obtained token

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

      RTM::API.init(conf[:key], conf[:sec], conf)
      @perms = 'read'
   end

   def teardown
   end

   # -----------------------------------------------------------------
   # helper
   #
   def prompt_for_auth(url)
      puts 'authorize this url : ' + url
      puts 'then, push enter here.'
      gets
   end

   def get_frob
      frob, err = RTM::Auth::GetFrob.new.invoke
      assert_equal('ok', err)
      assert_equal(40, frob.length)
      return frob
   end

   def get_token(frob)
      res, err = RTM::Auth::GetToken.new(frob).invoke
      assert_equal('ok', err)
      assert_equal(40, res[:token].length)
      assert_equal(@perms, res[:perms])
      return res[:token]
   end

   def get_token_interactive
      frob = get_frob
      url = RTM::API.get_auth_url(@perms, frob)
      prompt_for_auth(url)

      get_token(frob)
   end


   # -----------------------------------------------------------------
   # tests
   #
   def test_getFrob
      get_frob
   end

   # this test requires user authentication manually, so disabed normally.
   # def test_getToken
   def not_test_getToken
      get_token_interactive
   end

   def test_checkToken
      token = get_token_interactive

      auth, err = RTM::Auth::CheckToken.new(token).invoke
      assert_equal('ok', err)
      assert_equal(@perms, auth[:perms])
   end
end
# vim:fdm=indent
