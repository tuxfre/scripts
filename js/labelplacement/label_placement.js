/**
 *  @file	label_placement.js
 *  @name	BVIG's lablel placement JS hack
 *  @brief	A script to add label placement guidelines (screenshots from the label specification PDFs) to the label printing GUI.
 *  @usage	Just insert script tag below at the end of your page (just before </body>, + don't forget to adapt the path to the JS file)
 *  		<script src="label_placement.js" type="text/javascript"></script>
 */

window.onload = function() {
	/***************************************************************************************************************************************************************************************************************************/
	// Script configuration																							[type]		Description												Sample value
	var scriptconfig = [];																						//	************************************************************************************************************
	scriptconfig["higlightchanges"]		= true;																	//	[boolean]	Should we highlight the edited input fields				true
	scriptconfig["appname"]				= "Label placement guidelines";											//	[string]	Title of our container									"Label placement guidelines"
	scriptconfig["higlightcolor"]		= "rgb(255, 255, 0)";													// 	[string]	If yes, which background color, CSS compatible string	"rgb(255, 255, 0)"	[For IE11, no alpha]
	scriptconfig["higlighttextcolor"]	= "rgb(255, 0, 0)";														// 	[string]	If yes, which text color, CSS compatible string			"rgb(255, 0, 0)"	[For IE11, no alpha]
	scriptconfig["higlighttextweight"]	= "bold";																// 	[string]	If yes, which text weight, CSS compatible string		"normal"
	scriptconfig["showpictures"]		= true;																	//	[boolean]	Should we display the label placement pictures			true
	scriptconfig["imageroot"]			= "./images/";															//	[string]	Path to the root folder for the images					"./images/"
	scriptconfig["imagezoom"]			= "166%";																//	[string]	Zoom percentage when the mouse hovers the images		"150%"
	scriptconfig["jqueryjsurl"]			= "//code.jquery.com/jquery-3.3.1.min.js";								//	[string]	URL of jQuery's main JS file (can be a local path)		"//code.jquery.com/jquery-1.7.1.min.js"
	scriptconfig["jqueruiyjsurl"]		= "//code.jquery.com/ui/1.12.1/jquery-ui.min.js";						//	[string]	URL of jQueryUI's main JS file (can be a local path)	"//code.jquery.com/jquery-1.7.1.min.js"
	scriptconfig["jqueryuicssurl"]		= "//code.jquery.com/ui/1.12.1/themes/ui-lightness/jquery-ui.min.css";	//	[string]	URL of jQueryUI's main CSS file (can be a local path)	"//code.jquery.com/jquery-1.7.1.min.js"
																												//	[object]	CSS attributes for our container (woops, too long...)	[JS Object, see doc on $.css()]
	scriptconfig["containerstyle"]		= {"width": "42%", "height": "94%", "padding": "0.5em", "top": "3%", "right": "1.5%", "position": "absolute", "overflow-x": "hidden", "overflow-y": "auto"};
																												//	[string]	CSS style for the warning p	(woops, too long...)		[valid CSS]
	scriptconfig["warningstyle"]		= "background-color: rgb(255, 255, 0); color: rgb(255,0,0); font-weight: bold; font-size: 150%; border: 5px solid rgb(255,0,0); margin: 0.75em; padding: 0.5em;";
																												//	[string]	URL for our loading image	(woops, too long...)		[valid URL, including dataurl]
	scriptconfig["loading"]		= "data:image/gif;base64,R0lGODlhZAANAOMAALy+vOTm5Pz6/MzOzMTGxPTy9MTCxOzq7Pz+/P///wAAAAAAAAAAAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQJBQAJACwAAAAAZAANAAAEzTDJSau9OOvNu/9gKI5kaZ7ohAgCYq3ty7oVTFO2HNezfqs93o4SGAwOluIxaURWlE5ik7l8Tq1VaXYCrRQIBgChQPkCxOSJGV0mnMftd1qyhqvd7Ls8nqfj7RIHZwAGARSCZ4WHhISGE4Jhio+MkoGUjpaRmAmQjYuJm4ieeoRzCWsGpqiqeKl8rqSwfomstK+1pRUHV1pRXEabgcAWuwPBnMO6yYfLj7y/WxIsQxPTP9JBFNYW2xXd2tnV4djU5Ncp6Onq6+zt7u/wExEAIfkECQUAEwAsAAAAAGQADQCEfH58xMLE5ObkpKKk9Pb0jI6M1NLUzM7M7O7svLq8/P78lJaUhIaExMbE7Ors/Pr8lJKU3NrcvL68////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABf7gJI5kaZ5oqq5syyrPo7h0bd+0Iy2LhODAoHDlgACOgIWDBJOZmrMS9BmLMqtUpxS71V69jwESOXiMHAfDsiQwHNYktNrUfpvk8FE9L8LT3XwTfiICBWNHBWsEDRISDQQki42PkYyOkCOSl5WTmCKalJmWoZ+jnhOgmBEMh0cRfY0JAXkOAQkSs3GxuWe2uLS7tL68sBKywrfEgsGEhoeJnwG2pKgBnZXTpwTWm6LZkdzUi9+Z4doN5GGtZWcHdiWDce6B8e3v8nPw83dp9PtnRpBAyFPFyogYXg5y+WJQBMKGE6aUeJgFIsU4CSBASBBoiMePNpqYAUmypMmTKAODhAAAIfkECQUAFQAsAAAAAGQADQCEfH58xMLE5ObkpKKklJKU9Pb01NLUjI6MhIaEzM7M7O7stLa0nJ6c/P78hIKExMbE7OrslJaU/Pr83NrcvL68////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABf5gJY5kaZ5oqq5s66KNJDVvbd94pRiJUkKUSCTgyxmPuIaB4HBEErQKhACoAiIQUmxm2ka1su/I2w2XuSVy2jwSOKwAh6AiGVTf8YFkBEkYsj9+gCR9fyaFg3yCh4uBho6JC3BVC1IHkwAHcxUFDxQUDwUknZ+ho56goiOkqaelqiKspquos7G1sHaTAxUTCJgOEyIQAZ8BiQrFFMckycbIyswjzsvQz83R1tUjkpOVEJeTCICysJyoAeas6a7L6ujvxurKtpz0sG5wDll1mHp8Bh4RCphoGMFDB38kHCgQYEODDZUwAUAAyjAqVggkkoGGBEcxIj6aEFmCpEc2YB46jjAJMEFBCAsIEKBQEInNmze27MHJs6fPn0BXhAAAIfkECQUAGAAsAAAAAGQADQCEfH58xMLEpKKk5ObklJKU9Pb0jIqM1NLUtLa07O7shIaEzM7MnJ6c/P78vL68hIKExMbE7OrslJaU/Pr8jI6M3NrcvLq89PL0////AAAAAAAAAAAAAAAAAAAAAAAAAAAABf4gJo5kaZ5oqq5s675jM00NbN/42dRmchyJUsQhkQSCuaRSNTkwGIdJ7EB4ACQHXoQA6D4kkdIMNT6VTWex1LxGt0WNQBfwcGit88cAMxHM5wJtPgdhJYOFJIc9P4gjioaMi4QkFwp/BhciCH9dFhgDFJwAFIUFEA4OEAUkpqiqrKepqyOtsrCusyK1r7SxvBgJooUMogIYFQp4eRUiEQGoAY0Jzw7RidTWjtjS29fQ3N8jFwaXmRibnJ6gogalpxa/GKYWtr308fP1uhD3ufL8+v71GzHBwh8LayIooxOmT7E2ESIJkUgi4qSJFytSHGGxUbONfJwwWNCmSRUABDGiNOMyh4DHNCRgEnwTk+ZMMjZFyNSZ08cCjxEsECBgweOSo0hvyKCRtKnTp1CjiggBACH5BAkFABgALAAAAABkAA0AhHx+fMTCxKSipOTm5JSSlPT29IyKjNTS1LS2tOzu7ISGhMzOzJyenPz+/Ly+vISChMTGxOzq7JSWlPz6/IyOjNza3Ly6vPTy9P///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAX+ICaOZGmeaKqubOu+bTNNDWzf+NnUZnIciVLEIZEEgrmkUjQzTQ4MxmEyahwID4DkwIsQAOCHJFJqnsxO6lmdRqFJkR+56siCA7yBPUyeCMCAAAJsPgdzJIWHI4k9co2Gj4oYBRAODhAFIxcGgQYXIhaBYBYYAxSiABRzlJaYJKyXmSOwrrOVsa+3tSK0siIJAZYBhwmocwyoAhgVCqgPFSIRwQ7DiNPVi9eKwMLb2tbduQ4WuxfNgJ4iCKikpntgBquV5L6TEBa4tvi79vv1lP5yBYTjaMSEOoAsqInw7kGfP6IGjYgDSUhBghUxSsJAcWPHNU4WRFnAZsICLAAxCEyJ9gUQAUlvSMQ0yKZMTZk3ad6YieHCgQWSIlggQMDCxiVIk9qQQUOp06dQoy4JAQAh+QQJBQAZACwAAAAAZAANAIR8fnzEwsTk5uSkoqSUkpT09vTU0tSMiozs7uy0trSEhoTMzsycnpz8/vzc2ty8vryEgoTExsTs6uyUlpT8+vyMjoz08vS8urzc3tz///8AAAAAAAAAAAAAAAAAAAAAAAAF/mAmjmRpnmiqrmzrvvDZUFQT33g+NraJGAZESfKYTAJCnZJFQzVLFAODYaDsDAQIYGLoSQiAMGQigVpPT1Pa7DwPgeXSzxAXNR7acKAnyIvLFANhgwADbnN1I4g+cIx0jokZBREPDxEFJJOVlyMWB4QHFiIXhGEXGQIVpQAVcZqWmCOvnLKUsJm2tCKzsSIIAZUBib/BdQircQyrAxkOCqsQDiISwA/CJMTWw9XXitzbxbgPF7qSERe3IhbPg6EiCaunAmClB66U5L3m6OWT/Pr+0u06J3BaozePRlDAM+jCGQl+AEAAJKiUoRESDpLImHCjRowfDXYksYakG4ULNKYscENhQRYABKpMoxeGQKSSCk+abMNzyU4TFgwsiCThAgECFyL5XMr0xYwaTaNKnUoVRQgAIfkECQUAGQAsAAAAAGQADQCEfH58xMLE5ObkpKKklJKU9Pb01NLUjIqM7O7stLa0hIaEzM7MnJ6c/P783NrcvL68hIKExMbE7OrslJaU/Pr8jI6M9PL0vLq83N7c////AAAAAAAAAAAAAAAAAAAAAAAABf5gJo5kaZ5oqq5s675w3FBUE994Pja2iRgGREnymEwCQp1SREM1T08SxcBgGCg7AwECmBh6EgJgDJlISlE0Fro2pUcS4Ln0M8xJ9Xum8eCOAz0CfmRnFANjiAADbXk+co52kHoZBREPDxEFJJWXmZuWmJoiFgeJBxYiF4ljFxkCFasAFXOcoZ+doiK1niO7uRkIAZcBesHDxcIPxCMIsXMMsQMZDgqxEA4iEsnLzNvIx3jetxe8uhEXtr3n6RkW1YinIgmxrQJiqwe0luS/lejllNYB9Mcu26MhB0nEiTSCQh9EF9ZIGAQAQqFDqxbBSbiRoUKOBj1KaaPGCUkmCzKqLGhDYcEWAASuZLs3hsCkNw1P5jS55AXOdgYWTJJwgQCBC5N6Kl36YkYNplCjSo0aAgAh+QQJBQAZACwAAAAAZAANAIR8fnzEwsTk5uSkoqSUkpT09vTU0tSMiozs7uy0trSEhoTMzsycnpz8/vzc2ty8vryEgoTExsTs6uyUlpT8+vyMjoz08vS8urzc3tz///8AAAAAAAAAAAAAAAAAAAAAAAAF/mAmjmRpnmiqrmzrvnCsNhTVyHieN7eJGAZESfKYTAJCnauGYp6cJuiIYmAwDJRRw0CAACaGnoQAKEMmkpKUtJ5mTRJguvQzzEn1+yhPajy8ZQE9AoBmaRQDZYoAA28ZfHRyPpIkBREPDxEFlZeZmyOWmJqcop8ZFgeLBxYiF4tlFxkCFa8AFXOhnqS6oJ2jewGYAXoIwQ/DeMbIwMJ3CLVzDLUDGQ4KtRAOIhLKxN3JzaQXvyKWF7zlEefkGeboFteKqyIJtbECZK8HuJfjpu3q0AFc9y9DHDtwKJE4qGebwgwU/ii68EZCIQAQDiV61WgEw4QIhzx008SRGpNsNVBCXGBlgSMKC7oAIIBlW74yBBq2EbETokolOXZaMLCgoYQLBAhcaAi0qVMZNGw8nUq1KtAQACH5BAkFABkALAAAAABkAA0AhHx+fMTCxOTm5KSipJSSlPT29NTS1IyKjOzu7LS2tISGhMzOzJyenPz+/Nza3Ly+vISChMTGxOzq7JSWlPz6/IyOjPTy9Ly6vNze3P///wAAAAAAAAAAAAAAAAAAAAAAAAX+YCaOZGmeaKqubOu+cCyLDUU1c67HDW4iBgOiJHlMJoHhbmRDNU9PU7Q0FVEMDIaBMmoYCBDAxOCTEABoyERC5ULdxCC7BDTMSfX7KP+TkxoPYWgBPgKCaWwUA2iMAANwfHR+JAURDw8RBZSWmJojlZeZm6GeIqCdIxYHjQcWIheNaBcZAhWxABVzp6KfnLwiCAGXAXrBw8XCD8R4yct7zXcIt3MMtwMZDgq3EA4iEtDMx6MXvxmVF6i96OXn6aYR66UW2oytIgm3swJnsQe6luRKmYPnztskEhIOjkhoxwRDPQYbMgnE6IIbCYcAQEi0KNajhQojQrQCp42TkiQ1qjBBmYHCgiwL4LgEA4DAFm/80BCAqJLkkp8relowsACihAsECFwYCbSp0xU1bjydSrVqiRAAIfkECQUAGQAsAAAAAGQADQCEfH58xMLE5ObkpKKklJKU9Pb01NLUjIqM7O7stLa0hIaEzM7MnJ6c/P783NrcvL68hIKExMbE7OrslJaU/Pr8jI6M9PL0vLq83N7c////AAAAAAAAAAAAAAAAAAAAAAAABf5gJo5kaZ5oqq5s675wLLMNRTVzrscNbiIGA6IkeUwmgeHLhmKenCZoSUqiZigGBsNAGTUMBAhgYvBJCIA0ZCKZdk2SYLsENMxJ9fso/5P37SQND2JpAT4ChGptFANpjgADbxl8JAURDw8RBZWXmZsjlpianKKfIqGepKkiFgePBxYiF49pFxkCFbQAFXOoo3sBmAF6CMEPw3jGyMDCxMrOzXu6cwy6AxkOCroQDiISz6QXv6cRF6vk5uMZlumm6+Xn7+0jFtqOsCIJurYCaLQHvS6Jc5chDiAifhAeJGFQj7eEDCFeGeTowhsJiQBAWNSIVqQRDZ9IctNkZBWTIzKsiLBCYYGWBZJahgFAgIs3f2kIOFS5oycMlRYMLHAo4QIBAhcc+lzK9EWNG02jSpUaAgAh+QQJBQAZACwAAAAAZAANAIR8fnzEwsTk5uSkoqSUkpT09vTU0tSMiozs7uy0trSEhoTMzsycnpz8/vzc2ty8vryEgoTExsTs6uyUlpT8+vyMjoz08vS8urzc3tz///8AAAAAAAAAAAAAAAAAAAAAAAAF/mAmjmRpnmiqrmzrvnAsz2NDUQ2t726TmwiDAVGSPCaTALF0QzVPT1OUSXFWoVcSxcBgGLINAwECmBh+EgJgDZlISBLhuxQ0zEn1+ygPlPftf3oND2RrAT8ChWxvFANrjwADVwURDw8RBSSUlpialZeZI5ugnpyhIqOdop+qGRYHkAcWIheQaxcZAhW2ABVzCAGWAXrAwsTBD8N4yMp7zMfGy9EiCLxzDLwDGQ4KvBAOqJUXrRmUF6Sr5+Tm6OHqp+UR757zIhbdj7IiCby4Amq2DtyJA6iIH4MF4RxUmHAEQT0iHmoh9OjCFQmKAEBg5MiWJC1ZqFgZiYWklJAiLygs6LIgi8oxAAh8iQhwDQGIPHLymDLCgoEFECVcIEDgAk6dSJOusIFDqdOnMEIAACH5BAkFABUALAAAAABkAA0AhHx+fMTCxOTm5KSipPT29JSSlMzOzOzu7LS2tIyKjPz+/JyenLy+vISChMTGxOzq7Pz6/JSWlNTS1PTy9Ly6vP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAX+YCWOZGmeaKqubOu+cCzPdG3fqKKch2QcJgUEsisJicFhkXRcjppJpFEZdVYghsHCAHlKCoBGxOB8GCQPk0AiEZgevnTJjFaz3fP4+ywnrdtMDA0AYQxdFQKDhGF4FQQODAwOBCSPkZOVkJKUI5abmZecIp6YnZqlo6eiEwmLAAkTIgiuhAgjDwGRAX0VuLq8vgy7JMHDt7nCwMjGIsXKv7e0AHIL0gOmFJKx2NqZ2Q7bqd/hjg7j3t3c4OjrIhOKhA3bs7S2t3p5BrzNbPu9fHvq5BFIDOAcgyIgMHBF4dADeGF4QSkxRAqJilYqTGRChSIEAhk3Puk4AsuCLYcYrnwhVIALjpcwVQw5AUdfzJs4c+rcCTMEACH5BAkFAA8ALAAAAABkAA0Ag3x+fMTCxOzq7Ly6vPT29JyenISGhMzOzPTy9Pz+/MTGxOzu7Ly+vPz6/IyKjP///wTn8MlJq7046827/2AojmRpnmKSXEnTrFX7WjJM1bRrT3is5zNfcNI4FAqHRkVwOAgsTCe0+VxSp1JrlhKtcq9a76PBAJgBAaWEoGAwFAgKIeCGUxDtd3yCr+8lfXp3eXZ8hH8PgYWAh3wOZwAOfwJuDAFilG6XXG4DmxOZnpidnxKhpQ+nowyinKylApBmXngBnohsrIuJeQG4vb+awZbDvnLAg8ITCwaQBohdWGKmYF9boNXY19TbqdncYg0DkANqEj0ULkNEPxXqOxLvFvLu7en27OtjRkjmKP8ARbgISLCgwYMIA0YAADtpVmgzKy91V3JOZmZCdndmNDRMTGNOMmdRR1dKQ3Z1VG1nSXova0JuK2taR2xhVjlDVThIYVdEd1JiN1hJbzR3";
	// Which elements we target in the page
	var targetelements = [];																					//	************************************************************************************************************
	targetelements["inputs"]			= "input[name='f04']";													//	[string]	The jQuery selector for the inputs to be highlighted	"input[name='f04']"
	targetelements["lotid"]				= "#P320_LOTID";														//	[string]	The jQuery selector for the lotid						"#P320_LOTID"
	targetelements["partid"]			= "#P320_PARTID";														//	[string]	The jQuery selector for the partid						"#P320_PARTID"
	targetelements["recipe"]			= "#P320_RECIPE_ID_DISPLAY";											//	[string]	The jQuery selector for the recipe name					"#P320_RECIPE_ID_DISPLAY"
	targetelements["labelset"]			= "#P320_LABELSET_ID_DISPLAY";											//	[string]	The jQuery selector for the labelset name				"#P320_LABELSET_ID_DISPLAY"
	targetelements["param_table"]		= "#R10789303400736206";												//	[string]	The jQuery selector for the promis param table			"#R10789303400736206"

	// Misc. useful variables
	var pagetitle 						= "Print Shipping Label"; 												//	[string]	The expected title of the page we target				"Print Shipping Label"
	/***************************************************************************************************************************************************************************************************************************/

	// Script
	if(typeof jQuery === "undefined") {
		// Start by loading the jQuery js file
		var jqueryscripttag = document.createElement("script");
		jqueryscripttag.src = scriptconfig["jqueryjsurl"];
		jqueryscripttag.type = "text/javascript";
		document.getElementsByTagName("head")[0].appendChild(jqueryscripttag);
	}
	// Now let's check whether the page title is the one we expect
	if ($(document).prop("title") === pagetitle) {
		// We're on the right page, let's populate some variables
		var lotid		= $.trim($(targetelements["lotid"]).text());
		var partid		= $.trim($(targetelements["partid"]).text());
		var recipe		= $.trim($(targetelements["recipe"]).text());
		var labelset	= $.trim($(targetelements["labelset"]).text());
		// Let's hide the horizontal scrollbar on the page for purely cosmetic reasons ;)
		$("body").css({"overflow-x": "hidden", "overflow-y": "auto"});
		// Let's display the "Label already printed" warning
		// Recommended date format ISO 8601 (see https://xkcd.com/1179/)
		$("<p id=\"labelset_warning\"><b style=\"font-size: 150%; background-color: red; color: white; margin-bottom: 2em;\"><span class=\"ui-icon ui-icon-alert \"></span>Beware</b><br/>Lot <b>B21323.L14</b> was already printed with recipe <b>VPK01</b> on <b>2018-05-28T09:31:19Z</b> by user <b>bvig</b> on printer <b>PU006_1</b></p>").insertBefore( targetelements["param_table"] );
		$("#labelset_warning").dialog({title: "Label already printed"});
		// Let's allow highlighting the changed fields, if enabled in the settings
		if (scriptconfig["higlightchanges"]) {
			$(targetelements["inputs"]).change(function(){
				$(this).css({"background-color": scriptconfig["higlightcolor"], "color":  scriptconfig["higlighttextcolor"],"font-weight": scriptconfig["higlighttextweight"]});
			});		
		}
		// Let's add the picture container and pictures, if enabled in the settings
		if(scriptconfig["showpictures"]) {
			// Detect if jQueryUI is loaded
			if(typeof jQuery.ui ===  "undefined") {
				// Start by loading the jQueryUI js file
				$.ajax({
				  url: scriptconfig["jqueruiyjsurl"],
				  dataType: "script",
				  cache: true
				  });
			}
			// And then brute-load our CSS theme for jQuery UI
			$("<link/>", {
				rel: "stylesheet",
				type: "text/css",
				href: scriptconfig["jqueryuicssurl"]
			}).appendTo("head");
			// Create a container for the images
			$("body").prepend("<div id=\"labelplacement\" title=\"" + scriptconfig["appname"] + "\" class=\"ui-widget-content\"><h2 class=\"ui-widget-header\">" + scriptconfig["appname"] + "</h2><div id=\"jsonresult\">\n</div></div>");
			// Add some styling
			$("#labelplacement").css(scriptconfig["containerstyle"]);
			// Make our container draggable
			$("#labelplacement").draggable();
			// Make our container resizable (yes, yes, I could have done both in one single line...)
			$("#labelplacement").resizable();
			// Fetch the json file containing the infos
			$.getJSON("labelsets.json", function(data) {
				// Loop the labelsets [todo: better variable naming]
				$.each(data, function(key, val) {
					// Identify the labelset used on the page
					if (val.name === labelset) {
						// Loop the label placement items for this labelset
						$.each(val.data, function(key1, val1) {
							// Create a sring containing the image
							var labelsetinfo = "<p><img src=\"" + scriptconfig["loading"] + "\" onload=\"this.src='" + scriptconfig["imageroot"] + "" + val1.image + "';\" width=\"?\" height=\"?\" title=\"" + val1.comment + "\" class=\"lblplacement\"></p>";
							// If a warning is defined for this image then we add it to our string
							if (val1.warning !== undefined) {
								labelsetinfo = labelsetinfo + "<p title=\"Warning! Please, pay attention.\" style=\"" + scriptconfig["warningstyle"] + "\">" + val1.warning + "</p>";
							}
							// If we add a link defined, we add it too
							if (val1.link_url !== undefined) {
								labelsetinfo = labelsetinfo + "<p>Link to: <a href=\"" + val1.link_url + "\" target=\"_blank\" title=\"Click here to open " + val1.link_text + " in a new window\">"+ val1.link_text + "</a></p>" ;
							}
							// Finally we add our string (including a title) to the DOM
							$("#jsonresult").append("<h3 title=\"" + val1.comment + "\">" + val1.comment + "</h3>\n<div style=\"border-bottom: 2px solid rgb(200,200,200)\" title=\"" + val1.comment + "\">" + labelsetinfo + "</div>\n\n");
						});
					}
				});
				$("img.lblplacement").hover(function() {
					$(this).css({"zoom": scriptconfig["imagezoom"]});
				}).mouseout(function() {
					$(this).css({"zoom": "100%"});
				});
			});
		}
	}
}