/*
* Revision CR Number   Release No      Date            Modified By     Description
* 1.0                                  20-Dec-2019     venu            Implimented TestDataFactory      
*/
@isTest
private class MassOpportunityUpdateButtonExtensionTest {
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert oWDsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        insert listUserTdf;
        System.runAs(listUserTdf[0]) {
            list<Account> listAccTdf=TestDataFactory.createNAccount(1,'End-User Account');
            listAccTdf[0].OwnerId = listUserTdf[0].Id;
            insert listAccTdf;
            list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Standard Opportunity');
            for(Opportunity opp : listOppTdf){
                opp.AccountId=listAccTdf[0].id;
                opp.Quote_Numbers__c = '12345';
                opp.Probability = 10;
                opp.Override_Probability__c = '10%';
                opp.Amount=355000;
                opp.Description = 'Desc';
                opp.NextStep = 'NextStep';
                opp.Deal_Registration_Status__c = 'New';
                opp.Skip_Calculate_LOT_OCEAN__c = false;
            }
            insert listOppTdf;
        }
        TriggerExecutionController.setSkipAllTriggers(false);
    }	
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
    //public static Opportunity testOpportunity;
    //public static List<Opportunity> opptyList = new List<Opportunity>();
    //public static List<ID> lstIds = new List<ID>(); 
    //static Account testAccount;
    /* static void createTestData(){
Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];

//Create a user with Standard User profile
User recordCreator = new User(Username = 'TestValidUser1' + '@dell.com',
Alias = 'Test', 
Email = 'Test212'+'@dell.com', 
LastName = 'Test22',
Title = 'GCC Program Manager', 
ProfileId = profile.Id, 
LanguageLocaleKey = 'en_US', 
LocaleSidKey = 'en_US', 
EmailEncodingKey = 'UTF-8', 
TimeZoneSidKey = 'America/Los_Angeles',
Country = 'US',
Badge_Number__c = 'Test'+System.currentTimeMillis());
insert recordCreator;

System.runAs(recordCreator) {
//Create Account
testAccount = new Account(Name = 'Test Account for Account Plan Test', Type = 'End User', Participating_in_LOB_Program__c = true, OwnerId = recordCreator.Id);
insert testAccount;

TriggerControlHandler.setOpportunityTriggersInactive();
TriggerExecutionController.setSkipOpportunityTriggers(true);

Opportunity oppty;
for (integer i=0 ; i<100 ; i++) {
Oppty = new Opportunity();
Oppty.Name = 'test'+i;
Oppty.AccountId = testAccount.Id;
Oppty.StageName = 'Plan - 1%';
Oppty.Forecast_Category_Override__c = 'Omitted';
Oppty.CloseDate = System.Today()+20;
Oppty.Quote_Numbers__c = '12345';
Oppty.Probability = 10;
Oppty.Override_Probability__c = '10%';
Oppty.Amount=355000;
Oppty.Description = 'Desc'+i;
Oppty.NextStep = 'NextStep'+i;
Oppty.Skip_Calculate_LOT_OCEAN__c = false;
opptyList.add(Oppty);
}           

insert opptyList;  

TriggerExecutionController.setSkipOpportunityTriggers(false);         
TriggerControlHandler.setOpportunityTriggersActive();


for(integer j=0; j<opptyList.size(); j++)
{
lstIds.add(opptyList[j].Id);           
}
}
}
*/
    private static ApexPages.StandardSetController init(){
        //createTestData();
        list<Opportunity> listOpp=[select id from Opportunity Limit 2];
        list<id> listIds=new list<id>();
        for(Opportunity opp : listOpp){
            listIds.add(opp.id);
        }
        String strquery= 'SELECT id,Name,Account.Name,StageName,CloseDate,Quote_Numbers__c,Probability,Override_Probability__c,Unweighted_Rev_Formula__c,Description,NextStep,PartnerAccount.Name FROM Opportunity Where Id IN:listIds';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(strquery));
        return setCtrl;
    }
    static testMethod void massOpportunityUpdateButtonExtensionCancel(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        MassOpportunityUpdateButtonExtension stdController = new MassOpportunityUpdateButtonExtension(controller);
        stdController.cancel();
        system.assertEquals(controller, controller);
        test.stopTest();
    }
    static testMethod void massOpportunityUpdateButtonExtensionRedirect(){
        test.startTest();
        ApexPages.StandardSetController controller = init();
        // now pass it to the extension
        MassOpportunityUpdateButtonExtension stdController = new MassOpportunityUpdateButtonExtension(controller);
        stdController.redirectToMassUpdatePage();
        system.assertEquals(stdController, stdController);
        test.stopTest();
    }
    /*static testMethod void MassOpportunityUpdateButtonExtensionRedirect02(){
test.startTest();
ApexPages.StandardSetController controller = init();
// now pass it to the extension
MassOpportunityUpdateButtonExtension stdController = new MassOpportunityUpdateButtonExtension(controller);
Profile newProfile = [SELECT Id FROM profile WHERE Name LIKE '%PRM%' LIMIT 1];

//Create a user with Standard User profile
User newUser = new User(Username = 'TestValidUser3' + '@dell.com',
Alias = 'Test', 
Email = 'Test313'+'@dell.com', 
LastName = 'Test22',
Title = 'GCC Program Manager', 
ProfileId = newProfile.Id, 
LanguageLocaleKey = 'en_US', 
LocaleSidKey = 'en_US', 
EmailEncodingKey = 'UTF-8', 
TimeZoneSidKey = 'America/Los_Angeles',
Country = 'US',
Badge_Number__c = 'Test'+System.currentTimeMillis());
insert newUser;
System.runAs(newUser) {
stdController.redirectToMassUpdatePage();
}
test.stopTest();
}*/
}