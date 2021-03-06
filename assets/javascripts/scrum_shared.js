function toggleScrumRowGroup(el) {
	var tr = $(el).closest('tr');
	var n = $(tr).next();
	$(tr).toggleClass('open');
	var isOpened = $(tr).hasClass('open')
	
	trLevel = parseInt($(tr).attr('level'));
	nLevel = trLevel + 1;
	
	while (n != undefined && nLevel > trLevel) {
		if(isOpened){			
			$(n).show();
			if($(n).hasClass('group'))
				$(n).addClass('open')
		} else {
			$(n).hide();
			if($(n).hasClass('group'))
				$(n).removeClass('open')
		}
		
		n = $(n).next();;
		nLevel = parseInt($(n).attr('level'));
	}
}

function cancelInlineChild(elem){
	$(elem).parents('.inline_child_container').each(function(index, element){
		element.innerHTML = '';
	});
}


function contextMenuShow(event) {
  var mouse_x = event.pageX;
  var mouse_y = event.pageY;
  var render_x = mouse_x;
  var render_y = mouse_y;
  var dims;
  var menu_width;
  var menu_height;
  var window_width;
  var window_height;
  var max_width;
  var max_height;

  $('#context-menu').css('left', (render_x + 'px'));
  $('#context-menu').css('top', (render_y + 'px'));
  $('#context-menu').html('');

  // collect ids
  ids_params_string = '';
  $('#issue-table input[name="ids[]"]').each(
                  function(index, element){
                    if(element.checked)
                      ids_params_string += 'ids[]=' + element.value + '&';
                  });

  data = ids_params_string + $(event.target).parents('form').first().serialize() + $('#context_menu_form').serialize();

  $.ajax({
    url: contextMenuUrl,
    data: data,
    success: function(data, textStatus, jqXHR) {
      $('#context-menu').html(data);
      menu_width = $('#context-menu').width();
      menu_height = $('#context-menu').height();
      max_width = mouse_x + 2*menu_width;
      max_height = mouse_y + menu_height;

      var ws = window_size();
      window_width = ws.width;
      window_height = ws.height;

      /* display the menu above and/or to the left of the click if needed */
      if (max_width > window_width) {
       render_x -= menu_width;
       $('#context-menu').addClass('reverse-x');
      } else {
       $('#context-menu').removeClass('reverse-x');
      }
      if (max_height > window_height) {
       render_y -= menu_height;
       $('#context-menu').addClass('reverse-y');
      } else {
       $('#context-menu').removeClass('reverse-y');
      }
      if (render_x <= 0) render_x = 1;
      if (render_y <= 0) render_y = 1;
      $('#context-menu').css('left', (render_x + 'px'));
      $('#context-menu').css('top', (render_y + 'px'));
      $('#context-menu').show();

      if (window.parseStylesheets) { window.parseStylesheets(); } // IE

    }
  });
}

function clear_form_elements(ele) {
    $(ele).find(':input').each(function() {
        switch(this.type) {
        	case 'select-one':
        		if(default_issue_target_version=="")
        			$(this).val('');
            	break;
            case 'password':
            case 'select-multiple':
            case 'text':
              $(this).val('');
              break;
            case 'textarea':
                value = typeof(default_issue_description) == "undefined" ? "" : default_issue_description;
                $(this).val(value);
                break;
            case 'checkbox':
            case 'radio':
                this.checked = false;
        }
    });

}
function select_menu_item(scrum_label_class){
	$(function(){
		$('#main-menu ul li a.' + scrum_label_class).addClass('selected');
	})
}


function toggleScrumIssuesSelection(el) {
  var checkStatus = $("#issue-table input:checkbox").is(":checked");
  $("#issue-table input:checkbox").attr("checked", !checkStatus);
  if(!checkStatus) 
    $("#issue-table input:checkbox").parent().parent().addClass("context-menu-selection")  
  else
    $("#issue-table input:checkbox").parent().parent().removeClass("context-menu-selection")
  
}