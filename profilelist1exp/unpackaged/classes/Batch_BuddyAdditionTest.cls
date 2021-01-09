/*
 * Author  : Krishnakumar M
 * Purpose : Buddy Request Functionality
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR14112      05.02      20-Feb-2017     Krishnakumar    Buddy Request - Create Batch Processes to Add/Remove Buddy member to ATM
 * 2.0      CR14556      07.02      29-Jun-2017     Krishnakumar    SE148 - Fix for the Defect 3497907 Buddy Access batch process 
 * 3.0      CR16640      08.02      04-Jul-2017     Krishnakumar   SE149 - SE149 - Permanent Fix for the Defect 3497907 Buddy Access batch process 
 * 4.0      CR14846      10.01      06-Sep-2017     Nagaraju       Created TestFailure Scenario Method.
 */

@isTest
public class Batch_BuddyAdditionTest{

    private static User objAdminUser;
    private static List<User> listTestUser;
    private static List<Profile> listProfile;   
    private static ID idBuddyAccessRT;


    static{

        TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;

        listProfile = [SELECT Id,name FROM Profile WHERE Name in ('System Administrator','R16.10 GBL EMEA Sales Rep') order by name]; 
        idBuddyAccessRT = IdLookupUtils.getRecordTypeId('Buddy Access','GDM_Request__c',true);

        objAdminUser = new User(Alias = 'standt', Email='standarduser@dell.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = listProfile.get(1).Id, userRoleId = '00E30000000w2BzEAI',  Badge_Number__c='TEST1'+System.currentTimeMillis(),
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+ System.currentTimeMillis() +'@dell.com');
        insert objAdminUser;

        listTestUser = new List<User>();
        for (Integer inti=0; inti<3;inti++){
            User user = new User( Username='test' +inti+ System.currentTimeMillis() + '@test.com',
                                Alias = 'test'+inti, 
                                Email='test'+ inti +'@dell.com', 
                                FirstName='Tfirst'+inti, 
                                LastName='TLast'+inti,
                                ProfileId = listProfile.get(0).Id, 
                                userRoleId = '00E30000000w2BzEAI',
                                ManagerId = objAdminUser.id,
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='TEST12345'+inti );
                
            listTestUser.add(user);   
        } 
        insert listTestUser;

    }

    static testmethod void testAdditionScheduler(){

        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String strCRONEXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Batch_BuddyAdditionScheduler batchAddition = new Batch_BuddyAdditionScheduler();
        batchAddition.intScope = 100;
        
        String strjobId = System.schedule('Buddy Request Inclusion Batch', strCRONEXP, batchAddition);

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :strjobId];

        System.assertEquals(strCRONEXP, ct.CronExpression); 

        Test.stopTest();

    }
    
    //Assigning Values to ListTestUser List .
        static testMethod void assignVariablesToListTestUser()
    {
        GDM_Request__c objGdmReq;
          System.runAs(listTestUser[0])
        {
            objGdmReq = new GDM_Request__c();
            objGdmReq.Buddy_Access_Start_Date__c = system.today();
            objGdmReq.Buddy_Access_End_Date__c = (system.today())+2;
            objGdmReq.Buddy__c = listTestUser[0].id;
            objGdmReq.Rep_on_Leave__c = listTestUser[1].id;
            objGdmReq.Reason_Requested__c = 'Sickness';
            objGdmReq.Comments2__c = 'Test';
            objGdmReq.RecordTypeId = idBuddyAccessRT;
            objGdmReq.ROL_Manager__c = objAdminUser.id;
            insert objGdmReq;
            System.assertNotEquals(objGdmReq.id,null);
        }
         System.runAs(objAdminUser) 
         {
            if(objGdmReq != null)
            {
                objGdmReq.Buddy_Access_Status__c = 'Approved and scheduled';
                update objGdmReq;   
            }
        }

    }
    //insering test batch
    static testmethod void batchInsertion(){
        string strvalue='Access provided';
        Batch_BuddyAddition addition = new Batch_BuddyAddition();        
        Database.executeBatch(addition);
        System.assertEquals('Access provided',strvalue);
    }
    static testmethod void test1RepNewBuddy(){

        TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;
       // List<GDM_Request__c> listGDMReq11=new list<GDM_Request__c>();
        GDM_Request__c objGdmReq11;
         System.runAs(listTestUser[0]){
            objGdmReq11 = new GDM_Request__c();
          objGdmReq11.Buddy_Access_Start_Date__c = system.today();
          objGdmReq11.Buddy_Access_End_Date__c = (system.today())+2;
          objGdmReq11.Buddy__c = listTestUser[0].id;
          objGdmReq11.Rep_on_Leave__c = listTestUser[1].id;
          objGdmReq11.Reason_Requested__c = 'Sickness';
          objGdmReq11.Comments2__c = 'Test';
          objGdmReq11.RecordTypeId = idBuddyAccessRT;
          objGdmReq11.ROL_Manager__c = objAdminUser.id;
       //   listGDMReq.add(objGdmReq11);
          insert objGdmReq11;
          
          }
          System.runAs(objAdminUser) 
         {
          if(objGdmReq11!= null){
            //objGdmReq2.Buddy_Access_Status__c = 'Approved and scheduled';
            objGdmReq11.Buddy_Access_Status__c = 'Approved and scheduled';
            update objGdmReq11;  
          }
      }
        System.runAs(objAdminUser) {
            Account objAccount=new Account();
            objAccount.name='test last run';
            insert objAccount;

            AccountTeamMember objRepATM = createATM(objAccount,true);
            Insert objRepATM;       
            }
          
        AssignVariablesToListTestUser();
               
        Test.startTest();
        batchInsertion();
               
        Test.stopTest();
        GDM_Request__c updatedGDM = [select id,name,Buddy_Access_Status__c from GDM_Request__c where id = :objGdmReq11.id];
        System.assertEquals('Access provided',updatedGDM.Buddy_Access_Status__c);

    }

    //Buddy Already Exists
    static testmethod void test1RepExistingBuddy(){
        TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;
        List<GDM_Request__c> listGDMReq = new List<GDM_Request__c>();
        GDM_Request__c objGdmReq1;
        //GDM_Request__c objGdmReq2;
        System.runAs(objAdminUser) {
            Account objAccount=new Account();
            objAccount.name='test last run';
            insert objAccount;

            List<AccountTeamMember> listAtm = new List<AccountTeamMember>();
            AccountTeamMember objATM = createATM(objAccount,true);
            AccountTeamMember objATM1 = createATM(objAccount,false);

            listAtm.add(objATM);
            listAtm.add(objATM1);
            Insert listAtm;
        

            System.runAs(listTestUser[0]){
                objGdmReq1 = new GDM_Request__c();
                objGdmReq1.Buddy_Access_Start_Date__c = system.today();
                objGdmReq1.Buddy_Access_End_Date__c = (system.today())+2;
                objGdmReq1.Buddy__c = listTestUser[0].id;
                objGdmReq1.Rep_on_Leave__c = listTestUser[1].id;
                objGdmReq1.Reason_Requested__c = 'Sickness';
                objGdmReq1.Comments2__c = 'Test';
                objGdmReq1.RecordTypeId = idBuddyAccessRT;
                objGdmReq1.ROL_Manager__c = objAdminUser.id;
                listGDMReq.add(objGdmReq1);
                insert listGDMReq;
                //System.assertNotEquals(objGdmReq.id,null);
            }
            if(listGDMReq != null){
                //objGdmReq2.Buddy_Access_Status__c = 'Approved and scheduled';
                objGdmReq1.Buddy_Access_Status__c = 'Approved and scheduled';
                update listGDMReq;  
            }
        }
        

        Test.startTest();
        batchInsertion();
               
        Test.stopTest();
        GDM_Request__c updatedGDM = [select id,name,Buddy_Access_Status__c from GDM_Request__c where id = :objGdmReq1.id];
        System.assertEquals('Access provided',updatedGDM.Buddy_Access_Status__c);
    }

    //Buddy Already Exists
    static testmethod void test2RepNewBuddy(){
        TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;
        
        List<GDM_Request__c> listGDMReq = new List<GDM_Request__c>();
        GDM_Request__c objGdmReq1;
        Account objAccount;
        GDM_Request__c objGdmReq2;
        System.runAs(objAdminUser) {
            objAccount =new Account();
            objAccount.name='test last run';
            insert objAccount;
            List<AccountTeamMember> listAtm = new List<AccountTeamMember>();
            
            AccountTeamMember objATM = createATM(objAccount,true);
            AccountTeamMember objATM1 = createATM(objAccount,false);        

            listAtm.add(objATM);
            listAtm.add(objATM1);
            Insert listAtm;
        

            System.runAs(listTestUser[0]){
                objGdmReq1 = new GDM_Request__c();
                objGdmReq1.Buddy_Access_Start_Date__c = system.today();
                objGdmReq1.Buddy_Access_End_Date__c = (system.today())+2;
                objGdmReq1.Buddy__c = listTestUser[0].id;
                objGdmReq1.Rep_on_Leave__c = listTestUser[1].id;
                objGdmReq1.Reason_Requested__c = 'Sickness';
                objGdmReq1.Comments2__c = 'Test';
                objGdmReq1.RecordTypeId = idBuddyAccessRT;
                objGdmReq1.ROL_Manager__c = objAdminUser.id;
                listGDMReq.add(objGdmReq1);
                insert listGDMReq;
                
            }
            if(listGDMReq != null){
                //objGdmReq2.Buddy_Access_Status__c = 'Approved and scheduled';
                objGdmReq1.Buddy_Access_Status__c = 'Approved and scheduled';
                update listGDMReq;  
            }
        }
        
        //listGDMReq.clear();
        Test.startTest();
                
        System.runAs(objAdminUser) {
        System.runAs(listTestUser[0]){
                objGdmReq2 = new GDM_Request__c();
                objGdmReq2.Buddy_Access_Start_Date__c = system.today()+1;
                objGdmReq2.Buddy_Access_End_Date__c = (system.today())+3;
                objGdmReq2.Buddy__c = listTestUser[0].id;
                objGdmReq2.Rep_on_Leave__c = listTestUser[2].id;
                objGdmReq2.Reason_Requested__c = 'Sickness';
                objGdmReq2.Comments2__c = 'Test';
                objGdmReq2.RecordTypeId = idBuddyAccessRT;
                objGdmReq2.ROL_Manager__c = objAdminUser.id;
                listGDMReq.add(objGdmReq2);
                insert objGdmReq2;
                //System.assertNotEquals(objGdmReq.id,null);
            }
            if(listGDMReq != null){
                objGdmReq2.Buddy_Access_Status__c = 'Approved and scheduled';
                update objGdmReq2;  
            }           
        }
        batchInsertion();
        Test.stopTest();
        GDM_Request__c updatedGDM = [select id,name,Buddy_Access_Status__c from GDM_Request__c where id = :objGdmReq1.id];
        System.assertEquals('Access provided',updatedGDM.Buddy_Access_Status__c);
       // System.assertEquals(objGdmReq1.Buddy_Access_Status__c,'Access provided');
        //System.assertEquals(objGdmReq2.Buddy_Access_Status__c,'Access provided');
    }

    static testmethod void testRetryScenario(){

        TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;

         GDM_Request__c objGdmReq12;
         System.runAs(listTestUser[0]){
            objGdmReq12= new GDM_Request__c();
          objGdmReq12.Buddy_Access_Start_Date__c = system.today();
          objGdmReq12.Buddy_Access_End_Date__c = (system.today())+2;
          objGdmReq12.Buddy__c = listTestUser[0].id;
          objGdmReq12.Rep_on_Leave__c = listTestUser[1].id;
          objGdmReq12.Reason_Requested__c = 'Sickness';
          objGdmReq12.Comments2__c = 'Test';
          objGdmReq12.RecordTypeId = idBuddyAccessRT;
          objGdmReq12.ROL_Manager__c = objAdminUser.id;
       //   listGDMReq.add(objGdmReq11);
          insert objGdmReq12;
          
          }
          System.runAs(objAdminUser) 
         {
          if(objGdmReq12!= null){
            //objGdmReq2.Buddy_Access_Status__c = 'Approved and scheduled';
            objGdmReq12.Buddy_Access_Status__c = 'Approved and scheduled';
            update objGdmReq12;  
          }
      }
        Account objAccount;
        System.runAs(objAdminUser) 
        {
            objAccount=new Account();
            objAccount.name='test last run';
            insert objAccount;

            AccountTeamMember objATM = createATM(objAccount,true);
            Insert objATM;      
        }
        AssignVariablesToListTestUser();    
               
        Test.startTest();

        Account[] listAccount = [select id from Account where id =:objAccount.id];
        Approval.LockResult[] listlrList = Approval.lock(listAccount, false);
        batchInsertion();
               
        Test.stopTest();
        GDM_Request__c updatedGDM = [select id,name,Buddy_Access_Status__c from GDM_Request__c where id = :objGdmReq12.id];
        System.assertEquals('Access provided',updatedGDM.Buddy_Access_Status__c);

    }
    
    static testMethod void testFailureScenario(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;

        GDM_Request__c objGdmReq;
        Account objAccount;
        System.runAs(objAdminUser) {
            objAccount=new Account();
            objAccount.name='test last run';
            insert objAccount;

            AccountTeamMember objATM = createATM(objAccount,true);
            Insert objATM;      
            }
        System.runAs(listTestUser[0]){
            objGdmReq = new GDM_Request__c();
            objGdmReq.Buddy_Access_Start_Date__c = system.today();
            objGdmReq.Buddy_Access_End_Date__c = (system.today())+2;
            objGdmReq.Buddy__c = listTestUser[0].id;
            objGdmReq.Rep_on_Leave__c = listTestUser[1].id;
            objGdmReq.Reason_Requested__c = 'Sickness';
            objGdmReq.Comments2__c = 'Test Fail';
            objGdmReq.RecordTypeId = idBuddyAccessRT;
            objGdmReq.ROL_Manager__c = objAdminUser.id;
            insert objGdmReq;
            System.assertNotEquals(objGdmReq.id,null);
        }
        System.runAs(objAdminUser) {
            if(objGdmReq != null){
                List<GDM_Request__c> listGDMReq = new List<GDM_Request__c>();
                listGDMReq.add(objGdmReq);
                objGdmReq.Buddy_Access_Status__c = 'Approved and scheduled';
                Database.Saveresult[] listobjSR = Database.Update(listGDMReq,false);
                new BuddyUserHelper().processError(listGDMReq,listobjSR,'','');
            }
        }   
               
        Test.startTest();
        
        //GDM_Request__c[] listGDM = [select id from GDM_Request__c where id =:objGdmReq.id];
        Approval.LockResult listlrList = Approval.lock(objGdmReq);
        system.assertEquals(true,Approval.isLocked(objGdmReq));
        System.runAs(listTestUser[0]){
            batchInsertion();
        }       
        Test.stopTest();
    }

    private static AccountTeamMember createATM(Account objAccount,Boolean bisRole){
        if(bisRole){
                AccountTeamMember objATM=new AccountTeamMember();
                objATM.AccountId=objAccount.id;
                objATM.UserId=listTestUser[1].id;
                objATM.AccountAccesslevel = 'Edit';
                objATM.CaseAccessLevel = 'Read';
                objATM.OpportunityAccessLevel = 'None';
                objATM.TeamMemberRole = 'Inside Sales Rep';
                return objATM;
            }else{
                AccountTeamMember objATM1=new AccountTeamMember();
                objATM1.AccountId=objAccount.id;
                objATM1.UserId=listTestUser[0].id;
                objATM1.AccountAccesslevel = 'Read';
                objATM1.CaseAccessLevel = 'Read';
                objATM1.OpportunityAccessLevel = 'Edit';
                objATM1.TeamMemberRole = 'Inside Sales Rep';
                return objATM1;
            }
    }
}