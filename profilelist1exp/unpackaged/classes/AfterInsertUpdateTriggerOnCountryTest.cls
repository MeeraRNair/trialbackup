/**
 * Description: Test class to verify:
      -When the country vendor name is getting disabled  and 
	  if the number of countries for which account needs to be updated are more than 1 throw error for those countries

	 - Similarly for a single country if the number of accounts are more than 26 throw error 
	   else disable corresonding Accounts also from Incentives

    
Version: 1.0 

Author: Meera R Nair

History:
    1.0 - 10-Dec-2012: Creation, to be released in 14.2
    1.1(Bikram) - 14-Jan-2013: Removed field Is Country Enabled for Incentives 
 */
@isTest
private class AfterInsertUpdateTriggerOnCountryTest {

    static testMethod void insertsingleCountrywithSuccessAccountTest() {
        // Create Test Data
        
        //insert country
        Country__c testCountry  = new Country__c(Code__c = '@@', Region__c = 'APJ',Inc_Vendor_Name__c='Partner Advantage',Inc_Vendor_End_Point__c = 'test');
        insert testCountry ; 
        
        //Create Account
        Account testacc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = '@@',
                      Is_Enabled_for_Incentives__c = true,
                      type='Partner');
                      
        insert testacc; 
            
        
        //update Country Inc_Vendor_Name__c
        testCountry.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        update testCountry;
        
        //Query Account and verify Is_Enabled_for_Incentives__c is false
        Account res1 = [SELECT id,Is_Enabled_for_Incentives__c FROM Account WHERE id = :testacc.Id];
        System.assertEquals(res1.Is_Enabled_for_Incentives__c, false);
        
        //Enable the country again
        testCountry.Inc_Vendor_Name__c = 'Partner Advantage';
        update testCountry;   
        //insert more than 25 accounts, update country and verify operation is not success
        Account accnt;
        List<Account> testaccnts = new List<Account>();
        for(Integer cnt=0;cnt<30;cnt++){
            accnt = new Account(
                      Name = 'Test Account'+cnt,
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = '@@',
                      Is_Enabled_for_Incentives__c = true,
                      type='Partner');
            testaccnts.add(accnt);  
        }
        insert testaccnts;
        try{
            //update country
            testCountry.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
            update testCountry;
        }catch(Exception e){
            //Asserts country update failed
            System.assert(e.getMessage().contains('All Accounts need to be disabled Incentives access, before turning off on Country level. Please raise DLR to disable all Accounts in the particular country.'));
        }
        
        
        //update more than one country at same time
        List<Country__c> cntryList = new List<Country__c>();
        //testCountry.Inc_Vendor_Name__c = 'Partner Advantage';
        //cntryList.add(testCountry);
        Country__c testCountry1  = new Country__c(Code__c = '##', Region__c = 'APJ',Inc_Vendor_Name__c='Partner Advantage',Inc_Vendor_End_Point__c = 'test');
        cntryList.add(testCountry1);
        Country__c testCountry2  = new Country__c(Code__c = '$$', Region__c = 'APJ',Inc_Vendor_Name__c='Partner Advantage',Inc_Vendor_End_Point__c = 'test');
        cntryList.add(testCountry2);
        upsert cntryList;
        accnt.Account_Country_Code__c = '##';
        update accnt;
        cntryList[0].Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        cntryList[1].Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        try{
            update cntryList;
        }catch(Exception e){
            //Asserts country update failed
            System.assert(e.getMessage().contains('All Accounts need to be disabled Incentives access, before turning off on Country level. Please raise DLR to disable all Accounts in the particular country.'));            
        }
    }
}