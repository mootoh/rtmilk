#
# make config.dat to store API_KEY, SHARED_SECRET, TOKENs.
#
require File.dirname(__FILE__) + '/test_helper.rb'

CONFIG = File.dirname(__FILE__) + '/../config.dat' # config data file

# if file exists, exit
if FileTest.readable?(CONFIG)
   exit
end

done = false

def getToken(perms, frob)
   url = RTM::API.get_auth_url(perms, frob)
   puts "follow this link to acqure token (#{perms}) : " + url
   puts ', then press enter here.'
   gets

   res = RTM::Auth::GetToken.new(frob).invoke
   return res[:token]
end

fh = open(CONFIG, 'w')
begin
   hash = {}
   puts 'Enter your API key.'
   hash[:key] = gets.chomp

   puts 'Enter your shared secret.'
   hash[:sec] = gets.chomp

   RTM::API.init(hash[:key], hash[:sec])

   # get a frob
   frob = RTM::Auth::GetFrob.new.invoke
   puts 'acquired frob : ' + frob

   #
   # choose permission
   #
   puts 'choose permission: [R]ead, [W]rite, or [D]elete .'
   selected = gets.chomp

   perms = {
      'r' => 'read',
      'R' => 'read',
      'w' => 'write',
      'W' => 'write',
      'd' => 'delete',
      'D' => 'delete' }

   #
   # get tokens
   #
   token = getToken(perms[selected], frob)
   hash[:token] = token

   puts 'acquired token is ' + token

   #
   # save
   #
   Marshal.dump(hash, fh)
   puts 'all done !!!'
   puts "your informations stored to #{CONFIG}."
   done = true
ensure
   fh.close

   unless done
      File.unlink(CONFIG)
   end
end
