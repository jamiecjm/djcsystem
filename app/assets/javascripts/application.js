// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require bootstrap-sprockets
//= require jquery_ujs
//= require jquery_nested_form
//= require turbolinks
//= require_tree .

document.addEventListener("turbolinks:load",function(){

	var particles_options = {
  "particles": {
    "number": {
      "value": 6,
      "density": {
        "enable": true,
        "value_area": 800
      }
    },
    "color": {
      "value": "#1b1e34"
    },
    "shape": {
      "type": "polygon",
      "stroke": {
        "width": 0,
        "color": "#000"
      },
      "polygon": {
        "nb_sides": 6
      },
      "image": {
        "src": "img/github.svg",
        "width": 100,
        "height": 100
      }
    },
    "opacity": {
      "value": 0.3,
      "random": true,
      "anim": {
        "enable": false,
        "speed": 1,
        "opacity_min": 0.1,
        "sync": false
      }
    },
    "size": {
      "value": 160,
      "random": false,
      "anim": {
        "enable": true,
        "speed": 10,
        "size_min": 40,
        "sync": false
      }
    },
    "line_linked": {
      "enable": false,
      "distance": 200,
      "color": "#ffffff",
      "opacity": 1,
      "width": 2
    },
    "move": {
      "enable": true,
      "speed": 8,
      "direction": "none",
      "random": false,
      "straight": false,
      "out_mode": "out",
      "bounce": false,
      "attract": {
        "enable": false,
        "rotateX": 600,
        "rotateY": 1200
      }
    }
  },
  "interactivity": {
    "detect_on": "canvas",
    "events": {
      "onhover": {
        "enable": false,
        "mode": "grab"
      },
      "onclick": {
        "enable": false,
        "mode": "push"
      },
      "resize": true
    },
    "modes": {
      "grab": {
        "distance": 400,
        "line_linked": {
          "opacity": 1
        }
      },
      "bubble": {
        "distance": 400,
        "size": 40,
        "duration": 2,
        "opacity": 8,
        "speed": 3
      },
      "repulse": {
        "distance": 200,
        "duration": 0.4
      },
      "push": {
        "particles_nb": 4
      },
      "remove": {
        "particles_nb": 2
      }
    }
  },
  "retina_detect": true
}

	particlesJS("nasa-particles", particles_options);

	$('[data-toggle="tooltip"]').tooltip(); 
	
	$('body').on('focus',".datepicker", function(){
	    $(this).datepicker({
	    	dateFormat: 'yy-mm-dd',
			changeMonth: true,
			changeYear: true,
			yearRange: "-100:+0" 
	    });
	})

	$('.add_nested_fields').click(function(){
		window.setTimeout(unwrap,5)
	})

	$('.non-member .remove_nested_fields').click()
	
	$(".ren_remove:first").css('display','none')

	$('.btn').on('click',function(){
		$("div").find("[style='display: none;']").find('input').attr('required',false)
		$("div").find("[style='display: none;']").find('select').attr('required',false)
	})

	$(document).on('click',".clickable-row",function() {
        window.location = $(this).data("href");
    });

	$(document).on('click','#sales_table tbody tr td:not(:first-child)',function (){
		 location.href = $(this).parent().attr('id');
	});

	$(document).on('click','#request-table tbody tr td:not(:first-child)',function (){
		 location.href = $(this).parent().attr('id');
	});

	$('#download').click(function(){
		html2canvas($('#chart'), {
		  onrendered: function(canvas) {
		    var myImage = canvas.toDataURL("image/png")
		    $('#download_link').attr('href',myImage)
		    document.getElementById('download_link').click();
		  }
		});
		
		// printToFile($('#chart'))
	})

	$("#btnExport").click(function(e) {
	    e.preventDefault();

	    //getting data from our table
	    var data_type = 'data:application/vnd.ms-excel';
	    var table_div = document.getElementById('sales_table');
	    if (table_div === null){
	    	var table_div = document.getElementById('request-table');
	    }
	    if (table_div === null){
	    	var table_div = document.getElementById('member_table');
	    }
	    var table_html = table_div.outerHTML.replace(/ /g, '%20');
	    var a = document.createElement('a');
	    a.href = data_type + ', ' + table_html;
	    a.download = 'exported_table_' + Math.floor((Math.random() * 9999999) + 1000000) + '.xls';
	    a.click();
	  });

	window.setTimeout(function() { $(".alert").alert('close'); }, 10000);


	$("#scroll-to-features-btn").click(function() {
	    $('html, body').animate({
	        scrollTop: $("#features").offset().top-100
	    }, 1500);
	});

	$("#scroll-to-top-btn").click(function() {
	    $('html, body').animate({
	        scrollTop: $("#signup").offset().top-100
	    }, 500);
	});
})

// function downloadURI(uri, name) {
//     var link = document.createElement("a");
//     link.download = name;
//     link.href = uri;
//     link.click();
//     //after creating link you should delete dynamic link
//     //clearDynamicLink(link); 
// }

// //Your modified code.
// function printToFile(div) {
//     html2canvas(div, {
//         onrendered: function (canvas) {
//             var myImage = canvas.toDataURL("image/png");
//             //create your own dialog with warning before saving file
//             //beforeDownloadReadMessage();
//             //Then download file
//             downloadURI("data:" + myImage, "chart.png");
//         }
//     });
// }