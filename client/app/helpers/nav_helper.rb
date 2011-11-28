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
    returning out = Section.not_hidden do
      out.insert(-2, :blog)
    end
  end
  
end