#
# for Remember the Milk REST API
#     http://www.rememberthemilk.com/services/api/overview.rtm
#
# $Id: api.rb 11 2007-01-08 04:02:44Z takayama $
#

require 'net/http'
require 'digest/md5'
require 'rubygems'
require 'xmlsimple'
require 'uri'

# access the {Remember the Milk}[http://www.rememberthemilk.com/] REST APIs.
module RTM

# API classes.
class API
   RTM_URI   = 'www.rememberthemilk.com'
   REST_PATH = '/services/rest/'
   AUTH_PATH = '/services/auth/'

   PERMS = ['read', 'write', 'delete']

   #--
   # -----------------------------------------------------------------
   # class methods
   #++
   
   def API.key ; @@key ; end
   def API.params ; @@params ; end
   def API.token ; @@token ; end

   # initialize the API context.
   # make sure to call this before using any API calls.
   def API.init(h)
      @@key = h[:key] if h.has_key? :key
      @@sec = h[:secret] if h.has_key? :secret
      @@frob = h[:frob] if h.has_key? :frob
      @@token = h[:token] if h.has_key? :token

      @@params = { 'api_key' => @@key }
      @@http = Net::HTTP.new(RTM_URI)
   end

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

   private

   # sign parameters.
   def API.sign(params)
      sig = @@sec
      sig += params.collect { |k, v| [k, v].join('') }.sort.join('')
      sig = Digest::MD5.hexdigest(sig)
   end
end # API

#--
# ---------------------------------------------------------------
# subclasses
#++

class API
   # Exception class, takes msg and code.
   class Error < StandardError
      def initialize(h)
         err = h['err'].first
         @code = err['code'].to_i
         msg = err['msg'] + ' (error code=' + err['code'] + ')'
         super(msg)
      end
   end

   # rtm.auth API.
   class Auth
      METHOD = 'rtm.auth'

      # see spec[http://www.rememberthemilk.com/services/api/methods/rtm.auth.checkToken.rtm].
      def Auth.checkToken(token)
         p = API.params.dup
         p['method'] = METHOD + '.checkToken'
         p['auth_token'] = token
         res = API.request(API.uri_req(p))
      end

      # see spec[http://www.rememberthemilk.com/services/api/methods/rtm.auth.getFrob.rtm].
      def Auth.getFrob
         p = API.params.dup
         p['method'] = METHOD + '.getFrob'

         res = API.request(API.uri_req(p))
         res['frob'].first
      end

      # see {spec}[http://www.rememberthemilk.com/services/api/methods/rtm.auth.getToken.rtm].
      def Auth.getToken(frob)
         p = API.params.dup
         p['method'] = METHOD + '.getToken'
         p['frob']   = frob

         res = API.request(API.uri_req(p))
         res['auth'].first['token'].first
      end
   end # Auth

   class Contacts
      def Contacts.add
      end

      def Contacts.delete
      end

      def Contacts.getList
      end
   end # Contacts

   class Groups
      def Groups.add
      end

      def Groups.addContact
      end

      def Groups.delete
      end

      def Groups.getList
      end

      def Groups.removeContact
      end
   end # Groups

   class Lists
      METHOD = 'rtm.lists'

      def Lists.add(timeline, name, filter=nil)
         p = API.params.dup
         p['method'] = METHOD + '.add'
         p['auth_token'] = API.token
         p['timeline'] = timeline
         p['name'] = name
         p['filter'] = filter if filter

         res = API.request(API.uri_req(p))
      end

      def Lists.archive
      end

      def Lists.getList(alive_only=true)
         p = API.params.dup
         p['method'] = METHOD + '.getList'
         p['auth_token'] = API.token

         res = API.request(API.uri_req(p))
         lists = res['lists'].first['list']

         if alive_only
            lists.collect { |l| l if l['deleted'] == '0' }.compact
         else
            lists
         end
      end

      def Lists.setDefaultList
      end

      def Lists.setName
      end

      def Lists.unarchive
      end
   end # Lists

   class Reflection
      def Reflection.getMethodInfo
      end

      def Reflection.getMethods
      end
   end # Reflection

   class Settings
      def Settings.getList
      end
   end # Settings

   class Tasks
      METHOD = 'rtm.tasks'

      def Tasks.add(timeline, list, name)
         p = API.params.dup
         p['method'] = METHOD + '.add'
         p['auth_token'] = API.token
         p['timeline'] = timeline
         p['name'] = name
         p['list_id'] = list

         res = API.request(API.uri_req(p))
         res['list'].first['taskseries'].first
      end

      def Tasks.addTags
      end

      def Tasks.complete
      end

      def Tasks.delete(timeline, list, series, task)
         p = API.params.dup
         p['method'] = METHOD + '.delete'
         p['auth_token'] = API.token
         p['timeline'] = timeline
         p['list_id'] = list
         p['taskseries_id'] = series
         p['task_id'] = task

         res = API.request(API.uri_req(p))
         res['list'].first['taskseries'].first
      end

      def Tasks.getList(list=nil, last_sync=nil)
         p = API.params.dup

         p['method'] = METHOD + '.getList'
         p['auth_token'] = API.token
         p['list_id'] = list if list
         p['last_sync'] = last_sync if last_sync

         res = API.request(API.uri_req(p))
         res['tasks'].first['list']
      end

      def Tasks.moveProiority
      end

      def Tasks.moveTo
      end

      def Tasks.postpone
      end

      def Tasks.removeTags
      end

      def Tasks.setDueDate
      end

      def Tasks.setEstimate
      end

      def Tasks.setName
      end

      def Tasks.setPriority
      end

      def Tasks.setRecurrence
      end

      def Tasks.setTags
      end

      def Tasks.setURL
      end

      def Tasks.uncomplete
      end

      class Notes
         METHOD = 'rtm.tasks.notes'
=begin
api_key (Required)
    Your API application key. See here for more details.
timeline (Required)
    The timeline within which to run a method. See here for more details.
list_id (Required)
    The id of the list to perform an action on.
taskseries_id (Required)
    The id of the task series to perform an action on.
task_id (Required)
    The id of the task to perform an action on.
note_title (Required)
    The title of a note.
note_text (Required)
    The body of a note. 
=end
         def Notes.add(timeline, list, series, task, title, text)
            p = API.params.dup
            p['method'] = METHOD + '.add'
            p['auth_token'] = API.token

            p['timeline'] = timeline
            p['list_id'] = list
            p['taskseries_id'] = series
            p['task_id'] = task
            p['note_title'] = title
            p['note_text'] = text

            res = API.request(API.uri_req(p))
         end

         def Notes.delete(timeline, note)
            p = API.params.dup
            p['method'] = METHOD + '.delete'
            p['auth_token'] = API.token

            p['timeline'] = timeline
            p['note_id'] = note

            res = API.request(API.uri_req(p))
         end

         def Notes.edit(timeline, note, title, text)
            p = API.params.dup
            p['method'] = METHOD + '.edit'
            p['auth_token'] = API.token

            p['timeline'] = timeline
            p['note_id'] = note
            p['note_title'] = title
            p['note_text'] = text

            res = API.request(API.uri_req(p))
         end
      end # Notes
   end # Tasks

   class Test # TODO
      METHOD = 'rtm.test'

      def Test.echo # TODO
         req = REST_PATH + '?method=' + METHOD + '.echo' + '&api_key=' + @k
         puts req

         r, b = @http.get(req)
         puts r
         puts b
      end

      def Test.login # TODO
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
   end # Test

   class Time # TODO
      def Time.convert # TODO
      end

      def Time.parse # TODO
      end
   end # Time

   class TimeLines
      METHOD = 'rtm.timelines'

      def TimeLines.create
         p = API.params.dup
         p['method'] = METHOD + '.create'
         p['auth_token'] = API.token

         res = API.request(API.uri_req(p))
         t = res['timeline'].first
      end
   end # TimeLines

   class TimeZones # TODO
      def TimeZones.getList
      end
   end # TimeZones

   class Transactions
      def Transactions.undo
      end
   end # Transactions
end # API

end # RTM
# vim:fdm=indent
