/**
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      General		16.10       28-Oct-2015     Niveda          Created.
 *
 */
 
@isTest(SeeAllData=false)
public class AfterInsertTaskTriggerTest {
	
 	static testMethod void testTaskTrigger () {
 		TriggerExecutionController.setSkipAllTriggers(true);
		Account cAccount = new Account(Name = 'C Account Test', Account_Country_Code__c = 'US', Account_Country__c ='UNITED STATES');
    	insert cAccount;
    
    	Contact  cContact = new Contact(status__c = 'Prospect', FirstName = 'C Scott', LastName = 'Summers', AccountId = cAccount.Id, Decision_Making_Role__c = 'End User', Email = 'Cyclops@Xmen.com');
    	insert cContact;
    	
    	Case testCase = new Case(AccountId = cAccount.Id, ContactId = cContact.Id, Origin = 'Partner Portal', 
    							Sub_Type_Internal_User__c = 'Password Reset', Subject = 'Test Case Class 1', Description = 'This is a test', Priority = 'Medium',
                        		Alternate_Phone__c = '123456789', Case_Category__c = 'Partner', Country_Area__c = 'UNITED STATES');       
  		insert testCase;
		TriggerExecutionController.setSkipAllTriggers(false);
		
    	Id npsRTId = StaticFactory.getRecordTypeIdByName('Task', 'NPS Task');
      	
      	
      	Test.startTest();
  		Task testTask = new Task();
     	testTask.Subject = 'Detractor'; 
     	testTask.WhatId = testCase.Id; 
     	testTask.RecordTypeId = npsRTId;
     	insert testTask;
     	Test.stopTest();
 	}
     
}