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
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestDataGeneratorTest {

    //Test Methods to test on calling getObject method without inserting the records in TestDatGenerator. This is done
    //through calling TestDataGenerator.getObject(object, count, map, doInsert) method
    static testMethod void getObjectMethodsNoInsert()
    {
        integer startCount = 0;
        integer endCount = 0;
            
        string testDataLastName = 'TestMethodUser';                     
        
        Test.startTest();
        startCount = [SELECT COUNT() FROM User WHERE LastName = :testDataLastName];
        
        System.debug('#DEBUG# Start Count is ' + startCount);
        
        Map<String, String> valueMap = new Map<String, String>();
        valueMap.put('str_LastName',testDataLastName);
        
        List<User> testUsers = (List<User>)TestDataGenerator.getObject(new User(), 10, valueMap, false);
        
        System.debug('#DEBUG# created users in this are ' + testUsers);
        
        endCount = [SELECT COUNT() FROM User WHERE LastName = :testDataLastName];  
        
        System.debug('#DEBUG# End Count is ' + endCount);
        
        //No record should be inserted, count should be the same
        System.assert(endCount == startCount); 
        
        List<User> testUsers2 = (List<User>)TestDataGenerator.getObject(new User(), 10, valueMap);      
        System.debug('#DEBUG# created users in this are ' + testUsers2);
        endCount = [SELECT COUNT() FROM User WHERE LastName = :testDataLastName];
        
        System.debug('#DEBUG# End Count is ' + endCount);
        
        //Records are inserted, endCount should be larger than startCount
        System.assert(endCount > startCount);               
                    
        Test.stopTest();
        
    }   
    
    //Create AccountTeamMember when UserList is set
    static testMethod void createAccountTeamMemberWithUserList()
    {
        String testDataUserLastName = 'TestMethodUserLastName';
        
        Test.startTest();       
        
        Map<String, String> valueMap = new Map<String, String>();
        
        valueMap.put('str_LastName','TestMethodUserLastName');        
        
        List<User> testUsers = (List<User>)TestDataGenerator.getObject(new User(), 100, valueMap);
        TestDataGenerator.setUserList(testUsers);
        
        Set <String> userSet = new Set<String>();
        
        for(User u:testUsers)
        {
            userSet.add(u.Id);
        }
        
        System.debug('#DEBUG# Users created are ' + testUsers);
        
        List<AccountTeamMember> testAccTeamMember = (List<AccountTeamMember>)TestDataGenerator.getObject(new AccountTeamMember(), 100);
        
        System.debug('#DEBUG# AccountTeamMembers created are ' + testAccTeamMember);
        
        //The UserId of the newly created AccounTeamMember should be one of the Id in the UserList
        System.assert(userSet.contains(testAccTeamMember[0].UserId));
        
        Test.stopTest();
        
    } 
    
    //Create AccountTeamMember when UserList is not set
    static testMethod void createAccountTeamMemberWithoutUserList() {
        
        TestDataGenerator.setUserList(new List<User>());
        
        Test.startTest();
        
        List<AccountTeamMember> testAccTeamMember = (List<AccountTeamMember>)TestDataGenerator.getObject(new AccountTeamMember(), 100);
        
        System.debug('#DEBUG# AccountTeamMembers created are ' + testAccTeamMember);
        
        System.assert(String.valueOf(testAccTeamMember[0].UserId) != '');
        
        Test.stopTest();
    }

    //Test Method for setValueTosObject(sObject sObj, Map<String, String> mString)
    static testMethod void setValueTosObjectTest() {
        
        string testAccountName = 'Test Account';
        string testAnnualRevenue = '888.88';
        string testFiscalYear = String.valueOf(Date.today());
    
        Map<String, String> valueMap = new Map<String, String>();

        valueMap.put('str_name', testAccountName);
        valueMap.put('dec_AnnualRevenue', testAnnualRevenue);
        valueMap.put('dat_Fiscal_Year_End__c', testFiscalYear);        
               
        Account testAccount = (Account)TestDataGenerator.getObject(new Account(), 1, valueMap)[0]; 

        System.debug('#DEBUG# Account created: ' + testAccount);
        System.assertEquals(testAccount.name,testAccountName);
        System.assertEquals(testAccount.AnnualRevenue,Decimal.valueof(testAnnualRevenue));
        System.assertEquals(testAccount.Fiscal_Year_End__c,Date.valueOf(testFiscalYear));
        
        valueMap.clear();
        
        string testOpptyName = 'Test Opportunity';
        string testDateTime = String.valueOf(DateTime.now());
        string testDealScore = '18';
        
        valueMap.put('str_AccountId', testAccount.Id);
        valueMap.put('str_Name', testOpptyName);
        valueMap.put('dtm_Tier_1_Approved_Rejected__c',testDateTime);
        valueMap.put('dbl_Deal_Score__c',testDealScore);
        
        Opportunity testOppty = (Opportunity)TestDataGenerator.getObject(new Opportunity(), 1, valueMap)[0]; 
        
        System.debug('#DEBUG# Opportunity created: ' + testOppty);
    
        System.assertEquals(testOppty.name,testOpptyName);        
        System.assertEquals(testOppty.Tier_1_Approved_Rejected__c,DateTime.valueOfGmt(testDateTime));
        System.assertEquals(testOppty.Deal_Score__c,Decimal.valueOf(testDealScore));        
        
    }
    
    //Test Method for defaultForMandatoryField(sObject sObj, integer i, integer count)
    static testMethod void defaultForMandatoryFieldTest() {
        
        Map<String, String> valueMap = new Map<String, String>();
        
        Test.startTest();

        //Start testing default values for user object  
        User testUser = (User)TestDataGenerator.getObject(new User(), 1)[0];  
        
        System.debug('#DEBUG# User created: ' + testUser);
        
        System.assert(testUser.LastName != '');
        System.assert(testUser.UserName != '');
        System.assert(testUser.Email != '');        
        System.assert(testUser.Alias != '');
        System.assert(testUser.Badge_Number__c != '');                                                    
        //End testing default values for user object  
        
        //Start testing default values for Account object                                               
        Account testAccount = (Account)TestDataGenerator.getObject(new Account(), 1)[0];    
        
        System.debug('#DEBUG# Account created: ' + testAccount);
        System.assert(testAccount.Name != '');
        //End testing default values for Account object
        
        //Start testing default values for Opportunity object
        valueMap.clear();
        
        valueMap.put('str_AccountId', testAccount.Id);
        
        Opportunity testOppty = (Opportunity)TestDataGenerator.getObject(new Opportunity(), 1, valueMap)[0];
        System.debug('#DEBUG# Opportunity created: ' + testOppty);
        System.assert(testOppty.Name != '');
        //End testing default values for Opportunity object
        
        //Start testing default values for Sales Channel Group object
        Sales_Channel_Group__c testSCG = (Sales_Channel_Group__c) TestDataGenerator.getObject(new Sales_Channel_Group__c(), 1)[0];
        System.debug('#DEBUG# Sales Channel Group created: ' + testSCG);
        System.assert(testSCG.Name != '');
        System.assert(testSCG.Group_ID__c != '');
        //End testing default values for Sales Channel Group object
        
        Test.stoptest();
    }
    
    //Create AccountTeamMember when account list is not set
    static testMethod void createAccountTeamMemberWithoutAccList()
    {
        TestDataGenerator.setAccList(new List<Account>());
        
        Test.startTest();
        
        List<AccountTeamMember> testAccTeamMember = (List<AccountTeamMember>)TestDataGenerator.getObject(new AccountTeamMember(), 100);
        
        System.debug('#DEBUG# AccountTeamMembers created are ' + testAccTeamMember);
        System.assert(String.valueOf(testAccTeamMember[0].AccountId) != '');
        
        Test.stopTest();            
        
    }
    
    //create AccountTeamMember when account list is set
    static testMethod void createAccountTeamMemberWithAccList()
    {        
        Test.startTest();                

        List<Account> testAccounts = (List<Account>)TestDataGenerator.getObject(new Account(), 100);
        TestDataGenerator.setAccList(testAccounts);
        
        Set <String> accSet = new Set<String>();
        
        for(Account acc:testAccounts)
        {
            accSet.add(acc.Id);
        }
        
        System.debug('#DEBUG# Accounts created are ' + testAccounts);
        
        List<AccountTeamMember> testAccTeamMember = (List<AccountTeamMember>)TestDataGenerator.getObject(new AccountTeamMember(), 100);
        
        System.debug('#DEBUG# AccountTeamMembers created are ' + testAccTeamMember);
        
        //The AccountId should be one of the Id in account list
        System.assert(accSet.contains(testAccTeamMember[0].AccountId));
        
        Test.stopTest();
        
    } 
    
    //Create OpportunityTeamMember when opportunity list is not set
    static testMethod void createOpportunityTeamMemberWithoutOppList()
    {
        TestDataGenerator.setOppList(new List<Opportunity>());
        
        Test.startTest();
        
        List<OpportunityTeamMember> testOppTeamMember = (List<OpportunityTeamMember>)TestDataGenerator.getObject(new OpportunityTeamMember(), 100);
        
        System.debug('#DEBUG# OpportunityTeamMembers created are ' + testOppTeamMember);
        System.assert(String.valueOf(testOppTeamMember[0].OpportunityId) != '');
        
        Test.stopTest();            
        
    }
    
    //create OpportunityTeamMember when opportunity list is set
    static testMethod void createOpportunityTeamMemberWithOppList()
    {   
       // TestDataGenerator.setOppList(new List<Opportunity>());
             
        Test.startTest();                

       List<Opportunity> testOppty = (List<Opportunity>)TestDataGenerator.getObject(new Opportunity(), 2);
        TestDataGenerator.setOppList(testOppty);
        
        Set <String> oppSet = new Set<String>();
        
        for(Opportunity opp:testOppty)
        {
            oppSet.add(opp.Id);
        }
        System.debug('#DEBUG# Opportunities created are ' + testOppty);
       
        List<OpportunityTeamMember> testOppTeamMember = (List<OpportunityTeamMember>)TestDataGenerator.getObject(new OpportunityTeamMember(), 2);
        System.debug('#DEBUG# OpportunityTeamMembers created are ' + testOppTeamMember);
        
        //The OpportunityId should be one of the Id in opportunity list
        System.assert(oppSet.contains(testOppTeamMember[0].OpportunityId));
       // System.assert(String.valueOf(testOppTeamMember[0].OpportunityId) != '');
        Test.stopTest();
    } 
    
    static testMethod void createObjectsTest()
    {
        
        Test.StartTest();
        //Following codes are commented because the test are covered in other test methods
        /*
        List<Account> testAccs = (List<Account>)TestDataGenerator.getObject(new Account(), 1);
        System.debug('#DEBUG# Accounts created are ' + testAccs);
        System.assert(testAccs.size() == 1);
        
        List<User> testUsers = (List<User>)TestDataGenerator.getObject(new User(), 1);
        System.debug('#DEBUG# Users created are ' + testUsers);
        System.assert(testUsers.size() == 1);
        
        List<Opportunity> testOpportunities = (List<Opportunity>)TestDataGenerator.getObject(new Opportunity(), 1);
        System.debug('#DEBUG# Opportunities created are ' + testOpportunities);
        System.assert(testOpportunities.size() == 1);
        */
        
        List<AccountShare> testAccShare = (List<AccountShare>)TestDataGenerator.getObject(new AccountShare(), 10);
        System.debug('#DEBUG# AccountShares created are ' + testAccShare);
        System.assert(testAccShare.size() == 10);
        
        List<AccountTeamMember> testATM = (List<AccountTeamMember>)TestDataGenerator.getObject(new AccountTeamMember(), 10);
        System.debug('#DEBUG# AccountTeamMembers created are ' + testATM);
        System.assert(testATM.size() == 10);
        
        List<OpportunityTeamMember> testOTM = (List<OpportunityTeamMember>)TestDataGenerator.getObject(new OpportunityTeamMember(), 10);
        System.debug('#DEBUG# OpportunityTeamMembers created are ' + testOTM);
        System.assert(testOTM.size() == 10);
        
        List<OpportunityShare> testOpportunityShare = (List<OpportunityShare>)TestDataGenerator.getObject(new OpportunityShare(), 10);
        System.debug('#DEBUG# OpportunityShares created are ' + testOpportunityShare);
        System.assert(testOpportunityShare.size() == 10);
        
        List<Sales_Channel_Group__c> testSCG = (List<Sales_Channel_Group__c>)TestDataGenerator.getObject(new Sales_Channel_Group__c(), 10);
        System.debug('#DEBUG# OpportunityShares created are ' + testSCG);
        System.assert(testSCG.size() == 10);
        Test.StopTest();
    }
}