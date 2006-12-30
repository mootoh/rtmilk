#
# simple example for rtm.rb
#
# $Id$
#
#
$LOAD_PATH << File.dirname(__FILE__) + '/..'
require 'rtm'

# -------------------------------------------------------------------
# API_KEY and SHARED_SECRET are required.
#
API_KEY       = 'aaa'
SHARED_SECRET = 'bbb'

RTM::API.init(:key => API_KEY, :secret => SHARED_SECRET)

# -------------------------------------------------------------------
# get auth url for read
#
frob = RTM::get_frob
uri = RTM::get_auth_url(:perm => 'read', :frob => frob)

puts 'access, login, and authenticate following uri on your browser,'
puts 'then hit return to continue'
puts '  http://' + uri

gets

token = RTM::API::Auth.getToken(frob)
RTM::API.init(:token => token)

# -------------------------------------------------------------------
# get all lists
#
lists = RTM::Lists.new
lists.each { |l| puts l.name }

# -------------------------------------------------------------------
# get all tasks
#
tasks = RTM::Tasks.new
tasks.each { |t| puts t.name }

