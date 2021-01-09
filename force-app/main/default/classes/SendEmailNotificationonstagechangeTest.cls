/*
Test class for SendEmailNotificationonstagechange trigger
*/
@isTest
public class SendEmailNotificationonstagechangeTest{
    
    static Account testAccount;
    static User us;
    static Opportunity testOpp;
    static Support_Request__c suppReq;
    static Sales_Motion_User_Role__c salMotionusrol;

    /* Create Test Support Request */
    static testmethod void createTestNotification() {
        
        
        Id testpro = [SELECT Id FROM profile WHERE Name = 'System Administrator'].id;
        Test.StartTest();
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
        //us.Badge_Number__c='Test'+System.currentTimeMillis();
        insert us;
        
        //Create Test Data SalesMotion User Role    
        salMotionusrol = new Sales_Motion_User_Role__c();
        salMotionusrol.Name = 'TestSalesMonstionuser';
        salMotionusrol.Role__c = 'SOC SOM';
        salMotionusrol.Username__c = us.Id;
        insert salMotionusrol;
        
        
        for( Integer i=0; i<200; i++ ) {    
        //inserting the opportunity
            testOpp = new Opportunity();            
            testOpp.Name = 'test opportunity';
            testOpp.StageName = 'Qualify - 30%';
            testOpp.recordtypeid = '012300000004zf2';
            testOpp.Description = 'Automatically closed out because Book Date is past due over 6 months.';
            testOpp.Won_Lost_Comment__c = 'Automatically closed out because Book Date is past due over 6 months.';
           // testOpp.Past_Due_Auto_Closed__c = True;
            testOpp.Competitor_Lost_To__c = 'Unknown';
           // testOpp.Reason_Won_Lost__c = 'Past Due Auto Closed';
            testOpp.CloseDate = date.today()+30;
        }   
        insert testOpp;
       
        Test.StopTest();
        suppReq = new Support_Request__c();        
        //suppReq.SOM__c = salMotionusrol.Id;   
        suppReq.SOM_Email__c = 'SOC_Engagement@Dell.com';
        suppReq.Status__c = 'new';
        suppReq.Opportunity__c=testOpp.Id;
        suppReq.recordtypeid = '012A0000000ViNO';
        insert suppReq;
        
        suppReq.Status__c = 'Accept';
        suppReq.SOM__c = salMotionusrol.Id;  
        update suppReq; 
        
        testOpp.StageName='Commit - 90%';
        update testOpp;
        
    }
      
}