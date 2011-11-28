module NavHelper

  def in_nav_item?(nav_item)
    if nav_item == :blog?
      in_blog?
    else
      false
    end
  end
  
  def nav_item_heading(nav_item)
    case nav_item
    when :blog
      'Spotted'
    else
      nav_item.to_s
    end
  end
  
  def nav_item_path(nav_item)
    case nav_item
    when :blog
      Blog.first
    else
      nav_item
    end
  end
  
  def nav_items
    returning @nav_items ||= Section.root.not_hidden.dup do
      idx = [@nav_items.size, 2].min * -1
      @nav_items.insert(idx, :blog)
    end
  end
  
end