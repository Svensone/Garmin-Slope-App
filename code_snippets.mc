////  HERE API CALL for Places of interests
//
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