/*!
 *
 *  @copyright:___________2012, Kundenname
 *  @link:________________http://www.kundenwebseite.de
 *  @author:______________Jung von Matt/Neckar
 *  @namespace:___________JM
 *  @projectDescription:__global plugins/functions
 *
 *  @version:_____________1.0
 *  @revision:____________$Revision: 1819 $
 *  @lastmodified:________$Date: 2012-09-07 16:48:49 +0200 (Fr, 07 Sep 2012) $,  $Author: oliver.hook $
 *
 */

/**
 * Use a closure to protect namespace and `$`
 */
(function($) {

	/**
	 * Create private namespace
	 * 
	 */
	var JM = {};

	JM.isIPad = navigator.userAgent.match(/iPad/i) !== null;
	JM.isIPhone = navigator.userAgent.match(/iPhone/i) !== null;
	JM.isIPod = navigator.userAgent.match(/iPod/i) !== null;
	// TODO is android

	/**
	 * Global public vars
	 * 
	 * @alias globalPublicVars
	 * @namespace JM
	 * @return {boolean, string}
	 */
	JM.globalPublicVars = function() {
		var config = {
			'var1' : '1',
			'var2' : 2
		}

		var setVar = function(varName, varData) {
			config[varName] = varData;
		}

		var getVar = function(varName) {
			return config[varName];
		}

		return {
			setVar : setVar,
			getVar : getVar
		}
	}();

	// Set/Get vars:
	// JM.globalPublicVars.setVar('var1',false)
	// JM.globalPublicVars.getVar('var2')

	/**
	 * A short snippet for detecting versions of IE in JavaScript without
	 * resorting to user-agent sniffing
	 * 
	 * @alias IeSniff
	 * @namespace JM
	 * @return {string} of ie browser/version
	 */
	JM.IeSniff = function() {

		var undef, v = 3, div = document.createElement('div'), all = div
				.getElementsByTagName('i');

		while (div.innerHTML = '<!--[if gt IE ' + (++v)
				+ ']><i></i><![endif]-->', all[0])
			;

		return v > 4 ? v : undef;

	}();

	// Thus, to detect IE:
	// if (JM.IeSniff) {}
	// And to detect the version:
	// JM.IeSniff === 6 // IE6
	// JM.IeSniff > 7 // IE8, IE9 ...
	// JM.IeSniff < 9 // Anything less than IE9

	$(document).ready(function() {
		if ($.browser.flash == false) {
			// $(".JM_areaDc").show();
		}

		window.setTimeout(function() {
			FB.init({
				appId : '@project.facebook.appid@', // App ID
				status : true, // check login status
				cookie : true, // enable cookies to allow
				oauth : true, // enable OAuth 2.0
				xfbml : true
			// parse XFBML
			});

			FB.Canvas.setAutoGrow();
			// FB.Canvas.setSize({ width: 809, height: 900 });

		}, 250);

		$('#footerImprint').click(function(event) {
			event.preventDefault();
			openImprint();
		});
		$('#footerTerms').click(function(event) {
			event.preventDefault();
			openTerms();
		});
		$('#footerPrivacy').click(function(event) {
			event.preventDefault();
			openPrivacy();
		});
	});

})(jQuery);