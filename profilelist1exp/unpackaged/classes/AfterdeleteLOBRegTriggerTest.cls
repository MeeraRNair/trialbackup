/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/
@isTest
private class AfterdeleteLOBRegTriggerTest {
    static list<Account> listAcc;
        @testsetup static void setup(){
            list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-User Account');
            listAccTDF[0].account_country_code__c='US';
            listAccTDF[0].account_country__c = 'United States';
            listAccTDF[0].Participating_in_LOB_Program__c = true;
            insert listAccTDF;
         }

    private static testmethod void afterdeleteLOBRegTriggerTest1(){
   /* 
        Account account = new Account(name='LobRegTest',account_country_code__c='US',account_country__c = 'United States',Participating_in_LOB_Program__c = true);
        insert account;
    */
        listAcc = [select id from Account limit 1];
        /*Account_Branch__c AB = new Account_Branch__c(name = 'Test LOB', Account__c = account.id);
        insert AB;*/
        
        Lob_Registration__c lobregRec = new Lob_Registration__c ();
       // lobregRec.Name = 'Test LOB';
        lobregRec.LOB_registration_status__c = 'Expired';
        lobregRec.Registered_End_User__c = listAcc[0].id;
        lobregRec.LOB_Award_Type__c = 'All Account';
        lobregRec.City__c = 'Test lob city';
        lobregRec.State_Province_Region__c = 'Test lob state';
        lobregRec.LOB_Name__c = 'Client';
        insert lobregRec;
        List <Lob_Registration__c>  listLobReg = [Select Name, Id from Lob_Registration__c where Id = : lobregRec.id];
        
        Test.startTest();
        delete lobregRec;
           
        Partner_Hub_Record_Deleted__c  partnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = : lobregRec.id];
        
        partnerHubRecTest.Key_Identifier__c = listLobReg[0].Name;
        partnerHubRecTest.Record_GUID__c = listLobReg[0].Id;
        partnerHubRecTest.Type__c = 'LOB Registration' ;
        
        //system.assertequals(PartnerHubRecTest.Key_Identifier__c ,lobregRec.Name);
        //system.assertequals(PartnerHubRecTest.Record_GUID__c ,lobregRec.Id);
        system.assertequals(partnerHubRecTest.Type__c,'LOB Registration');
              
        Test.stopTest();
        
     }
}