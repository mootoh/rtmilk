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

# API module
module API

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

      @@http = Net::HTTP.new(RTM_URI)
   end

   # getter methods
   def API.key; @@key; end

   # invoke a method
   def invoke
      head, body = @@http.get(make_url)
      puts '--------------------------------------------------'
      puts body
      puts '--------------------------------------------------'
      result = XmlSimple.new.xml_in(body)
      response, err = parse_result(result)
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

   def make_url
      r  = REST_PATH + '?' 

      @param = {} unless @param
      @param['method'] = @method
      @param['api_key'] = @@key
      r += @param.collect { |k, v| [k, v].join('=') }.sort.join('&')
      r += '&api_sig=' + sign
      URI.escape r
   end
end # API

end # RTM
require 'rtmilk/api/auth'

# vim:fdm=indent
