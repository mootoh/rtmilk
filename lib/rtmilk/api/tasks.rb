#
# rtm.tasks : Tasks API
#
require 'test/unit/assertions'
module RTM
module Tasks

# get all TaskSeries.
class GetList < RTM::API
   # return [list_id, taskseries*]*
   def parse_result(result)
      super
      result['tasks'].first['list']
   end

   def initialize(token, list_id=nil, filter=nil, last_sync=nil)
      super 'rtm.tasks.getList', token
      @param[:list_id] = list_id if list_id
      @param[:filter] = filter if filter
      @param[:last_sync] = last_sync if last_sync
   end
end # GetList

class Add < RTM::API
   def parse_result(result)
      super
      [result['list'].first, result['transaction']]
   end

   def initialize(token, timeline, list, name)
      super 'rtm.tasks.add', token
      @token  = token
      @param[:timeline] = timeline
      @param[:list_id] = list
      @param[:name] = name
   end
end # Add

class Delete < RTM::API
   def parse_result(result)
      super
      [result['list'].first, result['transaction']]
   end

   def initialize(token, timeline, list, taskseries, task)
      super 'rtm.tasks.delete', token
      @param[:timeline] = timeline
      @param[:list_id] = list
      @param[:taskseries_id] = taskseries
      @param[:task_id] = task
   end
end # Delete

end # Tasks


#
# Task class.
# Unfortunately, RTM API defines this object as TaskSeries.
# That seemes to be unnatural.
class Task
   attr_reader :list, :chunks, :notes

   include Test::Unit::Assertions

   def name; @taskseries['name']; end
   def id; @taskseries['id']; end
   def modified; @taskseries['modified']; end
   def tags; @taskseries['tags']; end
   def participants; @taskseries['participants']; end
   def url; @taskseries['url']; end
   def created; @taskseries['created']; end
   def source; @taskseries['source']; end

   # find a Task by name.
   def Task.find(arg)
      all_tasks(arg[:list]).find do |task|
         task.name =~ /#{arg[:name]}/
      end
   end

   # find all tasks by list, and name
   def Task.find_all(arg)
      tasks = all_tasks(arg[:list])
      if arg.has_key? :name
         tasks.find_all do |task|
            task['name'] =~ /#{arg[:name]}/
         end
      else
         tasks
      end
   end

private
   def Task.all_tasks(list = nil)
      result = RTM::Tasks::GetList.new(RTM::API.token, list).invoke
      ret = []

      result.each do |x|
         if x.has_key? 'taskseries'
            x['taskseries'].each do |y|
               ret.push Task.new(:taskseries => y, :list => x['id'])
            end
         end
      end
      ret
   end

public
   # create a Task.
   def initialize(arg)
      assert_equal(Hash, arg.class)

      @list = if arg.has_key? :list
         arg[:list]
      else
         RTM::List.inbox['id']
      end

      if arg.has_key? :name  # create from scratch
         result,transaction = RTM::Tasks::Add.new(
            RTM::API.token,
            RTM::Timeline.new(RTM::API.token).to_s,
            @list, arg[:name]).invoke
         @taskseries = result['taskseries'].first
         assert(@list, result['id'])
         create_chunks
         @notes = []
      else 
         assert(arg.has_key?(:taskseries))
         @taskseries = arg[:taskseries]
         create_chunks
         create_notes
      end
   end

   # delete a Task and its all chunks.
   def delete
      chunks.collect { |chunk| chunk.delete(id, @list) }
   end

   def addNote(arg)
      assert_equal(Hash, arg.class)

      n = RTM::Note.new(
         :task => self,
         :title => arg[:title], 
         :body  => arg[:body])
      @notes.push n
   end

private
   def create_chunks
      @chunks = []
      @taskseries['task'].each do |t|
         @chunks.push Chunk.new(t)
      end
   end

   def create_notes
      @notes = []
      assert_equal(Array, @taskseries['notes'].class)
      assert_equal(Hash, @taskseries['notes'].first.class)
      if @taskseries['notes'].first.has_key? 'note'
         @taskseries['notes'].first['note'].each do |n|
            @notes.push Note.new(:hash => n)
         end
      end
   end
end # Task

# correspond to each Task.
class Chunk
   def completed; @hash['completed']; end
   def added; @hash['added']; end
   def postponed; @hash['postponed']; end # TODO
   def priority; @hash['priority']; end
   def id; @hash['id']; end
   def deleted; @hash['deleted']; end
   def has_due_time; @hash['has_due_time'] == '1' ; end
   def estimate; @hash['estimate']; end
   def due; @hash['due']; end

   def initialize(hash)
      @hash = hash
   end

   def delete(series, list)
      token    = RTM::API.token
      timeline = RTM::Timeline.new(RTM::API.token).to_s
      RTM::Tasks::Delete.new(token, timeline, list, series, id).invoke # TODO
   end
end # Chunk

end # RTM
# vim:fdm=indent
