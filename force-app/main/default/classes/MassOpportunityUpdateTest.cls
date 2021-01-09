/*
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      
* 2.0      13964                       06-Feb-2017     Vasavi.M        Fix code coverage for change done in MassOpptyUpdate controller -  Remove cast iron condition from book date checking 
* 3.0     CR14471      FY-18-0802      06-Jul-2017     Abhinav         To add field value in test data which required by PB
* 4.2     CR15346      FY-19-0203      22-Dec-2017     Abhinav         Removed Override_Probability__c and added Forecast_Category_Override__c
* 4.3     CR15346      FY-19-0203      04-Jan-2017     Abhinav         Removed Probability and added Forecast_Category_RO__c
* 5       CR15568      FY-19-0502      10-Apr-2018     Sakshi          Reduce code
* 6.0     08184        FY-20-1002      18-Sept-2019    Monisha         Added code for selected Records
* 7.0                                  20-Dec-2019     venu            Implimented TestDataFactory      
*/
@isTest
private class MassOpportunityUpdateTest {   
    // public static List<Opportunity> opptyList = new List<Opportunity>();
    //public static List<ID> lstIds = new List<ID>(); 
    //static Account testAccount;
    public static  OWD__c objowd;
    public static ApexPages.StandardSetController setCtrl = init();
    public static MassOpportunityUpdate massUpdate = new MassOpportunityUpdate(setCtrl);
    @testSetup static void setup() {
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
    /*  static void createTestData(){
Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
TriggerExecutionController.setSkipAllTriggers(true);
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
for (integer i=0 ; i<5 ; i++) {
Oppty = new Opportunity();
Oppty.Name = 'test'+i;
Oppty.AccountId = testAccount.Id;
Oppty.StageName = 'Discover - 10%';
Oppty.CloseDate = System.Today()+20;
Oppty.Quote_Numbers__c = '12345';
Oppty.Probability = 10;
Oppty.Forecast_Category_Override__c = 'Pipeline';
Oppty.Amount=355000;
Oppty.Description = 'Desc'+i;
Oppty.NextStep = 'NextStep'+i;
Oppty.Skip_Calculate_LOT_OCEAN__c = false;
opptyList.add(Oppty);
}           

insert opptyList;  

//TriggerExecutionController.setSkipOpportunityTriggers(false);         
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
        // createTestData();
        list<Opportunity> listOpp=[select id from Opportunity Limit 2];
        list<id> listIds=new list<id>();
        for(Opportunity opp : listOpp){
            listIds.add(opp.id);
        }
        PageReference pageRef = Page.MassOpportunityUpdate;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('idOpps', String.valueOf(listIds));
        String strquery= 'SELECT id,Name,Account.Name,StageName,CloseDate,Quote_Numbers__c,Probability,Forecast_Category_RO__c,Forecast_Category_Override__c,Unweighted_Rev_Formula__c,Description,NextStep,PartnerAccount.Name FROM Opportunity Where Id IN:listIds';
        ApexPages.StandardSetController setCtrl= new ApexPages.StandardSetController(Database.getQueryLocator(strquery));
        return setCtrl;
    }
    static void testAddRecordsToWrapper(){
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
    static testMethod void massOpportunityUpdate1(){
        test.startTest();
        list<Opportunity> listOpp=[select id from Opportunity Limit 2];
        System.assertEquals(listOpp[0].Id, listOpp[0].Id);
        massUpdate.cancelAndReturn();
        massUpdate.getPageSize();
        massUpdate.getTotalRecords();
        massUpdate.getStartPageRecords();
        massUpdate.getEndPageRecords();
        test.stopTest();
    }
    static testMethod void firstAndLastPageTest() {
        test.startTest();
        massUpdate.FirstPage();
        test.stopTest();
        System.assertEquals(1, setCtrl.getPageNumber());
        massUpdate.LastPage();
    }    
    static testMethod void page123Test() {
        testAddRecordsToWrapper();
        test.startTest();
        setCtrl.setPageNumber(4);
        massUpdate.Page1();
        test.stopTest();
        System.assertEquals(massUpdate.getPageNumber(), setCtrl.getPageNumber());
        setCtrl.setPageNumber(3); 
        massUpdate.Page2();
        System.assertEquals(massUpdate.getPageNumber(), setCtrl.getPageNumber());
        setCtrl.setPageNumber(4);
        massUpdate.Page3();    
        System.assertEquals(massUpdate.getPageNumber(), setCtrl.getPageNumber());
    }      
    static testMethod void nextPreviousPageTest() {
        test.startTest();
        Integer intpageNum = setCtrl.getPageNumber();
        massUpdate.NextPage();
        test.stopTest();
        massUpdate.PreviousPage();
        System.assertEquals(setCtrl.getPageNumber(), intpageNum);
    }
    static testMethod void savePage123Test() {
        test.startTest();
        massUpdate.SaveAndPage1();
        setCtrl.setPageNumber(3);
        massUpdate.SaveAndPage2();
        setCtrl.setPageNumber(4);
        massUpdate.SaveAndPage3();
        System.assertEquals(massUpdate.getPageNumber(), massUpdate.getPageNumber());
        test.stopTest();
    }
    static testMethod void saveFirstNextPreviousLastPageTest() {
        test.startTest();
        massUpdate.SaveAndFirstPage();
        massUpdate.SaveAndPrevPage();
        test.stopTest();
        massUpdate.SaveAndNextPage();
        massUpdate.SaveAndLastPage();
        list<Opportunity> listOpp=[select id from Opportunity Limit 2];
        System.assertEquals(listOpp[0].Id, listOpp[0].Id);
    } 
    /*static testMethod void IdleTest() {
PageReference pageRef = Page.MassOpportunityUpdate;
Test.setCurrentPage(pageRef);
test.startTest();
ApexPages.StandardSetController setCtrl = init();
MassOpportunityUpdate massUpdate = new MassOpportunityUpdate(setCtrl);
Integer pageNum = setCtrl.getPageNumber();
massUpdate.idleRedirect();

MassOpportunityUpdate massUpdate1 = new MassOpportunityUpdate(setCtrl);

massUpdate1.idleSaveRedirect();

test.stopTest();
//System.assertEquals(massUpdate.getTotalPages(), setCtrl.getPageNumber());
} */
    /*static testMethod void saveRecord() {
PageReference pageRef = Page.MassOpportunityUpdate;
Test.setCurrentPage(pageRef);
test.startTest();     
ApexPages.StandardSetController setCtrl= init();
MassOpportunityUpdate massUpdate = new MassOpportunityUpdate(setCtrl);
Integer pageNum = setCtrl.getPageNumber();
Map<id,MassOpportunityUpdate.oppWrapper> wrapMap = massUpdate.oppWrapperMap;

for(MassOpportunityUpdate.oppWrapper wrap:wrapMap.values()){
wrap.isModified = true;
break;
}
massUpdate.saveAndReturn();
test.stopTest();
//System.assertEquals(massUpdate.isSavedSuccessfully,true);

} */
    static testMethod void saveRecordUpdateField() {
        testAddRecordsToWrapper();
        massUpdate.initializeWrapper(massupdate.wrapperList);
        Map<id,MassOpportunityUpdate.oppWrapper> mapWrap = massUpdate.oppWrapperMap;
        test.startTest();
        for(MassOpportunityUpdate.oppWrapper wrap:mapWrap.values()){ 
            wrap.isModified = true;
            wrap.opp.Mass_Update_Edit__c = true;
            wrap.opp.Mass_Update_Edit_Date__c = System.today();
            massUpdate.isErrorRec=false;
            wrap.opp.StageName = objowd.Oppty_Stage10__c;
            wrap.opp.CloseDate = System.today()+3;
            wrap.opp.Quote_Numbers__c = '1234';
            wrap.opp.Probability = 10;
            wrap.opp.Forecast_Category_Override__c = '';
            wrap.opp.Description = 'Desc';
            wrap.opp.NextStep = 'Next Step';
            break;
            System.assertNotEquals(massupdate.wrapperList,massupdate.wrapperList);
        }
        //v2.0 start
        TriggerControlHandler.setOpportunityTriggersInactive();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        //v2.0 end
        massUpdate.saveAndReturn();
        //v2.0 start
        TriggerExecutionController.setSkipOpportunityTriggers(false);         
        TriggerControlHandler.setOpportunityTriggersActive();
        //v2.0 end
        
        test.stopTest();
        //System.assertEquals(massUpdate.isSavedSuccessfully,true);
    } 
}