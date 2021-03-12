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
var zAngleNorm = null;
var zAngle_short = null;
var zAngle3_degrees = null;
var angleDisplay = 0;
var zSlope = null;
var x1= 260;
var x2 =130;
var y1= 130 ;
var y2 = 130;

// GPS Variables
var locationString;
var referenceLocation;

// //Display
var displayWidth = 260;
var displayHeight = 260;

// Elevation Api
var angleAPI = 0;



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
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:setPosition));
        // activate Accelerometer (period= every "" seconds, sampleRate= number of values per period)
		var options = {:period => 4, :sampleRate => 1, :enableAccelerometer => true};
		Sensor.registerSensorDataListener(method(:accelHistoryCallback), options);
		
		View.onUpdate(dc);
	}

	function accelHistoryCallback(sensorData) {
		// Step 1: Gett the data: 
		//////////////////////////
		// Option1:  sensorData
		// Which value from sensorData? mean value or set treshold?
		var xAccel = sensorData.accelerometerData.x[0];
		var yAccel = sensorData.accelerometerData.y[0];
		var zAccel = sensorData.accelerometerData.z[0];
		System.println("  Accelerometer Data from .accelerometerData x, y and z : "+ xAccel + ", " + yAccel + ", " + zAccel);
		
		// Option 2: Sensor.getInfo() // why different data from Sensor.getInfo()? sensorData(see above) same with .FIT file
//		var info = Sensor.getInfo();
//		var accel = info.accel;
//		// Acceleration Data
////	var xAccel = accel[0];
////    var yAccel = accel[1];
////    var zAccel = accel[2];
//		System.println("Accelerometer Data from .getInfo() x, y and z " + accel );

		// Step 2: Normalize the data:
		//////////////////////////////////
        var norm = Math.sqrt(sq(xAccel) + sq(yAccel) + sq(zAccel));
        var xNorm = xAccel / norm;
        var yNorm = yAccel / norm;
        var zNorm = zAccel / norm;
        
		// Step 3: Calculate the Angle and Slope of Device deviation from horizontal position 
		/////////////////////////////////////////////////////////////////////////////////////

        // Version 1:
        // error suscepticle - if zAccel = 0, widget breaks - since not able to divide with zero
        // http://wizmoz.blogspot.com/2013/01/simple-accelerometer-data-conversion-to.html
        // only for Z since indicates angle device deviation from horizontal position
        
        // zAngle = Math.atan(Math.sqrt(sq(xAccel) + sq(yAccel)) / zAccel);
        
        // // no difference in Angle results if normalized
        // zAngleNorm = Math.atan(Math.sqrt(sq(xNorm) + sq(yNorm)) / zNorm);
        // zAngleNorm = zAngleNorm / Math.PI * 180;
        
        // zAngle = zAngle / Math.PI * 180; // from radians to degrees
        // zAngle_short = zAngle.format("%.f"); // no decimal needed 
        
        // // steigungswinkel -> Steigung m= tan(alpha)
        // zSlope = Math.tan(zAngle);
        // System.println( "Version 1: Angle in degrees : "+ zAngle_short + "  Slope : "+zSlope);
        // System.println("Version 1 Normalized:" + zAngleNorm);
        

		// Versioin 3 :
		///////////////
		// see Pdf 'Freescale Accelerometer' Ch. 5 

		var m = Math.sqrt(( Math.pow(xAccel, 2) + Math.pow(yAccel, 2) + Math.pow(zAccel, 2)));
		var cos_p = zAccel / m;
		var zAngle3 = Math.acos(cos_p);
		zAngle3_degrees = zAngle3 * 180 / Math.PI; 			// from radians to degrees
		zAngle3_degrees = zAngle3_degrees.format("%.f"); 	// round angle to full degrees
		var zSlope3 = Math.tan(zAngle3);  					// calculate slope of line from angle
		
		// if angle > 90, line in left upper field. Angle needs to bee subtracted by 180
		if (zAngle3_degrees.toNumber() > 90) {
		angleDisplay = (zAngle3_degrees.toNumber() - 180);
		angleDisplay = angleDisplay.abs().toString();
		} else {
		angleDisplay = zAngle3_degrees.toString();
		}
		
        System.println( "Version 3: Angle in degrees : " + angleDisplay + "  Slope : "+zSlope3);

		// Getting the coordinates for the slope line on display
		// if angle(in degrees) > 90, (x2|y2) becomes center and (x1|y1) calculated with lin. function - since slope negative
		if (zAngle3_degrees.toNumber() > 90) {
		x1 = 0;
		y1 = (-zSlope3) * (0 -(displayWidth/2)) + (displayHeight/2);
		x2 = displayWidth/2;
		y2 = displayHeight/2;
		} else {
		x1 = displayWidth / 2 ; 
		y1 = displayHeight / 2 ;
		x2 = displayWidth;
		y2 = (-zSlope3)*(displayWidth - x1) + y1;
		}
		
		System.println("coordinates for slope line on display : x1/y1 :" + x1 + "/"+ y1 + " x2/ y2 : " + x2 + " /" + y2);
        
		//	Check if NEEDED !? 
		// normally wearing watch left arm -> arm movement max -40 to +90 degrees
		// background image enough if slope fields on right side (left side not needed?)
		
		WatchUi.requestUpdate();
		}


    function onShow() {
    }


    // Update the view (display data and info on scree)
    function onUpdate(dc) {
        // clear the display
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	dc.clear();
    	
    	// Draw backgroundImage, 
    	dc.drawBitmap(0, 0, backgroundImg);
		// Slope-Line (Deviation from horizontal Level) 
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(2);
		dc.drawLine(x1, y1, x2, y2); // (x1|y1) display center
		
		var angle1 = angleDisplay + '°';
		var angle2 = angleAPI + '°';
		
		// Slope Data (Accelerometer)
		dc.drawText(120, 176, Gfx.FONT_XTINY, angle1, Gfx.TEXT_JUSTIFY_LEFT);
		// Gps Data (Airmap API, calculate with height difference)
		dc.drawText(120, 220, Gfx.FONT_XTINY, angle2, Gfx.TEXT_JUSTIFY_LEFT);

        WatchUi.requestUpdate();
    }
    
    function setPosition(info) {
        
        // create String of current GPS Data for Api Call
        var myLocation = info.position.toDegrees();
        var lat = myLocation[0];
        var long = myLocation[1];
        locationString = lat + "," + long;
// 		second Gps Location
		var long2 = long + 0.001; // lat and long in decimaldegrees - adding 1sec (equal 30.9m) to longitude
		referenceLocation = lat + "," + long2;
       	// System.print("GPS Location at:" + locationString + ", reference-location at:  " + referenceLocation);
        
        makePlacesWebRequest(); // Make API Call 
        WatchUi.requestUpdate(); 
    }
    function makePlacesWebRequest() {
		// 1. Google Maps Platform Api for Elevation - not free of cost
//    	var url = "https://maps.googleapis.com/maps/api/elevation/json?locations=" + locationString + "&key="+ $.google_elevation_api_key; 	
    	
		// 2. Airmap API // free of charge ?
//		make API Call for 2 gps-locations
		var url = "https://api.airmap.com/elevation/v1/ele/path?points=" + locationString + "," + referenceLocation + "/X-API-Key:{" + $.airmap_key +"}/Content-Type:application/json;charset=utf-8";
	
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
// 	check if API Call successful, otherwise show error code of https response
    function onReceive(responseCode, data) {
    	if (responseCode == 200){
    	parseResponse(data);
    	} else {
    	System.println("Call unsuccessful, error code: " + responseCode.toString());
    	}
    }
//  parse response data of Api Call and calculate slope-angle of current gps location
    function parseResponse(data){
	    var results = data.get("data");
		var results1 = results[0];
		// elevation in meter for path between gps-location 1 and gps-location 2 (30.9m )
		var elevation =  results1.get("profile");
		// System.println(elevation);
		
		// take difference of first and last elevation result from "elevation" -> opposite cathete
		var height_diff = null;

		height_diff = elevation[0]- elevation[3];
		height_diff = height_diff.abs();
//		System.println(" height Difference in m : " + height_diff + " on a length of 30.9m");

		// angle of right traingle with arctan( opposite cathete / ankathete) 
		// ankathete = 30.9 since adding 1 sec to longitude 
		var angle = Math.atan2(height_diff, 30.9);
		// angle in degrees
		angleAPI = angle * 100;
		angleAPI = angleAPI.toNumber().format("%.f");
//		System.println(" API Angle in degrees : " + angleAPI);
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
