// This Batch Apex Class was created by SFDC to help hide the Get Chatter Desktop link so Dell users download from RAP
// This class can be used as a generic class to set User Preferences
// To run this class to update the UserPreferencesHideCSNDesktopTask field on the User Object:
// Copy the following lines of code to the System Log and Execute 
//		
//      SetUserPrefs turnOff = new SetUserPrefs();
//		turnOff.Query=	'SELECT Id, UserPreferencesHideCSNDesktopTask FROM User WHERE isactive=true and usertype=\'Standard\' ';
//		turnOff.Field = 'UserPreferencesHideCSNDesktopTask';
//		turnOff.Value = true; 

global class SetUserPrefs implements Database.Batchable<sObject> {

	global  String Query;
   	global  String Field;
   	global  Boolean Value;

	global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope){
     	for(sobject s : scope){
	    	s.put(Field,Value); 
	    }
     	Database.update(scope, false); // allow partial updates to succeed	
    }

   	global void finish(Database.BatchableContext BC) { 
		// Get the ID of the AsyncApexJob representing this batch job     
	   	// from Database.BatchableContext. 
	   	// Query the AsyncApexJob object to retrieve the current job's information.  
	    
	   	AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
	      					TotalJobItems, CreatedBy.Email 
	      					from AsyncApexJob 
	      					where Id = :BC.getJobId()];
	   
	   	// Send an email to the Apex job's submitter notifying of job completion.  
	   	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	   	String[] toAddresses = new String[] {a.CreatedBy.Email}; 
	   	mail.setToAddresses(toAddresses);
	   	mail.setSubject('Apex set User Preference' + a.Status);
	   	mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems +
	   							' batches with '+ a.NumberOfErrors + ' failures.');
	   	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   	
   	}
   	
   	static testmethod void t1() { 
		
		Profile pr = [select id from profile where name='Standard User' limit 1]; 
        
        User u = new User(alias = 'standt', 
                          email='standarduser@dell.com.sit', 
                          emailencodingkey='UTF-8', 
                          lastname='Testing22', 
                          languagelocalekey='es', 
                          localesidkey='en_US', 
                          profileid = pr.Id, 
                          UserPreferencesHideCSNDesktopTask = false,
                          timezonesidkey='America/Los_Angeles', 
                          username='standard' + String.valueOf(System.now().getTime()) + '@dell.com.sit');
                          
                          u.Badge_Number__c = 'test' + String.valueOf(System.now().getTime());
            
		insert u;
        u = [ select id,UserPreferencesHideCSNDesktopTask from user where id = :u.id limit 1];
        system.assert( u.id != null);
        system.assert( u.UserPreferencesHideCSNDesktopTask == false);

        
		Test.StartTest();
		
		SetUserPrefs turnOff = new SetUserPrefs();
		// here we limit the scope to perform a valid test
		turnOff.Query=	'SELECT Id, UserPreferencesHideCSNDesktopTask FROM User where lastname = \'Testing22\' ';
		turnOff.Field = 'UserPreferencesHideCSNDesktopTask';
		turnOff.Value = true; 
		ID batchprocessid = Database.executeBatch(turnOff);	
		
		Test.StopTest();
		
		user u2 = [SELECT Id, UserPreferencesHideCSNDesktopTask FROM User WHERE lastname = 'Testing22' limit 1];
		system.assert( u2 != null );
		system.assert( u2.UserPreferencesHideCSNDesktopTask );
	} 
}