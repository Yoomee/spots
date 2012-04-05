/* DO NOT MODIFY. This file was compiled Thu, 05 Apr 2012 16:38:26 GMT from
 * /Users/si/projects/spots/app/coffeescripts/client/tramlines_coffee.coffee
 */

var ActivityFilter;

ActivityFilter = {
  filter: function(type) {
    var _this = this;
    $('.activity_type_grid a').removeClass('active');
    $('#activity_filter_' + type).addClass('active');
    return $('.activity_grid').animate({
      opacity: 0
    }, 500, function() {
      $('.activity_grid a').hide();
      if (type === 'all') {
        $('.activity_grid a').show();
      } else {
        $('.activity_grid a.type_' + type).show();
      }
      return $('.activity_grid').animate({
        opacity: 1
      }, 300);
    });
  }
};
