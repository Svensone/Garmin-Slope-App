using Toybox.Application;
using Toybox.Position;
using Toybox.System as Sys;

class Slope_WidgetApp extends Application.AppBase {

	var locationString;
	
    function initialize() {
        AppBase.initialize();
    }
	
	function onStart(state) {
	}
	
	function onStop(state) {    
	}
    // Return the initial view of your application here
    function getInitialView() {
        return [ new Slope_WidgetView() ];
    }

}