module MusculaHelper
  def muscula_js(log_id = 1182) 
    javascript_tag do
      "var Muscula = Muscula || {};
      Muscula.settings = {
          logId: #{log_id},  googleAnalyticsEvents: 'none'
      };
      (function () {
          var m = document.createElement('script'); m.type = 'text/javascript'; m.async = true;
          m.src = (window.location.protocol == 'https:' ? 'https:' : 'http:') +
              '//musculahq.appspot.com/Muscula.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(m, s);
          Muscula.run = function (s) { eval(s); Muscula.run = function () { }; };
      })();"
    end
  end
end