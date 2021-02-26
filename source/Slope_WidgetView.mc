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
var zAngle = null;
var zAngle2 = 30;
var zAngle2_short = null;
var zSlope = null;
var Angle3 = null;
var x1= 260;
var x2 =130;
var y1= 60 ;
var y2 = 130;
var yValue = 70;

// GPS Variables
var posnInfo;
var locationString;

//Display
var displayWidth = 260;
var displayHeight = 260;

// API Route 
var categoryLabel;
var distanceLabel;
var sightsLabel;
var items;
var index = 1;


class Slope_WidgetView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }
	
    var gpsDataString;
	var accelZData;
	var backgroundImg;
	
    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
//		Testing if data from sensors available (now displayed in onUpdate()
        gpsDataString = View.findDrawableById("gps");
        accelZData = View.findDrawableById("accelZ");
        
        // Load resources
        backgroundImg = WatchUi.loadResource(Rez.Drawables.bg);
        // activate GPS Data
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:setPosition));
        // activate Accelerometer (period= every "" seconds, sampleRate= number of values per period)
		var options = {:period => 1, :sampleRate => 1, :enableAccelerometer => true};
		Sensor.registerSensorDataListener(method(:accelHistoryCallback), options);
		
		View.onUpdate(dc);
	}

	function accelHistoryCallback(sensorData) {
		// Option1:  sensorData
		// Which value from sensorData? mean value or set treshold?
		var xAccel = sensorData.accelerometerData.x[0];
		var yAccel = sensorData.accelerometerData.y[0];
		var zAccel = sensorData.accelerometerData.z[0];
		// System.println(sensorData.accelerometerData.z);
		
		// Option 2: Sensor.getInfo()
		var info = Sensor.getInfo();
		var accel = info.accel;
		// Acceleration Data
//		var xAccel = accel[0];
//      var yAccel = accel[1];
//      var zAccel = accel[2];
		System.println("Accelerometer Data x, y and z " + accel);
        // Normalize the data
        var norm = Math.sqrt(sq(xAccel) + sq(yAccel) + sq(zAccel));
        var xNorm = xAccel / norm;
        var yNorm = yAccel / norm;
        var zNorm = zAccel / norm;
        
        // Version 1: Calculate the Angle
        // http://wizmoz.blogspot.com/2013/01/simple-accelerometer-data-conversion-to.html
        // only for Z since indicates angle device deviation from horizontal position
        zAngle = Math.atan(Math.sqrt(sq(xNorm) + sq(yNorm)) / zNorm);
        zAngle2 = zAngle / Math.PI * 180; // from radians to degrees
        zAngle2_short = zAngle2.format("%.2f");
        // steigungswinkel -> Steigung m= tan(alpha)
        zSlope = Math.tan(zAngle2);
        
        System.println( "Angle in degrees : " + zAngle2 + "Slope : "+zSlope);
        
        // Version 2:
        // https://github.com/otfried/cs109-kotlin/blob/master/mini-apps/gravity2.kt
        //http://otfried.org/courses/cs109/project-level.html
//        Angle3 = Math.atan2(xNorm, yNorm);
//        //convert to degrees
//        Angle3 = Angle3 * 180 / Math.PI;
		
		// y-Value for slope-line on display (x1 and y1 are center of display)
		if (zAccel >0) {
		x1 = 130 ;
		y1 = 130 ;
		x2 = 260 ;
		y2 = (zSlope)*(260-130)+130;
		} else {
		x1 = 0;
		y1 = (-zSlope)*(260-130)+130;
		x2 = 130 ;
		y2 = 130;
		}
		System.println("x1 :" + x1 + "y1 :"+ y1 + "x2 : " + x2 + "y2 :" + y2);
//		
//		yValue = ((Math.tan(zAngle2))*(0-130))+130;
//		yValue = yValue.toNumber();
////		System.println("YValue" + yValue);
		
        accelZData.setText(zAngle2.toNumber().format("%.2f").toString());
        WatchUi.requestUpdate();
		}

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
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
		// Slope
		dc.drawText(120, 176, Gfx.FONT_XTINY, zAngle2_short, Gfx.TEXT_JUSTIFY_LEFT);
		// Gps
		dc.drawText(120, 220, Gfx.FONT_XTINY, locationString, Gfx.TEXT_JUSTIFY_LEFT);
        WatchUi.requestUpdate();
    }
    
    function setPosition(info) {
        posnInfo = info;
        // display GPS Data on Display
        gpsDataString.setText(info.position.toDegrees()[0].toString());
        
        // create String for HERE Api - Testing API Functionality
        var myLocation = info.position.toDegrees();
        var lat = myLocation[0].format("%.2f");
        var long = myLocation[1].format("%.2f");
        locationString = lat + "," + long;
//        System.print("GPS Location at:"+ locationString);
        
        makePlacesWebRequest();
        WatchUi.requestUpdate();
    }
    function makePlacesWebRequest() {
    	var url = "https://places.api.here.com/places/v1/discover/explore";
    	var parameters = {
    	 "app_id"=> "ArManpHbgDWqpudJe0J6",
    	 "app_code" => "1b3pMO1e2VZRhw5AiNG7wg",
    	 "at" => locationString,
    	 "cat" => "sights-museums",
    	 "size" => "5",
    	 "pretty" => "true",
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
    
    function onReceive(responseCode, data) {
    	if (responseCode == 200){
    	parseResponse(data);
    	} else {
    	System.println("Call unsuccessful, error code: " + responseCode.toString());
    	}
    }
    
    function parseResponse(data){
	    var results = data.get("results");
		  items = results.get("items");
		  setLabel();
    }
    function setLabel() {
    	var place = items[0];
		var title = place.get("title");
		var distance = place.get("distance");
		var category = place.get("category");
		var categoryTitle = category.get("title");
		sightsLabel = title;
		categoryLabel = categoryTitle;
		distanceLabel = "in " + distance + "m";
//		System.println("API CALL:" + title +',' + categoryTitle +','+ distanceLabel);

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
