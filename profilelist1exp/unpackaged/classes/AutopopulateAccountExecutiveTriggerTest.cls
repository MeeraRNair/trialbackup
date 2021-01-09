@isTest
public class AutopopulateAccountExecutiveTriggerTest{
    
    static Account testAccount;
    static User us;
    static AccountTeamMember acctTeamMem;
    static Customer_Engagement__c custEng;

    static testMethod void AutopopulateAccountExecutiveTest(){
        
          
        Id testpro = [SELECT Id FROM profile WHERE Name = 'System Administrator'].id;

        //Creating Test Users:
        us = new USER();
        us.FirstName= 'Demo';
        us.LastName = 'Test User';
        us.Email = 'abc@dell.com';
        us.Username = 'testvaliduser' +'@dell.com';
        us.CommunityNickname = 'testcomname';
        us.LanguageLocaleKey = 'en_US';
        us.LocaleSidKey = 'en_GB';
        us.timezonesidkey = 'GMT';
        us.emailencodingkey = 'ISO-8859-1';
        us.alias = 'tAls';        
        us.Profileid = testpro;     
        us.phone = '58694258';
        us.Mobilephone = '9858685925';
        us.fax='89652358';
        us.Street ='Test Street';
        us.City = 'Test City';
        us.State = 'Tx';
        us.PostalCode ='1234';
        us.Country ='Test COuntry';
        us.Badge_Number__c='1223456';
        insert us;  
        
        //Create Test Data - Account
        testAccount = new Account();
            testAccount.Name='Test Account';
            testAccount.Owner_Update__c = us.Id;
            insert testAccount;
            
       // Inserting AccountTeamMember
        acctTeamMem = new AccountTeamMember();
            acctTeamMem.AccountId = testAccount.Id;
            acctTeamMem.UserId = us.Id;
            acctTeamMem.TeamMemberRole = 'Account Executive';
            insert acctTeamMem;                  
         
         // Inserting Customer Engagement        
        custEng = new Customer_Engagement__c();                     
            custEng.Primary_Account__c = testAccount.Id;
            custEng.Account_Executive__c = us.Id;
            insert custEng;
        
    }       
}