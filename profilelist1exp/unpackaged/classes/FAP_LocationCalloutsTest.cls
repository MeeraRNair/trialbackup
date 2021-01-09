@IsTest
private class FAP_LocationCalloutsTest {

    private static testmethod void testBuild(){
    Account acct = new Account();
        acct.Name='Test Account 123 ABC';
        acct.Profile_Published_to_Partner_Finder__c='Yes';
        acct.Approved_for_Partner_Finder__c=true;
        acct.Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        acct.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        insert acct;
        acct.IsPartner = true;
        update acct;


        Partner_Location__c loc = new Partner_Location__c();              
        loc.Name = acct.Name + ' - Test Location ' + '1';
        loc.Latitude__c =  random(-90, 90);
        loc.Longitude__c =  random(-180,180);
        loc.Account__c = acct.Id;
        loc.Point_of_Contact_Email__c = 'tloc'+  '1' +'@testlocation.com';  
         loc.City__c = 'MARIETTA';
        loc.Country__c = 'UNITED STATES (US)';
        loc.Postal_Code__c ='30066';
        loc.State_Province__c = 'GA';
        loc.Street__c  ='1190 KENNESTONE CIR';
        insert loc;
        update loc;
        PageReference pageRef = Page.FAP_PartnerDetails;
        Test.setCurrentPage(pageRef);
        FAP_PageUtils.put('id',loc.id);  
          FAP_LocationCallouts.isGeoLocationUpdate = true;
        FAP_LocationCallouts.getLocation(loc.id);

    }
     private static Double random(Double min, Double max){
      return min + (Math.random() * (max - min));
    }
    
       private static testmethod void mockTestBuild(){
          Account acct = new Account();
        acct.Name='Test Account 123 ABC';
        acct.Profile_Published_to_Partner_Finder__c='Yes';
        acct.Approved_for_Partner_Finder__c=true;
        acct.Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        acct.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        insert acct;
        acct.IsPartner = true;
        update acct;


        Partner_Location__c loc = new Partner_Location__c();              
        loc.Name = acct.Name + ' - Test Location ' + '1';
        loc.Latitude__c =  random(-90, 90);
        loc.Longitude__c =  random(-180,180);
        loc.Account__c = acct.Id;
        loc.Point_of_Contact_Email__c = 'tloc'+  '1' +'@testlocation.com';  
         loc.City__c = 'MARIETTA';
        loc.Country__c = 'UNITED STATES (US)';
        loc.Postal_Code__c ='30066';
        loc.State_Province__c = 'GA';
        loc.Street__c  ='1190 KENNESTONE CIR';
        insert loc;
        update loc;
        PageReference pageRef = Page.FAP_PartnerDetails;
        Test.setCurrentPage(pageRef);
        FAP_PageUtils.put('id',loc.id);  
         
         Test.setMock(HttpCalloutMock.class, new FAP_MockHttpResponseGeneratorTest());
           FAP_LocationCallouts.isGeoLocationUpdate = false;
        FAP_LocationCallouts.getLocation(loc.id);
          
                   
       
     }  
}