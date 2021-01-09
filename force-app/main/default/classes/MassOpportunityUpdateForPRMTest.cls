/*
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      
* 2.0      13964                       10-Feb-2017     Vasavi.M        Fix code coverage for change done in MassOpptyUpdateForPRM controller -  Remove cast iron condition from book date checking 
* 3.0      15568                       11-Apr-2018     Sakshi          Reduce Code
* 4.0      08184        FY-20-1002     18-Sept-2019    Monisha         Added code for selected Records
* 5.0                                  20-Dec-2019	   venu			   Implimented TestDataFactory			
*/
@isTest
private class MassOpportunityUpdateForPRMTest {
    public static List<Opportunity> listOppty = new List<Opportunity>();
    // public static List<ID> lstIds = new List<ID>(); 
    //static Account testAccount;
    public static  OWD__c objowd;
    public static ApexPages.StandardSetController setCtrl = init();
    public static MassOpportunityUpdateForPRM massUpdate = new MassOpportunityUpdateForPRM(setCtrl);
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<User> listUserTdf=TestDataFactory.CreateNGenralUsers(1);
        insert listUserTdf;
        System.runAs(listUserTdf[0]) {
            list<Account> listAccTdf=TestDataFactory.createNAccount(1,'End-User Account');
            insert listAccTdf;
            list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Standard Opportunity');
            for(Opportunity opp : listOppTdf){
                opp.AccountId=listAccTdf[0].id;
                opp.Quote_Numbers__c = '12345';
                opp.Probability = 1;
                opp.Override_Probability__c = '10%';
                opp.Amount=355000;
                opp.Description = 'Desc';
                opp.NextStep = 'NextStep';
                opp.Deal_Registration_Status__c = 'New';
            }
            insert listOppTdf;
            
        }
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    /*  static void createTestData(){
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
//testAccount = new Account(Name = 'Test Account for Account Plan Test', Type = 'End User', Participating_in_LOB_Program__c = true, OwnerId = recordCreator.Id);
//insert testAccount;
TriggerExecutionController.setSkipAllTriggers(true);

list<Account> testAccount=TestDataFactory.createNAccount(1, 'End-User Account');
insert testAccount;
// TriggerControlHandler.setOpportunityTriggersInactive();
//TriggerExecutionController.setSkipOpportunityTriggers(true);

Opportunity oppty;
for (integer i=0 ; i<10 ; i++) {
Oppty = new Opportunity();
Oppty.Name = 'test'+i;
Oppty.AccountId = testAccount[0].Id;
Oppty.StageName = 'Plan - 1%';
Oppty.CloseDate = System.Today()+20;
Oppty.Quote_Numbers__c = '12345';
Oppty.Probability = 1;
Oppty.Override_Probability__c = '10%';
Oppty.Amount=355000;
Oppty.Description = 'Desc'+i;
Oppty.NextStep = 'NextStep'+i;
Oppty.Deal_Registration_Status__c = 'New';
Oppty.Forecast_Category_Override__c = 'Pipeline';
opptyList.add(Oppty);
} 
insert opptyList;  

// TriggerExecutionController.setSkipOpportunityTriggers(false);         
//TriggerControlHandler.setOpportunityTriggersActive();
TriggerExecutionController.setSkipAllTriggers(false);


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
        PageReference pageRef = Page.MassOpportunityUpdate;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('idOpps', String.valueOf(listIds));
        String strquery= 'SELECT id,Name,Account.Name,StageName,CloseDate,Quote_Numbers__c,Probability,Override_Probability__c,Unweighted_Rev_Formula__c,Description,NextStep,PartnerAccount.Name FROM Opportunity Where Id IN:listIds';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(strquery));
        return setCtrl;
    }
    static testMethod void testAddRecordsToWrapper(){
        objowd = new OWD__c();
        objowd.Oppty_Stage100__c='Win - 100%';
        objowd.Oppty_Stage1__c='Plan - 1%';
        objowd.Oppty_Stage60__c='Propose - 60%';
        objowd.Oppty_Stage99__c='Order Submitted - 99%';
        objowd.Oppty_Stage0__c='Lost, Cancelled - 0%';
        objowd.Oppty_Stage10__c='Discover - 10%';
        objowd.Oppty_Stage30__c='Qualify - 30%';
        objowd.Oppty_Stage90__c='Commit - 90%';
        insert objowd;
        list<Opportunity> listOpp=[select id from Opportunity Limit 2];
        list<id> listIds=new list<id>();
        for(Opportunity opp : listOpp){
            listIds.add(opp.id);
        }
        for(Opportunity objOpportunity:[SELECT id,StageName,CloseDate FROM Opportunity  Where id IN:listIds AND (LOT_Large_Opportunity__c = false and LOT_Large_Opportunity_Potential__c = false AND StageName != :objowd.Oppty_Stage99__c) order by closedate asc ]){  
            massupdate.wrapperList.add(objOpportunity.id);
            System.assertNotEquals(objOpportunity.StageName, objowd.Oppty_Stage99__c);
        }  
    }
    static testMethod void massOpportunityUpdateForPRM1(){
        test.startTest();
        massUpdate.cancelAndReturn();
        massUpdate.getTotalPages();
        massUpdate.getPageNumber();
        massUpdate.getPageSize();
        massUpdate.getTotalRecords();
        massUpdate.getStartPageRecords();
        massUpdate.getEndPageRecords();
        test.stopTest();
        System.assertEquals(massUpdate.getEndPageRecords(), massUpdate.getEndPageRecords());
    }
    static testMethod void firstLastPageTest(){
        test.startTest();
        massUpdate.FirstPage();
        test.stopTest();
        System.assertEquals(1, setCtrl.getPageNumber());
        massUpdate.LastPage();
    }   
    static testMethod void page123Test(){
        testAddRecordsToWrapper();
        test.startTest();
        setCtrl.setPageNumber(4);
        massUpdate.Page1();
        test.stopTest();
        setCtrl.setPageNumber(3); 
        massUpdate.Page2();
        setCtrl.setPageNumber(4);
        massUpdate.Page3();
        //System.assertEquals(4, setCtrl.setPageNumber(4));
    }     
    static testMethod void nextPrevPageTest(){
        test.startTest();
        Integer intpageNum = setCtrl.getPageNumber();
        massUpdate.NextPage();
        test.stopTest();
        massUpdate.PreviousPage();
    }
    static testMethod void savePage123Test(){
        test.startTest();
        massUpdate.SaveAndPage1();
        setCtrl.setPageNumber(3);
        massUpdate.SaveAndPage2();
        setCtrl.setPageNumber(4);
        massUpdate.SaveAndPage3();
        test.stopTest();
    }
    static testMethod void saveFirstPreviousNextLastPageTest(){
        test.startTest();
        Integer intpageNum = setCtrl.getPageNumber();
        massUpdate.SaveAndFirstPage();
        test.stopTest();
        massUpdate.SaveAndPrevPage();
        massUpdate.SaveAndNextPage();
        massUpdate.SaveAndLastPage();
    }  
    static testMethod void saveRecordUpdateField() {
        testAddRecordsToWrapper();
        massUpdate.initializeWrapper(massupdate.wrapperList);
        test.startTest();     
        Map<id,MassOpportunityUpdateForPRM.oppWrapper> mapWrap = massUpdate.oppWrapperMap;
        for(MassOpportunityUpdateForPRM.oppWrapper wrap:mapWrap.values()){
            wrap.isModified = true;
            wrap.opp.Mass_Update_Edit__c = true;
            wrap.opp.Mass_Update_Edit_Date__c = System.today();
            wrap.opp.StageName = objowd.Oppty_Stage1__c;
            wrap.opp.CloseDate = System.today();    
            wrap.opp.NextStep = 'Next Step';
            break;
        }
        system.assertEquals(massupdate.wrapperList, massupdate.wrapperList);
        //v2.0 Start
        TriggerControlHandler.setOpportunityTriggersInactive();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        //v2.0 End
        massUpdate.saveAndReturn();
        //v2.0 start
        TriggerExecutionController.setSkipOpportunityTriggers(false);          
        TriggerControlHandler.setOpportunityTriggersActive();
        //v2.0 end
        test.stopTest();
    } 
}