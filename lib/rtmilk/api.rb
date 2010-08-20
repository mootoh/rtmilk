#
# for Remember the Milk REST API
#     http://www.rememberthemilk.com/services/api/overview.rtm
#

require 'net/http'
require 'digest/md5'
require 'rubygems'
require 'xmlsimple'
require 'uri'

# access the {Remember the Milk}[http://www.rememberthemilk.com/] REST APIs.
module RTM

# API class
class API

private
   RTM_URI   = 'www.rememberthemilk.com'
   REST_PATH = '/services/rest/'
   AUTH_PATH = '/services/auth/'
   PERMS = ['read', 'write', 'delete']

public
   # initialize the API context.
   def API.init(key, sec, option=nil)
      @@key = key
      @@sec = sec

      if (option)
         begin
            @@token = option[:token] if option.has_key? :token
         rescue => e
            puts e.message
         end
      end

   end

   def API.token=(token)
      @@token = token
   end

   # getter methods
   def API.key; @@key; end
   def API.token; @@token; end

   # invoke a method
   def invoke
      response = Net::HTTP.get(RTM_URI, make_url)
      # puts '--------------------------------------------------'
      # puts response
      # puts '--------------------------------------------------'
      result = XmlSimple.new.xml_in(response)
      ret = parse_result(result)
   end

   # get Auth URL (both desktop/webapp)
   def API.get_auth_url(perms, frob=nil)
      param = { :api_key => @@key, :perms => perms }
      if frob
         param['frob'] = frob
      end

      sig = API.sign(param)

      r  = 'http://' + RTM_URI + AUTH_PATH + '?'
      r += param.collect { |k, v| [k, v].join('=') }.sort.join('&')
      r += '&api_sig=' + sig
      r
   end

   def sign
      API.sign(@param)
   end

private
   # sign parameters
   def API.sign(param)
      sig = @@sec
      sig += param.collect { |k, v| [k, v].join('') }.sort.join('')
      Digest::MD5.hexdigest(sig)
   end

   def initialize(method, token=nil, timeline=nil)
      @method   = method
      @token    = token ? token : nil
      @timeline = timeline ? timeline : nil
      @param = {}
   end

   def make_url
      r  = REST_PATH + '?' 

      @param = {} if @param == nil
      @param['method'] = @method
      @param['auth_token'] = @token unless @token == nil
      @param['timeline'] = @timeline unless @timeline == nil
      @param['api_key'] = @@key
      r += @param.collect { |k, v| [k, v].join('=') }.sort.join('&')
      r += '&api_sig=' + sign
      URI.escape r
   end

protected
   # parse result
   def parse_result(result)
      unless result['stat'] == 'ok'
         raise RTM::Error, result['err'].first['msg']
      end
   end
end # API

end # RTM
require 'rtmilk/api/auth'
require 'rtmilk/api/timelines'
require 'rtmilk/api/lists'
require 'rtmilk/api/tasks'
require 'rtmilk/api/notes'

# vim:fdm=indent
