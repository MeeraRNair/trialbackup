@isTest
private class AfterDeleteCertificationTrackerTrigrTest { 
    static List<Certification_Tracker__c> listcerTracker;
    @testsetup static void setup() { 
        List<Certification_Tracker__c> listCerTrackerTDF = TestDataFactory.createNcertTracker(1);
        insert listCerTrackerTDF;
    }     

    private static testmethod void afterDeleteCertificationTrackerTrigger(){
    
        // Account account = new Account(name='CertTest',account_country_code__c='US');
        // insert account;
        
        
       // Certification_Tracker__c certTrackRec = new Certification_Tracker__c ();
        // certTrackRec.Account_Id__c = account.id;
       // insert certTrackRec;
        listcerTracker = [select Name, id from Certification_Tracker__c limit 1 ];
        system.assertEquals(listcerTracker[0].Name, listcerTracker[0].Name);
        List <Certification_Tracker__c>  listCertRecTest = [Select Name, Id from Certification_Tracker__c where Id = : listcerTracker[0].id];
        delete listCertRecTest;
        
        Test.startTest();
            
        List <Partner_Hub_Record_Deleted__c>  listPartnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = : listcerTracker[0].id];
        
        listPartnerHubRecTest[0].Key_Identifier__c = listcerTracker[0].Name ;
        listPartnerHubRecTest[0].Record_GUID__c = listcerTracker[0].Id ;
        listPartnerHubRecTest[0].Type__c = 'Competency Tracker' ;
                
        Test.stopTest();
        
     }
}