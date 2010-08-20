#
# rtm.auth : Auth API
#
module RTM
module Auth

class GetFrob < RTM::API
   # return frob
   def parse_result(result)
      super
      result['frob'].first
   end

   def initialize
      super 'rtm.auth.getFrob'
   end
end # GetFrob

class GetToken < RTM::API
   # return {:token, :perms, :user => {id, name, fullname}}
   def parse_result(result)
      super
      Auth.parse_result_auth(result)
   end

   def initialize(frob)
      super 'rtm.auth.getToken'
      @param = {:frob => frob}
   end
end # GetToken

class CheckToken < RTM::API
   # return {:token, :perms, :user => {id, name, fullname}}
   def parse_result(result)
      super
      Auth.parse_result_auth(result)
   end

   def initialize(token)
      super 'rtm.auth.checkToken'
      @param = {:auth_token => token}
   end
end # CheckToken

private
# return {:token, :perms, :user => {id, name, fullname}}
def Auth.parse_result_auth(result)
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
end

end # Auth
end # RTM
# vim:fdm=indent
