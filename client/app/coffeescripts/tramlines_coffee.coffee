ActivityFilter = 
  
  filter: () ->
    group_id = $('#activity_filter a.active').attr('data-filter')
    date = $('input#activity_date_filter').val()
    if (group_id == null)
      $('#activity_filter a:first').addClass 'active'
      group_id = $('#activity_filter a.active').attr('data-filter')
      
    new_href = window.location.origin + window.location.pathname
    search_params = "?filter=#{group_id}"
    search_params += "&date=#{date}" unless date==""
    new_href += search_params
    if history.pushState != undefined
      $.ajax
        url: '/activities',
        beforeSend: ActivityFilter.hideActivities
        complete: () ->
          history.pushState 
            path: this.path,
            '',
            new_href
          ActivityFilter.showActivities()
        data:
          organisation_group_id: group_id
          date: date
    else
      window.location.href = new_href
  selectFilter: (group_id) ->
    $('#activity_filter a').removeClass('active')
    $("#activity_filter a[data-filter=#{group_id}]").addClass('active')
    ActivityFilter.filter()
  hideActivities: () ->
    $('.activity_grid').animate
      opacity: 0,
      500
  showActivities: () ->
    $('.activity_grid').animate
      opacity: 1,
      300          
  initDatepicker: (options) ->
    $('input#activity_date_filter').datepicker
      dateFormat: 'dd-mm-y',
      defaultDate: options.defaultDate,
      minDate: (+options.numWeeksNotice*7),
      showOn: 'button',
      buttonImage: '/images/calendar.png',
      buttonImageOnly: true,
      onSelect: (dateText, inst) ->
        $('#activity_date_filter_label').html(dateText.replace(/-/g, '/'))
        ActivityFilter.filter()
  filterByType: (type) ->
    $('#activity_filter a').removeClass 'active'
    $("#activity_filter_#{type}").addClass 'active'
    $('.activity_grid').animate
      opacity: 0,
      500,
      =>
        $('.activity_grid a').hide()
        if type == 'all'
          $('.activity_grid a').show()
        else
          $('.activity_grid a.type_' + type).show()
        $('.activity_grid').animate
          opacity: 1,
          300
