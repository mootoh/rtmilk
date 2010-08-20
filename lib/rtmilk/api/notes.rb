#
# rtm.tasks.notes : Notes API
#
require 'test/unit/assertions'

module RTM
module Tasks
module Notes

class Add < RTM::API
   def parse_result(result)
      super
      [result['note'].first, result['transaction'].first]
   end

   def initialize(token, timeline, list, taskseries, task, title, text)
      super 'rtm.tasks.notes.add', token
      @param[:timeline] = timeline
      @param[:list_id] = list
      @param[:taskseries_id] = taskseries
      @param[:task_id] = task
      @param[:note_title] = title
      @param[:note_text] = text
   end
end # Add

class Delete < RTM::API
   def parse_result(result)
      super
   end

   def initialize(token, timeline, note)
      super 'rtm.tasks.notes.delete', token
      @param[:timeline] = timeline
      @param[:note_id] = note
   end
end # Delete

class Edit < RTM::API
   def parse_result(result)
      super
      [result['note'].first, result['transaction'].first]
   end

   def initialize(token, timeline, note, title, text)
      super 'rtm.tasks.notes.edit', token
      @param[:timeline] = timeline
      @param[:note_id] = note
      @param[:note_title] = title
      @param[:note_text] = text
   end
end # Add

end # Notes
end # Tasks

# = a Note.
#
# belongs to Task (TaskSeries).
#
# == usage:
# * n = RTM::Note.new(:task=>_task_, :title=>'yeah', :body=>'you')
# * n.title = 'newtitle'
# * n.body = 'newbody'
# * n.delete
#
class Note
   include Test::Unit::Assertions

   def id; @hash['id']; end
   def title; @hash['title']; end
   def modified; @hash['modified']; end
   def body; @hash['content']; end
   def created; @hash['created']; end

   def initialize(arg)
      assert_equal(Hash, arg.class)

      if arg.has_key? :hash # already constructed
         @hash = arg[:hash]
      else # from scratch
         assert(arg.has_key?(:task))
         assert_equal(RTM::Task, arg[:task].class)
         assert(arg.has_key?(:title))
         assert(arg.has_key?(:body))

         @hash, transaction = RTM::Tasks::Notes::Add.new(
            RTM::API.token, 
            RTM::Timeline.new(RTM::API.token).to_s,
            arg[:task].list, arg[:task].id,
            arg[:task].chunks.first.id, # XXX: Note belongs to TaskSeries, why need Task id ?
            arg[:title],
            arg[:body]).invoke
      end
   end

   # alter title field.
   def title=(text)
      ret, transaction = RTM::Tasks::Notes::Edit.new(
         RTM::API.token, 
         RTM::Timeline.new(RTM::API.token).to_s,
         id,
         text,
         body).invoke
      assert(ret['id'], id)
      @hash['title'] = text
   end

   # alter body field.
   def body=(text)
      ret, transaction = RTM::Tasks::Notes::Edit.new(
         RTM::API.token, 
         RTM::Timeline.new(RTM::API.token).to_s,
         id,
         title,
         text).invoke
      assert(ret['id'], id)
      @hash['content'] = text
   end

   # delete this note.
   # after deleted, should not touch this object.
   def delete
      RTM::Tasks::Notes::Delete.new(
         RTM::API.token, 
         RTM::Timeline.new(RTM::API.token).to_s,
         id).invoke
   end

   def Note.update(arg)
      ret, transaction = RTM::Tasks::Notes::Edit.new(
         RTM::API.token, 
         RTM::Timeline.new(RTM::API.token).to_s,
         arg[:id],
         arg[:title],
         arg[:body]).invoke
   end
end # Note

end # RTM
# vim:fdm=indent
