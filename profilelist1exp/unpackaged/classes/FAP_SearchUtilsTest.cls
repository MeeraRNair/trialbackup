@IsTest
private class FAP_SearchUtilsTest {

    private static testmethod void testDistanceChange(){
        System.assertEquals(100,FAP_SearchUtils.distanceChange(100,1)); 
        System.assertEquals(50,FAP_SearchUtils.distanceChange(100,2)); 
        System.assertEquals(25,FAP_SearchUtils.distanceChange(100,3)); 
        System.assertEquals(12.5,FAP_SearchUtils.distanceChange(100,4));  
    }

    private static testmethod void testFilterResultsOutsideDistance(){
        List<FAP_SearchHit> hits = new List<FAP_SearchHit>();
        for(Integer lat = -50; lat < -45; lat++){
            for(Integer lng = -160; lng < -155; lng++){
                hits.add(new FAP_SearchHit(new Partner_Location__c(
                    Name = 'test (' + lat + ',' + lng + ')',Latitude__c = lat,Longitude__c = lng)));
            }           
        }
        System.assertEquals(25,hits.size());
        final FAP_GeoPoint referencePoint = new FAP_GeoPoint(-48,-158);
        for(FAP_SearchHit hit : hits){
            System.assertEquals(false,hit.containsDistance);
            hit.setDistanceToPoint(referencePoint);
            System.assertEquals(true,hit.containsDistance);
        }
        hits = FAP_SearchUtils.filterResultsOutsideDistance(hits,200);
        for(FAP_SearchHit hit : hits){
            System.assert(hit.distanceInKilometers <= 200);
        }        
        System.assertEquals(15,hits.size());
    }
    

}