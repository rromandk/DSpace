/*
** Script aplicado sólo sobre ala página del aspecto "EditProfile"
*/

$(document).ready(function(){
	if($('form#aspect_eperson_EditProfile_div_information').length){
		$('form#aspect_eperson_EditProfile_div_information').attr('onkeydown','javascript:return disableEnterKey(event);');
	}
});