@isTest
public class ContactTriggerHelperTest {
    
     static testMethod void testupdateAuditTracks(){
        Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        TriggerExecutionController.setSkipAllTriggers(true); 
        Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        insert acc;
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj1;
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = acc.id;
        insert testPartnerTrackObj2;
        
        Account salesAcc = new Account();
        salesAcc.Name = 'testSalesmotionAccount';
        salesAcc.NPS_Qualified_Contacts__c = 1;
        salesAcc.Partner_Track__c = testPartnerTrackObj.id;
        salesAcc.Master_Group_Id__c = acc.id;
        insert salesAcc; 
        
        Account salesAcc2 = new Account();
        salesAcc2.Name = 'testSalesmotionAccount 2';
        salesAcc2.NPS_Qualified_Contacts__c = 1;
        salesAcc2.Partner_Track__c = testPartnerTrackObj2.id;
        salesAcc2.Master_Group_Id__c = acc.id;
        insert salesAcc2;
        
        final List<Contact> activeContacts = new List<Contact>();
         
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'ilo'+intuserNumber +'_mishra'+'@DELLTEAM.com'; 
         
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Email=''+intuserNumber+'@DELLTEAM.com'; 
        con.FirstName = 'John'; 
        con.LastName = strnewusername;
        con.Status__c = 'Customer';
        con.phone = '673978902';
        con.EligibleTracks__c =  testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id;
        con.Audit_Track__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id;
        
        Test.startTest();
        ProcessFlowTriggerController.isTest = false;
        insert con;
         
         contact conToUpdate = new contact();
         conToUpdate.id = [select id,FirstName,EligibleTracks__c from contact where id = : con.id][0].id;
         conToUpdate.FirstName = 'Testing';
         conToUpdate.EligibleTracks__c = testPartnerTrackObj2.id;
         TriggerExecutionController.setSkipAllTriggers(false);
         update conToUpdate;
        
        Test.stopTest();
        
    }
}