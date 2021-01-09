/**
 * Test class for servicesAccountBeforeInsertUpdate
  Micky   06-03-2014  
 */
@isTest
private class servicesAccountBeforeInsertUpdateTest {
    public static Account testAcc;
    public static Country__c testCountry;
    public static Contact testContact;
    public static Services_Account__c testServicesAccnt;
    static testMethod void insertServicesAccountTest() {
        // Create Test Data
        createTestData();
        Test.startTest();
        //enable contact for incentives
        testContact.Is_Enabled_for_Incentives__c = true;
        update testContact;
        testServicesAccnt.Services_Account_Health__c = 'Green';
        update testServicesAccnt;
        //retrieve result and asserts
        Services_Account__c seracc = [SELECT Relationship__c,Services_Account_Health__c
                       FROM Services_Account__c WHERE id=:testServicesAccnt.id];
        System.assertEquals(seracc.Relationship__c, 'Channel');
        System.assertEquals(seracc.Services_Account_Health__c, 'Green');
        Test.stopTest();
    }
    public static void createTestData(){
        
        //Create Country
        //Insert Country
        testCountry  = new Country__c(Code__c = 'XY', Region__c = 'NA',Inc_Vendor_Name__c='Partner Direct Rewards Center',Inc_Vendor_End_Point__c='Test End point');
        insert testCountry ; 
        //Create Account
        testAcc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = 'XY',
                      Is_Enabled_for_Incentives__c = true,                     
                      type='Partner'
                      );
                      
        insert testAcc; 
        //Create Contact
        string email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com';
        testContact = new Contact(AccountId = testAcc.id, Email = email, Lastname = 'Contact');
        insert testContact;
        //Create Services Account
        testServicesAccnt = new Services_Account__c(Account__c = testAcc.id, Relationship__c = 'Channel');
        insert testServicesAccnt;       
    }
}