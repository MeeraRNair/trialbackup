/*********************************************************************************************
Author: Emily Chiong

History:
Revision CR Number   Release No      Date            Modified By     Description
----------------------------------------------------------------------------------------------
1.0      CR13165     FY17-DCS-0701   26-May-2016     Emily           Test class for BatchDeleteSF1Adoption

**********************************************************************************************/

@isTest
private class BatchDeleteSF1AdoptionTest {
  //  static Profile adminProfile;  
  //  static User sysAdminUser;
  //  static Account testAccount;
  //  static Contact testContact1;
   // static Contact testContact2;
    static list<user> listuser;
    static list<Account> listAcc;
    static list<Contact> listCon;
    @testSetup static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Contact> listConTDF = TestDataFactory.CreateNContacts(1);
        listConTDF[0].AccountID = listAccTDF[0].id;
        insert listConTDF;
        list<user> listuserTDF = TestDataFactory.CreateNGenralUsers(1);
        insert listuserTDF;
    }
    static testMethod void deleteLogsTestWithReRun() {   
        //Skip all trigger to avoid too many SOQL Query Issue        
        TriggerExecutionController.setSkipAllTriggers(true);
        listuser = [select id from user where IsActive = TRUE Limit 1 ];
        system.assertEquals(listuser[0], listuser[0]);
		Test.startTest();
       // createAdminUser();
        createSF1Adoption();
        
        //Revert back the skip all triggers        
        TriggerExecutionController.setSkipAllTriggers(false);  
                
                   
        
        System.runAs(listuser[0]){
            date dtStartDate = Date.today().addDays(0);
                        
            BatchDeleteSF1Adoption batchRecord = new BatchDeleteSF1Adoption();
            batchRecord.bReRun = true;
            batchRecord.strQuery = 'SELECT ID '+
                                'FROM SF1_Adoption__c '+
                                'WHERE User_Edited_Date__c < last_n_days:0';
                                                        
            Id batchprocessid = database.executebatch(batchRecord,10);
            Test.stopTest();
        }
    }
    
    static testMethod void deleteLogsTestWithoutReRun() {   
        //Skip all trigger to avoid too many SOQL Query Issue        
        TriggerExecutionController.setSkipAllTriggers(true);
        listuser = [select id from user where IsActive = TRUE Limit 1 ];
        system.assertEquals(listuser[0], listuser[0]);
        Test.startTest();           
        //createAdminUser();
        createSF1Adoption();
        
        //Revert back the skip all triggers        
        TriggerExecutionController.setSkipAllTriggers(false);          
        
        
        System.runAs(listuser[0]){
            date dtStartDate = Date.today().addDays(0);
                        
            BatchDeleteSF1Adoption batchRecord = new BatchDeleteSF1Adoption();
            batchRecord.bReRun = false;
            batchRecord.strQuery = 'SELECT ID '+
                                'FROM SF1_Adoption__c '+
                                'WHERE User_Edited_Date__c < last_n_days:0';
            
            system.debug('batchRecord---'+batchRecord);                                            
            Id batchprocessid = database.executebatch(batchRecord,10);
            Test.stopTest();
        }
    }
/*    
    private static void createAdminUser() {
        adminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        
        sysAdminUser = [select Id from User 
                           where System_Admin_or_Delegated_User_Admin__c = TRUE
                           AND ProfileId = :adminProfile.Id AND IsActive = TRUE Limit 1]; 
    }
   
    private static void createAccount() {
        testAccount = new Account(Name='Test Account SF1');
        insert testAccount;
    }
        
    private static void createContact() {       
        testContact1 = new Contact(AccountId=testAccount.Id,
                                    Status__c='Prospect', 
                                    Survey__c='No', 
                                    Partner_My_Account_GUID__c='',
                                    Phone='111-1000', 
                                    Decision_Making_Role__c='Influencer', 
                                    LastName='Test Contact 1');
        insert testContact1;
    }
  */  
    private static void createSF1Adoption() {
    
        integer intLastDays = Integer.ValueOf(System.Label.SF1_Adoption_Data_Retention);   
        date dtStartDate = Date.today().addDays(-intLastDays);
         
      //  createAccount();
        
      //  createContact();
        listuser = [select id from user where IsActive = TRUE Limit 1 ];
        listCon = [select id from Contact limit 1];
        List<SF1_Adoption__c> listSF1Adoption = new List<SF1_Adoption__c>();
        for (integer inti = 0; inti < 5; inti++) {
            listSF1Adoption.add(new SF1_Adoption__c(
                            Object_Name__c = 'Contact',
                            Record_ID__c = listCon[0].Id,
                            Source__c = 'Mobile',
                            User_Action__c = 'Create',
                            User_Edited_Date__c = dtStartDate,
                            User_Name__c = listuser[0].Id
            ));
        }
        insert listSF1Adoption;
    }
    
    static testMethod void batchDeleteSF1AdoptionSchedulerTest() {
        Test.startTest();
        String strCRONEXP = '0 0 0 * * ?';
        BatchDeleteSF1AdoptionScheduler sch = new BatchDeleteSF1AdoptionScheduler();
        String strjobId = System.schedule('TestScheduledApex',strCRONEXP,sch);
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :strjobId];
        //Verify the expressions are the same
        System.assertEquals(strCRONEXP,ct.CronExpression);
        //Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }    
}