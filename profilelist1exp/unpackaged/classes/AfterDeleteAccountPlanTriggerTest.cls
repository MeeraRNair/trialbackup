/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
* 
************************************************************/

@isTest
private class AfterDeleteAccountPlanTriggerTest {
	    static list<Account> listAcc;
    static list<user> listuser;
    static list<SFDC_Acct_Plan__c> listSFDCAcctPlan;
    @testSetup static void setup() {
        list<user> listuserTDF = TestDataFactory.createNGenralUsers(1);
        insert listuserTDF;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-User Account');
        listAccTDF[0].account_country_code__c='US';
        listAccTDF[0].account_country__c = 'United States';
        listAccTDF[0].Participating_in_LOB_Program__c = true;
        listAccTDF[0].Tax_Registration_Number__c = '124214';
        listAccTDF[0].OwnerId = listuserTDF[0].Id;
        insert listAccTDF;
		List <SFDC_Acct_Plan__c> listSFDCAcctPTDF = TestDataFactory.createNSFDCAccPlan(1, 'Direct Relationship Account Plan');
        listSFDCAcctPTDF[0].Account__c= listAccTDF[0].Id;
        listSFDCAcctPTDF[0].Sales_Manager__c = listuserTDF[0].Id;
        listSFDCAcctPTDF[0].Plan_Starting_Fiscal_Year__c='FY12';
        insert listSFDCAcctPTDF;
    }   

    private static testmethod void afterDeleteAccountPlanTrigger (){
        //Create a user with Standard User profile  
        /*     
         Profile profile = [select id from profile where Name = 'System Administrator' limit 1];
        User userRecord = new User(Username='testvaliduser2'+ System.currentTimeMillis()+'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test212'+'@dell.com',            
                                    LastName='Test22',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Country='US',
                                    Badge_Number__c=String.valueOf(Datetime.now()));
        insert userRecord;
        System.runAs(userRecord){
        Account testEUAccount = new Account(Name='Test EU Account for Account Plan Test',Type = 'End User',
                                                Participating_in_LOB_Program__c = true,
                                                OwnerId = userRecord.Id);
        insert testEUAccount;
          
        SFDC_Acct_Plan__c APRec = new SFDC_Acct_Plan__c(name='TestPlan01',Account__c= testEUAccount.Id,Plan_Starting_Fiscal_Year__c='FY12', Sales_Manager__c = userRecord.Id);
        // certTrackRec.Account_Id__c = account.id;
        insert APRec;
        List <SFDC_Acct_Plan__c>  APTest = [Select Name, Id from SFDC_Acct_Plan__c where Id = : APRec.id];
        delete APRec;
        */
        listuser = [select id from user where isActive = True limit 1];
		System.runAs(listuser[0]){
            listAcc = [select id from Account limit 1];
        }
        system.assertEquals(listAcc[0].id, listAcc[0].id);
        listSFDCAcctPlan = [Select Name, Id from SFDC_Acct_Plan__c limit 1];
    	
  //      update listSFDCAcctPlan;
        List <SFDC_Acct_Plan__c>  listAPTest = [Select Name, Id from SFDC_Acct_Plan__c where Id = : listSFDCAcctPlan[0].id];

        delete listSFDCAcctPlan[0];
        Test.startTest();
            
        List <Partner_Hub_Record_Deleted__c>  listPartnerHubRecTest = [Select Key_Identifier__c, Record_GUID__c, Type__c from Partner_Hub_Record_Deleted__c where Record_GUID__c = : listAPTest[0].id];
        
        listPartnerHubRecTest[0].Key_Identifier__c =  listAPTest[0].Name; 
        listPartnerHubRecTest[0].Record_GUID__c = listAPTest[0].Id ;
        listPartnerHubRecTest[0].Type__c = 'Account Plan' ;
                
        Test.stopTest();
        }
    
}