
ActionView::Helpers::TextHelper::AUTO_LINK_RE = %r{
    ( https?:// | www\. )
    [^\s<']+
  }x
  
module TextHelper

  GOOGLE_VIDEO_PLAYER_STRING = "<embed class='videoPlayer' type='application/x-shockwave-flash' src='http://video.google.com/googleplayer.swf?docId=#ID#&amp;hl=en-GB' flashvars='autoPlay=true&amp;playerMode=mini'>" 
  GOOGLE_VIDEO_URL_RE = %r{http://
    (video\.)?
    google\.
    (co\.[\w]{2} | com)
    /videoplay\?docid=
    (\d+) # This is the ID
  }x

  VIMEO_PLAYER_STRING = "<object width='#WIDTH#' height='#HEIGHT#'><param name='allowfullscreen' value='true' /><param name='allowscriptaccess' value='always' /><param name='movie' value='http://vimeo.com/moogaloop.swf?clip_id=#ID#&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1' /><embed src='http://vimeo.com/moogaloop.swf?clip_id=#ID#&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1' type='application/x-shockwave-flash' allowfullscreen='true' allowscriptaccess='always' width='#WIDTH#' height='#HEIGHT#'></embed></object>"

  VIMEO_URL_RE = %r{(http://www\. | http:// | www\.)
    vimeo\.com/
    (\d+)  # This is the ID
  }x
  
  SLIDESHARE_URL_RE = %r{(http://www\.|http://|www\.)slideshare\.net/slideshow/embed_code/([^<\s]*)}x
  
  SLIDESHARE_PLAYER_STRING = "<iframe src='http://www.slideshare.net/slideshow/embed_code/#ID#' width='#WIDTH#' height='#HEIGHT#' frameborder='0' marginwidth='0' marginheight='0' scrolling='no'></iframe>"
  
  YOUTUBE_PLAYER_STRING = "<object width='#WIDTH#' height='#HEIGHT#'><param name='movie' value='http://www.youtube.com/v/#ID#'></param><param name='wmode' value='transparent'></param><embed src='http://www.youtube.com/v/#ID#' type='application/x-shockwave-flash' wmode='transparent' width='#WIDTH#' height='#HEIGHT#'></embed></object>"

  FLICKR_SET_SLIDESHOW = "<iframe align='center' src='http://www.flickr.com/slideShow/index.gne?set_id=#ID#' frameBorder='0' width='#WIDTH#' height='#HEIGHT#' scrolling='no'></iframe>"

  YOUTUBE_URL_RE = %r{(http://www\. | http:// | www\.)
    youtube\.com\/watch[^\s<]*v=
    ([\w|-]+) # This is the ID
    [^\s<]*
  }x
  
  YOUTUBE_USER_URL_RE = %r{(http://www\. | http:// | www\.)
    youtube\.com\/user\/([\w|-]+)
    [^\s<]*
  }x
  
  YOUTUBE_USER_ID_URL_RE = %r{(http://www\. | http:// | www\.)
    youtube\.com\/user\/.*\/(\w*)$
  }x
  
  FLICKR_SET_URL_RE = %r{(http://www\. | http:// | www\.)
    flickr\.com\/photos\/[^/]*/sets/
    ([\d]+) # This is the ID
    [^\s<]*
  }x

  WUFOO_FORM_RE = %r{(http://www\. | http:// | www\.)
    ([\w]+) # This is the wufoo user
    \.
    wufoo\.com/forms/
    ([\w]+) # This is the form ID
    /?
  }x
  
  WUFOO_PLAYER_STRING = <<EOS 
  <div id='wufoo-#ID#'>Fill out my <a href='http://#USER#.wufoo.com/forms/#ID#'>online form</a>.</div>
  <script type="text/javascript">
    var #ID#;
    (function(d, t) {
      var s = d.createElement(t), options = {
        'userName':'#USER#', 
        'formHash':'#ID#', 
        'autoResize':true,
        'height':'#HEIGHT#',
        'async':true,
        'header':'show'
      };
      s.src = ('https:' == d.location.protocol ? 'https://' : 'http://') + 'wufoo.com/scripts/embed/form.js';
      s.onload = s.onreadystatechange = function() {
        var rs = this.readyState; 
        if (rs) 
          if (rs != 'complete') 
            if (rs != 'loaded') return;
        try { 
          #ID# = new WufooForm();
          #ID#.initialize(options);
          #ID#.display(); 
        } 
        catch (e) {}
      }
      var scr = d.getElementsByTagName(t)[0], par = scr.parentNode; par.insertBefore(s, scr);
    })(document, 'script');
  </script>
EOS
  
  def absolutize_img_srcs(text)
    text.gsub(/(<img[^>]src=['"])\//) do 
      "#{$1}#{site_url}/"
    end
  end
        
  def add_video_players(text, options = {})
    text = add_google_players(text)
    text = add_youtube_players(text, options)
    text = add_vimeo_players(text, options)
    text = add_slideshare_players(text,options)
    text = add_flickr_slideshows(text,options)
    text = add_wufoo_forms(text, options)
  end
  
  def bracket(options = {}, &block)
    if options.is_a?(String)
      return options.blank? ? '' : "(#{options.strip})"
    end
    out = capture(&block)
    out = case
      when out.blank?
        ''
      when !options.empty?
        content_tag(:span, "(#{out.strip})", options)
      else
        "(#{out.strip})"
    end
    concat(out)
  end  

  def contentize(text,options={})
    auto_link(add_video_players(text,options))
  end

  def full_pluralize(before, count, after, options = {})
    options.reverse_merge!(:use_no => true)
    case
      when count==1
        out = "#{third_personalize_text(before).strip} 1 #{after.singularize}"
      when count == 0 && options[:use_no]
        out = "#{first_personalize_text(before).strip} no #{after.pluralize}"
      else
        out = "#{first_personalize_text(before).strip} #{pluralize(count, after)}"
    end
    #options[:use_no] ? out.gsub('0', 'no') : out
  end
  
  def indefinite_article(text,capitalize = false)
    a = capitalize ? "A" : "a"
    %w(a e i o u).include?(text[0].chr.downcase) ? "#{a}n" : a
  end
  
  def indefinite_articleize(text, capitalize = false)
    indefinite_article(text,capitalize) + text
  end
  
  def pluralize_without_count(count, singular, plural = nil)
    ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
  end

  def read_more_truncate(text, options ={})
    return if text.blank?
    options.reverse_merge!(:length => 400, :simple_format => true, :more_link => "Read more", :less_link => "Read less", :truncate_string => '...', :quotes => false, :strip_tags => true)
    text = strip_tags(text) if options[:strip_tags]
    if text.length <= options[:length]
      text = "\"#{text}\"" if options[:quotes]
      if options[:simple_format]
        return auto_link(simple_format(text), :target => '_blank')
      else
        return auto_link(text, :target => '_blank')
      end
    end
    javascript = "var par = $(this).parentsUntil('.read_more_wrapper').last(); par.hide(); par.siblings().show();"
    read_more_link = link_to_function(options[:more_link], javascript, :class => 'read_more_link')
    read_less_link = link_to_function(options[:less_link], javascript, :class => 'read_less_link')

    text = auto_link(text, :all, :target => "_blank")
    head = text.word_truncate_html(options[:length], options[:truncate_string]) + "&nbsp;" + read_more_link
    full = text  + "&nbsp;" + read_less_link
    if options[:quotes]
      head = "\"#{head}\""
      full = "\"#{full}\""
    end
    if options[:simple_format]
      head = simple_format(head)
      full = simple_format(full)
    end
    # head = text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m]
    
    ret = "<span class='read_more_wrapper'>
            <span class='read_more_trunc'>
              #{head}
            </span>
            <span class='read_more_full' style='display:none'>
              #{full}
            </span>
          </span>" 
  end

  def simple_format_with_word_truncation(text, length)
    simple_format text.word_truncate(length)
  end

  # Inverse of ActionView::Helpers::TextHelper#simple_format
  def simple_unformat text
    ret = replace_line_breaks text
    ret = replace_p_tags ret
    ret = CGI::unescapeHTML ret
    ret = unescape_spaces ret
    strip_tags ret
  end
  
  def strip_video_player_urls(text)
    text.gsub!(GOOGLE_VIDEO_URL_RE,'')
    text.gsub!(VIMEO_URL_RE,'')
    text.gsub!(YOUTUBE_URL_RE,'')
    text.gsub!(SLIDESHARE_URL_RE,'')
    text.gsub!(FLICKR_SET_URL_RE,'')
    text.gsub!(WUFOO_FORM_RE, '')
    text
  end

  # # Like the Rails _truncate_ helper but doesn't break HTML tags or entities.
  # def truncate_html(text, max_length = 30, ellipsis = "...")
  #   return if text.nil?
  #   doc = Hpricot(text.to_s)
  #   ellipsis_length = Hpricot(ellipsis).inner_text.mb_chars.length
  #   content_length = doc.inner_text.mb_chars.length
  #   actual_length = max_length - ellipsis_length
  #   content_length > max_length ? doc.truncate(actual_length).inner_html : text.to_s
  # end

  def truncate_html(text, max_length = 30, ellipsis = '...')
    return if text.nil?
    text.truncate_html(max_length, ellipsis)
  end
  
  private
  def add_flickr_slideshows(text, options = {})
    options = options.reverse_merge(:width => '100%', :height => 400)
    text.gsub(FLICKR_SET_URL_RE) do
      set_id = $2
      out = FLICKR_SET_SLIDESHOW.gsub(/#ID#/, set_id)
      out.gsub!(/#WIDTH#/, options[:width].to_s)
      out.gsub!(/#HEIGHT#/, options[:height].to_s)
    end
  end

  def add_google_players(text)
    text.gsub(GOOGLE_VIDEO_URL_RE) do
      gv_id = $3
      left, right = $`, $'
      # detect already linked URLs and URLs in the middle of a tag
      if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
        # do not change string; URL is already linked
        $1
      else
        GOOGLE_VIDEO_PLAYER_STRING.gsub(/#ID#/, gv_id)
      end
    end
  end
  
  def add_slideshare_players(text, options = {})
    options = options.reverse_merge(:width => '100%', :height => 400)
    text.gsub(SLIDESHARE_URL_RE) do
      slideshare_id = $2
      out = SLIDESHARE_PLAYER_STRING.gsub(/#ID#/, slideshare_id)
      out.gsub!(/#WIDTH#/, options[:width].to_s)
      out.gsub!(/#HEIGHT#/, options[:height].to_s)
    end
  end
  
  def add_vimeo_players(text, options = {})
    options = options.reverse_merge(:width => 400, :height => 300)
    text.gsub(VIMEO_URL_RE) do
      vimeo_id = $2
      left, right = $`, $'
      # detect already linked URLs and URLs in the middle of a tag
      if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
        # do not change string; URL is already linked
        $1
      else
        out = VIMEO_PLAYER_STRING.gsub(/#ID#/, vimeo_id)
        out.gsub!(/#WIDTH#/, options[:width].to_s)
        out.gsub!(/#HEIGHT#/, options[:height].to_s)        
      end
    end
  end
  
  def add_wufoo_forms(text, options = {})
    options = options.reverse_merge(:height => 339)
    text.gsub(WUFOO_FORM_RE) do
      puts "FOUND #{$&}"
      wufoo_id = $3
      wufoo_user = $2
      left, right = $`, $'
      if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
        # do not change string; URL is already linked
        puts "ALREADY LINKED"
        $&
      else
        out = WUFOO_PLAYER_STRING.gsub(/#ID#/, wufoo_id)
        out.gsub!(/#USER#/, wufoo_user)
        out.gsub!(/#HEIGHT#/, options[:height].to_s)
        puts "out = #{out}"
        out
      end
    end
  end
  
  def add_youtube_players(text, options = {})
    options = options.reverse_merge(:width => 425, :height => 350)
    text.gsub(YOUTUBE_URL_RE) do
      youtube_id = $2
      left, right = $`, $'
      if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
        # do not change string; URL is already linked
        $1
      else
        out = YOUTUBE_PLAYER_STRING.gsub(/#ID#/, youtube_id)
        out.gsub!(/#WIDTH#/, options[:width].to_s)
        out.gsub!(/#HEIGHT#/, options[:height].to_s)
      end
    end
  end
  
  def replace_line_breaks text
    text.gsub(/\<br\s*\>/, "\n")
  end

  def replace_p_tags text
    text.gsub(/\<\/p\>\<p\>/, "\n\n#{$1}")
  end

  def unescape_spaces text
    text.gsub(/&nbsp;/, ' ')
  end
  
  def was_or_were(n)
    n == 1 ? 'was' : 'were'
  end
 
end
