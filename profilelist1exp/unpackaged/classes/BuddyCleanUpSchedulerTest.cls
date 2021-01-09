/*
 * Author  : Nagaraju Yelluri
 * Purpose : Buddy Cleanup Functionality
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR14846      10.01      25-Aug-2017     Nagaraju        Deletes old Buddy ATM requests which are in Access Removed Status.
 */
 @isTest
public class BuddyCleanUpSchedulerTest{

private static Id IdATMBackupRT;
  private static User objAdminUser;
  private static List<User> listTestUser;
  private static List<Profile> listProfile;
  private static ID IdBuddyAccessRT;


  static{

    TriggerExecutionController.setSkipAllTriggers(true);
    ProcessFlowTriggerController.isTest = true;

    listProfile = [SELECT Id,name FROM Profile WHERE Name in ('System Administrator','R16.10 GBL EMEA Sales Rep') order by name]; 
    IdBuddyAccessRT = IdLookupUtils.getRecordTypeId('Buddy Access','GDM_Request__c',true);
    IdATMBackupRT = IdLookupUtils.getRecordTypeId('ATM History For Buddy Access','GDM_Request__c',true);

    objAdminUser = new User(Alias = 'standt', Email='standarduser@dell.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = listProfile.get(1).Id, userRoleId = '00E30000000w2BzEAI',  Badge_Number__c='TEST1'+System.currentTimeMillis(),
    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+ System.currentTimeMillis() +'@dell.com');
    insert objAdminUser;

    listTestUser = new List<User>();
        for (Integer i=0; i<3;i++){
            User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
                                Alias = 'test'+i, 
                                Email='test'+ i +'@dell.com', 
                                FirstName='Tfirst'+i, 
                                LastName='TLast'+i,
                                ProfileId = listProfile.get(0).Id, 
                                userRoleId = '00E30000000w2BzEAI',
                                ManagerId = objAdminUser.id,
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='TEST12345'+i );
                
            listTestUser.add(user);   
        } 
        insert listTestUser;

  }

  

    static testmethod void testBuddyCleanupcheduler(){

    TriggerExecutionController.setSkipAllTriggers(true);
    ProcessFlowTriggerController.isTest = true;

    GDM_Request__c objGdmReq;
    AccountTeamMember objRepATM;
    AccountTeamMember objBuddyATM;
    GDM_Request__c objATMHistory1;
    System.runAs(objAdminUser) {
        Account objAccount=new Account();
        objAccount.name='test last run';
        insert objAccount;
        objRepATM=createATM(objAccount.id,listTestUser[0].id);
        objBuddyATM=createATM(objAccount.id,listTestUser[1].id);     
        }
    System.runAs(listTestUser[0]){
        objGdmReq = new GDM_Request__c();
        objGdmReq.Buddy_Access_Start_Date__c = system.today();
        objGdmReq.Buddy_Access_End_Date__c = (system.today())+2;
        objGdmReq.Buddy__c = listTestUser[0].id;
        objGdmReq.Rep_on_Leave__c = listTestUser[1].id;
        objGdmReq.Reason_Requested__c = 'Sickness';
        objGdmReq.Comments2__c = 'Test';
        objGdmReq.RecordTypeId = IdBuddyAccessRT;
        objGdmReq.ROL_Manager__c = objAdminUser.id;
        insert objGdmReq;
        System.assertNotEquals(objGdmReq.id,null);
    }

    System.runAs(objAdminUser) {
    objATMHistory1 = createBackupATM(objRepATM,objBuddyATM,objGdmReq,false);
    
    objGdmReq.Buddy_Access_Status__c = 'Access Removed';
    objGdmReq.Buddy_Access_End_Date__c = (system.today())-120;
    update objGdmReq;
    
    }
    Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        BuddyCleanUpScheduler buddyCleaner = new BuddyCleanUpScheduler();
        //batchAddition.intScope = 100;
        
        String jobId = System.schedule('Buddy Request Inclusion Batch', CRON_EXP, buddyCleaner);

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 

        Test.stopTest();
        List<GDM_Request__c> objGdm = [select id from GDM_Request__c where id = :objATMHistory1.id];
        system.debug('Deleted ?'+objGdm);
        system.assertEquals(objGdm.size(),0);

  }
  
   static GDM_Request__c createBackupATM(AccountTeamMember objRepAtm,AccountTeamMember objBuddyAtm,GDM_Request__c objGdmReq,Boolean bIsNew){
    
        GDM_Request__c objATMHistory = new GDM_Request__c();
        objATMHistory.RecordTypeId = IdATMBackupRT;
        objATMHistory.Is_New_Buddy__c = bIsNew;
        objATMHistory.Account_ID__c = objBuddyAtm.AccountId;
        objATMHistory.AccountAccessLevel__c = objBuddyAtm.AccountAccessLevel;
        objATMHistory.CaseAccessLevel__c = objBuddyAtm.CaseAccessLevel;
        //objATMHistory.GDM_Request_Id__c = objGdmReq.id;
        objATMHistory.GDM_Request__c = objGdmReq.id;
        objATMHistory.OpportunityAccessLevel__c = objBuddyAtm.OpportunityAccessLevel;
        objATMHistory.TeamMemberRole__c = objBuddyAtm.TeamMemberRole;
        objATMHistory.Rep_Account_Access_Level__c = objRepAtm.AccountAccessLevel;
        objATMHistory.Rep_Case_Access_Level__c = objRepAtm.CaseAccessLevel;
        objATMHistory.Rep_Opportunity_Access_Level__c = objRepAtm.OpportunityAccessLevel;

        insert objATMHistory;

        return objATMHistory;
  }
  
  static AccountTeamMember createATM(ID idAccount,ID idUser){
      AccountTeamMember objATM=new AccountTeamMember();
      objATM.AccountId= idAccount;
      objATM.UserId= idUser;
      objATM.AccountAccessLevel='Edit';
      objATM.CaseAccessLevel='Read';
      objATM.OpportunityAccessLevel='Edit';
      objATM.TeamMemberRole = 'Inside Sales Rep';    
    insert objATM;
    return objATM;          
  }
  
}