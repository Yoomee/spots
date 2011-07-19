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
  findMe: function(){
    if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(ActivityMap.centerMap);
    } else {
      alert("Sorry, your browser doesn't support this");
    }
  },
  centerMap: function(geoposition){
    var point = new google.maps.LatLng(geoposition.coords.latitude, geoposition.coords.longitude);
    map.setZoom(10);
    map.panTo(point);
  },
  findPostCode: function(){
    var postcode = $('#postcode').val();
    if ((postcode != $('#postcode').attr('title')) && postcode.length){
      var url = '/geocode?address='+postcode+',UK';
      $.get(url, function(data){
        if (typeof data == 'object'){
          var point = new google.maps.LatLng(data.lat, data.lng);
          map.setZoom(10);
          map.panTo(point);
        }
      });
    }
  }
};