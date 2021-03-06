@istest
public class PMCIntegrationtest {
      //Define variables
    static Account testAccount;
    static Contact testContact;
    static Country__c testCountry;
    static Partner_Request__c request;
    static Lead suggestionLead;
    static User userRecord;
    
        public static testMethod void testPMCIntegration(){  
        
        TriggerExecutionController.setSkipAllTriggers(true);
         
          
         testAccount = new Account(
            name='Test Partner 1',
            Account_Country_Code__c = 'US',
            Account_Country__c = 'United States',            
            Account_ID__c = ''+System.currentTimeMillis()
        );
            try{   
              insert testAccount;  
            } 
            catch(exception e)
            {
               System.debug('failed insert------------account>>'+e.getMessage());
                
            }
       
            
        testContact = new Contact(
            lastname='Test Contact 1',
            AccountId = testAccount.Id,
            Decision_Making_Role__c = 'Influencer',
            Job_Function__c = 'OTHER',
            Job_Function_Role__c = 'Others',
            Email = 'test@saz.com', 
            Email_Opt_In__c = 'true',
            Partner_My_Account_GUID__c = ''+System.currentTimeMillis());
       try{   
              insert testContact;  
            } 
            catch(exception e)
            {
               System.debug('failed insert------------contact>>'+e.getMessage());
                
            }
 
        test.startTest();
        
        system.debug('test contact id---->'+testContact.Id);
        Contact contactList = [select id,Name,salutation,firstname,lastname,Account.Name,Account.Billing_Address_CN__c,Account.Account_Country_Code__c,email,phone,mobilephone,Fax,LastModifiedDate,LastModifiedBy.name,CreatedDate,Email_Opt_In__c,LastModifiedBy.LANGUAGELOCALEKEY,account.BillingCity,account.BillingState,account.BillingPostalCode from contact where id=:testContact.id AND Partner_My_Account_GUID__c!=null ];        
        system.debug('ContactList value---------->>'+contactList);  
        
        system.assert(contactList != null);
        
        Test.setMock(HttpCalloutMock.class, new PMC_MockHttpResponseGenerator());  
        PMCIntegration.pmcPostCallout(testContact.Id);
  
        test.stopTest();
            
        }            
}