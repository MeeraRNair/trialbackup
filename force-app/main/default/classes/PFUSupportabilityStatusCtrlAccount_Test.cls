/************************************************************************
Name: PFUSupportabilityStatusCtrlAccountTest 
Author: Noraiman Afiq
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
*1.0     07-Sept-2016     Afiq           Created for PFUSupportabilityStatusCtrlAccount
************************************************************************/
@isTest
private class PFUSupportabilityStatusCtrlAccount_Test{
    
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
            list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
            insert listAccTdf;
            list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
            listOppTdf[0].AccountId=listAccTdf[0].id;
            listOppTdf[0].Partner_Opportunity_Stage__c='Discover - 10%';
            listOppTdf[0].Probability = 10;
            listOppTdf[0].Supportability_Status__c='Supportable';
            insert listOppTdf;
            list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(3);
            listOppLineItemTdf[0].OpportunityId=listOppTdf[0].id;
            listOppLineItemTdf[1].OpportunityId=listOppTdf[0].id;
            listOppLineItemTdf[2].OpportunityId=listOppTdf[0].id;
            insert listOppLineItemTdf;
            TriggerExecutionController.setSkipAllTriggers(false);
        }
    
    private static testMethod void addLineItemsSuppStatus() { 
        
        /* List<OpportunityLineItem> testLineItemList = new List<OpportunityLineItem>();
List<Product2> Product2List = new List<Product2>();
List<PricebookEntry> pbeList = new List<PricebookEntry>();
*/
        // 7.4 To create customsettings
        insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
        
        //TriggerExecutionController.setSkipAllTriggers(true);
        /*  Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
insert testAccount;        
Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
Primary_Product_Delivery_Address_Country__c ='SLOVAKIA',
Primary_Product_Delivery_Address_Region__c ='LATAM',
AccountId=testAccount.Id, 
StageName='Discover - 10%',
Partner_Opportunity_Stage__c='Discover - 10%',
Probability = 10,
Supportability_Status__c='Supportable',
CloseDate = System.Today() + 30 );
insert testOppty;   
//Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
Id pbk1 = Test.getStandardPricebookId();

Product2 newPrdct = new Product2(Product_ID__c = '1234',Name = 'Test Product',
Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='EMC Hot Spot', EMC_CRUD_Behavior__c='Read/Write',
IsActive = TRUE);
Product2List.add(newPrdct);

Product2 newPrdct2 = new Product2(Product_ID__c = '5678',Name = 'Test Product2',
Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='EMC Hot Spot', EMC_CRUD_Behavior__c='Read Only',
IsActive = TRUE);
Product2List.add(newPrdct2);

Product2 newPrdct3 = new Product2(Product_ID__c = '4321',Name = 'Test ProductA',
Product_Line_Desc__c = 'EMC',EMC_Sales_Motion__c ='', EMC_CRUD_Behavior__c='',
IsActive = TRUE);
Product2List.add(newPrdct3);

insert Product2List;

PricebookEntry PBE= new PricebookEntry (Product2ID=newPrdct.id,
Pricebook2ID=pbk1,
isActive=true,
useStandardPrice=false,
UnitPrice = 50);
pbeList.add(PBE);

PricebookEntry PBE1= new PricebookEntry (Product2ID=newPrdct2.id,
Pricebook2ID=pbk1,
isActive=true,
useStandardPrice=false,
UnitPrice = 50);
pbeList.add(PBE1);

PricebookEntry PBE3= new PricebookEntry (Product2ID=newPrdct3.id,
Pricebook2ID=pbk1,
isActive=true,
useStandardPrice=false,
UnitPrice = 50);


pbeList.add(PBE3);

insert pbeList;

OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
pricebookEntryId=PBE.id,
Mrgn__c =6,
Discount_off__c = 7,
UnitPrice = 100,
Quantity =2,
Description = 'Line Description'
); 


//Add Product with Supportability Status = Supportable
OpportunityLineItem  testLineItem2 = new OpportunityLineItem(Opportunityid =testOppty.Id,
pricebookEntryId=PBE1.id,
Mrgn__c =6,
Discount_off__c = 7,
UnitPrice = 100,
Quantity =2,
Description = 'Line Description',
Supportability_Status__c = 'Supportable'
);

//Add Product with Supportability Status = Expired. This will trigger to cover scenario precedance lower
OpportunityLineItem  testLineItem3 = new OpportunityLineItem(Opportunityid =testOppty.Id,
pricebookEntryId=PBE3.id,
Mrgn__c =6,
Discount_off__c = 7,
UnitPrice = 100,
Quantity =2,
Description = 'Line Description',
Supportability_Status__c = 'Expired'
); 

//TriggerExecutionController.setSkipAllTriggers(false);

//TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
//TriggerExecutionController.setSkipAccountTriggers(true);
//TriggerExecutionController.setSkipOpportunityTriggers(true);

testLineItemList.add(testLineItem);
*/
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        list<OpportunityLineItem> listOppLineItem=[select id from OpportunityLineItem Limit 3];
        // for(OpportunityLineItem opl : listOppLineItem){
        //   listOppLineItem1.add(opl);
        //}
        List<Id> listOptyNew= new List<Id>();
        List<Id> listOptyNew2= new List<Id>();
        List<Id> listOptyNew3= new List<Id>();
        List<Id> listOptyNew4= new List<Id>();
        
        Test.startTest();
        
        listOptyNew.add(listOpp[0].Id); // 1.0        
        PFUSupportabilityStatusCtrlAccount.UpdateSupportabilityStatus(listOptyNew);
        
        listOptyNew2.add(listOpp[0].Id); // 1.0        
        PFUSupportabilityStatusCtrlAccount.UpdateSupportabilityStatus(listOptyNew2);  
        // testLineItemList.add(listOppLineItem[2]);
        
        listOptyNew3.add(listOpp[0].Id); // 1.0        
        PFUSupportabilityStatusCtrlAccount.UpdateSupportabilityStatus(listOptyNew3);          
        
        listOptyNew4.add(listOpp[0].Id); // 1.0        
        PFUSupportabilityStatusCtrlAccount.UpdateSupportabilityStatus(listOptyNew4);    
        
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        // testLineItemList.add(testLineItem2);
        
        //insert testLineItemList;
        // Delete listOppLineItem1[0];
        
        Test.stopTest();
        
        //TriggerExecutionController.setSkipAccountTriggers(false);
        //TriggerExecutionController.setSkipOpportunityTriggers(false);
    }   
}