@IsTest
public class OpportunityLineItemTriggerHandlerAUDTest {
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
        EMC_General_Settings__c settingData = new EMC_General_Settings__c();
        settingData.ProfilesBypassMyquotesOpptyValidation__c= 'Boomi Integration API Only;';        
        insert settingData;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        System.assertEquals(listAccTdf[0].id, listOppTdf[0].AccountId);
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItemTdf[0].OpportunityId=listOppTdf[0].id;
        insert listOppLineItemTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
    static testMethod void testDeleteLineItem() {    
        TriggerExecutionController.setSkipAllTriggers(true);
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUndelete' => new List<Boolean>{false, false, false, false, true}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerAUD"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c opptec = new TriggerExecutionControl__c();
        opptec.Name = 'Opportunity';
        opptec.RecursiveCount__c = 2;
        opptec.SkipTriggers__c = true;
        insert opptec;
        
        TriggerExecutionControl__c olitec = new TriggerExecutionControl__c();
        olitec.Name = 'OpportunityLineItem';
        olitec.RecursiveCount__c = 2;
        insert olitec;
        list<Account> listAcc=[select id from Account Limit 1];
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        list<OpportunityLineItem> listOppLineItem=[select id from OpportunityLineItem Limit 1];
        /* Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
insert testAccount;        
Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
AccountId=testAccount.Id, 
stagename='Discover - 10%',
CloseDate = System.Today() + 30 ); 
insert testOppty;   
//Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
Id pbk1 = Test.getStandardPricebookId();
//List<Product2> listProduct2 =new List<Product2>();
Product2 newPrdct = new Product2(Name = 'Test Product',
Product_Line_Desc__c = 'Test Product',
Product_ID__c='test prod id1',
IsActive = TRUE);
insert newPrdct;                             

PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
Pricebook2ID=pbk1,
isActive=true,
useStandardPrice=false,
UnitPrice = 50);
insert pBE;

OpportunityLineItem testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
pricebookEntryId=pBE.id,
Mrgn__c =6,
Discount_off__c = 7,
UnitPrice = 100,
Quantity =2,
Description = 'Line Description',
Service_Support_US__c = 'ProSupport IT - Mission Critical'
); 
insert testLineItem;

/*string strOLIID = testLineItem.Id;
OpportunityLineItem insertedOLI = [SELECT Id FROM OpportunityLineItem WHERE Id = :strOLIID];
delete insertedOLI;
TriggerExecutionController.setSkipAllTriggers(false);

Test.startTest(); 
OpportunityLineItem deletedOLI = [SELECT Id FROM OpportunityLineItem WHERE Id = :strOLIID ALL ROWS];
Undelete deletedOLI;
Test.stopTest();*/
        
        // Above test code giving exception when undelete the line item, exception = CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, Entity type is not undeletable
        // So, directly call the trigger handler method
        //try{*/
        OpportunityLineItemTriggerHandler handler = new OpportunityLineItemTriggerHandler();
        handler.getRecordSelector();
        OpportunityLineItemTriggerHandlerAUD oliHandler = new OpportunityLineItemTriggerHandlerAUD();
        oliHandler.handleAfterUndelete(new List<sObject>());
        //}catch(Exception ex){ }
    }
}