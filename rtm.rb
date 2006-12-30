#
# for Remember the Milk REST API
#     http://www.rememberthemilk.com/services/api/overview.rtm
#
# $Id: rtm.rb 565 2006-12-29 16:06:13Z takayama $
#

require 'net/http'
require 'digest/md5'
require 'rubygems'
require 'xmlsimple'
require 'lib/api.rb'

=begin rdoc
access Remember the Milk REST APIs.
=end
module RTM
   class Contact
      attr_accessor :id, :fullname, :username

      def initialize(id, full=nil, user=nil)
         @id = id
         @fullname = full
         @user = user
      end
   end # Contact

   class Group
      attr_accessor :id, :name
   end # Group

   class List
      attr_accessor :id, :name, :deleted, :locked, :archived, :position, :smart, :filter

      def initialize(h)
         @id = h['id']
         @name = h['name']
         @deleted = h['deleted'] == '0'
         @locked = h['locked'] == '1'
         @archived = h['archived'] == '1'
         @position = h['position']
         @smart = h['smart'] == '1'
         @filter = h['filter']
      end

      def setDefault
      end # setDefault

      def setName(name)
      end # setName

      def archive
      end # archive

      def unarchive
      end # unarchive

      def <=>(other)
         @name <=> other.name
      end
   end # List

   class Lists
      include Enumerable

      attr_accessor :ls

      def initialize
         @ls = API::Lists.get(API.params, API.token).collect do |x|
            List.new x
         end
      end

      def each
         @ls.each do |x|
            yield x
         end
      end

      def add(name, filter)
      end # add
   end # Lists

   class TaskSeries
      attr_accessor :id, :created, :modified, :name, :source,
         :tags, :participants, :notes, :task

      def initialize(h)
         @id = h['id'] if h['id']
         @created = h['created'] if h['created']
         @modified = h['modified'] if h['modified']
         @name = h['name'] if h['name']
         @source = h['source'] if h['source']
         @tags = h['tags'].first if h['tags']
         @participants = h['participants'].first if h['participants']
         @notes = h['notes'].first if h['notes']

         if h['task']
            @task = h['task'].collect do |t|
               Task.new(t)
            end.flatten.compact
         end
      end

      class Task
         attr_accessor :id, :due, :has_due_time, :added, :completed,
            :deleted, :priority, :postponed, :estimate

         def initialize(h)
            @id = h['id'] if h['id']
            @due = h['due'] if h['due']
            @has_due_time = h['has_due_time'] == '1' if h['has_due_time']
            @added = h['added'] if h['added']
            @completed = h['completed'] if h['completed']
            @deleted = h['deleted'] if h['deleted']
            @priority = h['priority'] if h['priority']
            @postponed = h['postponed'] if h['postponed']
            @estimate = h['estimate'] if h['estimate']
         end
      end # Task
   end

   class Tasks
      include Enumerable

      attr_accessor :ts

      def initialize(list=nil, last=nil)
         @ts = API::Tasks.get(API.params, API.token, list, last).collect do |x|
            if x['taskseries']
               x['taskseries'].collect do |t|
                  TaskSeries.new t
               end
            else
               nil
            end
         end.flatten.compact
      end

      def each
         @ts.each do |x|
            yield x
         end
      end

      def [](i)
         to_a[i]
      end

      def size
         to_a.size
      end

   end # Tasks

end # RTM