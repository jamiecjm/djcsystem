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