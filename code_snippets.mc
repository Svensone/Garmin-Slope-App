   	

// Helper function to check type of object
///////////////////////////////////////////////
//
//	function type_name(obj) {
//	    if (obj instanceof Toybox.Lang.Number) {
//	        return "Number";
//	    } else if (obj instanceof Toybox.Lang.Long) {
//	        return "Long";
//	    } else if (obj instanceof Toybox.Lang.Float) {
//	        return "Float";
//	    } else if (obj instanceof Toybox.Lang.Double) {
//	        return "Double";
//	    } else if (obj instanceof Toybox.Lang.Boolean) {
//	        return "Boolean";
//	    } else if (obj instanceof Toybox.Lang.String) {
//	        return "String";
//	    } else if (obj instanceof Toybox.Lang.Array) {
//	        var s = "Array [";
//	        for (var i = 0; i < obj.size(); ++i) {
//	            s += type_name(obj);
//	            s += ", ";
//	        }
//	        s += "]";
//	        return s;
//	    } else if (obj instanceof Toybox.Lang.Dictionary) {
//	        var s = "Dictionary{";
//	        var keys = obj.keys();
//	        var vals = obj.values();
//	        for (var i = 0; i < keys.size(); ++i) {
//	            s += keys;
//	            s += ": ";
//	            s += vals;
//	            s += ", ";
//	        }
//	        s += "}";
//	        return s;
//	    } else if (obj instanceof Toybox.Time.Gregorian.Info) {
//	        return "Gregorian.Info";
//	    } else {
//	        return "???";
//	    }
//	}
//

////  HERE API CALL for Places of interests
//////////////////////////////////////////////////

//function makePlacesWebRequest() {
//    	var url = "https://places.api.here.com/places/v1/discover/explore";
//    	var parameters = {
//    	 "app_id"=> "ArManpHbgDWqpudJe0J6",
//    	 "app_code" => "1b3pMO1e2VZRhw5AiNG7wg",
//    	 "at" => locationString,
//    	 "cat" => "sights-museums",
//    	 "size" => "5",
//    	 "pretty" => "true",
//    	 };
//    	 
//    	var options = {
//    	:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
//    	};
//    	
//    	Comm.makeWebRequest(
//    	url,
//    	parameters,
//    	options,
//    	method(:onReceive)
//    	);
//    }
//    
//    function onReceive(responseCode, data) {
//    	if (responseCode == 200){
//    	parseResponse(data);
//    	} else {
//    	System.println("Call unsuccessful, error code: " + responseCode.toString());
//    	}
//    }
//    
//    function parseResponse(data){
//	    var results = data.get("results");
//		  items = results.get("items");
//		  setLabel();
//    }
//    function setLabel() {
//    	var place = items[0];
//		var title = place.get("title");
//		var distance = place.get("distance");
//		var category = place.get("category");
//		var categoryTitle = category.get("title");
//		sightsLabel = title;
//		categoryLabel = categoryTitle;
//		distanceLabel = "in " + distance + "m";
////		System.println("API CALL:" + title +',' + categoryTitle +','+ distanceLabel);
//
//    	WatchUi.requestUpdate();
//    }