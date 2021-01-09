@isTest
public class Batch_10DaysExpirationNotificationTest{
 @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
    }
    
    

static testmethod void testbatchmethod() {
    
    TriggerExecutioncontroller.setSkipAllTriggers(true);
    Account acc = new Account();
    acc.name = 'testaccount';
    insert acc;
    Contact con = new contact();
    con.lastname = 'testcon';
    con.email = 'test@test.com';
    con.Account_Changed__c = true;
    con.Accountid = acc.id;
    con.Status__c = 'Customer';
    insert con;
    System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
             vr.Bypass_Opportunity_VRs__c = true;
             insert vr;
    Opportunity oppt = new opportunity();
    oppt.name = 'Test oppt';
    oppt.Accountid = acc.id;
    oppt.CloseDate = system.Today()+10;
    oppt.Deal_Registration_Status__c = 'Approved';
    oppt.Deal_Created_Date_Time__c = system.Today();
    oppt.StageName = 'Plan - 1%';
    //oppt.Submitter_Language__c = 'English';
    oppt.Competitor_Lost_To__c = 'No Competitor/Dell Only';
    oppt.Partner_Account_Owner_Email__c = 'test@test.com';
    oppt.Deal_Expiration_Date__c = system.Today()+10;
  //  TriggerExecutionController.setSkipOpportunityTriggers(true); 
    insert oppt;
   // TriggerExecutionController.setSkipOpportunityTriggers(true);  
    List<Opportunity> listopplist = new List<opportunity>();
    listopplist.add(oppt);
    DealReg_DealExpiryTemplates__c d1 = new DealReg_DealExpiryTemplates__c();
    d1.name='English';
    d1.id__c='00XA0000000iwNY';
    insert d1;
    System.debug(oppt.Stagename +'-----'+ oppt.Deal_Reg_Oppty__c +'-----------' +oppt.Deal_Registration_Status__c+'-----------' +oppt.Days_Until_Deal_Expires__c);
    oppt.StageName = 'Qualify - 30%';
    Update oppt;

    Test.startTest();
    String strcronexp = '0 0 0 1 1 ? 2025'; 
    String strjobId = System.schedule('test Schedular_10DaysExpirationNotificationTest', strcronexp, new Schedular_10DaysExpirationNotification() );
    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :strjobId];
    System.assertEquals(strcronexp, ct.CronExpression); 

    Test.stopTest();    
    }


static testmethod void testbatchmethod2() {
    TriggerExecutionController.setSkipAllTriggers(true);
    Account acc = new Account();
    acc.name = 'testaccount';
   // TriggerExecutionController.setSkipAccountTriggers(true); 
    insert acc;
  //  TriggerExecutionController.setSkipAccountTriggers(false);  
    Contact con = new contact();
    con.lastname = 'testcon';
    con.email = 'test@test.com';
    con.Account_Changed__c = true;
    con.Accountid = acc.id;
    con.Status__c = 'Customer';
    insert con;
    System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
             vr.Bypass_Opportunity_VRs__c = true;
             insert vr;
    Opportunity oppt = new opportunity();
    oppt.name = 'Test oppt';
    oppt.Accountid = acc.id;
    oppt.CloseDate = system.Today()+10;
    oppt.Deal_Registration_Status__c = 'Approved';
    oppt.Deal_Created_Date_Time__c = system.Today();
    oppt.StageName = 'Plan - 1%';
    oppt.Submitter_Language__c = 'English';
    oppt.Competitor_Lost_To__c = 'No Competitor/Dell Only';
    oppt.Partner_Account_Owner_Email__c = 'test@test.com';
    oppt.Deal_Expiration_Date__c = system.Today()+10;
  //  TriggerExecutionController.setSkipOpportunityTriggers(true); 
    insert oppt;
  //  TriggerExecutionController.setSkipOpportunityTriggers(true);  
    List<Opportunity> listopplist = new List<opportunity>();
    listopplist.add(oppt);
    DealReg_DealExpiryTemplates__c d1 = new DealReg_DealExpiryTemplates__c();
    d1.name='English';
    d1.id__c='00XA0000000iwNY';
    //insert d1;
    //Batch_10DaysExpirationNotification batchtest = new Batch_10DaysExpirationNotification();
    
    oppt.StageName = 'Propose - 60%';
    update oppt;
    TriggerExecutionController.setSkipAllTriggers(false); 
    Test.startTest();
    String strcronexp = '0 0 0 1 1 ? 2025'; 
    String strjobId = System.schedule('test Schedular_10DaysExpirationNotificationTest', strcronexp, new Schedular_10DaysExpirationNotification() );
    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :strjobId];
    System.assertEquals(strcronexp, ct.CronExpression); 
                  
          
    //Database.Executebatch(batchtest);
    Test.stopTest();
    
    
}
///////////////////////////////////////////////////////
static testmethod void testbatchmethod3() {
    TriggerExecutionController.setSkipAllTriggers(true); 
    Account acc = new Account();
    acc.name = 'testaccount';
   // TriggerExecutionController.setSkipAccountTriggers(true); 
    insert acc;
   // TriggerExecutionController.setSkipAccountTriggers(false); 
    Contact con = new contact();
    con.lastname = 'testcon';
    con.email = 'test@test.com';
    con.Account_Changed__c = true;
    con.Accountid = acc.id;
    con.Status__c = 'Customer';
    insert con;
    System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
             vr.Bypass_Opportunity_VRs__c = true;
             insert vr;
    Opportunity oppt = new opportunity();
    oppt.name = 'Test oppt';
    oppt.Accountid = acc.id;
    oppt.CloseDate = system.Today()+30;
    oppt.Deal_Registration_Status__c = 'Approved';
    oppt.Deal_Created_Date_Time__c = system.Today();
    oppt.StageName = 'Plan - 1%';
    oppt.Submitter_Language__c = 'ENGLISH';
    oppt.Competitor_Lost_To__c = 'No Competitor/Dell Only';
   //oppt.Partner_Account_Owner_Email__c = 'test@test.com';
    oppt.Deal_Expiration_Date__c = system.Today()+30;
  //  TriggerExecutionController.setSkipOpportunityTriggers(true); 
    insert oppt;
  //  TriggerExecutionController.setSkipOpportunityTriggers(true);  
    List<Opportunity> listopplist = new List<opportunity>();
    listopplist.add(oppt);
    DealReg_DealExpiryTemplates__c d1 = new DealReg_DealExpiryTemplates__c();
    d1.name='ENGLISH';
    d1.id__c='00XA0000000iwNY';
    insert d1;
    OpportunityTeamMember testOTM = new OpportunityTeamMember (UserId=userinfo.getUserId(), TeamMemberRole='Reseller Contact', OpportunityId=oppt.Id);
        
    insert testOTM;
    // Batch_10DaysExpirationNotification batchtest = new Batch_10DaysExpirationNotification();
    oppt.StageName = 'Propose - 60%';
    update oppt;
    TriggerExecutionController.setSkipAllTriggers(false); 
    Test.startTest();
    String strcronexp = '0 0 0 1 1 ? 2025'; 
    String strjobId = System.schedule('test Schedular_10DaysExpirationNotificationTest', strcronexp, new Schedular_10DaysExpirationNotification() );
    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :strjobId];
    System.assertEquals(strcronexp, ct.CronExpression); 
                  
          
    //Database.Executebatch(batchtest);
    Test.stopTest();
    
    }
}