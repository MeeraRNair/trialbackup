/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#              Description
-------     ------      ----            --------    ---             -----------   
N/A         N/A         N/A             N/A         N/A             N/A
2.0         Venkat      10-Oct-2018     FY19-0102   16671           Added test Setup as the test class was failing.
*/
@isTest
public class SFDC_OSC_IntegrationService_Test
{
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
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    public static testMethod void getDealInfo(){
        SFDC_OSC_IntegrationService.AssociateDealWithSolution('995863487365','87428542742373','united states');
        /* Opportunity objOpp;
objOpp = new Opportunity();
objOpp.RecordTypeId = '012300000004zf2';
objOpp.Quote_Numbers__c = '123456';
objOpp.Customer_Requested_Delivery_Date__c = system.today() + 60;
objOpp.StageName='Propose - 60%';
objOpp.Probability = 60;
//objOpp.AccountId = objAccount.Id;
objOpp.Name = 'TEST Oppty 1';
objOpp.CloseDate = System.today() + 30;
objOpp.Primary_Product_Delivery_Address_Region__c = 'REGION1';
objOpp.Primary_Product_Delivery_Address_Country__c = 'COUNTRY1';
objOpp.Region__c = 'APJ';
objOpp.Amount=2334;
objOpp.Competitor_Lost_To__c = 'Unknown';
//objOpp.Deal_ID__c='1234';
insert objOpp;
*/
        list<Opportunity> listOpp=[select id,Deal_ID__c from Opportunity Limit 1];
        string strdealid=[select Deal_ID__c from opportunity where id=: listOpp[0].id].Deal_ID__c;
        system.assertNotEquals(listOpp[0].id, null);
        Solution__c solu = new Solution__c();
        solu.Opportunity__c= listOpp[0].Id;
        solu.OSC_Regional_ID__c='abc:123';
        insert solu;
        try{
            SFDC_OSC_IntegrationService.GetDealInfo(strdealid);
            SFDC_OSC_IntegrationService.GetDealInfo('');
            SFDC_OSC_IntegrationService.GetDealInfoDirect(strdealid,'');
            SFDC_OSC_IntegrationService.GetDealInfoDirect('','my error');
            SFDC_OSC_IntegrationService.GetDealInfoDirect('','');
            SFDC_OSC_IntegrationService.GetDealInfoForSolution('123','abc');
            SFDC_OSC_IntegrationService.GetDealInfoForSolution('123','abcd');
            SFDC_OSC_IntegrationService.DirectAssociateDealWithSolution('995863487365','87428542742373','united states');
            SFDC_OSC_IntegrationService.DirectAssociateDealWithSolution('','','');
            SFDC_OSC_IntegrationService.DirectAssociateDealWithSolution(strdealid,'123','abc');
            SFDC_OSC_IntegrationService.DirectAssociateDealWithSolution(strdealid,'123','abcd');
            //  SFDC_OSC_IntegrationService.AssociateDealWithSolution(dealid,'1234','abc');
        }catch(exception e){system.debug('exception');}
    }
}