/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage..
 */
 
 /***********************************************************
* Name          : SMBOpportunityTriggerTest
* ---------------------------------------------------------
* Revision  Name     Date        Description
* 1.0       Shue     09 Mar 2015  Fix test class: Change runAs user profile referring to CR6468_Unmatched_Opportunity_P_Value (VR) criteria

************************************************************/
 
 
 
@isTest
private class SMBOpportunityTriggerTest {
	
	static User userRecord1;
    static Account testEUAccount;
    static testMethod void Test_createSMBopportunity() {
    TestDataCreation();
    
    // Create Opportunity using the user created
    
    System.runAs(userRecord1){
    	List<RecordType> oppRecordType = [Select  r.Id  From RecordType r where r.SobjectType = 'Opportunity' and r.Id = '012A0000000Vhy7IAC'];
    	Opportunity testOppty1 = new Opportunity(Name='TEST Oppty 1',Region__c='MY', recordtypeid= oppRecordType[0].Id ,Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Propose - 60%', Probability = 60, CloseDate = System.today() + 30, Primary_Product_Delivery_Address_Region__c = 'EMEA');
    	insert testOppty1;
    	
    }
    
    
   System.runAs(userRecord1){
    	List<RecordType> oppRecordType = [Select  r.Id  From RecordType r where r.SobjectType = 'Opportunity' and r.Id = '012A0000000Vhy7IAC'];
    	Opportunity testOppty1 = new Opportunity(Name='TEST Oppty 1',Region__c=Null, recordtypeid= oppRecordType[0].Id ,Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Propose - 60%', Probability = 60, CloseDate = System.today() + 30, Primary_Product_Delivery_Address_Region__c = 'EMEA');
    	insert testOppty1;
    	
    }
    
    Map<string,Double> currencyConvMap = new Map<string,Double>();
    currencyConvMap = CurrencyUtils.getCurrencyConversionMap();
    
    Double convertedAmount = CurrencyUtils.getConvertedCurrencyInUSD('CNY', 10000);
   //Change user country to one which has no region ex: CX
   
   userRecord1.Country = 'CX';
   
   update userRecord1;
   
   System.runAs(userRecord1){
    	List<RecordType> oppRecordType = [Select  r.Id  From RecordType r where r.SobjectType = 'Opportunity' and r.Id = '012A0000000Vhy7IAC'];
    	Opportunity testOppty = new Opportunity(Name='TEST Oppty 2', Region__c='MY',recordtypeid= oppRecordType[0].Id ,Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Propose - 60%', Probability = 60, CloseDate = System.today() + 30, Primary_Product_Delivery_Address_Region__c = 'EMEA');
    	insert testOppty;
    	
    }
    
    
    }
    
     static void TestDataCreation(){
		
		  //Create a user with Standard User profile     	
     	  //Profile profile = [select id from profile where Name = 'Standard User' limit 1];
     	  
     	  //1.0 Starts
     	  //Create a user with IT GBL Data Load profile     	
     	  Profile profile = [select id from profile where Name = 'IT GBL Data Load' limit 1];
     	  //1.0 Ends

     	  userRecord1 = new User(Username='testvaliduser2' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test212'+'@dell.com',            
                                    LastName='Test22',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Country='US',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert userRecord1;
        
        //Create Account using the user profile
        System.runAs(userRecord1){
        	testEUAccount = new Account(Name='Test EU Account for SMB Opportunity',Type = 'End User',
                                                Participating_in_LOB_Program__c = true,
                                                OwnerId = userRecord1.Id);
        	insert testEUAccount;
        }
        
     	
     } 
}