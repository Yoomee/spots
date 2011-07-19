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