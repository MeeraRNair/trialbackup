/* 
History:
Version    Date           Modified By     Description     
1.0        11-Jun-2015    Jiji            Test class for OpportunityApprovalActionPannel
2.0        1-7-2019       Meenu           FY20-DCE-0202   16970   Field Trip clean up for Opportunity (Removed/Commented add_deal_type_overlay_specialist__c,
check_for_cross_border_deals__c,check_for_deal_threshold__c,check_for_other_channel_program__c,
check_for_sales_marketing_programs__c,check_for_specialty_dell_account__c,check_for_specialty_partner__c,
check_for_specialty_product__c,check_for_u_s_fed_mismatch__c,conduct_dell_account_selection__c,
review_lob_awards__c,review_open_opportunity__c field)
29-10-2019  Venugopalachary    Implimented TestDataFactory. 
*/
@isTest
private class OpportunityApprovalActionPannelExt_Test {
    public static list<Account> listAcc;
    Public static list<Opportunity> listOpp;
    @testSetup static void setup(){
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
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'End-User Account');
        insert listAccTDF;
        list<Account> listAccTdf1=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF1;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration-Submitted');
        insert listOppTdf;
    }
    static testMethod void crossBorderTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        listAcc=[select id from Account WHERE RecordType.Name='Partner Account' limit 1];
        listOpp=[SELECT ID From Opportunity LIMIT 1];
        listOpp[0].AccountId=listAcc[0].id;
        Update listOpp;
        test.stopTest();
        PageReference  pr = new PageReference('/apex/OpportunityApprovalActionPannel?Id='+listOpp[0].Id);
        Test.setCurrentPage(pr);
        system.assertNotEquals(listOpp[0].id, null);
        OpportunityApprovalActionPannelExt  controller = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(new Opportunity()));
        controller.okAction();
    }
    static testMethod void accountSelectionTest() {
        triggerexecutioncontroller.setSkipAllTriggers(True);
        test.startTest();
        listAcc=[select id from Account WHERE RecordType.Name='Partner Account' limit 1];
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        listOpp[0].AccountId=listAcc[0].id;
        Update listOpp;
        test.stopTest();
        PageReference  pr = new PageReference('/apex/OpportunityApprovalActionPannel?Id='+listOpp[0].Id);
        Test.setCurrentPage(pr);
        system.assertNotEquals(listOpp[0].id, null);
        OpportunityApprovalActionPannelExt  controller = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(new Opportunity()));
    }
    static testMethod void uSFedMisMatchTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Sales_Channel_Group__c scgRecord = new Sales_Channel_Group__c(Name = 'Fed Mismatch');
        insert scgRecord;
        listAcc=[select id from Account WHERE RecordType.Name='Partner Account' limit 1];
        listAcc[0].Sales_Channel__c = scgRecord.Id;
        update listAcc;
        test.startTest();
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        listOpp[0].AccountId=listAcc[0].ID;
        update listOpp;
        test.stopTest();
        PageReference  pr = new PageReference('/apex/OpportunityApprovalActionPannel?Id='+listOpp[0].Id);
        Test.setCurrentPage(pr);
        system.assertNotEquals(listOpp[0].id, null);
        OpportunityApprovalActionPannelExt  controller = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(new Opportunity()));
    }
    static testMethod void uSFedMisMatchwithPASCTest() {
        TriggerExecutionController.setSkipAllTriggers(true);  
        Sales_Channel_Group__c scgRecord = new Sales_Channel_Group__c(Name = 'Fed Mismatch');
        insert scgRecord;
        listAcc=[select id from Account WHERE RecordType.Name='Partner Account' limit 1];
        listAcc[0].Sales_Channel__c = scgRecord.Id;
        update listAcc; 
        test.startTest();
        Contact con = new Contact(AccountId = listAcc[0].Id, 
                                  Email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev', Lastname = 'UT');
        insert con;
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User(ContactId = con.Id, IsActive = true, 
                          Email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_')+ '@dell.com.fdev', 
                          LanguageLocaleKey = 'ja',
                          LastName = 'UT', Alias = 'UT', 
                          CommunityNickname = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'),
                          TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                          EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, 
                          UserName = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev',
                          Badge_Number__c = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'));
        insert u;
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        system.assertNotEquals(listOpp[0].id, null);
        listOpp[0].AccountId=listAcc[0].id;
        system.runAs(u){
            try{
                update listOpp;
            }
            catch(Exception e){}
        }
        test.stopTest();
        PageReference  pr = new PageReference('/apex/OpportunityApprovalActionPannel?Id='+listAcc[0].Id);
        Test.setCurrentPage(pr);
        OpportunityApprovalActionPannelExt  controller = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(new Opportunity()));
    }
    static testMethod void uSFedMisMatchwithoutMismatchTest() {
        TriggerExecutionController.setSkipAllTriggers(true);  
        Sales_Channel_Group__c scgRecord = new Sales_Channel_Group__c(Name = 'Mismatch');
        insert scgRecord;
        listAcc=[select id from Account WHERE RecordType.Name='Partner Account' limit 1];
        listAcc[0].Sales_Channel__c =scgRecord.Id;
        update listAcc;
        test.startTest();
        Contact con = new Contact(AccountId = listAcc[0].Id, 
                                  Email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev', Lastname = 'UT');
        insert con;
        string strproid = [SELECT id from profile WHERE Name LIKE '%EMEA PRM Portal User (MOSS)' ORDER BY Name DESC NULLS LAST LIMIT 1][0].Id; // Ver 1.0
        User u = new User(ContactId = con.Id, IsActive = true, 
                          Email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_')+ '@dell.com.fdev', 
                          LanguageLocaleKey = 'ja',
                          LastName = 'UT', Alias = 'UT', 
                          CommunityNickname = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'),
                          TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', 
                          EmailEncodingKey = 'ISO-8859-1', ProfileId = strproid, 
                          UserName = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev',
                          Badge_Number__c = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'));
        insert u;
        listOpp=[SELECT ID From Opportunity LIMIT 1];
        listOpp[0].AccountId=listAcc[0].Id;
        system.runAs(u){
            try{
                update listOpp;
            }
            catch(exception e){}
        }
        PageReference  pr = new PageReference('/apex/OpportunityApprovalActionPannel?Id='+listOpp[0].Id);
        Test.setCurrentPage(pr);
        system.assertNotEquals(listOpp[0].id, null);
        OpportunityApprovalActionPannelExt  controller = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(new Opportunity()));
    }
    static testMethod void reviewLOBAwardsTest() {
        TriggerExecutionController.setSkipAllTriggers(true);  
        listAcc=[select id from Account WHERE RecordType.Name='End-User Account' limit 1];
        listAcc[0].Account_Country_Code__c = 'US';
        update listAcc;
        LOB_Administration__c lobAdmin = new LOB_Administration__c(Name = 'TestLOBAdmin');
        insert lobAdmin;
        test.startTest();
        LOB_Registration__c lob = new LOB_Registration__c(Registered_End_User__c = listAcc[0].Id, 
                                                          LOB_registration_status__c = 'Dell(approved)',
                                                          LOB_Name__c = 'Client',
                                                          LOB_Award_Type__c = 'All Account'
                                                         );
        insert lob;
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        listOpp[0].AccountId=listAcc[0].id;
        update listOpp;
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         ProductCode = 'NON PC',
                                         Channel_Product_LOB__c = 'Software',
                                         Product_ID__c = 'sdfbjsd7823',
                                         IsActive = TRUE);
        listProduct2.add(newPrdct);                                 
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            ProductCode = 'UnDefined',
                                            Product_ID__c = 'sdfbjsd78239',
                                            Channel_Product_LOB__c = ' ',
                                            IsActive = TRUE);
        listProduct2.add(newappPrdct);
        try{
            insert listProduct2;
        }
        catch(exception e){}
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=Test.getStandardPricebookId(),
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE);                                        
        PricebookEntry appPBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=Test.getStandardPricebookId(),
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        try{
            listPricebook.add(appPBE);
            insert listPricebook;
        }
        Catch(exception e){}
        List<OpportunityLineItem> listOpplnItem =TestDataFactory.createNOpportunityLineItem(2);
        listOpplnItem[0].Opportunityid =listOpp[0].Id;
        listOpplnItem[0].pricebookEntryId=listPricebook[0].id;
        listOpplnItem[1].Opportunityid =listOpp[0].Id;
        listOpplnItem[1].pricebookEntryId=listPricebook[1].id;
        insert listOpplnItem;
        test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(False); 
        PageReference  pr = new PageReference('/apex/OpportunityApprovalActionPannel?Id='+listOpp[0].Id);
        Test.setCurrentPage(pr);
        system.assertNotEquals(listOpp[0].id, null);
        OpportunityApprovalActionPannelExt  controller = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(new Opportunity()));
    }
    static testMethod void reviewLOBAwardswithoneProdTest() {
        TriggerExecutionController.setSkipAllTriggers(true); 
        listAcc=[SELECT ID FROM Account WHERE RecordType.Name='Partner Account' LIMIT 1];
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        listOpp[0].Accountid=listAcc[0].id;
        update listOpp;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'AppAssure',
                                            ProductCode = 'UnDefined',
                                            Product_ID__c = 'sdfbjsd78237',
                                            Channel_Product_LOB__c = 'Software',
                                            IsActive = TRUE);
        insert newappPrdct;
        PricebookEntry appPBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                   Pricebook2ID=Test.getStandardPricebookId(),
                                                   isActive=true,
                                                   useStandardPrice=false,
                                                   UnitPrice = 50);
        insert appPBE;
        list<OpportunityLineItem> listOppLineItem=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItem[0].Opportunityid=listOpp[0].id;
        listOppLineItem[0].pricebookEntryId=appPBE.id;
        test.startTest();
        insert  listOppLineItem;
        test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false); 
        PageReference  pr = new PageReference('/apex/OpportunityApprovalActionPannel?Id='+listOpp[0].Id);
        Test.setCurrentPage(pr);
        system.assertNotEquals(listOpp[0].id, null);
        OpportunityApprovalActionPannelExt  controller = new OpportunityApprovalActionPannelExt(new ApexPages.StandardController(new Opportunity()));
    }
}