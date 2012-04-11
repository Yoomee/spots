var TramlinesAutocomplete = {
  searchedValue: "",
  addSelectionMadeClass: function(child_item) {
    var formtastic_input_li = child_item.parents('li.fb_autocomplete');
    formtastic_input_li.addClass('fb_selection_made');
  },
  removeSelectionMadeClass: function(child_item) {
    var formtastic_input_li = child_item.parents('li.fb_autocomplete');
    formtastic_input_li.removeClass('fb_selection_made');
  },
  save_fb_autocompletes: function() {
    $(".formtastic .fb_autocomplete").each(function(index) {
      $(this).find('input[type="hidden"]:first').val($(this).find('.facelist-values').attr('value').replace(',', ''));
    });
  }
};

var TramlinesPhotoBrowser = {

  clear: function(target_field) {
    $('#' + target_field + '_id').val('');
    $('#' + target_field + '_preview').html('');
    $('#' + target_field + '_clear').hide();
    return false;
  },

  init_links: function() {
    // Remove old click events and add one to .photo_browser_buttons
    $('.photo_browser_button').unbind('click');
    $('.photo_browser_button').click(function() {
      TramlinesPhotoBrowser.open($(this).attr('data-target'));
    });

    // Remove old click events and add one to .photo_browser_clear_links
    $('.photo_browser_clear').unbind('click');
    $('.photo_browser_clear').click(function() {
      TramlinesPhotoBrowser.clear($(this).attr('data-target'));
    });    
  },

  open: function(target_field) {
    var url = "/ckeditor/images?target_field=" + target_field;
    this.popup( url, 800, 600 );
  },
  
  /**
   * Opens Browser in a popup. The "width" and "height" parameters accept
   * numbers (pixels) or percent (of screen size) values.
   * @param {String} url The url of the external file browser.
   * @param {String} width Popup window width.
   * @param {String} height Popup window height.
   */
  popup : function( url, width, height ) {
    width = width || '80%';
    height = height || '70%';
    if ( typeof width == 'string' && width.length > 1 && width.substr( width.length - 1, 1 ) == '%' )
      width = parseInt( window.screen.width * parseInt( width, 10 ) / 100, 10 );
    if ( typeof height == 'string' && height.length > 1 && height.substr( height.length - 1, 1 ) == '%' )
      height = parseInt( window.screen.height * parseInt( height, 10 ) / 100, 10 );
    if ( width < 640 )
      width = 640;
    if ( height < 420 )
      height = 420;
    var top = parseInt( ( window.screen.height - height ) / 2, 10 ),
      left = parseInt( ( window.screen.width  - width ) / 2, 10 ),
      options = 'location=no,menubar=no,toolbar=no,dependent=yes,minimizable=no,modal=yes,alwaysRaised=yes,resizable=yes' +
        ',width='  + width +
        ',height=' + height +
        ',top='  + top +
        ',left=' + left;
    var popupWindow = window.open( '', null, options, true );
    // Blocked by a popup blocker.
    if ( !popupWindow )
      return false;
    try {
      popupWindow.moveTo( left, top );
      popupWindow.resizeTo( width, height );
      popupWindow.focus();
      popupWindow.location.href = url;
    }
    catch (e) {
      popupWindow = window.open( url, null, options, true );
    }
    return true ;
  },

  setImage: function(target_field, url, imageId) {
    $(target_field + '_id').val(imageId);
    $(target_field + '_preview').html("<img src='" + url + "' />");
    $(target_field + '_clear').show();
  }
  
};
  
$(document).ready(function() {

  TramlinesPhotoBrowser.init_links();
  
});

var TramlinesFormLinkRenderer = {
  
  action_with_page_param: function(form_id, page) {
  	action = $(form_id).attr('action');
  	if (action.match(/\?/)) {
  		return (action + '&page=' + page);
  	} else {
  		return (action + '?page=' + page);
  	}
  },
  submit_form: function(form_id, page_num) {
    var old_action = $(form_id).attr('action');
    var new_action = TramlinesFormLinkRenderer.action_with_page_param(form_id, page_num);
    $(form_id).attr('action', new_action);
    $(form_id).submit();
  }
  
};

function sleep(ms)
	{
		var dt = new Date();
		dt.setTime(dt.getTime() + ms);
		while (new Date().getTime() < dt.getTime());
	}

// e.g. ShoutFilter.filter({filter:'latest', parent_type:'Tag', parent_id:4, named_scope:'popular'})  
var ShoutFilter = {
  getShouts: function(data) {
    $('#shouts_filter_loader').show();
    $.ajax({
      url: '/shouts',
      data: data,
      complete: function() {
        $('#shouts_filter_loader').hide();
      },
      success: function(html) {
        $('#shout_wall').next('br').remove();
        $('#older_shouts_link').remove();
        $('#shout_wall').replaceWith(html);
        FancyboxLoader.loadAll();
      }
    });
  },
  filter: function(data) {
    $('.shouts_filter li').removeClass('active');
    $('#shouts_filter_' + data.filter).addClass('active');
    this.getShouts(data);
  }  
};

var FormtasticSelectWithOther = {
  toggleOther: function(selectInput) {
    var otherInput = selectInput.parent().find(".other_input_for_select");
    if (selectInput.val() == 'other') {
      otherInput.attr('name', selectInput.attr('name'));
      selectInput.attr('name', 'ignore_this');
      otherInput.val("");
      otherInput.show();
    } else {
      if (selectInput.attr('name') == "ignore_this") {
        selectInput.attr('name', otherInput.attr('name'));
      }
      otherInput.attr('name', 'ignore_this');          
      otherInput.hide();
    }
  }
};

var SlideshowForm = {
  formHtml: "",
  newFormsCount: 0,
  initForm: function() {
    $('.labelify').labelify({ labelledClass: 'labelified' });
    TramlinesPhotoBrowser.init_links();
  },
  addSlideshowItem:function() {
    $("#slideshow_item_forms ol:first").append(SlideshowForm.formattedformHtml());
    $('.labelify').labelify({ labelledClass: 'labelified' });
    TramlinesPhotoBrowser.init_links();    
  },
  formattedformHtml: function() {
    var html = SlideshowForm.formHtml;
    html = html.replace(/(slideshow_items_attributes_)(\d)/g, function(wholeMatch, firstMatch, secondMatch) {
      return (firstMatch + (SlideshowForm.newFormsCount + parseInt(secondMatch, 10)));
    });
    html = html.replace(/(\[slideshow_items_attributes\])\[(\d)\]/g, function(wholeMatch, firstMatch, secondMatch) {
      return (firstMatch + "[" + (SlideshowForm.newFormsCount + parseInt(secondMatch, 10)) + "]");
    });
    SlideshowForm.newFormsCount += 1;
    return html;
  },
  deleteSlide: function(link_elem) {
    if (confirm("Are you sure?")) {
      var fieldset_parent = link_elem.parents("fieldset.slideshow_item_form");
      fieldset_parent.find(".destroy_slideshow_item").val(1);
      fieldset_parent.fadeOut();
    }
  },
  savePositions: function() {
    $('#slideshow_item_forms ol:first fieldset').each(function(index) {
      $(this).find(".position_input").val(index);
    });
  },
  showImageInput: function(link_elem) {
    var fieldset_parent = link_elem.parents("fieldset.slideshow_item_form");
    fieldset_parent.find(".delete_image_input").val(0);
    fieldset_parent.find(".delete_video_input").val(1);    
    fieldset_parent.find(".image_or_video_input_links").hide();
    fieldset_parent.find(".video_input_container").hide();
    fieldset_parent.find(".image_input_container").show();
  },
  showVideoInput: function(link_elem) {
    var fieldset_parent = link_elem.parents("fieldset.slideshow_item_form");
    fieldset_parent.find(".delete_video_input").val(0);
    fieldset_parent.find(".delete_image_input").val(1);
    fieldset_parent.find(".image_or_video_input_links").hide();    
    fieldset_parent.find(".image_input_container").hide();    
    fieldset_parent.find(".video_input_container").show();
  },
  save_order: function() {
    $('#orderable_slides li').each(function(index) {
      $('#sortable_id_' + index).val($(this).attr('data-sortable-id'));
    });
  },
  updateNumbers: function() {
    $('#orderable_slides li').each(function(index,elem){
      $(elem).children('.number').html(index+1);
    });
  }
};

function setWaypoint(waypoint){
  if(waypoint == null || waypoint == '')
    waypoint = document.location.pathname + document.location.hash;
  $.post("/sessions/set_waypoint", { waypoint: waypoint} );
}