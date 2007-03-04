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
   RTM_URI   = 'www.rememberthemilk.com'
   REST_PATH = '/services/rest/'
   AUTH_PATH = '/services/auth/'
   PERMS = ['read', 'write', 'delete']

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

   # sign parameters
   def API.sign(param)
      sig = @@sec
      sig += param.collect { |k, v| [k, v].join('') }.sort.join('')
      Digest::MD5.hexdigest(sig)
   end

   def sign
      API.sign(@param)
   end

   # invoke a method
   def invoke
      sig = sign
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

=begin
   # tailor parameters into request uri.
   def API.uri_req(params)
      r  = REST_PATH + '?' 
      r += params.collect { |k, v| [k, v].join('=') }.sort.join('&')
      r += '&api_sig=' + sign(params)
      URI.escape r
   end

   # tailor parameters into auth uri.
   def API.uri_auth(params, h)
      p = params.dup
      p[:perms] = h[:perm]
      p[:frob]  = h[:frob] if h[:frob]
      p[:callback] = h[:callback] if h[:callback]

      r  = AUTH_PATH + '?'
      r += p.collect { |k, v| [k, v].join('=') }.sort.join('&')

      r += '&api_sig=' + sign(p)
      r
   end

   # construct auth uri from params.
   def API.auth_uri(params, h)
      RTM_URI + uri_auth(params, h)
   end

   # process http request, return response.
   def API.request(uri)
      head, body = @@http.get(uri)
      res = XmlSimple.new.xml_in(body)
      raise Error, res if 'fail' == res['stat']
      res
   end
=end
end # API

end # RTM
# vim:fdm=indent
