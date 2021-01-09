/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13668       FY17-DCS-0103   02-Nov-2016     Fenny           Update roll up summary in Opportunity when deleting OpportunityLineItem  
2.0         18399       FY21-DCS-0202   02-Jan-2020     Shubham Bhatt   Added custom setting in setup(GroupName__c) (added for opportunity split ) 
*/    
@isTest
private class OpportunityLineItemDeleteUtilitiesTest{
    
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert owdSetting;
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
       
        //added by Shubham Bhatt(rubicon)   Added custom setting in setup(GroupName__c) (added for opportunity split ) 
        list<GroupName__c> listGroupName = New list<GroupName__c>();
        listGroupName.add(New GroupName__c(Name = 'FPG_DPS__c', Group_Name__c = 'DPS',Label__c = 'Forecast Product Group DPS',API_Name__c = 'FPG_DPS__c'));
        listGroupName.add(New GroupName__c(Name = 'FPG_MDC__c', Group_Name__c = 'MDC',Label__c = 'Forecast Product Group DPS',API_Name__c = 'FPG_MDC__c'));
        listGroupName.add(New GroupName__c(Name = 'FPG_UDS__c', Group_Name__c = 'UDS',Label__c = 'Forecast Product Group DPS',API_Name__c = 'FPG_UDS__c'));
        listGroupName.add(New GroupName__c(Name = 'FPG_Enterprise__c', Group_Name__c = 'Enterprise',Label__c = 'Forecast Product Group DPS',API_Name__c = 'FPG_Enterprise__c'));
        insert listGroupName;
          
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        list<OpportunityLineItem> listOpptyLimeItemTdf=TestDataFactory.createNOpportunityLineItem(2);
        listOpptyLimeItemTdf[0].Opportunityid =listOppTdf[0].Id;
        listOpptyLimeItemTdf[1].Opportunityid =listOppTdf[0].Id;
        listOpptyLimeItemTdf[1]. Scheduled_Opportunity_Product__c = true;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        insert listOpptyLimeItemTdf;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        
    }   
    
    static testMethod void updateRollUpSummaryInOpportunityTest(){
        Test.startTest();
        insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
        
        ProcessFlowTriggerController.isTest = true;
        OpportunityLineItemDeleteUtilities.isTest = true;
        list<Opportunity> listOpp=[select id,AccountId from Opportunity Limit 1];
        
        list<OpportunityLineItem> listOpptyLimeItem=[select id,pricebookEntryId,Opportunityid,Scheduled_Opportunity_Product__c from OpportunityLineItem Limit 2];
        delete listOpptyLimeItem;
        Opportunity opp = [SELECT Scheduled_Product_Count__c, SOC_Qualify__c FROM Opportunity WHERE Id = :listOpp[0].Id];
        
        system.assertEquals(0.0, opp.Scheduled_Product_Count__c);
        
        Test.stopTest();
        
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
    }
}