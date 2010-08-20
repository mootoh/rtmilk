#
# simple example for rtm.rb
$LOAD_PATH << File.dirname(__FILE__) + '/../lib'
require 'rtmilk'

# -------------------------------------------------------------------
# API_KEY and SHARED_SECRET are required.
#
API_KEY       = 'aaa'
SHARED_SECRET = 'bbb'

RTM::API.init(API_KEY, SHARED_SECRET)

# -------------------------------------------------------------------
# get auth url for read
#
frob = RTM::Auth::GetFrob.new.invoke
url = RTM::API.get_auth_url('read', frob)

puts 'access, login, and authenticate following uri on your browser,'
puts 'then hit return to continue'
puts '  ' + url

gets


res = RTM::Auth::GetToken.new(frob).invoke
token = res[:token]
RTM::API.token = token

# -------------------------------------------------------------------
# get all lists
#
#
lists = RTM::List.alive_all
lists.each { |l| puts l['name'] }

# -------------------------------------------------------------------
# get all tasks
#
#tasks = RTM::Tasks.new
#tasks.each { |t| puts t.name }

