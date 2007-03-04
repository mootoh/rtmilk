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
   end

   def teardown
   end

   def test_getFrob
      res, err = RTM::Auth::GetFrob.new.invoke
      assert_equal('ok', err)
      assert_equal(40, res.length)
   end

   # this test requires user authentication manually, so disabed normally.
   # def test_getToken
   def not_test_getToken
      perms = 'read'

      frob, err = RTM::Auth::GetFrob.new.invoke
      url = RTM::API.get_auth_url(perms, frob)
      puts 'authorize this url : ' + url
      puts 'then, push enter here.'
      gets

      res, err = RTM::Auth::GetToken.new(frob).invoke
      assert_equal('ok', err)
      assert_equal(40, res[:token].length)
      assert_equal(perms, res[:perms])
   end

   def test_checkToken
   end

end
# vim:fdm=indent
