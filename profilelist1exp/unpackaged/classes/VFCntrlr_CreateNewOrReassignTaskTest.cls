/********************************************************************
* Name			: VFCntrlr_CreateNewOrReassignTaskTest 
* Description	: Test class for VFCntrlr_CreateNewOrReassignTaskAssignee
* -----------------------------------------------------------------------------------------------------------
* Revision      Name    	Date            Description
* 1.0           Josipinna   07.07.2011      Test class for VFCntrlr_CreateNewOrReassignTaskAssignee
*************************************************************************************************************/
@isTest
private class VFCntrlr_CreateNewOrReassignTaskTest {

	static Task task;
	static Account testAccount;
	static Opportunity testOpportunity;
	static List<User> testUserList;
    static string AssignOptions;
    static List<AccountTeamMember> testATM;
    static List<OpportunityTeamMember> testOTM;
    static String actualURL;
    
    static testMethod void setReturnURL_AssignOptions_AccountTeamMembers() {
    	System.debug('*****************START setReturnURL_AssignOptions_AccountTeamMembers*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.CreateNewOrReassignTaskAssignee;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('TaskId', task.Id);
        ApexPages.currentPage().getParameters().put('what_id', testAccount.Id);
        ApexPages.currentPage().getParameters().put('ReassignTask', 'false');
              
        ApexPages.StandardController taskRec = new ApexPages.StandardController(task);  	
    	VFCntrlr_CreateNewOrReassignTaskAssignee controller = new VFCntrlr_CreateNewOrReassignTaskAssignee(taskRec);    	
								    	    	
    	Test.startTest();

    	controller.aTaskId = task.Id;
    	controller.AssignOptions = 'Account Team Members';
    	controller.ListofSalesOrAccountTeamMember = testATM;
    	controller.SelectedRecordId = testATM[0].Id;
    	
    	controller.setReturnURL();
    	
    	Test.stopTest();
    	
  	
    	// Query record
    	Account AccountRec =[SELECT Id FROM Account WHERE Id =: testAccount.Id];
    									 
    	System.assertEquals(testAccount.Id, AccountRec.Id);
    	System.assertEquals('001', controller.recordIdPrefix);
    	System.assertEquals('AccountTeamMember', controller.sObjectType);
    	System.assertEquals('false', controller.ReassignTask);
    	System.assertEquals(False, controller.showSaveNClosebutton);
    	System.assertEquals('Account Team Members', controller.AssignOptions);
    	System.assertEquals(testATM[0].Id, controller.SelectedRecordId);

    	System.debug('***************** END setReturnURL_AssignOptions_AccountTeamMembers*****************');
    }
    
    static testMethod void setReturnURL_AssignOptions_SalesTeamMembers() {
    	System.debug('*****************START setReturnURL_AssignOptions_SalesTeamMembers*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.CreateNewOrReassignTaskAssignee;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('TaskId', task.Id);
        ApexPages.currentPage().getParameters().put('what_id', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('ReassignTask', 'True');
    
        ApexPages.StandardController taskRec = new ApexPages.StandardController(task);  	
    	VFCntrlr_CreateNewOrReassignTaskAssignee controller = new VFCntrlr_CreateNewOrReassignTaskAssignee(taskRec);    	
								    	    	
    	Test.startTest();
    	
    	controller.aTaskId = task.Id;
    	controller.AssignOptions = 'Sales Team Members';
    	controller.ListofSalesOrAccountTeamMember = testOTM;
    	  	
    	controller.setReturnURL();
    	
    	Test.stopTest();
    	
    	
    	// Query record
    	Opportunity OpportunityRec =[SELECT Id FROM Opportunity WHERE Id =: testOpportunity.Id];
							 
    	System.assertEquals(testOpportunity.Id, OpportunityRec.Id);
    	System.assertEquals('006', controller.recordIdPrefix);
    	System.assertEquals('OpportunityTeamMember', controller.sObjectType);
    	System.assertEquals('True', controller.ReassignTask);
    	System.assertEquals(True, controller.showSaveNClosebutton);
    	System.assertEquals('Sales Team Members', controller.AssignOptions);
    	
    	System.debug('***************** END setReturnURL_AssignOptions_SalesTeamMembers*****************');
    }
 
 
     static testMethod void setReturnURL_AssignOptions_Others() {
    	System.debug('*****************START setReturnURL_AssignOptions_Others*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.CreateNewOrReassignTaskAssignee;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('TaskId', task.Id);
        ApexPages.currentPage().getParameters().put('what_id', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('ReassignTask', 'True');
       
        
        ApexPages.StandardController taskRec = new ApexPages.StandardController(task);  	
    	VFCntrlr_CreateNewOrReassignTaskAssignee controller = new VFCntrlr_CreateNewOrReassignTaskAssignee(taskRec);    	
								    	    	
    	Test.startTest();
    	
    	controller.aTaskId = task.Id;
    	controller.AssignOptions = 'Others';
    	controller.User = testUserList;   	
    	controller.setReturnURL();
    	
    	Test.stopTest();

    	System.assertEquals('True', controller.ReassignTask);
    	System.assertEquals('Others', controller.AssignOptions);
    	System.assertEquals(UserInfo.getName(), controller.SelectedRecordName);
    	
    	System.debug('***************** END setReturnURL_AssignOptions_Others*****************');
    }   
   
    
    static testMethod void doContinue_test() {
    	System.debug('*****************doContinue_test*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.CreateNewOrReassignTaskAssignee;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('TaskId', task.Id);
        ApexPages.currentPage().getParameters().put('what_id', testAccount.Id);
        ApexPages.currentPage().getParameters().put('ReassignTask', 'true');
        
        ApexPages.StandardController taskRec = new ApexPages.StandardController(task);  	
    	VFCntrlr_CreateNewOrReassignTaskAssignee controller = new VFCntrlr_CreateNewOrReassignTaskAssignee(taskRec);    	
		
		controller.sObjectType = 'AccountTeamMember';
					    	    	
    	Test.startTest();  	  	
  	   	
    	controller.doContinue();

    	Test.stopTest();

		System.assertEquals('AccountTeamMember', controller.sObjectType);

    	System.debug('***************** END doContinue_test*****************');
    }
 
    static testMethod void getAccountTeamMember_test() {
    	System.debug('*****************START getAccountTeamMember_test*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.CreateNewOrReassignTaskAssignee;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('TaskId', task.Id);
        ApexPages.currentPage().getParameters().put('what_id', testAccount.Id);
        ApexPages.currentPage().getParameters().put('ReassignTask', 'false');
        
        ApexPages.StandardController taskRec = new ApexPages.StandardController(task);  	
    	VFCntrlr_CreateNewOrReassignTaskAssignee controller = new VFCntrlr_CreateNewOrReassignTaskAssignee(taskRec);    	
								    	    	
    	Test.startTest(); 	  	
    	   	
    	controller.getAccountTeamMember();
    	
    	Test.stopTest();

    	System.debug('***************** END getAccountTeamMember_test*****************');
    } 


    static testMethod void getSalesTeamMember_test() {
    	System.debug('*****************START getSalesTeamMember_test*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.CreateNewOrReassignTaskAssignee;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('TaskId', task.Id);
        ApexPages.currentPage().getParameters().put('what_id', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('ReassignTask', 'True');
    
        ApexPages.StandardController taskRec = new ApexPages.StandardController(task);  	
    	VFCntrlr_CreateNewOrReassignTaskAssignee controller = new VFCntrlr_CreateNewOrReassignTaskAssignee(taskRec);    	
								    	    	
    	Test.startTest();
    	
    	controller.aTaskId = task.Id;
    	controller.AssignOptions = 'Sales Team Members';
    	controller.ListofSalesOrAccountTeamMember = testOTM;
    	  	
    	controller.getSalesTeamMember();
    	
    	Test.stopTest();
    	
    	System.debug('***************** END getSalesTeamMember_test*****************');
    }
   
    static testMethod void doSaveClose_test() {
    	System.debug('*****************START doSaveClose_test*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.CreateNewOrReassignTaskAssignee;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('TaskId', task.Id);
        ApexPages.currentPage().getParameters().put('what_id', testAccount.Id);
        ApexPages.currentPage().getParameters().put('ReassignTask', 'false');
        
        ApexPages.StandardController taskRec = new ApexPages.StandardController(task);  	
    	VFCntrlr_CreateNewOrReassignTaskAssignee controller = new VFCntrlr_CreateNewOrReassignTaskAssignee(taskRec);    	
								    	    	
    	Test.startTest();
 	   	   	
    	controller.doSaveClose();
    	
    	Test.stopTest();

    	System.debug('***************** END doSaveClose_test*****************');
    }


    static testMethod void getAssignmentOptions_test() {
    	System.debug('*****************START getAssignmentOptions_test*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.CreateNewOrReassignTaskAssignee;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('TaskId', task.Id);
        ApexPages.currentPage().getParameters().put('what_id', testAccount.Id);
        ApexPages.currentPage().getParameters().put('ReassignTask', 'false');
        
        ApexPages.StandardController taskRec = new ApexPages.StandardController(task);  	
    	VFCntrlr_CreateNewOrReassignTaskAssignee controller = new VFCntrlr_CreateNewOrReassignTaskAssignee(taskRec);    	
								    	    	
    	Test.startTest();
	  	  	   	
    	controller.getAssignmentOptions();
    	
    	Test.stopTest();

    	System.debug('***************** END getAssignmentOptions_test*****************');
    }


    static testMethod void doCancel_test() {
    	System.debug('*****************START doCancel_test*****************');
    	
    	// Create test data
    	testDataCreation();
    	
    	PageReference pageRef = page.CreateNewOrReassignTaskAssignee;
    	Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('TaskId', task.Id);
        ApexPages.currentPage().getParameters().put('what_id', testAccount.Id);
        ApexPages.currentPage().getParameters().put('ReassignTask', 'True');
        
        ApexPages.StandardController taskRec = new ApexPages.StandardController(task);  	
    	VFCntrlr_CreateNewOrReassignTaskAssignee controller = new VFCntrlr_CreateNewOrReassignTaskAssignee(taskRec);    	
		actualURL = controller.doCancel().getUrl();	
								    	    	
    	Test.startTest();
    	  	  	   	
    	controller.doCancel();
    	
    	Test.stopTest();

		System.assertEquals('/'+task.Id, actualURL);
    	System.assertEquals('True', controller.ReassignTask);
    	System.debug('***************** END doCancel_test*****************');
    }
    
    
  // Create test data
    public static void testDataCreation() {
    	
    	TriggerExecutionController.setSkipAllTriggers(true);
    	
    	System.debug('***************** START testDataCreation *****************');
    	testUserList = new List<User>();

    	Profile profile = [select id from profile where name = 'System Administrator' limit 1];
                                
        for (integer i = 0; i < 2; i++) {
            User testUser = new User(Username='Test'+i+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test'+i, 
                                        Email='Test'+i+'@dell.com',            
                                        FirstName = 'User'+i,
                                        LastName='Test'+i, 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Test'+i+System.currentTimeMillis());
        		testUserList.add(testUser);
        }
        insert testUserList;
   
        
		// Create account
		testAccount = new Account(name='TestAccount');
		insert testAccount;

		// Create account team
		testATM = new List<AccountTeamMember>();

			// Build the account team
			AccountTeamMember acctTM0 = new AccountTeamMember();
			acctTM0.AccountId = testAccount.Id;
			acctTM0.UserId = testUserList[0].Id;
			acctTM0.TeamMemberRole = 'Account Administrator';
	
			AccountTeamMember acctTM1 = new AccountTeamMember();
			acctTM1.AccountId = testAccount.Id;
			acctTM1.UserId = testUserList[1].Id;
			acctTM1.TeamMemberRole = 'Sales Approver';

			testATM.add(acctTM0);		
			testATM.add(acctTM1);	


			insert testATM;        

        task = new Task(WhatId = testAccount.Id, OwnerId = testUserList[0].Id);
        insert task;         
        
		// Create the opportunities
		String sRecordType1 = '012300000004zf2';	// Standard Opportunity
		//Date dCloseDate = Date.newInstance(2011,11,26); // Fenny commented [18-July-2014]: to fulfill new VR OpptyBookDateValidation
		Date dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: to fulfill new VR OpptyBookDateValidation

		testOpportunity = new Opportunity(Name='Opportunity 1', AccountId=testAccount.Id, CloseDate=dCloseDate, StageName='Plan - 1%', Type='Deal/Bid - Direct', RecordTypeId=sRecordType1);
		
		insert testOpportunity;        
        

		// Create opportunity teams
		testOTM = new List<OpportunityTeamMember>();
		List<OpportunityShare> testOS = new List<OpportunityShare>();


			// Build the opportunity teams
			OpportunityTeamMember oppTM0 = new OpportunityTeamMember();
			oppTM0.OpportunityId = testOpportunity.Id;
			oppTM0.UserId = testUserList[0].Id;
			oppTM0.TeamMemberRole = 'TSM';
	
			OpportunityTeamMember oppTM1 = new OpportunityTeamMember();
			oppTM1.OpportunityId = testOpportunity.Id;
			oppTM1.UserId = testUserList[1].Id;
			oppTM1.TeamMemberRole = 'Sales Approver';

			testOTM.add(oppTM0);
			testOTM.add(oppTM1);
			
			insert testOTM;


        System.debug('***************** END testDataCreation *****************');

    
    }     
    
}