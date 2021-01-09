/**
* Name: SnPDealRegistrationMainClassTestClass
* Author: Patrick Redor
* Date: November 05,2012
* Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           6-dec-2019          Implimented TestDataFactory    

*/
@isTest 
private class SnPDealRegistrationMainClassTestClass {
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static list<OpportunityLineItem> listOppLineItem;
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
        list<Account> listAccTdf=TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        listOppTdf[1].AccountId=listAccTdf[1].id;
        insert listOppTdf;
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(2);
        listOppLineItemTdf[0].OpportunityID=listOppTdf[0].id;
        listOppLineItemTdf[1].OpportunityID=listOppTdf[1].id;
        insert listOppLineItemTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    private static testMethod void snPDealRegistrationMainClassTestMethod() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest(); 
        List<S_P_Vendor_Partner_Information__c> listsvpi = new List<S_P_Vendor_Partner_Information__c>();
        
        S_P_Vendor_Automation__c sva = new S_P_Vendor_Automation__c(Vendor_Name__c = 'Test', 
                                                                    Automation_Type__c = 'Partial Automation', Is_Active__c = true,
                                                                    Key_for_Encoding_and_Decoding__c = 'wEuqbRG0GruFXygWvQ2T3A==', 
                                                                    Integration_Key_Expiration_Days__c = 120);
        insert sva;
        
        Sales_Channel_Group__c testSCG = new Sales_Channel_Group__c (Name = 'Test SCG', Group_ID__c = '12345', 
                                                                     Segment_Name__c = '');
        insert testSCG;
        
        listOpp=[SELECT ID FROM Opportunity LIMIT 2];
        for(Opportunity opp : listOpp){
            opp.CloseDate = System.today();
        }
        update listOpp;
        system.assertNotEquals(listOpp[0].id, null);
        listOppLineItem=[SELECT ID FROM OpportunityLineItem LIMIT 1];
        listsvpi = [SELECT Account_Name__c, Integration_Key__c, S_P_Vendor_Automation_ID__c, Partner_Username__c, Is_Active__c,
                    Country__c, Partner_ID__c, Segment__c FROM S_P_Vendor_Partner_Information__c limit 5];
        for(Integer inti = 0; inti < 2; inti++){
            listsvpi.add(new S_P_Vendor_Partner_Information__c(Account_Name__c = 'testAccount' + inti, 
                                                               Integration_Key__c = '00001993020199553424242' + inti, S_P_Vendor_Automation_ID__c = sva.id,
                                                               Partner_Username__c = 'testAccount' + inti + '@dell.com.vmw', Is_Active__c = true,
                                                               Country__c = 'UNITED STATES',
                                                               Partner_ID__c = '11098' + inti, Segment__c = ''));
            listsvpi.add(new S_P_Vendor_Partner_Information__c(Account_Name__c = 'testAccount' + inti, 
                                                               Integration_Key__c = '00001993020199553424242' + inti, S_P_Vendor_Automation_ID__c = sva.id,
                                                               Partner_Username__c = 'testAccount' + inti + '@dell.com.vmw', Is_Active__c = true,
                                                               Partner_ID__c = '11098' + inti, 
                                                               Country__c = 'UNITED STATES', 
                                                               Segment__c = 'MPA'));
        }
        insert listsvpi;
        list<S_P_Vendors__c> listSpv=new list<S_P_Vendors__c>();
        S_P_Vendors__c sv = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id,
                                               Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                                               Customer_Name__c = 'test', Contact_Name__c = 'test', Phone__c = '9999999', 
                                               Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
                                               City__c = 'test', Zip__c = 'test', Total_NET__c = 76556, 
                                               Country__c = 'UNITED STATES', State__c = 'FL', 
                                               CurrencyIsoCode = 'USD', 
                                               How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
                                               'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'Test'); 
        listSpv.add(sv);
        S_P_Vendors__c sv2 = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id,//opp2.Id,
                                                Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                                                Customer_Name__c = 'test', Contact_Name__c = 'test', Phone__c = '9999999', 
                                                Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
                                                City__c = 'test', Zip__c = 'test', Total_NET__c = 76556, 
                                                Country__c = 'UNITED STATES', State__c = 'FL', 
                                                CurrencyIsoCode = 'USD', 
                                                How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
                                                'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'Test');
        listSpv.add(sv2);
        insert listSpv;
        sva.Expiration_Date__c = System.today().addDays(10);
        update sva;
        list<opportunitylineitem> listOpplnItem = [Select Id,S_P_Registerable__c,Brand_Desc__c from opportunitylineitem limit 2];
        SnPDealRegistrationMainClass.computeSnPProdQuantity(listOpplnItem, listSpv);
        Map<String, S_P_Vendor_Partner_Information__c> mapmspsvpi = new Map<String, S_P_Vendor_Partner_Information__c>();       
        String strsvKey = '';
        for(S_P_Vendor_Partner_Information__c svpi : listsvpi){
            strsvKey = '';
            try { 
                if(sv.Segment_Name__c != null){
                    strsvKey = (sv.S_P_Vendors_Name__c.toLowerCase().trim() + sv.Country__c.toLowerCase().trim() + sv.Segment_Name__c.toLowerCase()).trim();
                }else if(sv.Country__c != null){
                    strsvKey = sv.S_P_Vendors_Name__c.toLowerCase().trim() + sv.Country__c.toLowerCase().trim();
                }
                mapmspsvpi.put(strsvKey, svpi);   
            } catch(NullPointerException npe){
                
            }            
        }
        SnPDealRegistrationMainClass.sendEmailReminderForExpiringPartnerInformation();
        SnPDealRegistrationMainClass.updatePartnerID(sv, mapmspsvpi);
        new SnPRunApexOnceADayClass().execute(null);
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.stopTest();
    }
    static testMethod void snPDealRegistrationMainClassTestMethod2() { 
        TriggerExecutionController.setSkipAllTriggers(true);
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        Test.startTest();
        list<opportunitylineitem> listOpplnItem = [Select Id from opportunitylineitem limit 2];
       
        /*Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newPrdct = new Product2(Name = 'Test Product',Product_Line_Desc__c = 'Test Product',Product_ID__c='test prod id1',IsActive = TRUE);
        listProduct2.add(newPrdct);                                 
        Product2 newappPrdct = new Product2(Name = 'Test Product', Product_Line_Desc__c = 'AppAssure',Product_ID__c='test prod id2', IsActive = TRUE);
        listProduct2.add(newappPrdct);
        insert listProduct2;
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,Pricebook2ID=pbk1, isActive=true, useStandardPrice=false,UnitPrice = 50);
        listPricebook.add(pBE);                                        
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,Pricebook2ID=pbk1, isActive=true, useStandardPrice=false, UnitPrice = 50);
        listPricebook.add(apppBE);
        insert listPricebook; 
        TriggerExecutionController.setSkipAllTriggers(false);
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =listOpp[0].Id,pricebookEntryId=listPricebook[0].id, Mrgn__c =6, Discount_off__c = 7, UnitPrice = 100,Quantity =2,Description = 'Line Description', Service_Support_US__c = 'ProSupport IT - Mission Critical');   
        OpportunityLineItem  testappLineItem = new OpportunityLineItem(Opportunityid =listOpp[0].Id,pricebookEntryId=listPricebook[1].id, Mrgn__c =6, Discount_off__c = 7, UnitPrice = 100,Quantity =2,Description = 'Line Description', Service_Support_US__c = 'ProSupport IT - Mission Critical');   
        listOpplnItem.add(testLineItem);
        listOpplnItem.add(testappLineItem); 
        //TriggerExecutionController.setSkipOpportunityTriggers(true);*/
        TriggerExecutionController.setSkipAllTriggers(false);
        
        // system.assertEquals('Line Description',testappLineItem.Description );
        //insert listOpplnItem;
        Test.stopTest();        
    }
}