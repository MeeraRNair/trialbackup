@isTest
private class ChannelLOBchangeonproduct_test{
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<case> listCaseTDF=TestDataFactory.createNCases(1);
        insert listCaseTDF;
        list<Account> listAccTDF=TestDataFactory.createNAccount(2, 'Partner Account');
        insert listAccTDF;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration');
        insert listOppTdf;
        Contact partnerContact = new Contact(FirstName = 'MyTestContact',
                                             LastName = 'MyTestContact',
                                             AccountId =listAccTDF[0].Id,
                                             Status__c  =  'Marketing Suspect',
                                             Email = 'dealregTestContact@dell.com',
                                             Fax = '1234567',
                                             MobilePhone = '0987654',
                                             Last_Operation_Performed__c = 'testing',
                                             Phone = '1234500');
        insert partnerContact;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where Name like '%PRM Portal User%' limit 1];
        list<User> listUserTDF = TestDataFactory.createNPortalUser(1);
        listUserTDF[0].ProfileId=partnerProfiles[0].id;
        listUserTDF[0].ContactId=partnerContact.id;
        insert listUserTDF;
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Channel_Product_LOB__c = 'Client',
                                         Product_ID__c='test prod id1',
                                         IsActive = TRUE);
        listProduct2.add(newPrdct );                              
        Product2 newPrdcttwo = new Product2(Name = 'Test Product',
                                            Product_Line_Desc__c = 'Test Product',
                                            Product_ID__c='test prod id2',
                                            Channel_Product_LOB__c = 'Networking, Storage',
                                            DGR_Eligible__c = 'Yes',
                                            IsActive = TRUE);
        listProduct2.add(newPrdcttwo);
        
        insert listProduct2;  
        list<id> listproids = new List<id>();
        listproids.add(newPrdct.id);
        listproids.add(newPrdcttwo.id);
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry pBEone = new PricebookEntry (Product2ID=listProduct2[0].id,
                                                    Pricebook2ID=pbk1,
                                                    isActive=true,
                                                    useStandardPrice=false,
                                                    UnitPrice = 50);
        listPricebook.add(pBEone);
        PricebookEntry pBEtwo = new PricebookEntry (Product2ID=listProduct2[1].id,
                                                    Pricebook2ID=pbk1,
                                                    isActive=true,
                                                    useStandardPrice=false,
                                                    UnitPrice = 50);
        listPricebook.add(pBEtwo);
        
        insert listPricebook;
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(2);
        listOppLineItemTdf[0].Opportunityid=listOppTdf[0].id;
        listOppLineItemTdf[1].Opportunityid=listOppTdf[0].id;
        listOppLineItemTdf[0].pricebookEntryId=listPricebook[0].id;
        listOppLineItemTdf[1].pricebookEntryId=listPricebook[1].id;
        insert listOppLineItemTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
    static testMethod void channelLOBchangeonproducttestmethod(){
        list<Account> listAcc=[select id from Account Limit 1];
        TriggerExecutionController.setSkipAllTriggers(true); 
        system.assertNotEquals(listAcc[0].id, null);
        list<User> listUser=[select id from User Limit 1];
        system.runAs(listUser[0]){
            list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        }    
        list<OpportunityLineItem> listOppLineItem=[select id,Product2id from OpportunityLineItem Limit 2];
        list<id> listproids1 = new List<id>();
        for(OpportunityLineItem opl : listOppLineItem){
            listproids1.add(opl.Product2id);
        }
        ChannelLOBchangeonproduct.specialityQueue(listproids1);
    }
}