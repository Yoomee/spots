/* DO NOT MODIFY. This file was compiled Fri, 25 May 2012 12:22:18 GMT from
 * /Users/ianmooney/Rails/spots/app/coffeescripts/client/tramlines_coffee.coffee
 */

var ActivityFilter;

ActivityFilter = {
  filter: function() {
    var date, group_id, new_href, search_params;
    group_id = $('#activity_filter a.active').attr('data-filter');
    date = $('input#activity_date_filter').val();
    if (group_id === null) {
      $('#activity_filter a:first').addClass('active');
      group_id = $('#activity_filter a.active').attr('data-filter');
    }
    new_href = window.location.origin + window.location.pathname;
    search_params = "?filter=" + group_id;
    if (date !== "") search_params += "&date=" + date;
    new_href += search_params;
    if (history.pushState !== void 0) {
      return $.ajax({
        url: '/activities',
        beforeSend: ActivityFilter.hideActivities,
        complete: function() {
          history.pushState({
            path: this.path
          }, '', new_href);
          return ActivityFilter.showActivities();
        },
        data: {
          organisation_group_id: group_id,
          date: date
        }
      });
    } else {
      return window.location.href = new_href;
    }
  },
  selectFilter: function(group_id) {
    $('#activity_filter a').removeClass('active');
    $("#activity_filter a[data-filter=" + group_id + "]").addClass('active');
    return ActivityFilter.filter();
  },
  hideActivities: function() {
    return $('.activity_grid').animate({
      opacity: 0
    }, 500);
  },
  showActivities: function() {
    return $('.activity_grid').animate({
      opacity: 1
    }, 300);
  },
  initDatepicker: function(options) {
    return $('input#activity_date_filter').datepicker({
      dateFormat: 'dd-mm-y',
      defaultDate: options.defaultDate,
      minDate: +options.numWeeksNotice * 7,
      showOn: 'button',
      buttonImage: '/images/calendar.png',
      buttonImageOnly: true,
      onSelect: function(dateText, inst) {
        $('#activity_date_filter_label').html(dateText.replace(/-/g, '/'));
        return ActivityFilter.filter();
      }
    });
  },
  filterByType: function(type) {
    var _this = this;
    $('#activity_filter a').removeClass('active');
    $("#activity_filter_" + type).addClass('active');
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
