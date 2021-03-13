using Toybox.Application;
using Toybox.WatchUi as Ui;

class Slope_WidgetApp extends Application.AppBase {
	
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
    function onSettingsChanged(){
        Ui.requestUpdate();
    }
}