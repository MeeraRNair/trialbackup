/*
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Madhava     15-Jan-2016      16.12           207427  Production Defect: Edit Location not working
*/

public class FAP_LocationCallouts {

public static boolean isGeoLocationUpdate= true;
 
    @future (callout=true) 
    static public void getLocation(id ptnrLocationId){
      
        // gather partner location info
        Partner_Location__c pt = [SELECT City__c,Country__c,Postal_Code__c,State_Province__c,Street__c,Latitude__c,Longitude__c FROM Partner_Location__c WHERE id =: ptnrLocationId];
        system.debug('**Testaddr Partner_Location__c ' +pt);
        
        // create an address string
        String address = '';
        if (pt.Street__c != null){
            address += pt.Street__c +', ';
        }
        if (pt.City__c != null){
            address += pt.City__c +', ';
        }
        if (pt.State_Province__c != null){
            address += pt.State_Province__c +' ';
        }
        if (pt.Postal_Code__c != null){
            address += pt.Postal_Code__c +', ';
        }
        if (pt.Country__c != null){
            address += pt.Country__c;
        }
        system.debug('**Testaddr before encode ' +address );
        address = EncodingUtil.urlEncode(address, 'UTF-8');
        system.debug('**Testaddr after encode ' +address );
 
        // build callout
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string  googleMapsApi= FAP_Configuration.getInstance().googleMapsApiKey;
        String geocodingKey = 'AIzaSyB7q_EYP0NSSRbIT6stpRhCmD2OrmhT7S8';
        
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&key=' + geocodingKey+'&sensor=false');
        system.debug('**Testreq1 ' +req);
        req.setMethod('GET');
        req.setTimeout(60000);
        try{
            // callout
           HttpResponse res = h.send(req);
           
           system.debug('@@@@res.getBody()'+res.getBody());
           JSONParser responseParser = JSON.createParser(res.getBody());
            
            system.debug('@@@@responseParser'+responseParser);
            double latitude = null;
            double longitude = null;
            
            while(responseParser.nextToken() != null) {
                 system.debug('@@@@JSONToken.FIELD_NAME'+JSONToken.FIELD_NAME);
                system.debug('@@@@responseParser.getText()'+responseParser.getText());
                 system.debug('@@@@responseParser.getCurrentToken()'+responseParser.getCurrentToken());
                
                if((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) && (responseParser.getText()== 'location')) {
                    
                    system.debug('@@@@responseParser.getText()'+responseParser.getText());
                    responseParser.nextToken();
                    while (responseParser.nextToken() != JSONToken.END_OBJECT) {
                             
                        String locationText = responseParser.getText();
                        system.debug('@@@@locationText'+locationText);         
                        responseParser.nextToken();
                                 
                        if (locationText == 'lat'){
                        
                            system.debug('@@@@latitude'+responseParser.getDoubleValue());
                            latitude = responseParser.getDoubleValue();
                        
                        }else if (locationText == 'lng'){
                            
                            system.debug('@@@@longitude'+responseParser.getDoubleValue());      
                            longitude = responseParser.getDoubleValue();
                        
                        }
                    
                    }
                 }
                 
            }
            
            List<Partner_Location__c> ptnrLst = new List<Partner_Location__c>();
            
            // update coordinates if we get back
            if (latitude != null && longitude != null){
                
                isGeoLocationUpdate=false;
                
                pt.Latitude__c = latitude;
                pt.Longitude__c = longitude;
                ptnrLst.add(pt);
                
            }
  
            if(ptnrLst.size()>0){
            
                database.update(ptnrLst,false);
            
            }

        } catch (Exception e) {

        }

    }
    

}