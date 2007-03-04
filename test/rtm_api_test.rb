#
# tests for RTM::API.
#
# see http://d.hatena.ne.jp/secondlife/20060927/1159334813
#

require File.dirname(__FILE__) + '/test_helper.rb'

# fake class
class TestAPI
   include RTM::API

   def initialize
      @method = 'rtm.test.echo'
      @param = {'method' => @method}
   end

   def parse_result(result)
      [result['method'].first, result['stat']]
   end
end # TestAPI

class RTMAPITest < Test::Unit::TestCase
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
   end

   def teardown
   end

   def test_get_auth_url
      def check_include(url)
         assert_equal(0, url =~ /http:\/\//)
         assert_equal(7, url =~ /www\.rememberthemilk\.com/)
         assert_not_nil(url =~ /api_key/)
         assert_not_nil(url =~ /perms/)
         assert_not_nil(url =~ /api_sig/)
      end

      url = RTM::API.get_auth_url('read')
      check_include(url)

      url = RTM::API.get_auth_url('delete', 'asb')
      check_include(url)
      assert_not_nil(url =~ /frob/)

   end

   def test_sign
      tapi = TestAPI.new
      signed = tapi.sign
      assert_equal(32, signed.length)

      signed = RTM::API.sign({'method' => 'get'})
      assert_equal(32, signed.length)
   end

   def test_invoke
      tapi = TestAPI.new
      res, err = tapi.invoke
      assert_equal('rtm.test.echo', res)
      assert_equal('ok', err)
   end
end
# vim:fdm=indent
