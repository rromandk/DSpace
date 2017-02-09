/*
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */


/*
 * Funciones utilizadas durante la ejecución del
 * DescribeStep durante el Submission y el Workflow.
 */
if($('form#aspect_submission_StepTransformer_div_submit-cclicense')){
	
	// Solo ejecutar en la página de seleccion CC
	$(document).ready(function(){
		var nc_text = "";
		var sa_text = "";
		var nd_text = "";
		var showCCLicenseSelected = function(){
			switch (this.name){
				case "commercial_chooser":
					switch(this.value){
						case "y": nc_text = ""; break;
						case "n": nc_text = "-nc"; break;
					}
					break;
				case "derivatives_chooser":
					switch(this.value){
						case "y": nd_text = ""; sa_text=""; break;
						case "sa": nd_text = ""; sa_text = "-sa"; break;
						case "n": nd_text = "-nd"; sa_text=""; break;
					}
					break;
			}
			$('.selectedCCLicense').addClass('alert alert-info').html("La licencia actual seleccionada es <a target='_blank' href='https://creativecommons.org/licenses/by" + nc_text + nd_text + sa_text +"/4.0'>Creative Commons BY"+ (nc_text + nd_text + sa_text).toUpperCase() + " 4.0</a>");	
		};
		$("#N100AB input[name='commercial_chooser']").click(showCCLicenseSelected);
		$("#N100CD input[name='derivatives_chooser']").click(showCCLicenseSelected);
		$("#aspect_submission_StepTransformer_div_statusDivision").before('<div class="selectedCCLicense">&#160;</div>')
	});
}	
	
if ($('form#aspect_submission_StepTransformer_div_submit-describe')){	
	/**
	 * Methods used in the initialize of the XMLUI input-forms page.
	 */
	//globals variables
	var fieldIDPrefix = 'aspect_submission_StepTransformer_field_';
	var fields = ['dc_type','dc_type_version','dcterms_accessRights','dcterms_language','dcterms_license','dcterms_rights_embargoPeriod','dcterms_subject_area'];
//	var emptyAuthorityFields = ['dcterms_isPartOf_item','dcterms_isPartOf_issue','dcterms_relation','dcterms_hasPart','dcterms_isVersionOf', 'dcterms_identifier_url'];			
	var oldTypeValue = $('#aspect_submission_StepTransformer_field_dc_type').val();
	var oldLicenseValue = $('#aspect_submission_StepTransformer_field_dcterms_license').val();
	//For each input field can put a function name, having as prefix the input field name. P.e. for the field "dcterms_abstract" we can add the function "dcterms_abstract_make_shorter". 
	var preProcessorsFunctions = ['dcterms_license_selectChosenCC','dcterms_license_ccInputFieldControl','dc_type_typeVerification'];
	
	
	// Initializes fields when the page loads, for every field declared in the 'fields' array.
	$(document).ready(function(){
		fields.forEach(executePreprocessors);
		fields.forEach(makeReadonly);
//		emptyAuthorityFields.forEach(setPlaceHolders);
	});
	
	/**
	* Set place holders for empty authorities inputs
	*/
	function setPlaceHolders(inputFieldName, index, array){
		$('#'+ fieldIDPrefix + inputFieldName).prop("placeholder", "Descripción del recurso...");
		$('#'+ fieldIDPrefix + inputFieldName + '_authority').prop("placeholder", "Dirección del recurso...");
	}
				
	/**
	* Executes a list of preprocessing functions declared for every DCInput. If the input is not the current page, then no function is applied.
	*/
	function executePreprocessors(inputFieldName, index, array){
		//exists the input field? checks before apply the preprocessors.
		if($('#'+ fieldIDPrefix + inputFieldName).length){	
			preProcessorsFunctions.forEach(function(functionName, index, array){
				if(functionName.indexOf(inputFieldName) != -1){
					var functionToProcess = new Function("fieldName", functionName.replace(inputFieldName+"_","") + "(fieldName);");
					//Execute the function
					functionToProcess(inputFieldName);
				}
			});
		}
	}
	
	/**
	* Creates a row with a message indicating the CCLicense value set by the CCLicenseStep. 
	*/
	function selectChosenCC(licenseFieldName){
		$("fieldset#aspect_submission_StepTransformer_list_submit-describe div.control-group label.control-label").before('<p class="ds-form-item cc-license-user-selection"></p>');
		var ccSelectedRow = $('.cc-license-user-selection');
		var licenseText = extractCCLicenseText($('#'+ fieldIDPrefix + licenseFieldName).val());
		if (licenseText != null){
			if((licenseText.length > 0) && licenseText != "undefined"){
				ccSelectedRow.addClass('alert alert-warning').html("El usuario ha seleccionado la licencia <strong>Creative Commons "+licenseText+"</strong>.");
			}else{
				if($('#'+ fieldIDPrefix + licenseFieldName).val().length == 0)
					ccSelectedRow.addClass('alert alert-warning').html("<strong>ADVERTENCIA</strong>: no se ha seleccionado una licencia Creative Commons");
			}
		}
	}
		
	/**
	* Returns a CC License from the filtrate in a url. P.e.: for the 'http://creativecommons.org/licenses/by-nc-nd/4.0/
	* the function returns the string "Attribution NonCommercial NoDerivatives 4.0".
	*/
	function extractCCLicenseText(licenseURL){
	if(licenseURL != null){
			var ccKey = licenseURL.replace("http://creativecommons.org/licenses/","");
			var ccSplited = ccKey.split("/");
			var licenseText = "";
			//process CC features (p.e = "by-nd")
			ccKey.split("/")[0].split("-").forEach(function(feature, index, array){
				switch (feature){
					case "by": licenseText += "Attribution "; break;
					case "nd": licenseText += "NoDerivatives "; break;
					case "nc": licenseText += "NonCommercial "; break;
					case "sa": licenseText += "ShareAlike "; break;
				}
			});
			//process numberOfLicense
			licenseText += ccKey.split("/")[1];
			
			//process CC Jurisdiction, if exists (p.e = "by-nd")
			licenseText += (ccKey.split("/")[2] == "ar")? " Argentina":"";
			return licenseText;
	}
	}
	
	/**
	* Controls if the CC License field is selected with the correct CC License,  checking if it differs from value set by the CCLicenseStep.
	*/
	function ccInputFieldControl(inputFieldName){
		if($('#'+ fieldIDPrefix + inputFieldName).val().indexOf("http://creativecommons.org/licenses/") != -1){		
			var oldFieldValue = $('#'+ fieldIDPrefix + inputFieldName).val();
			//$('#'+ fieldIDPrefix + inputFieldName).val("");
			$('form.submission').on("submit unload", function(event){
				var AllowSubmit = ($('#'+ fieldIDPrefix + inputFieldName).val() == oldFieldValue)? false : true;
				if(!AllowSubmit){
					$('#'+ fieldIDPrefix + inputFieldName).addClass("error");
					(!$("div.msjCCError").length)?$('#'+ fieldIDPrefix + inputFieldName + "_confidence_indicator").after('<div class="error msjCCError alert alert-danger">*Debe seleccionar la licencia correspondiente</div>'):$.noop();
				}
				//Do a submit when the current CCLicense value differs of the old value.
				return AllowSubmit;
			});
		}
		//If user select "No license", then reset the field...
		$('form.submission').on("submit unload", function(event){
			if($('#'+ fieldIDPrefix + inputFieldName).val() == "Sin licencia"){
				$('#'+ fieldIDPrefix + inputFieldName).val("");
				$('#'+ fieldIDPrefix + inputFieldName + "_authority").val("");
				$('#'+ fieldIDPrefix + inputFieldName + "_confidence").val("");
			}
		});
	}
	
	/**
	 * Method used to make a field readonly
	 */
	function makeReadonly(inputFieldName, index, array){
		$('#'+ fieldIDPrefix + inputFieldName).prop("readonly",true);
	}
	
	//Evaluates the value of the dc.type field. If it changes, then submits the form and reload.
	function typeVerification(typeFieldName,index,array){
		
		$('form.submission').submit(function() {
		  if($(this).data("submitted") === true)
		    return false;
		  else
		    $(this).data("submitted", true);
		  });
		
		$('#'+ fieldIDPrefix + typeFieldName).on("autocompleteclose", function(event, ui){
		  var permitirSubmit = false;
		  if(oldTypeValue == "")
		    //Avoids make the submit if the autocomplete is currently empty.
		    permitirSubmit = ($(this).val() != "");
		  else
		    permitirSubmit = (oldTypeValue == $(this).val())? false : confirm("¿Está seguro que desea cambiar el tipo de documento?");
		  if(permitirSubmit) {
		    //Make the submit if the user select a new tipology
		    //Realizamos el submit de la página en caso de seleccionar una nueva tipología
		    oldTypeValue = $(this).val();
		    $('form.submission').submit();
		  } else {
		    //In case that the type does not have to change, returns to its original value
		    //En caso de que no haya que cambiar el tipo, se lo vuelve a su valor original 
		    $(this).val(oldTypeValue);
		  }
		});
	}
	
}