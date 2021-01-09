/*
 * Author  : Krishnakumar M
 * Purpose : Buddy Request Functionality
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR14112      05.02      20-Feb-2017     Krishnakumar    Buddy Request - Create Batch Processes to Add/Remove Buddy member to ATM
 * 2.0      CR14556      07.02      29-Jun-2017     Krishnakumar    SE148 - Fix for the Defect 3497907 Buddy Access batch process 
 * 3.0      CR16640      08.02      04-Jul-2017     Krishnakumar    SE149 - SE149 - Permanent Fix for the Defect 3497907 Buddy Access batch process
 * 4.0 		CR14846      10.01      06-Sep-2017     Nagaraju       Created TestFailure Scenario Method.
 */
@isTest
public class Batch_BuddyRevokeTest{
	
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

	static testmethod void testRevokeScheduler(){

		Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Batch_BuddyRevokeScheduler batchRevoke = new Batch_BuddyRevokeScheduler();
        batchRevoke.intScope = 100;
        
        String jobId = System.schedule('Buddy Request Exclusion Batch', CRON_EXP, batchRevoke);

        CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression); 

        Test.stopTest();

	}
	static testmethod void test1Rep1Buddy(){
		
		TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;
		List<GDM_Request__c> listBuddyReq = new List<GDM_Request__c>();
		GDM_Request__c objGdmReq;
		
		System.runAs(objAdminUser){
			Account objAccount=new Account();
			objAccount.name='test last run';
			insert objAccount;

			AccountTeamMember objRepATM=createATM(objAccount.id,listTestUser[0].id);
	        AccountTeamMember objBuddyATM=createATM(objAccount.id,listTestUser[1].id);        	        
	        System.runAs(listTestUser[0]){
	        	objGdmReq = new GDM_Request__c();
			    objGdmReq.Buddy_Access_Start_Date__c = system.today();
			    objGdmReq.Buddy_Access_End_Date__c = (system.today())+2;
			    objGdmReq.Buddy__c = listTestUser[1].id;
			    objGdmReq.Rep_on_Leave__c = listTestUser[0].id;
			    objGdmReq.Reason_Requested__c = 'Sickness';
			    objGdmReq.Comments2__c = 'Test';
			    objGdmReq.RecordTypeId = IdBuddyAccessRT;
			    objGdmReq.ROL_Manager__c = objAdminUser.id;
			    insert objGdmReq;
			    listBuddyReq.add(objGdmReq);
			    System.assertNotEquals(objGdmReq.id,null);
	        }
	        objGdmReq.Buddy_Access_Status__c = 'Access provided';
	        objGdmReq.Buddy_Access_Start_Date__c = (System.today())-2;
			objGdmReq.Buddy_Access_End_Date__c = System.today();
	        update objGdmReq;
	        system.debug('*******End-'+objGdmReq.Buddy_Access_End_Date__c);
	        System.assertEquals(objGdmReq.Buddy_Access_End_Date__c, System.today()); 
	        //System.assertEquals(objGdmReq.recordtype.developerName, 'Buddy_Access'); 
			
		}

		Test.startTest();
		Batch_BuddyRevoke revoke = new Batch_BuddyRevoke();
		Database.executeBatch(revoke);
		Test.stopTest();

        //System.assertEquals(objGdmReq.Buddy_Access_Status__c,'Access re');
	}

	// 2 Rep 1 Buddy Scenario
	static testmethod void test2Rep1Buddy(){

		TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;

		List<GDM_Request__c> listBuddyReq = new List<GDM_Request__c>();
		GDM_Request__c objGdmReq;
		GDM_Request__c objGdmReq1;
		Id IdBuddyAccessRT = IdLookupUtils.getRecordTypeId('Buddy Access','GDM_Request__c',true);
		
		System.runAs(objAdminUser){
			Account objAccount=new Account();
			objAccount.name='test last run';
			insert objAccount;

			List<AccountTeamMember> listAtm = new List<AccountTeamMember>();
			AccountTeamMember objRepATM = createATM(objAccount.id,listTestUser[0].id);
	        AccountTeamMember objBuddyATM1 = createATM(objAccount.id,listTestUser[1].id);
	        AccountTeamMember objRepATM2 = createATM(objAccount.id,listTestUser[2].id);
	           
	         System.runAs(listTestUser[0]){
	        	objGdmReq = new GDM_Request__c();
			    objGdmReq.Buddy_Access_Start_Date__c = system.today();
			    objGdmReq.Buddy_Access_End_Date__c = (system.today())+2;
			    objGdmReq.Buddy__c = listTestUser[1].id;
			    objGdmReq.Rep_on_Leave__c = listTestUser[0].id;
			    objGdmReq.Reason_Requested__c = 'Sickness';
			    objGdmReq.Comments2__c = 'Test';
			    objGdmReq.RecordTypeId = IdBuddyAccessRT;
			    objGdmReq.ROL_Manager__c = objAdminUser.id;
			    listBuddyReq.add(objGdmReq);

			    objGdmReq1 = new GDM_Request__c();
			    objGdmReq1.Buddy_Access_Start_Date__c = system.today();
			    objGdmReq1.Buddy_Access_End_Date__c = (system.today())+2;
			    objGdmReq1.Buddy__c = listTestUser[1].id;
			    objGdmReq1.Rep_on_Leave__c = listTestUser[2].id;
			    objGdmReq1.Reason_Requested__c = 'Sickness';
			    objGdmReq1.Comments2__c = 'Test';
			    objGdmReq1.RecordTypeId = IdBuddyAccessRT;
			    objGdmReq1.ROL_Manager__c = objAdminUser.id;
			    listBuddyReq.add(objGdmReq1);
			    insert listBuddyReq;
			    System.assertNotEquals(objGdmReq.id,null);
	        }
	        objGdmReq.Buddy_Access_Status__c = 'Access provided';
	        objGdmReq.Buddy_Access_Start_Date__c = (System.today())-2;
			objGdmReq.Buddy_Access_End_Date__c = System.today();
			update objGdmReq;
			objGdmReq1.Buddy_Access_Status__c = 'Access provided';
	        update objGdmReq1;
	        system.debug('*******End-'+objGdmReq.Buddy_Access_End_Date__c);
	        System.assertEquals(objGdmReq.Buddy_Access_End_Date__c, System.today()); 
	        //System.assertEquals(objGdmReq.recordtype.developerName, 'Buddy_Access'); 

	        GDM_Request__c objATMHistory1 = createBackupATM(objRepATM,objBuddyATM1,objGdmReq,true);
            GDM_Request__c objATMHistory3 = createBackupATM(objRepATM2,objBuddyATM1,objGdmReq1,false);
		}

		Test.startTest();
		Batch_BuddyRevoke revoke = new Batch_BuddyRevoke();
		Database.executeBatch(revoke);
		Test.stopTest();

        //System.assertEquals(objGdmReq.Buddy_Access_Status__c,'Access re');
	}	

	//Rep On leave Removed By Affirinity Team.
	static testmethod void testAffirinityRemoval(){
		
		TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;

		List<GDM_Request__c> listATMBuddy = new List<GDM_Request__c>();
		List<GDM_Request__c> listBuddyReq = new List<GDM_Request__c>();
		GDM_Request__c objGdmReq;
		GDM_Request__c objGdmReq1;
		Id IdBuddyAccessRT = IdLookupUtils.getRecordTypeId('Buddy Access','GDM_Request__c',true);
		

		System.runAs(objAdminUser){
			Account objAccount=new Account();
			objAccount.name='test last run';
			insert objAccount;

			List<AccountTeamMember> listAtm = new List<AccountTeamMember>();
			AccountTeamMember objBuddyATM=createATM(objAccount.id,listTestUser[1].id);
	        AccountTeamMember objRepATM=createATM(objAccount.id,listTestUser[0].id);
	        
	        
	         System.runAs(listTestUser[0]){
	        	objGdmReq = new GDM_Request__c();
			    objGdmReq.Buddy_Access_Start_Date__c = system.today();
			    objGdmReq.Buddy_Access_End_Date__c = (system.today())+2;
			    objGdmReq.Buddy__c = listTestUser[1].id;
			    objGdmReq.Rep_on_Leave__c = listTestUser[0].id;
			    objGdmReq.Reason_Requested__c = 'Sickness';
			    objGdmReq.Comments2__c = 'Test';
			    objGdmReq.RecordTypeId = IdBuddyAccessRT;
			    objGdmReq.ROL_Manager__c = objAdminUser.id;
			    listBuddyReq.add(objGdmReq);
			    insert listBuddyReq;
			    System.assertNotEquals(objGdmReq.id,null);
	        }
	        objGdmReq.Buddy_Access_Status__c = 'Access provided';
	        objGdmReq.Buddy_Access_Start_Date__c = (System.today())-2;
			objGdmReq.Buddy_Access_End_Date__c = System.today();
			update objGdmReq;
			
	        system.debug('*******End-'+objGdmReq.Buddy_Access_End_Date__c);
	        System.assertEquals(objGdmReq.Buddy_Access_End_Date__c, System.today()); 
	        //System.assertEquals(objGdmReq.recordtype.developerName, 'Buddy_Access'); 

	        GDM_Request__c objATMHistory1 = createBackupATM(objRepATM,objBuddyATM,objGdmReq,true);
	        
            //ATM is removed by Affinity Team
            delete objRepATM;
			
		}
		Test.startTest();
		Batch_BuddyRevoke revoke = new Batch_BuddyRevoke();
		Database.executeBatch(revoke);
		Test.stopTest();

        //System.assertEquals(objGdmReq.Buddy_Access_Status__c,'Access re');
	}	
    
    static testMethod void testFailureScenario(){
        
		TriggerExecutionController.setSkipAllTriggers(true);
        ProcessFlowTriggerController.isTest = true;

        GDM_Request__c objGdmReq;
        
         System.runAs(listTestUser[0]){
	        	objGdmReq = new GDM_Request__c();
			    objGdmReq.Buddy_Access_Start_Date__c = system.today();
			    objGdmReq.Buddy_Access_End_Date__c = (system.today())+2;
			    objGdmReq.Buddy__c = listTestUser[1].id;
			    objGdmReq.Rep_on_Leave__c = listTestUser[0].id;
			    objGdmReq.Reason_Requested__c = 'Sickness';
			    objGdmReq.Comments2__c = 'Test';
			    objGdmReq.RecordTypeId = IdBuddyAccessRT;
			    objGdmReq.ROL_Manager__c = objAdminUser.id;
			    insert objGdmReq;
			    System.assertNotEquals(objGdmReq.id,null);
	        }
        System.runAs(objAdminUser) {
	        if(objGdmReq != null){
	        	objGdmReq.Buddy_Access_Status__c = 'Access provided';
                objGdmReq.Buddy_Access_Start_Date__c = (System.today())-2;
                objGdmReq.Buddy_Access_End_Date__c = System.today();
                update objGdmReq;
	        }
    	} 	
    	       
    	Test.startTest();
        
        GDM_Request__c[] listGDM = [select id from GDM_Request__c where id =:objGdmReq.id];
    	Approval.LockResult[] lrList = Approval.lock(listGDM);
		

        Batch_BuddyRevoke revoke = new Batch_BuddyRevoke();
		Database.executeBatch(revoke);
               
        Test.stopTest();
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




}