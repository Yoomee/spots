module MembersHelper

  PERSON_TEXT_REPLACEMENTS = [["are", "is"], ["have", "has"], ["haven't", "hasn't"],["don't", "doesn't"], ["were", "was"]]
  
  def first_personalize_text(text)
    return '' if text.blank?    
    PERSON_TEXT_REPLACEMENTS.inject(out=text.to_s) do |out, rep|
      out.gsub(rep[1], rep[0])
    end
  end
  
  def forename_or_me(member)
    @logged_in_member==member ? 'me' : member.forename
  end
  
  def forename_or_my(member, options = {})
    @logged_in_member == member ? my(options[:capitalize]) : "#{member.forename}'s"
  end
  
  def forename_or_you(member, text='', options = {})
    if @logged_in_member==member
      out = "#{you(options[:capitalize])} #{first_personalize_text(text)}"
    else
      out = "#{member.forename} " + third_personalize_text(text)
    end
    out.strip
  end
  
  def forename_or_your(member, options = {})
    if options[:owner].blank?
      @logged_in_member == member ? your(options[:capitalize]) : "#{member.forename}'s"
    else
      return your(options[:capitalize]) if @logged_in_member == options[:owner]
      options[:owner] == member ? their(options[:capitalize]) : "#{options[:owner].forename}'s"
    end
  end
  
  def full_name_or_you(member, *args)
    options = args.extract_options!.reverse_merge(:capitalize => true)
    text = args.first || ""
    if logged_in_member == member
      out = you(options[:capitalize])
      out << " #{first_personalize_text(text)}"
    else
      out = "#{member.full_name} #{third_personalize_text(text)}"
    end
    out.strip
  end
  alias_method :you_or_full_name, :full_name_or_you
  
  def full_name_or_your(member, options = {})
    options.reverse_merge!(:member => @logged_in_member)
    if options[:owner].blank?
      options[:member] == member ? your(options[:capitalize]) : "#{member.full_name}'s"
    else
      return "your" if options[:member] == options[:owner]
      options[:owner] == member ? their(options[:capitalize]) : "#{options[:owner].full_name}'s"
    end
  end
  
  def member_names_list(members, options = {})
    options.reverse_merge!(:limit => 3)
    total_count = members.length
    return "" if total_count.zero?
    members = members.limit(options[:limit])
    if total_count <= options[:limit]
      members.map {|m| link_to(you_or_full_name(m), m)}.to_sentence
    else
      members.map {|m| link_to(you_or_full_name(m), m)}.join(", ") << " and #{pluralize(total_count - options[:limit], 'other')}"
    end
  end
  
  def my(capitalize = false)
    capitalize ? 'My' : 'my'
  end
  
  def their(capitalize = false)
    capitalize ? 'Their' : 'their'
  end
  
  def third_personalize_text(text)
    return '' if text.blank?
    PERSON_TEXT_REPLACEMENTS.inject(out=text) do |out, rep|
      out.gsub(rep[0], rep[1])
    end
  end
   
  def you(capitalize = false)
    capitalize ? 'You' : 'you'
  end
  
  def your(capitalize = false)
    capitalize ? 'Your' : 'your'
  end
  
end
