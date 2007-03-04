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
      @aapi = RTM::AuthAPI.new
   end

   def teardown
   end

   def test_getFrob
   end

   def test_getToken
   end

   def test_checkToken
   end

end
# vim:fdm=indent
