/*
REVISION HISTORY
================
Version    Author          Date               Release#         CR#          Description
-------    ------          ----               --------         ---          -----------
1.0        Emily           21-Mar-2018        FY19-DCE-0502    15540        Field Trip clean up for Opportunity
*/

@isTest(seeAllData=true)
public class ServicesAccountTriggerTest{


static Account testAccount;
static List <Services_Account__c> saList ;
static List <User> userList ;
static Opportunity testOpportunity;
static Services_Project__c sp;

static void createAccount(){
  
    testAccount = new Account(Name='Test Account 10');
    insert testAccount;
      
}

static void createUsers(){
   Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
   userList= new List <User> ();
    for(Integer i=0;i<=3;i++){
    User userRec= new User(FirstName='SOM', 
                                  LastName='Last'+i, 
                                  Title='CEO', 
                                  UserName='SOM'+i+'@test.com',
                                  Email='SOM@dell.com', Alias='cmapgba', 
                                  CommunityNickName='cmapgbta'+i, ProfileId = AdminProfile.Id,
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  EmailEncodingKey='UTF-8', 
                                  TimeZoneSidKey='Asia/Kuala_Lumpur',
                                  Badge_Number__c='som'+i);
         userList.add(userRec);
         
        }
        insert userList;
      
}

static void createOpportunity(){

        Date dCloseDate = System.Today()+10;
        
        testOpportunity = new Opportunity(Name='Test Opportunity 1', 
          Skip_Calculate_LOT_OCEAN__c=true, AccountId=testAccount.Id, Type='Deal/Bid Direct', 
          RecordTypeId='012300000004zf2', CloseDate=dCloseDate, StageName='Discover - 10%', DGR_Level__c = 'Level 0',Dell_Defined_Industry__c='Banking Financial Services & Insurance (BFSI)',
          //1.0 Delivery_Region_s__c='EMEA;AMER',
          Dell_Defined_LOB__c='Infrastructure & Cloud Computing');
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert testOpportunity;
        TriggerExecutionController.setSkipOpportunityTriggers(false);   

}

static void createSP(){
sp = new Services_Project__c(Opportunity__c= testOpportunity.Id);
TriggerExecutionController.setSkipAllTriggers(true);
insert sp;
TriggerExecutionController.setSkipAllTriggers(false);
}

static void createSA(Id userId){

Services_Account__c sa = new Services_Account__c(Account__c = testAccount.Id,MSG_Account__c=false,Primary_CE__c = userId);
insert sa;

}

 public static testMethod void TriggerTestMethod() {
 
 createUsers();
 createAccount();
 createOpportunity();
 createSP();
 //create first SA
 Test.StartTest();
 createSA(userList[0].Id);
 //System.AssertEquals(testAccount.Primary_CE_Email__c,'SOM@dell.com');
 createSA(userList[1].Id);
 //System.AssertEquals(testAccount.Primary_CE_Email__c,null);
 Services_Account__c saToDelete = [Select Id,Primary_CE__c from Services_Account__c where Primary_CE__c =:userList[0].Id];
 Delete saToDelete;
 //System.AssertEquals(testAccount.Primary_CE_Email__c,'SOM@dell.com');
 Test.StopTest();
 }





}