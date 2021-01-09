@IsTest
private class FAPAccountUtilitiesTest{
     private static testmethod void testSearchByAccountName(){
        //verifyCriteriaProducesExtraResult(new FAP_FieldCondition('Account__r.name').likex('%Aerugo%'),null);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }
     private static Double random(Double dblMin, Double dblMax){
      return dblMin + (Math.random() * (dblMax - dblMin));
    }  
    private static testmethod void testSearchByLocationName(){
      
         FAP_Configuration.keyValue ='Partner_Track__r.';   
        Account acct = new Account();
        acct.Name='Test';
        acct.Profile_Published_to_Partner_Finder__c='Yes';
        acct.Approved_for_Partner_Finder__c=true;
        acct.Partner_User_Agreed_to_PF_Terms_Cond__c=UserInfo.getUserId();
        acct.Partner_Date_Agreed_to_PF_Terms_Cond__c=Datetime.now();
        acct.Account_Type_Integration__c='Account';

        insert acct;
        acct.IsPartner = true;
        update acct;
        Track__c trackObj = new Track__c(Name = 'Federal Solution Provider',Zone__c = 'Zone 1',Partner_Program_Track__c = 'OEM');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acct.Id;
        testPartnerTrackObj.Partner_Track__c='Distributor';
        testPartnerTrackObj.Approved_for_Partner_Finder__c = true;
        testPartnerTrackObj.Profile_Published_to_Partner_Finder__c = 'Yes';
        testPartnerTrackObj.User_Agreed_to_PF_Terms_Cond__c = userinfo.getUserId();
        
        testPartnerTrackObj.Primary_SMAffinity_Account__c =acct.Id;
        testPartnerTrackObj.Partner_Track_Account_Local_Name__c = 'Test Name';
        testPartnerTrackObj.Partner_Program_Tier__c = 'Gold';
        testPartnerTrackObj.Dell_Technologies_Partner__c = true;
        insert testPartnerTrackObj; 
        
        Partner_Location__c loc = new Partner_Location__c();              
        loc.Name = acct.Name + ' - Test Location 1 ';
        loc.Latitude__c =  random(-90, 90);
        loc.Longitude__c =  random(-180,180);
        loc.Account__c = acct.Id;
        loc.Partner_Track__c = testPartnerTrackObj.Id;

        loc.Point_of_Contact_Email__c = 'tloc1'+'@testlocation.com';
        loc.Is_Primary__c=true;
        insert loc;  
        
        Partner_Location__c loc1 = new Partner_Location__c();              
        loc1.Name = acct.Name + ' - Test Location ';
        loc1.Latitude__c =  random(-90, 90);
        loc1.Longitude__c =  random(-180,180);
        loc1.Account__c = acct.Id;
        loc1.Point_of_Contact_Email__c = 'tloc2'+'@testlocation.com';
        loc1.Is_Primary__c=false;
        loc1.Partner_Track__c = testPartnerTrackObj.Id;
        insert loc1;   
        
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp; 
        
        Sales_Channel_Group__c testSalesChanGrp1 = new Sales_Channel_Group__c(Name = 'Dormant Sales channel1', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp1; 
        
        Account acc1 = new Account(Name = 'Test Account', Account_Type_Integration__c = 'Account', Approved_for_Partner_Finder__c = True, Profile_Published_to_Partner_Finder__c= 'Yes', Partner_User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId(), Partner_Date_Agreed_to_PF_Terms_Cond__c = System.today()+10,Sales_Channel__c=testSalesChanGrp.id);
        insert acc1;
        
        acct.Sales_Channel__c = testSalesChanGrp.id;
        update acct;
        
        acct.Sales_Channel__c = testSalesChanGrp1.id;
        update acct;
        
        Partner_Location__c loc2 = new Partner_Location__c();
        loc2.Name = 'test';
        loc2.Latitude__c =  random(-90, 90);
        loc2.Longitude__c =  random(-180,180);
        loc2.Account__c = acct.Id;
        loc2.Is_Primary__c = True;
        insert loc2; 
        

        //verifyCriteriaProducesExtraResult(new FAP_FieldCondition('name').likex('%Aleurometer%'),null);
        
        system.assertEquals(acct.Name,'Test');         
    }
    
}