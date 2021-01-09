@isTest
private class OpportunityQuoteTriggerHelperTest {
    
    @testSetup static void setup() {
        
        // Create common test data OWD customsetting
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Database.insert(owdSetting);
        
        // Create common test data Needed Quote GS customsetting
        Needed_Quote_GS__c objNQGS = new Needed_Quote_GS__c();
        objNQGS.add_quote_desc__c = 'You must enter a valid Quote#, Quantity, Configuration Services and Customer Requested Date on the Product in order to save the Opportunity at the desired Probability.    ';
        objNQGS.add_quote_desc2__c = 'Otherwise all other changes will be saved and the Stage / Probability will not be updated.';
        objNQGS.add_quote_err_msg__c = 'You must enter a valid Quote#, Quantity, Configuration Services and Customer Requested Date in order to save Opportunity Product.';
        objNQGS.add_quote_no_lot_prod_err_msg__c = 'There are not any products that currently meet LOT/Ocean/Needed-Quote criteria.';
        objNQGS.add_quote_title__c = 'Add Quote numbers to Products';
        objNQGS.alt_msg_desc__c = 'Please add quote numbers for all products.';
        objNQGS.alt_msg_title_lt__c = 'Opportunity';
        objNQGS.alt_msg_title_rt__c = 'stage could not be updated.';
        objNQGS.actionlist_nq_label__c = 'Add Quote numbers to Products';
        objNQGS.actionlist_nq_tooltip__c = 'All products must include quote information.';
        objNQGS.trigger_alt_msg__c = 'Please provide a valid Quote#, Quantity, Configuration Services and Customer Requested Date on the Products before changing the stage';
        Database.insert(objNQGS);
        
        TriggerExecutionController.setSkipAlltriggers(true);
        
        String strProfileId = [SELECT id from profile WHERE Name = 'R16.10 GBL Sales Mgr' LIMIT 1][0].Id;
        User u1 = new User(Alias = 'gblsales', Email='gblsalesmgr@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = strProfileId, TimeZoneSidKey='America/Los_Angeles', UserName='gblsales@dell.com', Badge_Number__c = getUniqueString());
        insert u1;
        
        /* Account testAccountObj =new Account(name='Test Account', 
		Account_Country_Code__c = 'US', 
		Account_Country__c = 'United States');
		insert testAccountObj;
		*/list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTdf[0].Account_Country_Code__c = 'US';
        listAccTdf[0].Account_Country__c = 'United States';
        insert listAccTdf;   
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        listOppTdf[1].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        /* Opportunity testOpportunity1 = new Opportunity (AccountID=testAccountObj.ID ,
RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
Name='TestOpp1',
Type = 'Deal/Bid - Indirect',
Domain__c='Deal Reg',
Solution_Type__c = 'Campus',
Solution_Name__c = 'Wireless Switches',
StageName='Plan - 1%',
Partner_Opportunity_Stage__c = 'Plan - 1%',
EMC_Opportunity_Number__c = '09872862',
CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');

Opportunity testOpportunity2 = new Opportunity (AccountID=testAccountObj.ID ,
RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId(),
Name='TestOpp2',
Type = 'Deal/Bid - Indirect',
Domain__c='Deal Reg',
Solution_Type__c = 'Campus',
Solution_Name__c = 'Wireless Switches',
StageName='Discover - 10%',
Partner_Opportunity_Stage__c = 'Discover - 10%',
EMC_Opportunity_Number__c = '09872863',
CloseDate= System.Now().Date().addDays(180),Primary_Competitor__c='Unknown',Competitor_Lost_To__c='Unknown');

List<Opportunity> listopp = new List<Opportunity>();            
listopp.add(testOpportunity1);
listopp.add(testOpportunity2);

insert listopp;
*/
        /*  Id pbk1 = Test.getStandardPricebookId();

Product2 newPrdct1 = new Product2(Name = 'Test Product1',ProductCode = 'TP1', Product_ID__c='test prod id1',Product_Line_Desc__c = 'Test Product1',IsActive = TRUE,EOL_Date_EMEA__c=System.Now().Date().addDays(240));
insert newPrdct1;                                      

PricebookEntry pbe1= new PricebookEntry (Product2ID=newPrdct1.id, Pricebook2ID=pbk1,isActive=true, useStandardPrice=false,UnitPrice = 50);                                 
insert pbe1;  

OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId =listOppTdf[0].Id,
pricebookEntryId=pbe1.id,
Mrgn__c =6,Discount_off__c = 7,
UnitPrice = 100,Quantity =2,
Description = 'Line Description1',
LOT_Indicator__c = true);   
insert oppLineItem;

OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId =listOppTdf[1].Id,pricebookEntryId=pbe1.id,Mrgn__c =6,Discount_off__c = 7,UnitPrice = 100000,Quantity =2,Description = 'Line Description1');   
insert oppLineItem2;
*/
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(2);
        listOppLineItemTdf[0].OpportunityId =listOppTdf[0].Id;
        listOppLineItemTdf[1].OpportunityId =listOppTdf[1].Id;
        listOppLineItemTdf[0].LOT_Indicator__c = true;
        insert listOppLineItemTdf;
        listOppTdf[0].OwnerId = u1.Id;
        update listOppTdf[0];
        listOppTdf[1].OwnerId = u1.Id;
        update listOppTdf[1];
        
        TriggerExecutionController.setSkipAlltriggers(false);
    }
    
    @isTest
    static void validateQuotesTest() {
        LOTOpportunityTriggerHandlerBU.bIsInLexUI = true;
        
        //Skip OpportunityTriggerHandlerAU
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "LOTOpportunityTriggerHandlerBU"},'; 
            }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity';
        tec.RecursiveCount__c = 2;
        insert tec;
        
        Test.startTest();
        TriggerExecutionController.setSkipAccounttriggers(true);
        try {
            List<Opportunity> listOpp = [SELECT Id, StageName FROM Opportunity];
            if(listOpp.size() > 0) {
                listOpp[0].StageName = 'Propose - 60%';
                listOpp[1].StageName = 'Propose - 60%';
                update listOpp;
            }
            system.assertNotEquals(listOpp[0].id, null);
        } catch(Exception ex) {
            Boolean bExpectedExceptionThrown =  ex.getMessage().contains('provide a valid Quote') ? true : false;
            //System.assertEquals(bExpectedExceptionThrown, true);
        }
        TriggerExecutionController.setSkipAccounttriggers(false);
        Test.stopTest();
    }
    
    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
}