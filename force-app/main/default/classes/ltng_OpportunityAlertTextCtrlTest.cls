/*
Revision       CR Number      Release No         Date         Modified By     Description
--------       ---------      ----------      -----------     ------------    -----------
1.0            CR 15184       FY18-DCS-0102   30-Nov-2017        Emily        To query Opportunity record using the Id passed from Lightning component
*/ 

@isTest
public class ltng_OpportunityAlertTextCtrlTest{
    static testMethod void testCreateOpportunity() {
        Opportunity objOpp;
        Opportunity objOppLex;
        Sales_Channel_Group__c objSalesChannelGrp;
        Account objAccount;
    
        TriggerExecutionController.setSkipAllTriggers(true);
    
        objSalesChannelGrp = new Sales_Channel_Group__c();
        objSalesChannelGrp.Name = 'TestChannelGroup1';
        objSalesChannelGrp.Region_Name__c = 'REGION1';
        objSalesChannelGrp.Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE';        
        insert objSalesChannelGrp;
        
        objAccount = new Account();
        objAccount.Name = 'TestAccount';
        objAccount.Sales_Channel__c = objSalesChannelGrp.Id;
        insert objAccount;
               
        objOpp = new Opportunity();
        objOpp.RecordTypeId = '012300000004zf2';        
        objOpp.StageName='Propose - 60%';
        objOpp.Probability = 60;
        objOpp.AccountId = objAccount.Id;
        objOpp.Name = 'TEST Oppty 1';
        objOpp.CloseDate = System.today() + 30;
        
        insert objOpp;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        objOpp = [SELECT Id FROM Opportunity WHERE Id =: objOpp.Id];
        
        objOppLex = ltng_OpportunityAlertTextCtrl.serverEcho(objOpp.Id);
        
        System.assertEquals(objOpp.Id, objOppLex.Id);
    }
}