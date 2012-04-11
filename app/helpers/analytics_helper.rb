module AnalyticsHelper
  
  
  def google_analytics_js
    if !(RAILS_ENV =~ /development|test/) && (tracker_code = APP_CONFIG['google_analytics']).present?
      javascript_tag do
        "var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '#{tracker_code}']);
        _gaq.push(['_trackPageview']);

        (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();"
      end
    end
  end
  
  def track_page_view(url)
    "_gaq.push(['_trackPageview', '#{url}']);"
  end
  
  def analytics_event(category, action)
    #TODO add label and value
    "_gaq.push(['_trackEvent', '#{category}', '#{action}', '#{label}', '#{value}']);"
  end
  
end
