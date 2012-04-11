# We want to allow target attribute
WhiteListHelper.attributes.merge %w{align name target style}
WhiteListHelper.tags.merge %w{caption table tbody tfoot th thead td tr}
module HtmlFilterHelper

  include WhiteListHelper
  
  def sanitize_params(params = params)
    params = walk_hash(params) if params
  end
  
  private
  def walk_array(array)
    array.each_with_index do |el, i|
      array[i] = walk_item(el)
    end
  end
  
  def walk_hash(hash)
    hash.keys.each do |key|
      hash[key] = walk_item(hash[key])
    end
    hash
  end
  
  def walk_item(item)
    case item
      when String
        white_list(item)
      when Hash
        walk_hash(item)
      when Array
        walk_array(item)
      else
        item
    end
  end
  
end
