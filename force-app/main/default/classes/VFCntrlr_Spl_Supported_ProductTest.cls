/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         10618                                       Hari Jakkala
2.0         16136       FY19-DCE-0802   13-July-2018    Venkat Sharan   Removed seeAllData and fixed test class as part of the story 5240538
3.0                     0102            29-10-2019      venu            Implimented TestDataFactory.  
*/
@isTest
private class VFCntrlr_Spl_Supported_ProductTest {
    static PricebookEntry pricebookEntry;
    static Product2 product;
    public static list<OpportunityTeamMember> listotmFound;
    public static list<OpportunityLineItem> listoliFound;
    public static Specialist_Supported_Products__c objSplSupporPrd;       
    Public Static String strotmid;    
    public static list<account> listAcc;
    public static list<Opportunity> listOpp;
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
        insert listAccTDF;  
        
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        insert listOppTdf;
    }
    static testMethod void myUnitTest(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        createProduct();
        createData();
        
        objSplSupporPrd = new Specialist_Supported_Products__c();
        PageReference pageRef = Page.VFSpecialistSupportedProduct;
        Test.setCurrentPage(pageRef);
        
        Specialist_Supported_Products__c ssp = [select Id, Opportunity__c, Opportunity_Team_Member__c, Product__c, Supporting__c, Opportunity_Team_Member__r.Name, Product__r.Name, Product__r.Product_Line_Desc__c from Specialist_Supported_Products__c limit 1];
        Opportunity foundOpportunity1 = [SELECT id FROM Opportunity o limit 1];
        ApexPages.currentPage().getParameters().put('oppId',foundOpportunity1.Id);
        ApexPages.currentPage().getParameters().put('sspId',ssp.Id);
        // Added by Hari
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.startTest();
        VFCntrlr_Specialist_Supported_Product controller = new  VFCntrlr_Specialist_Supported_Product();
        ApexPages.currentPage().getParameters().put('oppId', foundOpportunity1.Id);
        controller.oppTeamMemSelected = '--None--';
        controller.oppProductsSelected = '--None--';
        controller.oppId = foundOpportunity1.Id;
        controller.getOppProductsList();
        controller.getOppTeamMembersList();
        controller.getCanProceed();
        controller.nextAction();
        
        controller.cancelListView();
        controller.cancel();
        
        controller.oppTeamMemSelected = UserInfo.getName();
        controller.oppProductsSelected = product.Name;
        controller.nextAction();
        
        //Add records to wrapper list and call createordeletemethod
        controller.currentSplSupportPrdMap.put(UserInfo.getUserId() + '_' + product.Id, new VFCntrlr_Specialist_Supported_Product.specialistSupportPrdWrapper(listotmFound[0], listoliFound[0], 'Yes'));
        controller.nextAction();
        controller.getSupporingPicklistItems();
        controller.oppTeamMemListToLoad = listotmFound;
        controller.oppPrdListToLoad = listoliFound;
        controller.nextAction();
        controller.Save();
        controller.currentSplSupportPrdMap.put(UserInfo.getUserId() + '_' + product.Id, new VFCntrlr_Specialist_Supported_Product.specialistSupportPrdWrapper(objSplSupporPrd));
        
        controller.oppTeamMemId = '';
        controller.oppTeamMemListToLoad= listotmFound;
        
        controller.nextAction();
        controller.Save();
        system.assertEquals(true,controller.getCanProceed());
        system.assertEquals(UserInfo.getUserId(),controller.splSuppotedPrdList[0].specialist_Supported_Product.Opportunity_Team_Member__c);
        system.assertEquals('Test Product 1',controller.splSuppotedPrdList[0].specialist_Supported_Product.Product__r.Name);
        
        Test.stopTest(); 
    }
    public static void createData(){    
        list<Account> listAcc=[SELECT ID FROM Account Limit 1];
        list<Opportunity> listOpp=[SELECT ID FROM Opportunity Limit 1];
        listOpp[0].AccountID=listAcc[0].Id;
        listOpp[0].Skip_Calculate_LOT_OCEAN__c = true;
        update listOpp;
        Opportunity foundOpportunity1 = [SELECT  id FROM Opportunity o WHERE o.Id =:listOpp[0].Id];
        list<OpportunityLineItem> listOppLineItem=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItem[0].opportunityid=listOpp[0].id;
        listOppLineItem[0].pricebookentryid = pricebookEntry.Id;
        
        OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = listOpp[0].id,
                                                              UserId = UserInfo.getUserId(),
                                                              TeamMemberRole = 'FM');                                      
        Specialist_Supported_Products__c ssp = new Specialist_Supported_Products__c(Opportunity__c = listOpp[0].id, 
                                                                                    Opportunity_Team_Member__c = UserInfo.getUserId(), 
                                                                                    Product__c = product.Id, 
                                                                                    Supporting__c = 'Yes');
        
        TriggerControlHandler.setOpportunityTriggersInactive();         
        insert listOppLineItem;
        insert otm;         
        insert ssp;
        strotmid= otm.id;   
        
        listotmFound = [SELECT UserId, User.Name FROM OpportunityTeamMember WHERE OpportunityId=: listOpp[0].id ORDER BY User.Name];
        listoliFound = [Select Id, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, PricebookEntry.Product2.Product_Line_Desc__c From OpportunityLineItem WHERE OpportunityId=: listOpp[0].id];
        objSplSupporPrd = [select Id, Opportunity__c, Opportunity_Team_Member__c, Product__c, Supporting__c, Opportunity_Team_Member__r.Name, Product__r.Name, Product__r.Product_Line_Desc__c from Specialist_Supported_Products__c where Opportunity__c=: listOpp[0].id limit 1];
        
        TriggerControlHandler.setOpportunityTriggersActive(); 
    }
    
    static void createProduct(){
        
        product = new Product2(name = 'Test Product 1', Product_ID__c='test prod id1', family = 'Services', isActive = true, Dgr_Eligible__c = 'Yes');
        insert product;
        
        Id pb = Test.getStandardPricebookId();
        
        pricebookEntry = new PricebookEntry(pricebook2id = pb,
                                            product2id = product.id, unitprice = 1000.0, isActive = true);
        insert pricebookEntry;
    }     
}