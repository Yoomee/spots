// Default fancybox loader
// Will automatically attach fancybox to links with the following elements:
//  - a.fancy-img
//  - .gallery a
//  - a.fancy

// OPTIONS : source (http://fancybox.net/api)
// hideOnContentClick : Hides FancyBox when cliked on zoomed item (false by default)
// zoomSpeedIn : Speed in miliseconds of the zooming-in animation (no animation if 0)
// zoomSpeedOut : Speed in miliseconds of the zooming-out animation (no animation if 0)
// frameWidth : Default width for iframed and inline content
// frameHeight : Default height for iframed and inline content
// overlayShow : If true, shows the overlay (false by default)
// overlayOpacity : Opacity of overlay (from 0 to 1)
// itemLoadCallback : Custom function to get group items 
//                   (see example on source of : http://fancy.klade.lv/)


var FancyboxLoader = {
  loadAll: function() {
    var iOS = navigator.userAgent.match(/like Mac OS X/i) != null;
    $('a.fancy-img').fancybox({
      'hideOnOverlayClick': false,
      type: 'image',
      'centerOnScroll': !iOS
    });
    
    $(".gallery a").fancybox();
    
    $('a.fancy').fancybox({
      'hideOnOverlayClick': false,
      'autoScale': false,
      'centerOnScroll': !iOS
    });
    
    $('a.fancy-video').fancybox({
      'hideOnOverlayClick': false,
      'autoScale': false,
      'autoDimensions': false,
      'width': 600,
      'height': 400,
      'centerOnScroll': !iOS     
    });
    
    $("a.iframe").fancybox({
      'frameWidth': 800,
      'frameHeight': 600,
      'centerOnScroll': !iOS      
    });
  }
};

$(document).ready(  function() {
  FancyboxLoader.loadAll();
});