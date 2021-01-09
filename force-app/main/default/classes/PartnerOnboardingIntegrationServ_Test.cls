@isTest(seealldata=false)
public class PartnerOnboardingIntegrationServ_Test {
           public static testMethod void jsonGenarator() {
               Test.startTest();
                TriggerExecutionController.setSkipAllTriggers(true);
           Account acc = new Account();
         acc.Name = 'testAccount';
      acc.NPS_Qualified_Contacts__c = 1;
      insert acc;
     
     Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
         
              Contact con = new Contact();
      con.AccountId = acc.Id;
      con.Email = 'test@test.com';
      con.phone = '6739';
      con.LastName = 'conLastName';
      con.FirstName = 'conFirstName';
      con.Status__c = 'Customer';
      con.Email_Opt_In__c = 'yes';
      con.Survey__c = 'yes';
       con.Partner_My_Account_GUID__c ='962129cf-44d9-4ead-bd20-bdb743783606';
      con.Decision_Making_Role__c = 'Technical Buyer';
      insert con;
         
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.id;
            testPartnerTrackObj.DELLEMC_Ts_and_Cs_agreement_User__c =con.Id;
      testPartnerTrackObj.Partner_Track_Name__c= 'testPtTrack';
        insert testPartnerTrackObj;
        map<string,string> mapContactPartner = new map<String,String>();
               mapContactPartner.put(con.id, testPartnerTrackObj.id);
   Test.setMock(HttpCalloutMock.class, new ProfileServicesCalloutMockTest());
     PartnerOnboardingIntegrationServices.profileServicesIntegration(mapContactPartner);
     system.assertEquals('Technical Buyer', [Select Id,Decision_Making_Role__c From Contact Where Id =:con.Id].Decision_Making_Role__c);
               Test.stopTest();    
    }
}