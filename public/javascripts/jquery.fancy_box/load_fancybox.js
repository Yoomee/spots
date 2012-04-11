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
    $("a.fancy-img").fancybox({type: 'image'});
    $(".gallery a").fancybox();
    $("a.fancy").fancybox();
    $('a.fancy-video').fancybox({
      'hideOnOverlayClick': false,
      'autoScale': false,
      'autoDimensions': false,
      'width': 600,
      'height': 400
    });
    $("a.iframe").fancybox({
      'frameWidth': 800,
      'frameHeight': 600
    });
  }
};

$(document).ready(  function() {
  FancyboxLoader.loadAll();
});