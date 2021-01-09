/***********************************************************
* Name          : OCEANConfirmationPopUpControllerTest 
* Description   : test class for Class OCEANConfirmationPopUpController.
* ---------------------------------------------------------
* Revision  Name         Date        Description
* 1.0       Azwanti    28.07.2015    MAJ16.07 CR11453: created 
* 2.0       venu       09.12.2019    Implimented TestDataFactory  
************************************************************/
@isTest
public class OCEANConfirmationPopUpControllerTest{
    //Making list for Skip VRs
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
        //Added custom settings to populate StageName values.
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
            listOppTdf[0].Quote_Numbers__c='123456';
            listOppTdf[0].LOT_Mandatory_Fields__c=true;
            listOppTdf[0].Customer_Requested_Delivery_Date__c=System.today()+30;
            listOppTdf[0].How_many_shipments__c=1;
            listOppTdf[0].Name = 'TEST Oppty';
            listOppTdf[0].CloseDate=System.Today() + 30;
            listOppTdf[0].Ocean_Opportunity_Notification_Pop_Up__c=true;
            listOppTdf[0].StageName = 'Qualify - 30%';
            listOppTdf[0].Partner_Opportunity_Stage__c = 'Qualify - 30%'; 
            listOppTdf[0].Region__c='APJ';
            listOppTdf[0].Competitor_Lost_To__c='Unknown';
            listOppTdf[0].Primary_Competitor_Product_Type__c='Client';
            insert listOppTdf;
            list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(1);
            listOppLineItemTdf[0].OpportunityId=listOppTdf[0].id;
            insert listOppLineItemTdf;
            TriggerExecutionController.setSkipAllTriggers(false); 
            
        }
    
    static testmethod void testConfirmOceanEligible() {
        test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        /*  Opportunity oppty = new Opportunity(Quote_Numbers__c='123456',
LOT_Mandatory_Fields__c=true,
Customer_Requested_Delivery_Date__c=System.today()+30,
How_many_shipments__c=1,Name = 'TEST Oppty', 
CloseDate=System.Today() + 30,
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%',
Partner_Opportunity_Stage__c = 'Qualify - 30%', 
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
insert oppty;
*/
        Opportunity oppty=[select id,Quote_Numbers__c,Region__c,Partner_Opportunity_Stage__c,How_many_shipments__c,Customer_Requested_Delivery_Date__c,StageName,LOT_Mandatory_Fields__c,Competitor_Lost_To__c,Ocean_Opportunity_Notification_Pop_Up__c from Opportunity Limit 1];
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        OCEANConfirmationPopUpController controller = new OCEANConfirmationPopUpController(new ApexPages.StandardController(oppty));
        controller.confirmOceanEligible();
        
        Opportunity resultOppty = [SELECT Do_you_want_to_pursue_Ocean__c,Ocean_Opportunity_Notification_Pop_Up__c FROM Opportunity WHERE Id=:oppty.Id];
        system.assert(!resultOppty.Ocean_Opportunity_Notification_Pop_Up__c);
        system.assert(resultOppty.Do_you_want_to_pursue_Ocean__c == 'Yes');    
        TriggerExecutionController.setSkipAllTriggers(false);
        test.stopTest();
    }
    
    static testmethod void testConfirmNotOceanEligible() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        /* Opportunity oppty = new Opportunity(Quote_Numbers__c='123456',
LOT_Mandatory_Fields__c=true,
Customer_Requested_Delivery_Date__c=System.today()+30,
How_many_shipments__c=1,
Name = 'TEST Oppty',
CloseDate=System.Today() + 30, 
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%',
Partner_Opportunity_Stage__c = 'Qualify - 30%',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
insert oppty;
*/
        Opportunity oppty=[select id,Quote_Numbers__c,Region__c,Partner_Opportunity_Stage__c,How_many_shipments__c,Customer_Requested_Delivery_Date__c,StageName,LOT_Mandatory_Fields__c,Competitor_Lost_To__c,Ocean_Opportunity_Notification_Pop_Up__c from Opportunity Limit 1];
        
        OCEANConfirmationPopUpController controller = new OCEANConfirmationPopUpController(new ApexPages.StandardController(oppty));
        controller.confirmNotOceanEligible();
        
        Opportunity resultOppty = [SELECT Do_you_want_to_pursue_Ocean__c, Ocean_Opportunity_Notification_Pop_Up__c FROM Opportunity WHERE Id=:oppty.Id];
        system.assert(!resultOppty.Ocean_Opportunity_Notification_Pop_Up__c);   
        system.assert(resultOppty.Do_you_want_to_pursue_Ocean__c == 'No');  
        TriggerExecutionController.setSkipAllTriggers(false);
        test.stopTest();
        
    }
    
    static testmethod void testSetNotificationFlag() {
        test.startTest();
        TriggerExecutionController.setSkipAllTriggers(true);
        /* Opportunity oppty = new Opportunity(Name = 'TEST Oppty',
CloseDate=System.Today() + 30,
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%', 
Partner_Opportunity_Stage__c = 'Qualify - 30%',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
insert oppty;*/
        Opportunity oppty=[select id,Quote_Numbers__c,Region__c,Partner_Opportunity_Stage__c,How_many_shipments__c,Customer_Requested_Delivery_Date__c,StageName,LOT_Mandatory_Fields__c,Competitor_Lost_To__c,Ocean_Opportunity_Notification_Pop_Up__c from Opportunity Limit 1];
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        OCEANConfirmationPopUpController controller = new OCEANConfirmationPopUpController(new ApexPages.StandardController(oppty));
        controller.setNotificationFlag();
        
        Opportunity resultOppty = [SELECT Ocean_Opportunity_Notification_Pop_Up__c FROM Opportunity WHERE Id=:oppty.Id];
        system.assert(!resultOppty.Ocean_Opportunity_Notification_Pop_Up__c); 
        TriggerExecutionController.setSkipAllTriggers(false);
        test.stopTest();
    }
    
    static testmethod void testShowOLIQuoteCustReqDtNull(){
        /* Opportunity oppty = new Opportunity(Quote_Numbers__c='123456',
LOT_Mandatory_Fields__c=true,
Customer_Requested_Delivery_Date__c=System.today()+30,
How_many_shipments__c=1,
Name = 'TEST Oppty', 
CloseDate=System.Today() + 30, 
Ocean_Opportunity_Notification_Pop_Up__c=true,
StageName = 'Qualify - 30%',
Region__c='APJ',
Competitor_Lost_To__c='Unknown');
TriggerExecutionController.setSkipOpportunityTriggers(true);
insert oppty;*/
        Opportunity oppty=[select id,Quote_Numbers__c,Region__c,Partner_Opportunity_Stage__c,How_many_shipments__c,Customer_Requested_Delivery_Date__c,StageName,LOT_Mandatory_Fields__c,Competitor_Lost_To__c,Ocean_Opportunity_Notification_Pop_Up__c from Opportunity Limit 1];
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        /*  Id pricebookId = Test.getStandardPricebookId();

//Create your product
Product2 prod = new Product2(
Product_ID__c = '12547',
Name = 'Product X',
ProductCode = 'Pro-X',
isActive = true,
APJ_ASIA__c=10
);
insert prod;

//Create your pricebook entry
PricebookEntry pbEntry = new PricebookEntry(
Pricebook2Id = pricebookId,
Product2Id = prod.Id,
UnitPrice = 100.00,
IsActive = true
);
insert pbEntry;

//create your opportunity line item.
OpportunityLineItem oli = new OpportunityLineItem(
OpportunityId = oppty.Id,
Quantity = 20,
PricebookEntryId = pbEntry.Id,
TotalPrice = 500.00
);
TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
TriggerExecutionController.setSkipOpportunityTriggers(true);
insert oli;
TriggerExecutionController.setSkipOpportunityTriggers(false);
TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
*/
        OpportunityLineItem oli=[select id from OpportunityLineItem Limit 1];
        test.startTest();
        //oppty.Probability = 60; 
        oppty.StageName = 'Propose - 60%';
        oppty.LOT_Mandatory_Fields__c = true;
        oppty.Eligible_for_Ocean__c = 'Yes';
        oppty.Needed_Quote_Notification_Pop_Up__c = true;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        update oppty;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        test.stopTest();
        
        OCEANConfirmationPopUpController controller = new OCEANConfirmationPopUpController(new ApexPages.StandardController(oppty));
        system.assert(controller.getShowConsolidatePage());
        
    }
    
}