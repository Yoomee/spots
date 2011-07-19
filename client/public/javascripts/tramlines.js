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
  }
};