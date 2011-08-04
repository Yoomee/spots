var LoggedInNav = {
  hide_logged_in_member: function() {
    $('.logged_in_box').hide(0, function(){
      $('a.logged_in_member_link').removeClass("logged_in_member_link_highlight");
    });
  },
  show_logged_in_member: function() {
    $('.logged_in_box').show();
    $("a.logged_in_member_link").addClass("logged_in_member_link_highlight");          
  },
  hide_my_organisations: function() {
    $('.my_organisations_box').hide(0, function(){
      $('a.my_organisations_link').removeClass("my_organisations_link_highlight");
    });
  },
  show_my_organisations: function() {
    $('.my_organisations_box').show();
    $("a.my_organisations_link").addClass("my_organisations_link_highlight");        
  },
  toggle_logged_in_member: function() {
    if($("a.logged_in_member_link").hasClass('logged_in_member_link_highlight')){
      LoggedInNav.hide_logged_in_member();
    } else {
      LoggedInNav.hide_my_organisations();
      LoggedInNav.show_logged_in_member();
    }
  },
  toggle_my_organisations: function() {
    if($("a.my_organisations_link").hasClass('my_organisations_link_highlight')){
      LoggedInNav.hide_my_organisations();
    } else {          
      LoggedInNav.hide_logged_in_member();
      LoggedInNav.show_my_organisations();
    }            
  }
};

var TimeSlot = {
  setSelected: function(day){
    if(day.is(':checked')){
      day.parent().addClass('selected');
    } else {
      day.parent().removeClass('selected');
    }
  },
  setAllSelected: function(){
    $('.time_slot_day_input input[type="checkbox"]:checked').parent().addClass('selected');
  },
  toggleEdit: function(form_id){
    var form = $('#'+form_id);
    if (form.hasClass('disabled')) {
      form.removeClass('disabled');
      form.find('input').removeAttr('disabled');
      form.find('select').removeAttr('disabled');      
      form.find('.edit_link').html('Cancel');
    } else {
      form.addClass('disabled');
      form.find('input').attr('disabled', 'disabled');
      form.find('select').attr('disabled', 'disabled');
      form.find('.edit_link').html('Edit');    
    }

  }
};

var ActivityMap = {
  activityId: null,
  loading: function() {
    $('#activity_map_loader').show();
  },
  completed: function() {
    $('#activity_map_loader').hide();
  },
  findMe: function(act_id){
    ActivityMap.activityId = act_id;
    if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(ActivityMap.findNearestOrganisationFromGeoposition);
    } else {
      alert("Sorry, your browser doesn't support this");
    }
  },
  centerMap: function(geoposition){
    var point = new google.maps.LatLng(geoposition.coords.latitude, geoposition.coords.longitude);
    map.setZoom(10);
    map.panTo(point);
  },
  // findPostCode: function(){
  //   var postcode = $('#postcode').val();
  //   if ((postcode != $('#postcode').attr('title')) && postcode.length){
  //     var url = '/geocode?address='+postcode+',UK';
  //     $.get(url, function(data){
  //       if (typeof data == 'object'){
  //         return {'lat':data.lat, 'lng':data.lng};
  //       } else {
  //         $('#postcode').addClass('not_found');
  //         $('#address_not_found').blindDown();
  //         return false;
  //       }
  //     });
  //   }
  // },
  findPostCode: function(act_id) {
    ActivityMap.activityId = act_id;
    var postcode = $('#postcode').val();
    if ((postcode != $('#postcode').attr('title')) && postcode.length) {
      ActivityMap.findNearestOrganisation(postcode, null);
    }
  },
  findNearestOrganisationFromGeoposition: function(geoposition) {
    ActivityMap.findNearestOrganisation(null, geoposition);
  },
  findNearestOrganisation: function(postcode, geoposition) {
    if (postcode == null) {
      var urlData = {'activity_id':ActivityMap.activityId, 'lat':geoposition.coords.latitude, 'lng': geoposition.coords.longitude};
    } else {
      var urlData = {'activity_id':ActivityMap.activityId, 'address':postcode+',UK'};
    }
    $.ajax({
      url: '/organisations/search_address/',
      data: urlData,
      dataType: 'json',
      beforeSend: ActivityMap.loading(),
      complete: ActivityMap.completed(),
      success: function(data) {
        if (typeof data == 'object'){
          $('#organisation_panel').html(data.organisation_html);
          map.setZoom(10);
          var point = new google.maps.LatLng(data.lat, data.lng);
          map.panTo(point);
        } else {
          $('#postcode').addClass('not_found');
          $('#address_not_found').blindDown();
          return false;
        }
      }
    });
  },
  fetchOrganisation: function(act_id, org_id) {
    var url = '/organisations/' + org_id + '/activities/'+act_id;
    $.ajax({
      url: url,
      beforeSend: ActivityMap.loading(),
      complete: ActivityMap.completed(),
      success: function(data) {
        $('#organisation_panel').html(data);
      }
    });
  }
};

var ActivityFilter = {
  filter: function(type) {
    $('#activity_filter a').removeClass('active');
    $('#activity_filter_' + type).addClass('active');
    $('.activity_grid').animate({opacity:0}, 500, function() {
      $('.activity_grid a').hide();
      if (type=='all') {
        $('.activity_grid a').show();
      } else {
        $('.activity_grid a.type_' + type).show();
      }
      $('.activity_grid').animate({opacity:1}, 300);      
    });
  }
};