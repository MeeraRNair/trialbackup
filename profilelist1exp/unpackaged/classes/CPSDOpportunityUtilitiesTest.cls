/*
* Author   : Ranjith Mergu
* Purpose  : CPSDOpportunityUtilitiesTest test class for creating Opportunity related data. 
*
*/
@isTest
public class CPSDOpportunityUtilitiesTest {
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
        @testSetup static void setup() {
            // Create common test OWD settings
            OWD__c owdSetting = new OWD__c();
            owdSetting.Oppty_Stage1__c = 'Plan - 1%';
            owdSetting.Oppty_Stage10__c = 'Discover - 10%';
            owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
            owdSetting.Oppty_Stage60__c = 'Propose - 60%';
            owdSetting.Oppty_Stage90__c = 'Commit - 90%';
            owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
            owdSetting.Oppty_Stage100__c = 'Win - 100%';
            owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
            Insert owdSetting; 
            system.assertEquals('Qualify - 30%',owdSetting.Oppty_Stage30__c );
            TriggerExecutionController.setSkipAllTriggers(true);
            System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
            cs.Bypass_Opportunity_VRs__c = true;
            insert cs;
            ProcessFlowTriggerController.isTest = true;
            list<Account> listAccTdf=TestDataFactory.createNAccount(4, 'Partner Account');
            listAccTdf[0].CPSD_Account_ID__c='';
            listAccTdf[1].CPSD_Account_ID__c='31312312';
            listAccTdf[1].CPSD_Integration_Status__c='completed';
            insert listAccTdf;
            
            list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
            listOppTdf[0].AccountId=listAccTdf[0].Id;
            listOppTdf[0].Deal_Registration_Status__c= 'Approved';
            listOppTdf[0].EMC_ID_Opp__c ='123123123';
            listOppTdf[0].EMC_Opportunity_Number__c ='dhf2131212';
            listOppTdf[0].Distributor_Direct_Reseller_Account__c = listAccTdf[2].Id;
            listOppTdf[0].Indirect_Partner_Account__c = listAccTdf[3].Id;
            insert listOppTdf;
            TriggerExecutionController.setSkipAllTriggers(false);
            
        }  
    /* public static testmethod void testcloneOppsWithoutProducts() {
TriggerExecutionController.setSkipAllTriggers(true);
Test.startTest();
Account testAccountObj =new Account(name='Renewal Test Account',
Account_Country_Code__c = 'JC',
Account_Country__c = 'Jedi Country', 
Approved_for_Partner_Finder__c = false);
insert testAccountObj;
//TriggerExecutionController.setSkipAllTriggers(false);
Opportunity objP = new Opportunity(AccountId=testAccountObj.Id,
Name='TestParentOpportunity',
Type = 'Run Rate',
Domain__c='Deal Reg',
Solution_Type__c = 'Campus',
Solution_Name__c = 'Wireless Switches',
StageName='Plan - 1%',
CloseDate= System.Now().Date().addDays(180),
CPSD_Integration_Status__c ='',
Bill_To_Ship_To_Comments__c ='');
insert objP;
system.assertEquals('', objP.CPSD_Integration_Status__c);
system.assertEquals('', objP.Bill_To_Ship_To_Comments__c);
TriggerExecutionController.setSkipAccountTriggers(false);
TriggerExecutionController.setSkipOpportunityTriggers(false);
Test.stopTest();
}*/
    public static testMethod void testupdateCPSDIntegrationStatusToWaitingSync() {
        Test.startTest(); 
        TriggerExecutionController.setSkipAllTriggers(true);
        //System_Behavior_Bypasser__c cs = new System_Behavior_Bypasser__c();
        //cs.Bypass_Opportunity_VRs__c = true;
        //insert cs;
        //ProcessFlowTriggerController.isTest = true;
        /* Account newAcc = new Account(name='Test', Account_ID__c='1635123',CPSD_Account_ID__c='');
insert newAcc;  

Account newAcc1 = new Account(name='New Account 1', Account_ID__c='6242887', CPSD_Account_ID__c='31312312',
CPSD_Integration_Status__c='completed');
insert newAcc1; 

Account newPartnerAcc = new Account(name='parnerAcc',Account_ID__c='23342342', RecordTypeID=accRTId);
insert newPartnerAcc;

Account newPartnerAcc1 = new Account(name='123parnerAcc',Account_ID__c='34535', RecordTypeID=accRTId);
insert newPartnerAcc1;


Id dealRTId = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true);
Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
AccountId=newAcc.Id, 
Deal_Registration_Status__c= 'Approved',
RecordTypeID = dealRTId,
StageName = 'Plan - 1%',
CloseDate = System.Today() + 30, 
EMC_ID_Opp__c ='123123123',
EMC_Opportunity_Number__c ='dhf2131212',
Distributor_Direct_Reseller_Account__c = newPartnerAcc.Id,
Indirect_Partner_Account__c = newPartnerAcc1.Id,
ForecastCategoryName = 'Omitted'
);        
// TriggerExecutionController.setSkipOpportunityTriggers(true);
insert testOppty;
*/
        list<Account> listAcc=[select id from Account Limit 4];
        Opportunity testOppty=[select id,StageName,Affinity_ID__c,RecordTypeId,Deal_ID__c,ForecastCategoryName,Indirect_Partner_Account__c,Distributor_Direct_Reseller_Account__c,EMC_ID_Opp__c,EMC_Opportunity_Number__c from Opportunity limit 1];
        // TriggerExecutionController.setSkipOpportunityTriggers(false); 
        testOppty.Bill_To_Ship_To_Comments__c ='2334332';
        testOppty.StageName = 'Discover - 10%';
        testOppty.Probability = 10;
        testOppty.Name = 'Name Updated';
        testOppty.EMC_ID_Opp__c ='sd2323sdcd123';
        testOppty.AccountId = listAcc[1].Id;
        testOppty.CloseDate = System.Today() + 10;
        testOppty.EMC_Opportunity_Number__c = 'asd23626328';
        testOppty.Distributor_Direct_Reseller_Account__c = listAcc[3].Id;
        testOppty.Indirect_Partner_Account__c = listAcc[2].Id;
        testOppty.CPSD_Integration_Status__c ='Waiting Sync';
        testOppty.ForecastCategoryName ='Commit';
        //Set skip VRs
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        update testOppty;
        // update newAcc1;
        system.assertEquals('Waiting Sync',testOppty.CPSD_Integration_Status__c);
        //Reset skip VRs
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjAPINames);
        List<Opportunity> listOpp=new List<Opportunity>();
        listOpp.add(testOppty);
        CPSDOpportunityUtilities.updateCPSDIntegrationStatusToWaitingSync(listOpp,new Map<ID, Opportunity>(listOpp));
        CPSDOpportunityUtilities.cloneOppsWithoutProducts(listOpp);
        Test.stopTest();
        //system.assertEquals('Waiting Sync',testOppty.CPSD_Integration_Status__c);
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
}