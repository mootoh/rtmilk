#
# for Remember the Milk REST API
#     http://www.rememberthemilk.com/services/api/overview.rtm
#
# $Id: api.rb 566 2006-12-29 16:17:07Z takayama $
#

require 'net/http'
require 'digest/md5'
require 'rubygems'
require 'xmlsimple'

=begin rdoc
access Remember the Milk REST APIs.
=end
module RTM

=begin rdoc
API classes.
=end
class API
   RTM_URI   = 'www.rememberthemilk.com'
   REST_PATH = '/services/rest/'
   AUTH_PATH = '/services/auth/'

=begin rdoc
   Exception class, takes msg and code.
=end
   class Error < StandardError
      def initialize(hash)
         err = hash['err'].first
         @code = err['code'].to_i
         msg = err['msg'] + ' (error code=' + err['code'] + ')'
         super(msg)
      end
   end

   def API.init(h)
      @@key = h[:key] if h.has_key? :key
      @@sec = h[:secret] if h.has_key? :secret
      @@frob = h[:frob] if h.has_key? :frob
      @@token = h[:token] if h.has_key? :token

      @@params = { 'api_key' => @@key }
      @@http = Net::HTTP.new(RTM_URI)
   end

   def API.key
      @@key
   end

   def API.sec
      @@sec
   end

   def API.frob
      @@frob
   end

   def API.token
      @@token
   end

   def API.params
      @@params
   end

=begin rdoc
      sign parameters.
=end
   def API.sign(params)
      sig = @@sec
      sig += params.collect { |k, v| [k, v].join('') }.sort.join('')
      sig = Digest::MD5.hexdigest(sig)
   end

=begin rdoc
tailor parameters into request uri.
=end
   def API.uri_req(params)
      r  = REST_PATH + '?' 
      r += params.collect { |k, v| [k, v].join('=') }.sort.join('&')
      r += '&api_sig=' + sign(params)
      r
   end

=begin rdoc
tailor parameters into auth uri.
=end
   def API.uri_auth(params, perms, frob=nil)
      p = params.dup
      p['perms'] = perms

      p['frob'] = frob if frob

      r  = AUTH_PATH + '?'
      r += p.collect { |k, v| [k, v].join('=') }.sort.join('&')

      r += '&api_sig=' + sign(p)
      r
   end

   def API.auth_uri(params, perms)
      RTM_URI + uri_auth(params, perms)
   end

=begin rdoc
process http request, return response
=end
   def API.request(uri)
      head, body = @@http.get(uri)
      res = XmlSimple.new.xml_in(body)
      raise Error, res if 'fail' == res['stat']
      res
   end

   # ---------------------------------------------------------------
   # subclasses
   #

=begin rdoc
rtm.auth API.
=end
   class Auth
      METHOD = 'rtm.auth'

      def Auth.checkToken(params, token)
         p = params.dup
         p['method'] = METHOD + '.checkToken'
         p['auth_token'] = token
         res = API.request(API.uri_req(p))
      end

      def Auth.getFrob(params)
         p = params.dup
         p['method'] = METHOD + '.getFrob'

         res = API.request(API.uri_req(p))
         res['frob'].first
      end

      def getToken(frob)
         params_orig = @params.dup
         begin
            @params['method'] += '.getToken'
            @params['frob'] = frob

            res = request(uri_req)
            res['auth'].first['token'].first
         ensure
            @params = params_orig
         end
      end
   end # AuthAPI

   class ConcatcsAPI < API
   end # ConcatcsAPI

   class GroupsAPI < API
   end # GroupsAPI

   class Lists
      METHOD = 'rtm.lists'

      def Lists.get(params, token, alive_only=true)
         p = params.dup
         p['method'] = METHOD + '.getList'
         p['auth_token'] = token

         res = API.request(API.uri_req(p))
         lists = res['lists'].first['list']

         if alive_only
            lists.collect { |l| l if l['deleted'] == '0' }.compact
         else
            lists
         end
      end
   end # ListsAPI

   class ReflectionAPI < API
   end # ReflectionAPI

   class SettingsAPI < API
   end # SettingsAPI

   class Tasks
      METHOD = 'rtm.tasks'

      def Tasks.get(params, token, list=nil, last_sync=nil)
         p = params.dup

         p['method'] = METHOD + '.getList'
         p['auth_token'] = token
         p['list_id'] = list if list
         p['last_sync'] = last_sync if last_sync

         res = API.request(API.uri_req(p))
         res['tasks'].first['list']
      end

      class Notes
      end # Notes
   end # TasksAPI

   class TestAPI < API
      METHOD = 'rtm.test'

      def initialize(k, s)
         @k = k
         @s = s
         @http = Net::HTTP.new(RTM_URI)
      end

      def echo
         req = REST_PATH + '?method=' + METHOD + '.echo' + '&api_key=' + @k
         puts req

         r, b = @http.get(req)
         puts r
         puts b
      end

      def login
         params = {
            'method' => METHOD + '.login',
            'api_key' => @k
         }

         sig = @s
         sig += params.collect { |k, v| [k, v].join('') }.sort.join('')
         puts "sig = " + sig
         sig = Digest::MD5.hexdigest(sig)
         puts "hexed sig = " + sig

         req = REST_PATH + '?' 
         req += params.collect { |k, v| [k, v].join('=') }.sort.join('&')
         req += "&api_sig=" + sig

         puts "\n"
         puts "req = " + req

         r, b = @http.get(req)
         puts r
         puts b
      end
   end # TestAPI

   class TimeAPI < API
   end # TimeAPI

   class TimeLinesAPI < API
   end # TimeLinesAPI

   class TimeZonesAPI < API
   end # TimeZonesAPI

   class TransactionsAPI < API
   end # TransactionsAPI

end # API

end # RTM