#Used in Associate Babble
#TODO Make workers work in client.

class ConversationEmailWorker < Workling::Base

  def send_emails(options)
    if conversation = options[:conversation_type].constantize.find_by_id(options[:conversation_id])
      members = Member.related_to_tag(conversation.email_everyone_tag).not_including(conversation.member)
      members.each do |member|
        if conversation.is_media?
          Notifier.deliver_media_conversation(conversation, member)
        else
          Notifier.deliver_status_conversation(conversation, member)          
        end
      end  
    end
  end
  
end