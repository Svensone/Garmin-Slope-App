using Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Position;
using Toybox.Sensor;
using Toybox.Graphics as Gfx;
using Toybox.Math;
using Toybox.Communications as Comm;

// 		Variables
// Accelerometer
var aX = null;
var aY = null;
var aZ = null;
var angleL = null;
var zAngle = 30;
var zAngle_short = null;
var zSlope = null;
var zAngleV2 = null;
var zSlopeV2 = null;
var x1= 260;
var x2 =130;
var y1= 60 ;
var y2 = 130;

// GPS Variables
var locationString;
var referenceLocation;

// //Display
var displayWidth = 260;
var displayHeight = 260;

// Elevation Api
var angleAPI; 

class Slope_WidgetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }
	
	var backgroundImg;
    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        
		displayWidth = dc.getWidth();
		displayHeight = dc.getHeight();
		
		
		// Load resources
        backgroundImg = WatchUi.loadResource(Rez.Drawables.bg);
        // activate GPS Data
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:setPosition));
        // activate Accelerometer (period= every "" seconds, sampleRate= number of values per period)
		var options = {:period => 1, :sampleRate => 1, :enableAccelerometer => true};
		Sensor.registerSensorDataListener(method(:accelHistoryCallback), options);
		
		View.onUpdate(dc);
	}

	function accelHistoryCallback(sensorData) {
		// Step 1: Gett the data: 

		// Option1:  sensorData
		// Which value from sensorData? mean value or set treshold?
		var xAccel = sensorData.accelerometerData.x[0];
		var yAccel = sensorData.accelerometerData.y[0];
		var zAccel = sensorData.accelerometerData.z[0];
		System.println("Accelerometer Data from .accelerometerData x, y and z : "+ xAccel + ", " + yAccel + ", " + zAccel);
		
		// Option 2: Sensor.getInfo() // why different data from Sensor.getInfo()? sensorData(see above) same with .FIT file
//		var info = Sensor.getInfo();
//		var accel = info.accel;
//		// Acceleration Data
////	var xAccel = accel[0];
////    var yAccel = accel[1];
////    var zAccel = accel[2];
//		System.println("Accelerometer Data from .getInfo() x, y and z " + accel );

		// Step 2: Normalize the data:

        // Normalize the data
        // var norm = Math.sqrt(sq(xAccel) + sq(yAccel) + sq(zAccel));
        // var xNorm = xAccel / norm;
        // var yNorm = yAccel / norm;
        // var zNorm = zAccel / norm;
        
		// Step 3: Calculate the Angle and Slope of Device deviation from hor. position 

        // Version 1:
        // http://wizmoz.blogspot.com/2013/01/simple-accelerometer-data-conversion-to.html
        // only for Z since indicates angle device deviation from horizontal position
        zAngle = Math.atan(Math.sqrt(sq(xNorm) + sq(yNorm)) / zNorm);
        
        zAngle = zAngle / Math.PI * 180; // from radians to degrees
        zAngle_short = zAngle.format("%.f"); // no decimal needed 
        
        // steigungswinkel -> Steigung m= tan(alpha)
        zSlope = Math.tan(zAngle);
        System.println( "Version 1: Angle in degrees : " + zAngle_short + "  Slope : "+zSlope);
        
        // Version 2: WRONG !?
        // https://github.com/otfried/cs109-kotlin/blob/master/mini-apps/gravity2.kt
//        //http://otfried.org/courses/cs109/project-level.html
//        zAngleV2 = Math.atan2(xNorm, yNorm);
////        //convert to degrees
//        zAngleV2 = zAngleV2 * 180 / Math.PI;
//        zSlopeV2 = Math.tan(zAngleV2);
//		System.println( "Version 2 : Angle in degrees : " + zAngleV2 + "  Slope : "+zSlopeV2);

		// Versioin 3 :
		// see Pdf 'Freescale Accelerometer' Ch. 5 
		var m = Math.sqrt(( Math.pow(xAccel, 2) + Math.pow(yAccel, 2) + Math.pow(zAccel, 2)));
		var cos_p = zAccel / m;
		var zAngle3 = Math.acos(cos_p);
		zAngle3 = zAngle3 * 180 / Math.PI;
		var zslope3 = Math.tan(zAngle3);

		// Getting the coordinates for the slope line on display

		x1 = displayWidth / 2 ; 
		y1 = displayHeight / 2 ;
		x2 = displayWidth ;
		y2 = (zSlope3)*(displayWidth - x1) + y1;
		System.println("coordinates for slope line on display : x1/y1 :" + x1 + "/"+ y1 + " x2/ y2 : " + x2 + " /" + y2);
        
		//		NOT NEEDED !? 
		// y-Value for slope-line on display (x=130 and y=130 center of display of fenix6S)
		// normally wearing watch left arm -> arm movement max -40 to +90 degrees
		// background image enough if slope fields on right side (left side not needed?)
//		if (zAccel >0) {
//		x1 = 130 ;
//		y1 = 130 ;
//		x2 = 260 ;
//		y2 = (zSlope)*(260-130)+130;
//		} else {
//		x1 = 0;
//		y1 = (-zSlope)*(260-130)+130;
//		x2 = 130 ;
//		y2 = 130;
//		}

		
		
		
		
		WatchUi.requestUpdate();
		}

    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // clear the display
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	dc.clear();
    	// Draw backgroundImage, Line (Deviation from horizontal Level) & Data
    	dc.drawBitmap(0, 0, backgroundImg);
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		dc.drawLine(x1, y1, x2, y2);
		// Slope Data
		dc.drawText(120, 176, Gfx.FONT_XTINY, zAngle_short, Gfx.TEXT_JUSTIFY_LEFT);
		// Gps Data
		dc.drawText(120, 220, Gfx.FONT_XTINY, angleAPI, Gfx.TEXT_JUSTIFY_LEFT);

        WatchUi.requestUpdate();
    }
    
    function setPosition(info) {
        
        // create String of GPS Data for Api Call
        var myLocation = info.position.toDegrees();
        var lat = myLocation[0];
        var long = myLocation[1];
        locationString = lat + "," + long;
// 		second Gps Location
		var long2 = long + 0.001; // lat and long in decimaldegrees - adding 1 sec for 30.9m to longitude
		referenceLocation = lat + "," + long2;
       	System.print("GPS Location at:" + locationString + ", reference-location at:  " + referenceLocation);
        
        makePlacesWebRequest(); // Make API Call 
        WatchUi.requestUpdate(); 
    }
    function makePlacesWebRequest() {
		// 1. Google Maps Platform Api for Elevation - not free of cost
//    	var url = "https://maps.googleapis.com/maps/api/elevation/json?locations=" + locationString + "&key="+ $.google_elevation_api_key; 	
    	
		// 2. Airmap API // free of charge ?
//		make API Call for 2 gps-locations
		var url =  "https://api.airmap.com/elevation/v1/ele/path?points=" + locationString + "," + referenceLocation + "/X-API-Key:{" + $.airmap_key +"}/Content-Type:application/json;charset=utf-8";
	
		var parameters = {
    	 };
    	
    	var options = {
    	:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
    	};
    	
    	Comm.makeWebRequest(
    	url,
    	parameters,
    	options,
    	method(:onReceive)
    	);
    }
// 	check if successful, otherwise error code of https response
    function onReceive(responseCode, data) {
    	if (responseCode == 200){
    	parseResponse(data);
    	} else {
    	System.println("Call unsuccessful, error code: " + responseCode.toString());
    	}
    }
//  parse response data and calculate slope angle of current gps location
    function parseResponse(data){
	    var results = data.get("data");
		var results1 = results[0];
		// elevation in meter for path between gps-location 1 and gps-location 2 (30.9m )
		var profiles =  results1.get("profile");
		System.println(profiles);
		
		// take difference of first and last elevation result from "profiles" -> opposite cathete
		var height_diff = null;

		height_diff = profiles[0]- profiles[3];
		System.println(" height Difference in m : " + height_diff + " on a length of 30.9m");

//		if (profiles[0]> profiles[3]) {
//			height_diff = profiles[0]- profiles[3];
//		} else {
//			height_diff = profiles[3] - profiles[0];
//		}

		// angle of right traingle with arctan( opposite cathete / ankathete) 
		// ankathete = 30.9 since adding 1 sec to longitude 
		var angle = Math.atan2(height_diff, 30.9);
		// angle in degrees
		angleAPI = angle * 100;
		angleAPI = angleAPI.toNumber().format("%.2f");
		System.println(" API Angle in degrees : " + angleAPI);
    	WatchUi.requestUpdate();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    
    function onHide() {
    	// disable Listeners for battery/memory saving
    	Sensor.unregisterSensorDataListener();
    	Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:setPosition));
    }
    	
	// helper function
	function sq(x) {
			return x * x;
			}

	// Helper function to check type of object
	function type_name(obj) {
	    if (obj instanceof Toybox.Lang.Number) {
	        return "Number";
	    } else if (obj instanceof Toybox.Lang.Long) {
	        return "Long";
	    } else if (obj instanceof Toybox.Lang.Float) {
	        return "Float";
	    } else if (obj instanceof Toybox.Lang.Double) {
	        return "Double";
	    } else if (obj instanceof Toybox.Lang.Boolean) {
	        return "Boolean";
	    } else if (obj instanceof Toybox.Lang.String) {
	        return "String";
	    } else if (obj instanceof Toybox.Lang.Array) {
	        var s = "Array [";
	        for (var i = 0; i < obj.size(); ++i) {
	            s += type_name(obj);
	            s += ", ";
	        }
	        s += "]";
	        return s;
	    } else if (obj instanceof Toybox.Lang.Dictionary) {
	        var s = "Dictionary{";
	        var keys = obj.keys();
	        var vals = obj.values();
	        for (var i = 0; i < keys.size(); ++i) {
	            s += keys;
	            s += ": ";
	            s += vals;
	            s += ", ";
	        }
	        s += "}";
	        return s;
	    } else if (obj instanceof Toybox.Time.Gregorian.Info) {
	        return "Gregorian.Info";
	    } else {
	        return "???";
	    }
	}


}
