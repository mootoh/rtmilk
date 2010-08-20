#
# rtm.lists : Lists API
#

module RTM
#
# rtm.lists : Lists API
#
module Lists
   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.add.rtm
   class Add < RTM::API
      # return [name, smart, filter?, id, archived, deleted, position, locked]*
      def parse_result(result)
         super
         result['list'].first
      end

      def initialize(token, name, filter=nil)
         super 'rtm.lists.add', token, RTM::Timeline.new(token).to_s
         @param['name'] = name
         if filter
            @param['filter'] = filter
         end
      end
   end # Add

   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.archive.rtm
   class Archive < RTM::API
   end # Archive

   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.delete.rtm
   class Delete < RTM::API
      # return [name, smart, filter?, id, archived, deleted, position, locked]*
      def parse_result(result)
         super
         result['list'].first
      end

      def initialize(token, id)
         super 'rtm.lists.delete', token, RTM::Timeline.new(token).to_s
         @param['list_id'] = id
      end
   end # Delete

   class GetList < RTM::API
      # return [name, smart, filter?, id, archived, deleted, position, locked]*
      def parse_result(result)
         super
         result['lists'].first['list']
      end

      def initialize(token)
         super 'rtm.lists.getList', token
      end
   end # GetList

   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.setDefaultList.rtm
   class SetDefaultList < RTM::API
   end # SetDefaultList

   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.setName.rtm
   class SetName < RTM::API
      # return [name, smart, filter?, id, archived, deleted, position, locked]*
      def parse_result(result)
         super
         result['list'].first
      end

      def initialize(token, id, name)
         super 'rtm.lists.setName', token, RTM::Timeline.new(token).to_s
         @param['list_id'] = id
         @param['name'] = name
      end
   end # SetName

   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.unarchive.rtm
   class UnArchive < RTM::API
   end # UnArchive
end # Lists

# more friendly class.
class List
   #attr_reader :name, :smart, :id, :archived, :deleted, :position, :locked

   def initialize(arg)
      if arg.class == String # name
         @hash = RTM::Lists::Add.new(RTM::API.token, arg).invoke
      elsif arg.class == Hash # already constructed 
         @hash = arg
      else
         raise RTM::Error, "invalid argument"
      end
   end

   def name; @hash['name']; end
   def id; @hash['id']; end
   def position; @hash['position']; end
   def smart?; @hash['smart'] == '1'; end
   def archived?; @hash['archived'] == '1'; end
   def locked?; @hash['locked'] == '1'; end
   def deleted?; @hash['deleted'] == '1'; end

   def name=(new_name)
      RTM::API::SetName(RTM::API.token, @id, new_name)
   end

   # archive this list.
   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.archive.rtm
   def archive
   end

   # unarchive this list.
   def unarchive
   end

   # delete this list.
   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.delete.rtm
   def delete
      deleted = RTM::Lists::Delete.new(RTM::API.token, @hash['id']).invoke
   end

   # set this list as default.
   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.setDefaultList.rtm
   def set_default
   end

   # -----------------------------------------------------------------
   # class methods
   #

   # find a List by name.
   def List.find(name, alive_only=true) # by name
      lists = RTM::Lists::GetList.new(RTM::API.token).invoke
      lists.find do |list|
         if alive_only
            list['name'] == name && list['archived'] == '0' && list['deleted'] == '0'
         else
            list['name'] == name
         end
      end
   end

   # find all Lists.
   def List.find_all(name, alive_only=true) # by name
      lists = RTM::Lists::GetList.new(RTM::API.token).invoke
      lists.find_all do |list|
         if alive_only
            list['name'] == name && list['archived'] == '0' && list['deleted'] == '0'
         else
            list['name'] == name
         end
      end.collect do |x|
         List.new(x)
      end
   end

   # find all alive Lists.
   def List.alive_all
      lists = RTM::Lists::GetList.new(RTM::API.token).invoke
      lists.find_all do |list|
         list['archived'] == '0' && list['deleted'] == '0'
      end.collect do |x|
         List.new(x)
      end
   end

   # http://www.rememberthemilk.com/services/api/methods/rtm.lists.getList.rtm
   def List.get
   end

   def List.inbox
      List.find('Inbox')
   end
end # List

end # RTM
# vim:fdm=indent
