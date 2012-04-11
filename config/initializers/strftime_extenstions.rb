module StrftimeExtensions
  
  def self.included(base)
    base.send(:alias_method_chain, :strftime, :ordinal)
  end
  
  def strftime_with_ordinal(fmt='%F')
    fmt.gsub! /%o/ do |o|
      ordinalize(strftime_without_ordinal('%e'))
    end
    strftime_without_ordinal(fmt)
  end

  private
  def ordinalize(number)
    if (11..13).include?(number.to_i % 100)
      "#{number}th"
    else
      case number.to_i % 10
      when 1; "#{number}st"
      when 2; "#{number}nd"
      when 3; "#{number}rd"
      else    "#{number}th"
      end
    end
  end

end

Date.send(:include,StrftimeExtensions)
Time.send(:include,StrftimeExtensions)