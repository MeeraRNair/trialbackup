/*
Author: Raymond Yip

History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      20-Apr-2010    Raymond         Created for CR2561, R11.5
1.1      06-Sept-2010   Nooryati        Modified for CR3366
1.2      14-Dec-2010    Nooryati        CR5530: Provision to maintain the separate EOLs and RTSs by region
2.0      24-July-2015   Azwanti         R16.07: fix test class due to Too Many SOQL statement error

*/
@isTest
private class BatchUpdateOpptyForEOLProductTest2 {

    public static testmethod void BatchUpdateOpptyForEOLProductExecuteTest() {
        
        Opportunity testOppty = new Opportunity(Name='TEST Oppty 1', recordtypeid='012A0000000Tehs',Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Propose - 60%', Probability = 60, CloseDate = System.today() + 2, Primary_Product_Delivery_Address_Region__c = 'EMEA');
        //Opportunity testOppty = new Opportunity(Name='TEST Oppty 1', recordtypeid='012A0000000Tehs',Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Propose - 60%', Probability = 60, CloseDate = System.today() , Primary_Product_Delivery_Address_Region__c = 'EMEA');
        
        //To test when EOL 0 Days is already populated
        Date tempDate = System.today() - 30;
        Opportunity testOppty2 = new Opportunity(Name='TEST Oppty 2', recordtypeid='012A0000000Tehs',Skip_Calculate_LOT_OCEAN__c=true, EOL_0_Day_Email_Notification__c = tempDate, StageName = 'Propose - 60%', Probability = 60, CloseDate = System.today() + 4, Primary_Product_Delivery_Address_Region__c = 'EMEA');
                   
        List<Opportunity> testOpptyList = new List<Opportunity>();
        testOpptyList.add(testOppty);
        testOpptyList.add(testOppty2);
        
        //skip all the triggers to avoid Too Many SOQL Query issue
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testOpptyList;
        System.debug('testOpptyList: ' + [select Id, Name, CloseDate, StageName from Opportunity where Id in :testOpptyList]);
        
        List<Product2> testProdList = new List<Product2>();
        Product2 testProd1 = new Product2(Name='Test Product', Product_ID__c='xxyyzz1', EOL_Date_EMEA__c = System.today().addDays(30));
        testProdList.add(testProd1);
        
        Product2 testProd2 = new Product2(Name='Test Product', Product_ID__c='xxyyzz2', EOL_Date_EMEA__c = System.today().addDays(7));
        testProdList.add(testProd2);
        
        Product2 testProd3 = new Product2(Name='Test Product', Product_ID__c='xxyyzz3', EOL_Date_EMEA__c = System.today() - 29);
        testProdList.add(testProd3);
        
        Product2 testProd4 = new Product2(Name='Test Product', Product_ID__c='xxyyzz4', EOL_Date_EMEA__c = System.today().addDays(15));
        testProdList.add(testProd4);
        
        insert testProdList;
        System.debug('testOpptyList: ' + [select Id, Name, EOL_Date_EMEA__c from Product2 where Id in :testProdList]);
        
        System.debug('###DEBUG### testProd1 = ' + testProd1);
        System.debug('###DEBUG### testProd2 = ' + testProd2);
        System.debug('###DEBUG### testProd3 = ' + testProd3);
        System.debug('###DEBUG### testProd4 = ' + testProd4);        
        
        PriceBook2 standardPB = [SELECT Id FROM PriceBook2 WHERE IsStandard = TRUE];
        System.debug('###DEBUG### standardPB = ' + standardPB);
        
        PriceBook2 testPB = new PriceBook2(Name='Test PriceBook');
        insert testPB;
       
        PriceBookEntry pbes1 = new PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = testProd1.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
        PriceBookEntry pbes2 = new PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = testProd2.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
        PriceBookEntry pbes3 = new PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = testProd3.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
        PriceBookEntry pbes4 = new PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = testProd4.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
        
        PriceBookEntry pbe1 = new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd1.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);      
        PriceBookEntry pbe2 = new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd2.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);
        PriceBookEntry pbe3 = new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd3.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);
        PriceBookEntry pbe4 = new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd4.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);
        
        List<PriceBookEntry> pbesList = new List<PriceBookEntry>();
        pbesList.add(pbes1);
        pbesList.add(pbes2);
        pbesList.add(pbes3);
        pbesList.add(pbes4);
        insert pbesList;
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();       
        pbeList.add(pbe1);
        pbeList.add(pbe2);
        pbeList.add(pbe3);
        pbeList.add(pbe4);
        insert pbeList;
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for(integer i=1; i <= 5; i++) {
            oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId=testOpptyList[0].Id, quantity=80, unitPrice=80 ));
            oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe2.Id, OpportunityId=testOpptyList[0].Id, quantity=80, unitPrice=80 ));
            //oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe3.Id, OpportunityId=testOpptyList[0].Id, quantity=80, unitPrice=80 ));
            oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe4.Id, OpportunityId=testOpptyList[0].Id, quantity=80, unitPrice=80 ));
        }
        
        //To test when EOL 0 Days is already populated
        oliList.add(new OpportunityLineItem(PriceBookEntryId = pbe1.Id, OpportunityId=testOpptyList[1].Id, quantity=80, unitPrice=80 ));
        insert oliList; 
        
        BatchUpdateOpptyForEOLProduct2 temp = new BatchUpdateOpptyForEOLProduct2();
        
        temp.isTest = true;
        temp.testOpptyId = testOppty.Id;
        
        //revert back the skip all triggers before start test
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.StartTest();   
        BatchUpdateOpptyForEOLProductExecute2.executeBatch(temp);
        Test.StopTest();
        
        String query = 'SELECT Id, Name, EOL_30_Day_Email_Notification__c,' + 
                                'EOL_7_Day_Email_Notification__c,' +
                                'EOL_15_Day_Email_Notification__c,' + 
                                'EOL_0_Day_Email_Notification__c ' + 
                                'FROM Opportunity WHERE Id = \'' + testOppty.Id + '\'';
        System.debug('###DEBUG### query = ' + query);
        Opportunity result = database.query(query);
        
        System.debug('###DEBUG### result = ' + result);
        System.debug('###DEBUG### EOL_30_Day_Email_Notification__c = ' + result.EOL_30_Day_Email_Notification__c);
        System.debug('###DEBUG### EOL_15_Day_Email_Notification__c = ' + result.EOL_15_Day_Email_Notification__c);
        System.debug('###DEBUG### EOL_7_Day_Email_Notification__c = ' + result.EOL_7_Day_Email_Notification__c);
        System.debug('###DEBUG### EOL_0_Day_Email_Notification__c = ' + result.EOL_0_Day_Email_Notification__c);
     //   System.assert(result.EOL_30_Day_Email_Notification__c != null);
     //   System.assert(result.EOL_15_Day_Email_Notification__c != null);
      //  System.assert(result.EOL_7_Day_Email_Notification__c != null);
        //System.assert(result.EOL_0_Day_Email_Notification__c != null);
        
        String query2 = 'SELECT Id, Name, EOL_30_Day_Email_Notification__c,' + 
                                'EOL_15_Day_Email_Notification__c,' +
                                'EOL_7_Day_Email_Notification__c,' + 
                                'EOL_0_Day_Email_Notification__c ' + 
                                'FROM Opportunity WHERE Id = \'' + testOppty2.Id + '\'';
        System.debug('###DEBUG### query = ' + query2);
        Opportunity result2 = database.query(query2);
        
        System.assertNotEquals(tempDate, result.EOL_0_Day_Email_Notification__c);
        
    }
    
    public static testmethod void productIsActiveSetToFalseTest() {
        
        List<Product2> testProdList = new List<Product2>();
        Product2 testProd1 = new Product2(Name='Test Product 1', Product_ID__c='xxyyzz9', IsActive = TRUE, EOL_Date_EMEA__c = System.today().addDays(30));
        testProdList.add(testProd1);
        
        Product2 testProd2 = new Product2(Name='Test Product 2', Product_ID__c='xxyyzz10', IsActive = TRUE, EOL_Date_EMEA__c = System.today().addDays(7));
        testProdList.add(testProd2);
        
        Product2 testProd3 = new Product2(Name='Test Product 3', Product_ID__c='xxyyzz8',  IsActive = TRUE, EOL_Date_EMEA__c = System.today().addDays(15));
        testProdList.add(testProd3);
        
        insert testProdList;
        
        System.debug('###DEBUG### testProd1 = ' + testProd1);
        System.debug('###DEBUG### testProd2 = ' + testProd2);
        System.debug('###DEBUG### testProd3 = ' + testProd3);
        
        System.assert(testProd1.IsActive);
        System.assert(testProd2.IsActive);
        System.assert(testProd3.IsActive);
        
        PriceBook2 standardPB = [SELECT Id FROM PriceBook2 WHERE IsStandard = TRUE];
        System.debug('###DEBUG### standardPB = ' + standardPB);
        
        PriceBook2 testPB = new PriceBook2(Name='Test PriceBook');
        insert testPB;
        
        PriceBookEntry pbes1 = new PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = testProd1.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
        PriceBookEntry pbes2 = new PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = testProd2.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
        PriceBookEntry pbes3 = new PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = testProd3.Id, IsActive=TRUE, UnitPrice = 8, UseStandardPrice = FALSE);
                
        PriceBookEntry pbe1 = new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd1.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);      
        PriceBookEntry pbe2 = new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd2.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);
        PriceBookEntry pbe3 = new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProd3.Id,IsActive=TRUE, UnitPrice = 8, UseStandardPrice = TRUE);
                
        List<PriceBookEntry> pbesList = new List<PriceBookEntry>();
        pbesList.add(pbes1);
        pbesList.add(pbes2);
        pbesList.add(pbes3);
        insert pbesList;
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();       
        pbeList.add(pbe1);
        pbeList.add(pbe2);
        pbeList.add(pbe3);
        insert pbeList;       
        
        System.assert([SELECT Count() FROM PriceBookEntry WHERE Product2Id IN (:testProd1.Id, :testProd2.Id, :testProd3.Id) AND IsActive = TRUE] > 0);
        
        Test.StartTest(); 
            List<Product2> inactiveProdList = new List<Product2>();
            testProd1.IsActive = false;
            testProd2.IsActive = false;
            testProd3.IsActive = false;
            
            inactiveProdList.add(testProd1);
            inactiveProdList.add(testProd2);
            inactiveProdList.add(testProd3);

            update inactiveProdList;
        Test.StopTest();

        System.assertEquals(0, [SELECT Count() FROM PriceBookEntry WHERE Product2Id IN (:testProd1.Id, :testProd2.Id, :testProd3.Id) AND IsActive = TRUE]);

    }
}