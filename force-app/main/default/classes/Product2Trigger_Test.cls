/************************************************************************
Name: Product2Trigger_Test
Author: Kokilavani
History:
 Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
*1.0     08-May-2011     Kokilavani      Created for CR11414
*2.      29-May-2015     Krishnamoorthi  Updated for CR11506   
*3.0     15-feb-2017     Harsha          Fixed too many SOQL error
*4.0     25-Sep-2017     Azlan           Commented sendEmailToSalesEdge method
*4.1     25-Sep-2017     Azlan           Added SkipAllTriggers to False in new products creation
***********************************************************************/
@isTest(SeeAllData=false)
private class Product2Trigger_Test{

    
    /*    CR11506 - Created below 2 methods,
            testupdProduct2ForStdOpp
            testupdProduct2ForNonStdOpp --  To test the send email to salesedge@dell.com functionality when Product2's Name and Product Code are changed. 
            This method will cover the sendEmailToSalesEdge functionality in the below classes
            Product2TriggerHandler
            Product2Utilities*/
            
    //Test method to update Product2 associated to Standard Opportunity
    static testMethod void testupdProduct2ForStdOpp() {    
    
        Test.startTest(); 
        TriggerExecutionController.setSkipAllTriggers(true);
        Profile adminProfile = [SELECT Id from Profile where Name = 'System Administrator' LIMIT 1];

        User testAdminUser = new User(Username='TestAdmin'+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test 22', 
                                        Email='Test22'+'@dell.com',            
                                        LastName='Test Admin', 
                                        ProfileId = adminProfile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='Adm'+System.currentTimeMillis());
            
        insert testAdminUser;
        
        Profile dataloadProfile = [SELECT Id from Profile where Name = 'IT GBL Data Load' LIMIT 1];

        User testDataloadUser = new User(Username='TestDLR'+ System.currentTimeMillis() +'@dell.com',
                                        Alias = 'Test 22', 
                                        Email='Test22'+'@dell.com',            
                                        LastName='Test DLR', 
                                        ProfileId = dataloadProfile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Badge_Number__c='DLR'+System.currentTimeMillis());
            
        insert testDataloadUser;
        
        Account accTest = new Account(Name='Test Account for Salesedge');        
        insert accTest; 
        
        Contact objCon = new Contact();
        objCon.FirstName = 'Test FName';
        objCon.LastName = 'Test LastName';
        // objCon.CTI_Call_Log_Id__c = objCTICL.Id;
        objCon.AccountId = accTest.Id;
        objCon.Phone = '1234567890';
        objCon.Email = 'test@test.com';
        objCon.MailingCountry = 'US';
        objCon.MailingState = 'CA';
        objCon.MailingPostalCode = '95035';
        insert objCon;
        
        
        //Insert Standard Opportunity
        Opportunity oppTest = new Opportunity(Name='testOpportunity for Salesedge', 
                                                AccountId=accTest.Id, 
                                                StageName='10%',
                                                Quest_Software_Contact__c = objCon.Id,
                                                CloseDate = System.Today() + 30 ); 

        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        insert oppTest;
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        Id pricebookId = Test.getStandardPricebookId();
     
        Product2 newPrdct = new Product2(Name = 'Test Email Product',
                                         ProductCode = 'prdcd123',
                                         Product_ID__c='test prod id1', 
                                         Product_Line_Desc__c = 'Test Product',
                                         DSG_Sales_Motion__c = 'Read only product',
                                         IsActive = TRUE);
       
   //4.1        
        TriggerExecutionController.setSkipAllTriggers(false);
        insert newPrdct; 
        
        Map<Id, Product2> prodMap1 = new Map<Id, Product2>();
        prodMap1.put(newPrdct.Id, newPrdct);

        PricebookEntry PBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pricebookId,
                                                isActive=true,
                                                UnitPrice = 50);
                                                
        insert  PBE;                                    
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =oppTest.Id,
                                                                    pricebookEntryId=PBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        insert  testLineItem;                                                       
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
         
       
        
        Product2 prod2 = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id =: newPrdct.Id];
        
        prod2.Name = 'Test Email Product 2';
        prod2.ProductCode = 'prdcd1234';
        
        Map<Id, Product2> prodMap2 = new Map<Id, Product2> ();
        prodMap2.put(prod2.Id, prod2);

        //Check with Admin User
        System.runAs (testAdminUser){
 
 //4.0 Starts
      /*Boolean hasEmailSent = Product2Utilities.sendEmailToSalesEdge(prodMap1, prodMap2);
        system.assertEquals(true, hasEmailSent); //Email sent for other than data loader profile and for standard Opportunity*/
 //4.0 Ends
        }
        
        
        //Check with "IT GBL Data Load" User
        System.runAs (testDataloadUser){
//4.0 Starts
        /*Boolean hasEmailSent2 = Product2Utilities.sendEmailToSalesEdge(prodMap1, prodMap2);
        system.assertEquals(false, hasEmailSent2); //Email not send for data loader profile*/
 //4.0 Ends
        }
        
        TriggerExecutionController.setSkipAllTriggers(false);
        //Update the Product2 to cover the remaining code in Product2Utilities
        Product2 prod3 = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id =: newPrdct.Id];
        prod3.Name = 'Test Email Product 3';
        prod3.DSG_Sales_Motion__c = 'Bidirectional product';
        update prod3;
        
        Product2 prod4 = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id =: prod3.Id];
        prod4.ProductCode = 'prdcd12345';
        update prod4;
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        //TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        Test.stopTest();        
    } 
    
    //Test method to update Product2 associated to Non-Standard Opportunity
    static testMethod void testupdProduct2ForNonStdOpp() {  
        
        TriggerExecutionController.setSkipAllTriggers(true);
        Account accTest = new Account(Name='Test Account for Salesedge');        
        insert accTest;      
        
        //Insert Non-Standard Opportunity
        Opportunity oppTest = new Opportunity(Name='testOpportunity for Salesedge', 
                                                AccountId=accTest.Id,
                                                RecordTypeId = GlobalVariables.APOS_OPP_RETYPE, 
                                                StageName='10%',
                                                CloseDate = System.Today() + 30 ); 
     
        Test.startTest(); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        insert oppTest;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
     
        Id pricebookId = Test.getStandardPricebookId();
     
        Product2 newPrdct = new Product2(Name = 'Test Email Product',
                                         ProductCode = 'prdcd123',
                                         Product_ID__c='test prod id1', 
                                         Product_Line_Desc__c = 'Test Product',
                                         IsActive = TRUE);
               
        
        insert newPrdct; 
        Map<Id, Product2> prodMap1 = new Map<Id, Product2>();
        prodMap1.put(newPrdct.Id, newPrdct);

        PricebookEntry PBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pricebookId,
                                                isActive=true,
                                                UnitPrice = 50);
                                                
        insert  PBE;                                    
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =oppTest.Id,
                                                                    pricebookEntryId=PBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        insert  testLineItem;                                                       
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        
        Product2 prod2 = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id =: newPrdct.Id];
        
        prod2.Name = 'Test Email Product 2';
        prod2.ProductCode = 'prdcd1234';
        
        Map<Id, Product2> prodMap2 = new Map<Id, Product2> ();
        prodMap2.put(prod2.Id, prod2);

//4.0 Starts        
        /* Boolean hasEmailSent = Product2Utilities.sendEmailToSalesEdge(prodMap1, prodMap2);
           system.assertEquals(false, hasEmailSent); //Email not send for Product2 update associated to Non-Standard Opportunity*/
//4.0 Ends        
        Test.stopTest();        
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //Test method to update active Product2 to inactive
    static testMethod void testToUpdateActiveProductToInactive() {  
        
        TriggerExecutionController.setSkipAllTriggers(true);
        Id pricebookId = Test.getStandardPricebookId();
     
        Product2 newPrdct = new Product2(Name = 'Test Email Product',
                                         ProductCode = 'prdcd123',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id1', 
                                         IsActive = TRUE);
               
        
        insert newPrdct; 
        
        PricebookEntry PBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pricebookId,
                                                isActive=true,
                                                UnitPrice = 50);
                                                
        insert  PBE;                                    
        
        Test.startTest(); 
        
        newPrdct.isActive = FALSE;
        
        update newPrdct;
        
        PricebookEntry foundPBE = [Select isActive from PricebookEntry where Id = :PBE.Id];
        
        system.assertEquals(false, foundPBE.isActive); 
        
        Test.stopTest();        
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
}