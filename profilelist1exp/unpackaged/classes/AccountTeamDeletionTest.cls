@isTest
private class AccountTeamDeletionTest {

    private static Map<String, String> sParams;
    private static AccountTeamMember accTM;
    
   //Test Condition: 
   //1 Acc, 10 AccTMs, Acc.Status__c='Inactive'    
    static testMethod void deleteAccountTeamMembers_DeleteStatusInactive(){
       
        system.debug('##### Start deleteAccountTeamMembers_DeleteStatusInactive #####');

        sParams = new Map<String, String>();
        
        // Test data creation             
        // Option 1: Create each object manually at each test method
        /*
        sParams.put('int_NumberOfEmployees', '1000');       
        sParams.put('dbl_of_Orders_Previous_Quarter__c', '112');
        sParams.put('dec_Current_QTD_Rev_Desktops__c', '123456789');        
        sParams.put('dat_Fiscal_Year_End__c', '2009-03-31');        
        sParams.put('bln_DMU__c', 'true');      
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();                            
                                    
        TestDataGenerator.setUserList(TestDataGenerator.getObject(new User(), 10));
        
        sParams.put('str_AccountId', testAcc.Id);
        accTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10, sParams, true)[0];
        sParams.clear();
        */
              
        // Option 2: to insert unique field
        /*   
        List<User> testSingleUserList = new List<User>();
        User singleUser = new User();
        
        sParams.put('str_UserName', 'extraTestUser11@dell.com.apexdev103');
        singleUser = (User) TestDataGenerator.getObject(new User(), 1, sParams, false)[0];
        testSingleUserList.add(singleUser);
        sParams.clear();
        
        sParams.put('str_UserName', 'extraTestUser22@dell.com.apexdev103');
        singleUser = (User) TestDataGenerator.getObject(new User(), 1, sParams, false)[0];
        testSingleUserList.add(singleUser);
        sParams.clear();
        insert testSingleUserList;       
        
        TestDataGenerator.setUserList(testSingleUserList);            
        accTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 2)[0];
        */        
        
        // Option 3: TestDataGenerator handles all objects creation
        accTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10)[0];
				                
        system.debug('## deleteAccountTeamMembers_DeleteStatusInactive - Inserted Account TMs');
        
        try{    
            // ##KP asserts that the teammembers are added.             
            system.assertEquals(10, [SELECT count() FROM AccountTeamMember WHERE AccountId = :accTM.AccountId]);
        }
        catch(Exception e){
            system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        
        try {
            // Test the trigger by changing the status__c to Inactive
            //Start the test, this changes governor limit context to that of trigger rather than test  
            Test.startTest();     

            Account testAcc = new Account(Id = accTM.AccountId, status__c = 'Inactive');
            update testAcc;
                            
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest();
            
            // ##KP asserts that the teammembers are deleted.           
            System.assertEquals(0, [SELECT count() FROM AccountTeamMember WHERE AccountId = :accTM.AccountId]);
        }
        catch (Exception e){
            system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        
        system.debug('##### End deleteAccountTeamMembers_DeleteStatusInactive #####');        
    }     

   //Test Condition: 
   //1 Acc, 10 AccTMs, Acc.Status__c='I'      
	static testMethod void deleteAccountTeamMembers_DeleteStatusI(){
	
		system.debug('##### Start deleteAccountTeamMembers_DeleteStatusI #####');
		
		accTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10)[0];
				
		system.debug('##KV deleteAccountTeamMembers_DeleteStatusI - Inserted Account TMs');
		
		try {
    		// ##KP asserts that the teammembers are added.
    		System.assertEquals(10, [select count() from AccountTeamMember where AccountId = :accTM.AccountId]);
		}
    	catch(Exception e){
    		system.debug('##KP: Caught APEX exception'+e.getMessage());
		}
		
		try{
    		//Start the test, this changes governor limit context to that of trigger rather than test
    		Test.startTest();			
 
   	    	//##KP Test the trigger by changing the status__c to I
           	Account testAcc = new Account(Id = accTM.AccountId, status__c = 'I');
            update testAcc;
            
	    	//stop the test, this changes limit context back to test from trigger.
	    	Test.stopTest();

    		// ##KP asserts that the teammembers are deleted.
    		System.assertEquals(0, [select count() from AccountTeamMember where AccountId = :accTM.AccountId]);
	    }
		catch (Exception e){
    		system.debug('##KP: Caught APEX exception'+e.getMessage());
		}
		
		system.debug('##### End deleteAccountTeamMembers_DeleteStatusI #####');
	}
	
	//Test Condition:
	//1 Acc, 10 AccTMs, Acc.DMU__c='False', Acc.Account_Type_Integration__c='Sub Account'
	static testMethod void deleteAccountTeamMembers_DMUFalse_AccTypeIntegrationSubAccount(){
	
		system.debug('##### Start deleteAccountTeamMembers_DMUFalse_AccTypeIntegrationSubAccount #####');
		
		accTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10)[0];
				
		system.debug('##KV deleteAccountTeamMembers_DMUFalse_AccTypeIntegrationSubAccount - Inserted Account TMs');
	
		try {		
			// ##KP asserts that the teammembers are added.
			System.assertEquals(10, [select count() from AccountTeamMember where AccountId = :accTM.AccountId]);
		}
		catch(Exception e) {
			system.debug('##KP: Caught APEX exception'+e.getMessage());
		}
		
		try {
			//Start the test, this changes governor limit context to that of trigger rather than test
			Test.startTest();

			//##KP Test the trigger by changing DMU__c == false and Account_Type_Integration__c == 'Sub Account'
			Account testAcc = new Account(Id = accTM.AccountId);
			testAcc.DMU__c = false;
			testAcc.Account_Type_Integration__c = 'Sub Account';
			update testAcc;
			
			//stop the test, this changes limit context back to test from trigger.
			Test.stopTest();
		
			// ##KP asserts that the teammembers are deleted.
			System.assertEquals(0, [select count() from AccountTeamMember where AccountId = :accTM.AccountId]);			
		}
		catch (Exception e) {
			system.debug('##KP: Caught APEX exception'+e.getMessage());
		}
		
		system.debug('##### End deleteAccountTeamMembers_DMUFalse_AccTypeIntegrationSubAccount #####');
	}
	
	//Test Condition:
	//1 Acc, 0 AccTMs, Acc.Status__c=Inactive
	static testMethod void deleteAccountTeamMembers_EmptyAccTM(){
		
		system.debug('##### Start deleteAccountTeamMembers_EmptyAccTM #####');
		
		// Test data creation
		Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1)[0]; 
		
		system.debug('##KV deleteAccountTeamMembers_EmptyAccTM - Inserted Account');
		
		try {		
			// ##KP asserts that the teammembers are added.
			System.assertEquals(0, [select count() from AccountTeamMember where AccountId =: testAcc.id]);
		}		
		catch (Exception e) {
			system.debug('##KP: Caught APEX exception'+e.getMessage());					
		}
		
		try{			
			//Start the test, this changes governor limit context to that of trigger rather than test
			Test.startTest();

			// Test the trigger by changing the status__c to Inactive
			testAcc.status__c = 'Inactive';
			update testAcc;
					
			//stop the test, this changes limit context back to test from trigger.
			Test.stopTest();
			
			System.assertEquals(0, [select count() from AccountTeamMember where AccountId =: testAcc.id]);			
		} 
		catch (Exception e){
			system.debug('##KP: Caught APEX exception'+e.getMessage());
		}
		
		system.debug('##### End deleteAccountTeamMembers_EmptyAccTM #####');		
	} 
	
	//Test Condition:
	//70 Acc, 350 AccTMs, Acc.Status__c=Inactive
	static testMethod void deleteAccountTeamMembers_Bulkupdates(){
		
		system.debug('##### Start deleteAccountTeamMembers_Bulkupdates #####');
		
		sParams = new Map<String, String>();
		List<SObject> testAccList;	
		List<SObject> testAccTMList;
				
		testAccList = TestDataGenerator.getObject(new Account(), 8);
		
		TestDataGenerator.setUserList(TestDataGenerator.getObject(new User(), 8));
		
		for (SObject myAcc: testAccList) {
			sParams.put('str_AccountId', myAcc.Id);
			TestDataGenerator.getObject(new AccountTeamMember(), 8, sParams);			
			sParams.clear();
		}
		
		for(SObject myAcc: testAccList) {
			myAcc.put('status__c', 'Inactive');
		}
		
		try {
			//KV: some debug info
			system.debug('##KP: Limits.getDMLStatements()-'+ Limits.getDMLStatements());
			system.debug('##KP: Limits.getLimitDMLStatements()-'+Limits.getLimitDMLStatements());
			system.debug('##KP: Limits.getDMLRows()-'+ Limits.getDMLRows());
			system.debug('##KP: Limits.getLimitDMLRows()-'+ Limits.getLimitDMLRows());
			
			//KV: check the DML limits
			Integer almostDMLRows = Limits.getDMLRows() + testAccList.size();
			system.debug('##KP: almostDMLRows-' + almostDMLRows);
				
			//Start the test, this changes governor limit context to that of trigger rather than test
			Test.startTest();
			   
			system.debug('##CS: Account List Count ' + testAccList.size());
			update testAccList;
			system.debug('##KP: Updated Inactive Accounts');
			   
			//stop the test, this changes limit context back to test from trigger.
			Test.stopTest();
		}
		catch(Exception e) {
			system.debug('##KP: Caught APEX exception'+e.getMessage());		
		}
		
		try {
			for(SObject myAcc: testAccList){
				System.assertEquals(0, [select count() from AccountTeamMember where AccountId =: myAcc.id]);
			}
		}
		catch(Exception e){
			system.debug('##KP: Caught APEX exception'+e.getMessage());
		}
		
		system.debug('##### End deleteAccountTeamMembers_Bulkupdates #####');
	} 	

   //Test Condition: 
   //1 Acc, 101 AccTMs, Acc.Status__c='I'      
	static testMethod void deleteAccountTeamMembers_TestDMLLimits(){
	
		system.debug('##### Start deleteAccountTeamMembers_TestDMLLimits #####');
		
		accTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 101)[0];
				
		system.debug('##KV deleteAccountTeamMembers_TestDMLLimits - Inserted Account TMs');
		
		try {
    		// ##KP asserts that the teammembers are added.
    		System.assertEquals(101, [select count() from AccountTeamMember where AccountId = :accTM.AccountId]);
		}
    	catch(Exception e){
    		system.debug('##KP: Caught APEX exception'+e.getMessage());
		}
		
		try{
    		//Start the test, this changes governor limit context to that of trigger rather than test
    		Test.startTest();			
 
   	    	//##KP Test the trigger by changing the status__c to I
	    	Account testAcc = new Account(Id = accTM.AccountId, status__c = 'I');
	    	update testAcc;

	    	//stop the test, this changes limit context back to test from trigger.
	    	Test.stopTest();

    		// ##KP asserts that the teammembers are deleted.
    		//System.assertEquals(0, [select count() from AccountTeamMember where AccountId = :accTM.AccountId]);
	    }
		catch (Exception e){
    		
    		System.assert(e.getMessage().contains('Exceeded the DML limits'));
		}
		
		system.debug('##### End deleteAccountTeamMembers_TestDMLLimits #####');
	}
	
   //Test Condition: Negative
   //1 Acc, 10 AccTMs, Acc.Status__c='A'      
	static testMethod void deleteAccountTeamMembers_NoDeleteStatusA(){
	
		system.debug('##### Start deleteAccountTeamMembers_NoDeleteStatusA #####');
		
		accTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 10)[0];
				
		system.debug('##KV deleteAccountTeamMembers_DeleteStatusA - Inserted Account TMs');
		
		try {
    		// ##KP asserts that the teammembers are added.
    		System.assertEquals(10, [select count() from AccountTeamMember where AccountId = :accTM.AccountId]);
		}
    	catch(Exception e){
    		system.debug('##KP: Caught APEX exception'+e.getMessage());
		}
		
		try{
    		//Start the test, this changes governor limit context to that of trigger rather than test
    		Test.startTest();			
 
   	    	//##KP Test the trigger by changing the status__c to I
	    	Account testAcc = new Account(Id = accTM.AccountId, status__c = 'A');
	    	update testAcc;

	    	//stop the test, this changes limit context back to test from trigger.
	    	Test.stopTest();

    		// ##KP asserts that the teammembers are deleted.
    		System.assertEquals(10, [select count() from AccountTeamMember where AccountId = :accTM.AccountId]);
	    }
		catch (Exception e){
    		system.debug('##KP: Caught APEX exception'+e.getMessage());
		}
		
		system.debug('##### End deleteAccountTeamMembers_NoDeleteStatusA #####');
	}
		
	//Test condition:
	//10 Acc in the list, 1 Acc not in the list
	static testMethod void getFailedAccountListstr_ConvertListToString(){

		system.debug('##### Start getFailedAccountListstr_ConvertListToString #####');
		
		try{
			// Test data creation
			List <SObject> testAccList = TestDataGenerator.getObject(new Account(), 11); 
			
			system.debug('## Account List Count ' + testAccList.size());
						
			List<id> myIdList= new List<id>();
			String myOutput='';
			
			for(integer i=0; i<10; i++){
		   		myIdList.add(testAccList[i].Id);
		  	}
		  	
			// Test for Positive result
			Id pivotId =  myIdList[5];
			myOutput = AccountTeamDeletion.getFailedAccountListstr(myIdList,pivotId);
		 	system.assert(myOutput.contains(String.valueOf(pivotId)));
		  
		 	// Test for -ve result			
			myOutput = AccountTeamDeletion.getFailedAccountListstr(myIdList,testAccList[10].Id);
			system.assert(myOutput.contains('Sorry'));
		}
		catch(Exception e){
    		system.debug('##KP: Caught APEX exception'+e.getMessage());
  		}  
  		
  		system.debug('##### End getFailedAccountListstr_ConvertListToString #####');
	}
}