require 'rtm'

CONFIG = 'config.dat' # config data file

conf = Marshal.load(open(CONFIG))
RTM::API.init(conf)

# lists = RTM::Lists.new
# lists.each { |l| puts [l.id, l.name].join(' : ') }

tasks = RTM::Tasks.new(ARGV.shift)
tasks.each do |t|
   t.task.each do |x|
      puts ['□', t.name].join(' ') if x.completed == ''
   end
end
