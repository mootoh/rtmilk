#
# rtm.auth : Auth API
#
module RTM
module Auth

class GetFrob
   include API

   # return [frob, err]
   def parse_result(result)
      if result['stat'] == 'ok'
         [result['frob'].first, result['stat']]
      else
         [result['err'].first['msg'], result['stat']]
      end
   end

   def initialize
      @method = 'rtm.auth.getFrob'
   end
end # GetFrob

class GetToken
   include API

   # return [{:token, :perms, :user => {id, name, fullname}}, err]
   def parse_result(result)
      Auth.parse_result_auth(result)
   end

   def initialize(frob)
      @method = 'rtm.auth.getToken'
      @param = {:frob => frob}
   end
end # GetToken

class CheckToken
   include API

   # return [{:token, :perms, :user => {id, name, fullname}}, err]
   def parse_result(result)
      Auth.parse_result_auth(result)
   end

   def initialize(token)
      @method = 'rtm.auth.checkToken'
      @param = {:auth_token => token}
   end
end # CheckToken

private
# return [{:token, :perms, :user => {id, name, fullname}}, err]
def Auth.parse_result_auth(result)
   stat = result['stat']

   if 'ok' == stat
      auth = result['auth'].first
      user = auth['user'].first
      parsed = {
         :token => auth['token'].first,
         :perms => auth['perms'].first,
         :user  => {
            :id => user['id'],
            :name => user['username'],
            :fullname => user['fullname'] }
      }
      [parsed, stat]
   else
      [result['err'].first['msg'], stat]
   end
end

end # Auth
end # RTM
# vim:fdm=indent
