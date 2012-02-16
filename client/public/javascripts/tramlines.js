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
  bounceMarker: function(org_id) {
    eval('markerOrganisation' + org_id).setAnimation(google.maps.Animation.BOUNCE);
    setTimeout("eval('markerOrganisation" + org_id + "').setAnimation(null)", 800);
  },
  centerMap: function(geoposition){
    var point = new google.maps.LatLng(geoposition.coords.latitude, geoposition.coords.longitude);
    map.setZoom(10);
    map.panTo(point);
  },
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
    var urlData;
    if (postcode == null) {
      urlData = {'activity_id':ActivityMap.activityId, 'lat':geoposition.coords.latitude, 'lng': geoposition.coords.longitude};
    } else {
      urlData = {'activity_id':ActivityMap.activityId, 'address':postcode+',UK'};
    }
    $.ajax({
      url: '/organisations/search_address/',
      data: urlData,
      dataType: 'json',
      beforeSend: function() {
        ActivityMap.loading();
      },
      complete: function() {
        ActivityMap.completed();
      },
      success: function(data) {
        var point;
        if (data.unknown_location) {
          $('#postcode').addClass('not_found');
          $('#address_not_found').show();
          return false;
        } else if(data.no_results) {
          $('#postcode').removeClass('not_found');
          $('#address_not_found').hide();
          $('.organisation_panel').hide();
          $('.no_results').show().highlight(1000);
          map.setZoom(10);
          point = new google.maps.LatLng(data.lat, data.lng);
          map.panTo(point);
        } else {
          $('#postcode').removeClass('not_found');
          $('#address_not_found').hide();
          $('#organisation_panel').html(data.organisation_html);
          map.setZoom(10);
          point = new google.maps.LatLng(data.lat, data.lng);
          map.panTo(point);
          ActivityMap.bounceMarker(data.organisation_id);
        }
        return true;
      }
    });
  },
  fetchOrganisation: function(act_id, org_id) {
    ActivityMap.bounceMarker(org_id);
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

var FBLogin = {
  loginAndSubmitTimeSlotForm: function() {
    $.ajax({
      url:"/sessions/create_fb",
      success: function(data) {
        if (data=="success") {
          $("#time_slot_booking_submit").click();
        } else {
          alert("There was a problem logging in.");
        }
      }
    });
  },
  processTimeSlotBooking: function() {
    FB.login(
      function(response) {
        if (response.session) {
          return FBLogin.login_and_submit_form();
        } else {
          return true;
        }
      },
      {scope:'email'}
    );
    return false;
  }
};

var OrganisationForm = {
  saveLatLng: function(org_id) {
    $('#organisation_lat').val(eval("markerOrganisation"+org_id).getPosition().lat());
    $('#organisation_lng').val(eval("markerOrganisation"+org_id).getPosition().lng());
  }
};