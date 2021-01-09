/*
  * Author   : 
  * Purpose  : Test Class for CPDBXmlGenerator
  *
  * Revision CR Number   Release No     Date            Modified By     Description
  * -------- ---------   ----------     -----------     ------------    -----------
  * 1.0      			FY19-DCS-0102    21-11-2018     Sazleen         

*/    
    
@isTest
public class CPDBXmlGeneratorTest {    
    
      //Define variables
    static Account testAccount;
    static Contact testContact;
    static Country__c testCountry;
    static Partner_Request__c request;
    static Lead suggestionLead;
    static User userRecord;
    
        public static testMethod void testPartnerReqfrmContact(){  
		
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
        Contact contactList = [select id, Account.Account_Country_Code__c,Partner_My_Account_GUID__c,CPDB_Segment__c, CPDB_Updated_By__c from Contact 
                                         where id=:testContact.id AND Partner_My_Account_GUID__c!=null limit 1]; 
        system.assert(contactList != null);
        
        system.debug('contactList value---------->>'+contactList);  
        Test.setMock(HttpCalloutMock.class, new CPDB_MockHttpResponseGenerator());  
        CPDBXmlGenerator.getContactDataforCPDB(testContact.Id);
            
        test.stopTest();
      }
     
 

}