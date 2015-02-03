#
# tests for RTM::Auth API.
#

require File.dirname(__FILE__) + '/test_helper.rb'

class RTMAuthAPITest < Test::Unit::TestCase
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
      frob = RTM::Auth::GetFrob.new.invoke
      assert_equal(40, frob.length)
      return frob
   end

   def get_token(frob)
      res = RTM::Auth::GetToken.new(frob).invoke
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

   def test_invalidToken
      assert_raise(RTM::Error) {
         RTM::Auth::GetToken.new('detarame').invoke
      }
   end

   # this test requires user authentication manually, so disabed normally.
   def not_test_getToken
      get_token_interactive
   end

   # this test requires user authentication manually, so disabed normally.
   def not_test_checkToken
      token = get_token_interactive

      auth = RTM::Auth::CheckToken.new(token).invoke
      assert_equal(@perms, auth[:perms])
   end
end
# vim:fdm=indent
