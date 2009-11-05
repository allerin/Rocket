// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var ajax_calls;
ajax_calls = 0;

function add_ajax_call() {
	ajax_calls++;
	handle_spinny_thing();
}

function remove_ajax_call() {
	ajax_calls = ajax_calls - 1
	if (ajax_calls < 0)
	 ajax_calls = 0;
	handle_spinny_thing();
}

  function change()
      {
         if (document.getElementById('batch').value == '3')
       {
       
       
        document.getElementById('Search_by_status').value = 'Boxed/Completed';
       
       }
       else
       {
      
       document.getElementById('Search_by_status').value = '';
      
      }
      }

  function show_me()
      {
      
      if (document.getElementById('Global_change').style.display == 'none')
      {
       document.getElementById('Global_change').style.display = 'block';
       }
       else
       {
       document.getElementById('Global_change').style.display = 'none';
       
      }
      }
function handle_spinny_thing() {
	if (ajax_calls > 0 && $('spinner').hidden == true ) {
		$('spinner-inactive').setAttribute('hidden', 'true');
		$('spinner').removeAttribute('hidden');
	}
	else {
		$('spinner').setAttribute('hidden', 'true');
		$('spinner-inactive').removeAttribute('hidden');
	}
}


// Get the spinner goin when ajax calls are open...
Ajax.Responders.register({
  onCreate: function() {
    if($$('img.spinner').length > 0 && Ajax.activeRequestCount>0) {
			$$('img.spinner').each(function(img) {
				img.src = "/images/spin.gif"
			})
		}  
  },
  onComplete: function() {
    if($$('img.spinner').length > 0 && Ajax.activeRequestCount==0) {
			$$('img.spinner').each(function(img) {
				img.src = "/images/done.gif"
			})
		}
  }
});

function toggle_visibility(object_id){
  $(object_id).style.display = ($(object_id).style.display == 'none')? 'block' : 'none';
}
