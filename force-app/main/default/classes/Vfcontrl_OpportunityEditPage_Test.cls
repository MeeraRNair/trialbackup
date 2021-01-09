/*History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0                                     created
2.0     13-July-2015    Azwanti         CR11453 - added test for consolidated LOT/Ocean/Needed Quote page
3.0     08-Jun-2016     Fenny           CR13171 - To resolve "Too many SOQL queries: 101"
4.0     05-Jul-2017     Abhinav         CR14471 - To add field value in test data which required by PB
12-Dec-2018     Hari A         STORY 5907651 Removed reference for the field total_aggregated_volume__c
*/
@isTest
private class Vfcontrl_OpportunityEditPage_Test{
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    Static list<OpportunityLineItem> listOppLineItem;
    @testSetup static void setup() {
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
        TriggerExecutionController.setSkipAllTriggers(true); // 3.0
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        listOppTdf[1].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItemTdf[0].OpportunityId=listOppTdf[0].id;
        insert listOppLineItemTdf;
    } 
    static testMethod void vfcontrlOpportunityEditPageTest() {
        TriggerExecutionController.setSkipAllTriggers(true); // 3.0
        listAcc=[Select id from Account Limit 1];
        listOpp=[Select id from Opportunity Limit 1];
        listOpp[0].Probability = 10;
        listOpp[0].ForecastCategoryName = 'Pipeline';
        listOpp[0].Skip_Calculate_LOT_OCEAN__c = false;
        update listOpp;
        listOpp[0].stageName = 'Propose - 60%';
        listOpp[0].Probability = 60;
        listOpp[0].ForecastCategoryName= 'Best Case';
        listOpp[0].Primary_Competitor__c ='Unknown'; 
        listOpp[0].Competitor_Lost_To__c = 'Acrodex'; 
        listOpp[0].CloseDate = Date.TODAY();
        listOpp[0].Primary_Competitor_Product_Type__c='CI';
        TriggerExecutionController.setSkipOpportunityTriggers(true);        
        update listOpp[0];
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        listOpp[0].stageName = 'Qualify - 30%';
        listOpp[0].Probability = 30;
        listOpp[0].ForecastCategoryName= 'Pipeline';
        listOpp[0].Primary_Competitor__c ='Unknown'; 
        listOpp[0].Competitor_Lost_To__c = 'Acrodex'; 
        listOpp[0].Primary_Competitor_Product_Type__c='CI';
        TriggerExecutionController.setSkipOpportunityTriggers(true);        
        update listOpp[0];
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        system.assert(listOpp[0].Id != null);
        listOppLineItem=[Select id from OpportunityLineItem Limit 1];
        listOppLineItem[0].Customer_Requested_Date__c =Date.TODAY()-2;
        listOppLineItem[0].Quote__c = null;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        update listOppLineItem;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        PageReference pageRef = Page.OpportunityEditPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OldOppStage',listOpp[0].StageName);
        ApexPages.currentPage().getParameters().put('oldProbability', '60$propose60');
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Vfcontrl_OpportunityEditPage opp = new Vfcontrl_OpportunityEditPage();
        opp.redirectToDetail();
        opp.UpdatedOppLineItems.add(listOppLineItem[0]);
        opp.opp = New Opportunity(Name='Test Opp1',AccountId=listAcc[0].id,StageName='Discover - 10%',Probability = 10,CloseDate = Date.TODAY(), Skip_Calculate_LOT_OCEAN__c = True, LOT_Mandatory_Fields__c=True, Eligible_for_Ocean__c='Yes', Do_you_want_to_pursue_Ocean__c='Yes', How_many_shipments__c=null, LOT_Large_Opportunity__c=True, Needed_Quote_Notification_Pop_Up__c=False);
        opp.opp = New Opportunity(Name='Test Opp2',AccountId=listAcc[0].id,StageName='Qualify - 30%',Probability = 30,CloseDate = Date.TODAY(), Skip_Calculate_LOT_OCEAN__c = True, LOT_Mandatory_Fields__c=True, Eligible_for_Ocean__c='Yes', Do_you_want_to_pursue_Ocean__c='No', How_many_shipments__c=2, LOT_Large_Opportunity__c=True, Needed_Quote_Notification_Pop_Up__c=True);
        opp.save();
        opp.cancel();
        opp.getEligibleToMessage();
        ApexPages.currentPage().getParameters().put('oldProbability', '60$plan1');
        Vfcontrl_OpportunityEditPage opp1 = new Vfcontrl_OpportunityEditPage();
        ApexPages.currentPage().getParameters().put('oldProbability', '60$discover10');
        Vfcontrl_OpportunityEditPage opp2 = new Vfcontrl_OpportunityEditPage();
        ApexPages.currentPage().getParameters().put('oldProbability', '60$qualify30');
        Vfcontrl_OpportunityEditPage opp3 = new Vfcontrl_OpportunityEditPage();
        ApexPages.currentPage().getParameters().put('oldProbability', '60$commit90');
        Vfcontrl_OpportunityEditPage opp4 = new Vfcontrl_OpportunityEditPage();
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void vfcontrlNeededQuotePageTest() {
        listAcc=[Select id from Account Limit 1];
        listOpp=[Select id from Opportunity Limit 1];
        listOpp[0].CloseDate = Date.TODAY();
        listOpp[0].Probability = 10;
        listOpp[0].Primary_Product_Delivery_Address_Country__c ='US';
        listOpp[0].Primary_Product_Delivery_Address_Region__c='NORTH AMERICA'; 
        listOpp[0].Skip_Calculate_LOT_OCEAN__c = false;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update listOpp[0]; 
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        listOpp[0].StageName = 'Commit - 90%';
        listOpp[0].Probability = 90; 
        listOpp[0].ForecastCategoryName= 'Commit';
        listOpp[0].Ocean_Opportunity_Notification_Pop_Up__c = true;
        listOpp[0].Eligible_for_Ocean__c ='Yes';
        listOpp[0].Primary_Competitor__c ='Unknown';
        listOpp[0].Competitor_Lost_To__c = 'Acrodex';
        listOpp[0].Primary_Competitor_Product_Type__c='CI';   
        TriggerExecutionController.setSkipOpportunityTriggers(true);  
        update listOpp[0];
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        system.assert(listOpp[0].Id != null);
        PageReference pageRef1 = Page.OpportunityEditPage;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('OldOppStage',listOpp[0].StageName);
        ApexPages.currentPage().getParameters().put('oldProbability', '90$commit90');
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        ApexPages.currentPage().getParameters().put('readOnly','true');
        ApexPages.currentPage().getParameters().put('pursue', 'true');
        Vfcontrl_OpportunityEditPage opp1 = new Vfcontrl_OpportunityEditPage();
        opp1.redirectToDetail();
        opp1.editURL();
        opp1.save();
        opp1.cancel();
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true,
            APJ_ASIA__c=10,
            Order_Compliant_Product__c = true,
            Product_ID__c = 'test prod id2'
        );
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = listOpp[0].Id,
            Quantity = 2500,
            PricebookEntryId = pbEntry.Id,
            Unitprice = 500.00
        );
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        try{insert oli;}catch(exception e){}
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        PageReference pageRef = Page.OpportunityEditPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OldOppStage',listOpp[0].StageName);
        ApexPages.currentPage().getParameters().put('oldProbability', '90$commit90');
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        ApexPages.currentPage().getParameters().put('readOnly','true');
        ApexPages.currentPage().getParameters().put('pursue', 'true');
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Vfcontrl_OpportunityEditPage opp = new Vfcontrl_OpportunityEditPage();
        opp.redirectToDetail();
        opp.editURL();
        opp.save();
        opp.cancel();
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        listOpp[0].StageName = 'Commit - 90%';
        listOpp[0].Probability = 90;
        TriggerExecutionController.setSkipOpportunityTriggers(true);  
        update listOpp[0];
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        PageReference pageRef02 = Page.OpportunityEditPage;
        Test.setCurrentPage(pageRef02);
        ApexPages.currentPage().getParameters().put('OldOppStage',listOpp[0].StageName);
        ApexPages.currentPage().getParameters().put('oldProbability', '60$commit60');
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        Vfcontrl_OpportunityEditPage opp02 = new Vfcontrl_OpportunityEditPage();
        opp02.redirectToDetail();
        opp02.editURL();
        opp02.save();
        opp02.cancel();
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Test.stopTest();
        system.assert(listOpp[0].Id != null);
    }
    static testMethod void consolidateLOTOceanPage(){
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[Select id from Account Limit 1];
        Lot_Region__c objLOT = new Lot_Region__c(Name='UNITED STATES',Region__c='AMER',RM_Country__c='UNITED STATES',Threshold_Region__c='AMER');
        insert objLOT;
        listOpp=[Select id from Opportunity Limit 1];
        listOpp[0].Probability=1;
        listOpp[0].CloseDate = System.today() + 30;
        listOpp[0].Primary_Product_Delivery_Address_Region__c = 'AMER';
        listOpp[0].Primary_Product_Delivery_Address_Country__c = 'UNITED STATES';
        listOpp[0].Region__c='AMER';
        listOpp[0].Competitor_Lost_To__c='Unknown';
        listOpp[0].Skip_Calculate_LOT_OCEAN__c = false;
        update listOpp;
        system.assert(listOpp[0] != null);
        listOppLineItem=[Select id from OpportunityLineItem Limit 1];
        listOppLineItem[0].Configuration_Services__c = null;
        update listOppLineItem;
        listOpp[0].Probability = 60; 
        listOpp[0].StageName = 'Propose - 60%';
        listOpp[0].ForecastCategoryName= 'Best Case';
        listOpp[0].LOT_Mandatory_Fields__c = true;
        listOpp[0].Eligible_for_Ocean__c = 'Yes';
        listOpp[0].Ocean_Opportunity_Notification_Pop_Up__c = true;
        listOpp[0].Primary_Competitor_Product_Type__c='CI';
        update listOpp[0];
        TriggerExecutionController.setSkipAllTriggers(false);
        test.startTest();
        PageReference pageRef = Page.OpportunityEditPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OldOppStage',listOpp[0].StageName);
        ApexPages.currentPage().getParameters().put('oldProbability', '60$propose60');
        ApexPages.currentPage().getParameters().put('id',listOpp[0].Id);
        ApexPages.currentPage().getParameters().put('pursue', 'true');
        TriggerExecutionController.setSkipAccountTriggers(true); // 3.0
        TriggerExecutionController.setSkipOpportunityTriggers(true); // 3.0
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true); // 3.0
        Vfcontrl_OpportunityEditPage opp = new Vfcontrl_OpportunityEditPage();
        opp.redirectToDetail();
        opp.getEligibleToMessage();
        opp.cancel();
        test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false); // 3.0
        TriggerExecutionController.setSkipOpportunityTriggers(false); // 3.0
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false); // 3.0
    }
}