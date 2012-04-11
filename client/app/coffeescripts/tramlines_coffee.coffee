ActivityFilter = 
  
  filter: (type) ->
    
    $('#activity_filter a').removeClass 'active'
    $('#activity_filter_' + type).addClass 'active'
    
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
