/***********************************************************
* Name          : SnPUtilsTest
* Description   : All methods for S&P Vendor
* ---------------------------------------------------------
* Revision      Release  Name    Date            Description
* 1.0           11.10   MenMee  09.08.2010    CR2688 Migrate Dell Portal functionality to SFDC to capture Software and Peripherals deals          
* 1.1                   MenMee  29.11.2010    Review Test Cases - (reverted)
* 2.0           12.1    MenMee  07.12.2010    CR5540 Multicurrencies
* 2.1           12.1    MenMee  16.12.2010    CR4444 Addition of Distributor field in S&P DR Criteria object
* 2.2           12.1    MenMee  14.01.2011    Create RT for Criteria object. Distributor field will based on RT.
* 2.3           12.1    MenMee  01.02.2011    Defect67600 cater for case sensitive in map collection
* 3.0           12.7    MenMee  06.07.2011    CR 6253 Expiration date email notification 
* 3.1           12.7    MenMee  25.07.2011    Defect71565 include brand desc into criteria filter
* 3.2                   Jiji    09.07.2012    CR7326 Test class for SonicWall Product Insert
* 4.0           16.03   Shue    14.02.2015    Fix assertEquals & too many SOQL
* 4.1           16.03   Meghana 19.03.2015    Revert changes done for CR 10826---as per CRQ1166 changes are descoped in 16.03
*4.2            0102    Monisha  06.01.2020   Ignoring the test class to excute to opportunitysplit trigger.
************************************************************/
@isTest (SeeAllData=false)
private class SnPUtilsTest {
  static List<OpportunityLineItem> testOLIList2 = new List<OpportunityLineItem>();
  static List<OpportunityLineItem> testOLIList3 = new List<OpportunityLineItem>();
  static List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
  static List<User> testUserList = new List<User>();
  static List<Opportunity> testOppList = new List<Opportunity>();
  static Opportunity testOpp;
  static Opportunity testOpp2;
  static Opportunity testOpp3;
  static Sales_Channel_Group__c testSCG;
    
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
        OWD__c OWDsetting = new OWD__c();
        OWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        OWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        OWDsetting.Oppty_Stage100__c = 'Win - 100%';
        OWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        OWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        OWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        OWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        OWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert OWDsetting;
    }
    //4.2 Declaring the string variable to pass only the triggers that should be excuted on after update and insert.
    public static String strMockMetaData = '';
    
    //Test Case 1: Insert Qualified Opp Product (Acrobat & CS)
    //Expected: Opp Prod and Vendor is Qualified  
/*
    static testMethod void calculateQualifiedSnPDRProg_insertSnPOppProd() {
        List<OpportunityLineItem> testOLIList = new List<OpportunityLineItem>();
                    
        TestDataCreation();               
        //createOppLineItem (false);
        
        System.debug('########## START calculateQualifiedSnPDRProg_insertSnPOppProd ##########');               
          
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[0].Id, OpportunityId=testOpp.Id, quantity=4, UnitPrice=100, Mrgn__c = 1 )); //Adobe:Acrobat - New
     //   testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[1].Id, OpportunityId=testOpp.Id, quantity=1, UnitPrice=1, Mrgn__c = 1 )); //Adobe:Acrobat - Update
     //   testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[2].Id, OpportunityId=testOpp.Id, quantity=4, UnitPrice=100, Mrgn__c = 1 )); //Adobe:Creative Suites
    
        Test.startTest(); 
        
        insert testOLIList;           
       
        List<S_P_Vendors__c> actualVendorList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, Qualified_Product_Line_Desc__c, Product_Line_Desc__c, Missing_Segment__c, 
                    PM1__c, PM2__c, PM3__c, PM4__c, PM5__c, Special_Instructions__c, Total_NET__c  FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOpp.Id];
  
        //Rev 3.0
        actualVendorList[0].S_P_Deal_Status__c = 'Approved';
        actualVendorList[0].Deal_Expiration_Date__c = Date.today() + 7;
        actualVendorList[0].Vendor_Approval_Number__c = '12345';
        update actualVendorList;
    
        Test.stopTest();

        List<OpportunityLineItem> actualOliList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, quantity, totalprice FROM OpportunityLineItem WHERE Id IN (:testOLIList[0].Id, :testOLIList[1].Id, :testOLIList[2].Id)];
     
        actualVendorList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, Qualified_Product_Line_Desc__c, Product_Line_Desc__c, Missing_Segment__c, 
                    PM1__c, PM2__c, PM3__c, PM4__c, PM5__c, Special_Instructions__c, Total_NET__c,Send_Notification__c  FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOpp.Id];
                         
        System.assertEquals('Yes', actualOLIList[0].Qualified_for_S_P_Deal_Reg_Program__c); //Acrobat - New
        System.assertEquals('Yes', actualOLIList[1].Qualified_for_S_P_Deal_Reg_Program__c); //Acrobat - Update
        System.assertEquals('Yes', actualOLIList[2].Qualified_for_S_P_Deal_Reg_Program__c); //CS
                   
        System.assertEquals(1, actualVendorList.size());                
        System.assertEquals('Yes', actualVendorList[0].Qualified_for_S_P_Deal_Reg_Program__c);
        //System.assertEquals(';creative suites;;acrobat;', actualVendorList[0].Qualified_Product_Line_Desc__c); 
        System.assert(StringUtils.contains(actualVendorList[0].Qualified_Product_Line_Desc__c, ';acrobat;'));
        System.assert(StringUtils.contains(actualVendorList[0].Qualified_Product_Line_Desc__c, ';creative suites;'));         
        System.assertEquals(false, actualVendorList[0].Missing_Segment__c);
        System.assertEquals('Testing', actualVendorList[0].Special_Instructions__c);
        System.assertEquals(true, actualVendorList[0].Send_Notification__c);           
        System.debug('totalnet: '+actualVendorList[0].Total_NET__c);       

        System.debug('########## END calculateQualifiedSnPDRProg_insertSnPOppProd ##########');
    }
    */
    /*
    //Test Case 2: Edit quantity of (Acrobat)
  //Expected: Acrobat becomes unQualified, CS and vendor remains as Qualified 
    static testMethod void calculateQualifiedSnPDRProg_editSnPOppProd() {
                
        TestDataCreation();             
        createOppLineItem(false);
        System.debug('########## START calculateQualifiedSnPDRProg_editSnPOppProd ##########');
        
        Test.startTest();
        OpportunityLineItem oli1 = testOLIList2[0];
        oli1.Quantity = 1;
        update oli1;
        Test.stopTest();
        
        List<OpportunityLineItem> actualOliList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, quantity, totalprice FROM OpportunityLineItem WHERE Id IN (:testOLIList2[0].Id, :testOLIList2[1].Id) ];
     
        List<S_P_Vendors__c> actualVendorList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, Qualified_Product_Line_Desc__c, Product_Line_Desc__c, Missing_Segment__c, 
                    PM1__c, PM2__c, PM3__c, PM4__c, PM5__c, Total_NET__c  FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOpp2.Id];
        
        System.assertEquals('No', actualOliList[0].Qualified_for_S_P_Deal_Reg_Program__c); //Acrobat
        System.assertEquals('Yes', actualOliList[1].Qualified_for_S_P_Deal_Reg_Program__c); //CS
            
        System.assertEquals('Yes', actualVendorList[0].Qualified_for_S_P_Deal_Reg_Program__c);        
        System.assert(!StringUtils.contains(actualVendorList[0].Qualified_Product_Line_Desc__c, ';acrobat;'));
        System.assert(StringUtils.contains(actualVendorList[0].Qualified_Product_Line_Desc__c, ';creative suites;'));    
        
        System.debug('########## END calculateQualifiedSnPDRProg_editSnPOppProd ##########');       
    }   
    
    //Test Case 3: Delete All Opp Prod
    //Expected: Vendor also get deleted from Opp 
    static testMethod void calculateQualifiedSnPDRProg_deleteSnPOppProd() {
                
        TestDataCreation();             
        createOppLineItem(false);
       
        System.debug('########## START calculateQualifiedSnPDRProg_deleteSnPOppProd ##########');
        
        Test.startTest();
        delete testOLIList2;        
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Count() FROM OpportunityLineItem WHERE Id IN :testOLIList2]);
        System.assertEquals(0, [SELECT Count() FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOpp2.Id]);
        
        System.debug('########## END calculateQualifiedSnPDRProg_deleteSnPOppProd ##########');       
    }    
    
    //Test Case 4: a) Add un-SnP Opp Prod, b) Can't find criteria for SnP Opp Prod 
    //Expected: Opp Prod is unqualified, no vendor created for this Opp Prod
    static testMethod void calculateQualifiedSnPDRProg_nonSnPOppProd() {
                
        List<OpportunityLineItem> testOLIList = new List<OpportunityLineItem>();
                    
        TestDataCreation();               
        createOppLineItem(false);
        
        System.debug('########## START calculateQualifiedSnPDRProg_nonSnPOppProd ##########');               
          
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[3].Id, OpportunityId=testOpp.Id, quantity=4, UnitPrice=100, Mrgn__c = 1 )); //Acronis: Can't find criteria
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[4].Id, OpportunityId=testOpp.Id, quantity=4, UnitPrice=100, Mrgn__c = 1 )); //Non Tied Enterprise: non-SnP
    
        Test.startTest(); 
        insert testOLIList;           
        Test.stopTest();
        
        List<OpportunityLineItem> actualOliList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, quantity, totalprice FROM OpportunityLineItem WHERE Id IN (:testOLIList[0].Id,:testOLIList[1].Id)];
             
        System.assertEquals('No', actualOLIList[0].Qualified_for_S_P_Deal_Reg_Program__c); //Acronis
        System.assertEquals(null, actualOLIList[1].Qualified_for_S_P_Deal_Reg_Program__c); //Non Tied Enterprise

        System.assertEquals(1, [SELECT Count() FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOpp2.Id]); //Vendor for Acrobat
    
        System.debug('########## END calculateQualifiedSnPDRProg_nonSnPOppProd ##########');       
    } 
  
    //Test Case 5: Remove Segment and Refresh  
    //Expected: Missing segment = true, Opp Prod becames unqualified
    static testMethod void calculateQualifiedSnPDRProg_missingSegment() {
                 
        List<OpportunityLineItem> testOLIList = new List<OpportunityLineItem>();
                    
        TestDataCreation();      
        createOppLineItem(false);
                 
        testSCG.Segment_Name__c = '';
        update testSCG;
    
        System.debug('########## START calculateQualifiedSnPDRProg_missingSegment ##########');               

        List<Opportunity> testOpptyList = [SELECT Id, CloseDate, CreatedDate, CurrencyIsoCode, Primary_Product_Delivery_Address_Region__c, 
                        Primary_Product_Delivery_Address_Country__c, Account.Segment_Name_lookup__c 
                   FROM Opportunity WHERE Id=:testOpp2.Id];
        Test.startTest(); 
        SnpUtils.recalculateQualifiedSnPDRProg(testOpptyList[0]);           
              
        List<OpportunityLineItem> actualOliList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, quantity, totalprice FROM OpportunityLineItem WHERE Id IN (:testOLIList2[0].Id, :testOLIList2[1].Id)];
     
        List<S_P_Vendors__c> actualVendorList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, Qualified_Product_Line_Desc__c, Product_Line_Desc__c, Missing_Segment__c, 
                    PM1__c, PM2__c, PM3__c, PM4__c, PM5__c, Total_NET__c  FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOpp2.Id];
        
        System.assertEquals('No', actualOliList[0].Qualified_for_S_P_Deal_Reg_Program__c); //Acrobat
        System.assertEquals('Yes', actualOliList[1].Qualified_for_S_P_Deal_Reg_Program__c); //CS
            
        System.assertEquals('Yes', actualVendorList[0].Qualified_for_S_P_Deal_Reg_Program__c);
        System.assertEquals(true, actualVendorList[0].Missing_Segment__c);        
        System.assertEquals(';creative suites;', actualVendorList[0].Qualified_Product_Line_Desc__c);       

        delete testOLIList2[0];        
        Test.stopTest();
        
        System.assertEquals('Creative Suites', [SELECT Product_Line_Desc__c FROM OpportunityLineItem WHERE Id IN :testOLIList2][0].Product_Line_Desc__c);
        System.assertEquals(false, [SELECT Missing_Segment__c FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOpp2.Id][0].Missing_Segment__c);
                    
        System.debug('########## END calculateQualifiedSnPDRProg_missingSegment ##########');       
    }    
*/
    //Test Case 6:  
    //Expected: Missing segment remains true
  
    static testMethod void calculateQualifiedSnPDRProg_reCheckMissingSegment() {
    
    //4.2 Execute only the triggers that should be excuted on after update and insert of Opportunity and OLI.
  
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
              'BeforeUpdate' => new List<Boolean>{true, true, false, false, false},
              'BeforeInsert' => new List<Boolean>{true, false, true, false, false},
              'BeforeDelete' => new List<Boolean>{true, false, false, true, false}
        };

        for(String strEvent : mapEvents.keySet()) {
                if(strEvent=='BeforeUpdate'){
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
           }
           if(strEvent=='BeforeInsert'){
               strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBI"},'; 
           } 
           if(strEvent=='BeforeDelete'){
               strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBD"},';
           } 
           }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';  
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        //4.2 ENDS
                
        List<OpportunityLineItem> testOLIList = new List<OpportunityLineItem>();          
        TestDataCreation();
        createOppLineItem(true);
        
        system.debug('@@@@@ A. Limits.getQueries() - ' + Limits.getQueries());             
        testSCG.Segment_Name__c = '';
        update testSCG;
        system.debug('@@@@@ B. Limits.getQueries() - ' + Limits.getQueries());
      
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[0].Id, OpportunityId=testOppList[0].Id, quantity=4, UnitPrice=100, Mrgn__c = 1 )); //Adobe:Acrobat
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[2].Id, OpportunityId=testOppList[0].Id, quantity=4, UnitPrice=100, Mrgn__c = 1 )); //Adobe:Creative Suites
        //insert testOLIList; 
        system.debug('@@@@@ C. Limits.getQueries() - ' + Limits.getQueries());        
    
        System.debug('########## START calculateQualifiedSnPDRProg_reCheckMissingSegment ##########');               

        //System.assertEquals(true, [SELECT Missing_Segment__c FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOppList[0].Id][0].Missing_Segment__c);
        system.debug('@@@@@ D. Limits.getQueries() - ' + Limits.getQueries());
    
        //Test.startTest();
        //delete testOLIList2[1];        
        //Test.stopTest();
        system.debug('@@@@@ E. Limits.getQueries() - ' + Limits.getQueries());
        
        //System.assertEquals('Acrobat', [SELECT Product_Line_Desc__c FROM OpportunityLineItem WHERE Id IN :testOLIList][0].Product_Line_Desc__c);
        //System.assertEquals(true, [SELECT Missing_Segment__c FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOppList[0].Id][0].Missing_Segment__c);
        System.debug('########## END calculateQualifiedSnPDRProg_reCheckMissingSegment ##########');           
    }    
    /*
    //Rev 2.0
    //Test Case 7: Multicurrencies
    //Expected: Opp Prod with EUR also qualified  
    static testMethod void calculateQualifiedSnPDRProg_multicurrencies() {
        List<OpportunityLineItem> testOLIList = new List<OpportunityLineItem>();
                    
        TestDataCreation();  
        //Account
        Account testAcc3 = new Account(Name = 'Test Account multicurrencies', Sales_Channel__c = testSCG.Id);
        insert testAcc3;
              
        //Opportunity
        testOpp3 = new Opportunity(Name='Test Opp multicurrencies', recordtypeid='012A0000000Tehs', Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Discover - 10%', CloseDate = System.today() + 30,
                Primary_Product_Delivery_Address_Region__c = 'APJ', Primary_Product_Delivery_Address_Country__c = 'MALAYSIA', AccountId = testAcc3.Id, CurrencyISOCode = 'EUR');
        insert testOpp3;
    
        System.debug('########## START calculateQualifiedSnPDRProg_multicurrencies ##########');               
          
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[5].Id, OpportunityId=testOpp3.Id, quantity=4, UnitPrice=100, Mrgn__c = 0 )); //Adobe:Acrobat - New
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[6].Id, OpportunityId=testOpp3.Id, quantity=1, UnitPrice=1, Mrgn__c = 0 )); //Adobe:Acrobat - Update
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[7].Id, OpportunityId=testOpp3.Id, quantity=4, UnitPrice=100, Mrgn__c = 0 )); //Adobe:Creative Suites
    
        Test.startTest();
        insert testOLIList;           
        Test.stopTest();
        
        List<OpportunityLineItem> actualOliList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, quantity, totalprice, net__c FROM OpportunityLineItem WHERE Id IN (:testOLIList[0].Id, :testOLIList[1].Id, :testOLIList[2].Id)];
     
        List<S_P_Vendors__c> actualVendorList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, Qualified_Product_Line_Desc__c, Product_Line_Desc__c, Missing_Segment__c, 
                    PM1__c, PM2__c, PM3__c, PM4__c, PM5__c, Special_Instructions__c, Total_NET__c, CurrencyIsoCode, Distributor_Name__c  FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOpp3.Id];
  
        System.assertEquals('Yes', actualOLIList[0].Qualified_for_S_P_Deal_Reg_Program__c); //Acrobat - New
        System.assertEquals('Yes', actualOLIList[1].Qualified_for_S_P_Deal_Reg_Program__c); //Acrobat - Update
        System.assertEquals('No', actualOLIList[2].Qualified_for_S_P_Deal_Reg_Program__c);   //CS
        System.assertEquals(1, actualVendorList.size());                
        System.assertEquals('Yes', actualVendorList[0].Qualified_for_S_P_Deal_Reg_Program__c);
        System.assertEquals(';acrobat;', actualVendorList[0].Qualified_Product_Line_Desc__c);        
        System.assertEquals(false, actualVendorList[0].Missing_Segment__c);
        System.assertEquals('Testing mulitcurrencies', actualVendorList[0].Special_Instructions__c);  
        System.assertEquals('EUR', actualVendorList[0].CurrencyIsoCode);
        double totalOLINet = actualOliList[0].Net__c + actualOliList[1].Net__c; //Rev 3.1 + actualOliList[2].Net__c;
        System.debug('totalnet: '+totalOLINet + ' - ' + actualVendorList[0].Total_NET__c);
        System.assertEquals(totalOLINet, actualVendorList[0].Total_NET__c);          
        System.assertEquals('GTI;OTHER', actualVendorList[0].Distributor_Name__c);  //Rev 2.1
        System.debug('########## END calculateQualifiedSnPDRProg_multicurrencies ##########');
    } 
  //Rev 2.0-end

  //Rev 3.1
    //Test Case 8: Multicurrencies
  //Expected: Opp Prod with EUR also qualified  
    static testMethod void calculateQualifiedSnPDRProg_DellPrinterProduct() {
        List<OpportunityLineItem> testOLIList = new List<OpportunityLineItem>();
                    
        TestDataCreationForDellPrinter();  
        
        System.debug('########## START calculateQualifiedSnPDRProg_DellPrinterProduct ##########');               
          
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[0].Id, OpportunityId=testOpp.Id, quantity=2, UnitPrice=100, Mrgn__c = 0 ));  //Dell1130
        testOLIList.add(new OpportunityLineItem(PriceBookEntryId = pbeList[1].Id, OpportunityId=testOpp.Id, quantity=1, UnitPrice=1, Mrgn__c = 0 ));   //Dell1133
            
        Test.startTest();
        insert testOLIList;           
        Test.stopTest();
        
        List<OpportunityLineItem> actualOliList = [SELECT Id, Brand_Desc__c, Qualified_for_S_P_Deal_Reg_Program__c, quantity, totalprice, net__c FROM OpportunityLineItem WHERE Id IN (:testOLIList[0].Id, :testOLIList[1].Id)];
     
        List<S_P_Vendors__c> actualVendorList = [SELECT Id, Qualified_for_S_P_Deal_Reg_Program__c, Qualified_Product_Line_Desc__c, Product_Line_Desc__c, Missing_Segment__c, 
                    PM1__c, PM2__c, PM3__c, PM4__c, PM5__c, Special_Instructions__c, Total_NET__c, CurrencyIsoCode, Distributor_Name__c  FROM S_P_Vendors__c WHERE Opportunity__r.Id = :testOpp.Id];
  
        System.assertEquals('Yes', actualOLIList[0].Qualified_for_S_P_Deal_Reg_Program__c); //Dell 1130
        System.assertEquals('No', actualOLIList[1].Qualified_for_S_P_Deal_Reg_Program__c);   //Dell 1133
                   
        System.assertEquals(2, actualVendorList.size());                
    //Dell 1130
        System.assertEquals('Yes', actualVendorList[0].Qualified_for_S_P_Deal_Reg_Program__c);
        System.assertEquals(';personal laser printer;', actualVendorList[0].Qualified_Product_Line_Desc__c);        
        System.assertEquals(actualOLIList[0].totalprice, actualVendorList[0].Total_NET__c);          
        //Dell 1133
        System.assertEquals('No', actualVendorList[1].Qualified_for_S_P_Deal_Reg_Program__c);
        System.assertEquals(null, actualVendorList[1].Qualified_Product_Line_Desc__c);    

        System.debug('########## END calculateQualifiedSnPDRProg_DellPrinterProduct ##########');
    } 
    //Rev 2.0-end
   */
    private static void TestDataCreation() {
    
    TriggerExecutionController.setSkipAllTriggers(true);
    //SnPVendorsUtilities.isTest = true;
   // ProcessFlowTriggerController.isTest = true;
          
    //Product      
    List<Product2> testProdList = new List<Product2>();
    testProdList.add(new Product2(Name='Adobe', Product_Line_Desc__c = 'Acrobat', Product_ID__c = 'TestProd 1', Description = 'Acrobat - New', S_P_Registerable__c = true, ProductCode = 'Software', Family = 'S&P'));    
    testProdList.add(new Product2(Name='Adobe', Product_Line_Desc__c = 'Acrobat', Product_ID__c = 'TestProd 2', Description = 'Acrobat - Update', S_P_Registerable__c = true, ProductCode = 'Software', Family = 'S&P'));
    testProdList.add(new Product2(Name='Adobe', Product_Line_Desc__c = 'Creative Suites', Product_ID__c = 'TestProd 3', Description = 'CS - New', S_P_Registerable__c = true, ProductCode = 'Software', Family = 'S&P'));
    testProdList.add(new Product2(Name='Acronis', Product_Line_Desc__c = 'Acronis', Product_ID__c = 'TestProd 4', Description = 'New License', S_P_Registerable__c = true, ProductCode = 'Software', Family = 'S&P'));
    testProdList.add(new Product2(Name='Absolute', Product_Line_Desc__c = 'Non Tied Enterprise', Product_ID__c= 'TestProd 5', Description = 'Non Tied Enterprise', S_P_Registerable__c = false, ProductCode = 'Software', Family = 'S&P'));
    
    insert testProdList;
    system.debug('@@@@@ 1. Limits.getQueries() - ' + Limits.getQueries());  

    Id pbk1 = Test.getStandardPricebookId();
        
    PriceBook2 testPB = new PriceBook2(Name='Test PriceBook');
    insert testPB;
    system.debug('@@@@@ 2. Limits.getQueries() - ' + Limits.getQueries());  

    List<PriceBookEntry> stdpbeList = new List<PriceBookEntry>();    
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=pbk1 , Product2Id = testProdList[0].Id, IsActive=TRUE, UnitPrice = 8));
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=pbk1 , Product2Id = testProdList[1].Id, IsActive=TRUE, UnitPrice = 8));
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=pbk1 , Product2Id = testProdList[2].Id, IsActive=TRUE, UnitPrice = 8));
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=pbk1 , Product2Id = testProdList[3].Id, IsActive=TRUE, UnitPrice = 8));
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=pbk1 , Product2Id = testProdList[4].Id, IsActive=TRUE, UnitPrice = 8));
    
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=pbk1 , Product2Id = testProdList[0].Id, IsActive=TRUE, UnitPrice = 8, CurrencyISOCode = 'EUR'));
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=pbk1 , Product2Id = testProdList[1].Id, IsActive=TRUE, UnitPrice = 8, CurrencyISOCode = 'EUR'));
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=pbk1 , Product2Id = testProdList[2].Id, IsActive=TRUE, UnitPrice = 8, CurrencyISOCode = 'EUR'));
    insert stdpbeList;
    system.debug('@@@@@ 3. Limits.getQueries() - ' + Limits.getQueries());  
        
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[0].Id, IsActive=TRUE, UnitPrice = 8));
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[1].Id, IsActive=TRUE, UnitPrice = 8));
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[2].Id, IsActive=TRUE, UnitPrice = 8));
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[3].Id, IsActive=TRUE, UnitPrice = 8));
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[4].Id, IsActive=TRUE, UnitPrice = 8));
    
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[0].Id, IsActive=TRUE, UnitPrice = 8, CurrencyISOCode = 'EUR'));
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[1].Id, IsActive=TRUE, UnitPrice = 8, CurrencyISOCode = 'EUR'));
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[2].Id, IsActive=TRUE, UnitPrice = 8, CurrencyISOCode = 'EUR'));    
    insert pbeList;
    system.debug('@@@@@ 4. Limits.getQueries() - ' + Limits.getQueries());  

    Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        
        for (integer i=0; i<10;i++){
            User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
                                Alias = 'test'+i, 
                                Email='test'+ i +'@dell.com', 
                                FirstName='Tfirst'+i, 
                                LastName='TLast'+i,
                                ProfileId = userProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='TEST12345'+i );
                
            testUserList.add(user);   
        } 
        insert testUserList;     
        system.debug('@@@@@ 5. Limits.getQueries() - ' + Limits.getQueries());           
  
    //Criteria
    Id criteriaByCountryRecTypeId = IdLookupUtils.getRecordTypeId('Criteria by Country', 'S_P_DR_Criteria__c', true);  
    Id criteriaByRegionRecTypeId = IdLookupUtils.getRecordTypeId('Criteria by Region', 'S_P_DR_Criteria__c', true);  
    
    List<S_P_DR_Criteria__c> testCriteriaList = new List<S_P_DR_Criteria__c>();
    testCriteriaList.add(new S_P_DR_Criteria__c(Name = 'Criteria:Acrobat:MPA;FED', Region__c = 'APJ', Country_Name__c = 'MALAYSIA',  Segment__c = 'MPA;FED', Segment_Required__c = true, CurrencyISOCode = 'USD',
                                Primary_Record__c = false, Min_Qty__c = 2.00, Min_days_before_Book_Date__c = 10, Min_NET__c = 1.00, Product_Line_Desc__c = 'ACROBAT',
                                Brand_Desc__c = 'Adobe', 
                                Special_Instructions__c = 'Testing', RecordTypeId = criteriaByCountryRecTypeId));
    
    testCriteriaList.add(new S_P_DR_Criteria__c(Name = 'Criteria:Acrobat:BSD:PRIMARY', Region__c = 'APJ', Segment__c = 'BSD', Segment_Required__c = true, CurrencyISOCode = 'USD',
                                Primary_Record__c = true, Min_Qty__c = 2.00, Min_days_before_Book_Date__c = 10, Min_NET__c = 1.00, Product_Line_Desc__c = 'Acrobat',
                                Brand_Desc__c = 'Adobe', 
                                RecordTypeId = criteriaByRegionRecTypeId));
    //Rev 2.3 
    testCriteriaList.add(new S_P_DR_Criteria__c(Name = 'Criteria:CS:FED:PRIMARY', Region__c = 'APJ', Country_Name__c = 'MALAYSIA', Segment_Required__c = false, CurrencyISOCode = 'USD',
                                Primary_Record__c = true, Min_Qty__c = 2.00, Min_days_before_Book_Date__c = 10, Min_NET__c = 1.00, Product_Line_Desc__c = 'Creative Suites',
                                Brand_Desc__c = 'ADOBE', 
                                Special_Instructions__c = 'Testing', RecordTypeId = criteriaByCountryRecTypeId));

    //Rev 2.1
    //Rev 2.0
    testCriteriaList.add(new S_P_DR_Criteria__c(Name = 'Criteria:Acrobat:MPA;FED:EUR', Region__c = 'APJ', Country_Name__c = 'MALAYSIA',  Segment__c = 'MPA;FED', Segment_Required__c = true, CurrencyISOCode = 'EUR',
                                Primary_Record__c = true, Min_Qty__c = 2.00, Min_days_before_Book_Date__c = 10, Min_NET__c = 1.00, Product_Line_Desc__c = 'Acrobat',
                                Brand_Desc__c = 'Adobe',  
                                Special_Instructions__c = 'Testing mulitcurrencies', Distributor_Name__c = 'GTI;OTHER', RecordTypeId = criteriaByCountryRecTypeId));
 //   Test.startTest();
    insert testCriteriaList;
    system.debug('@@@@@ 6. Limits.getQueries() - ' + Limits.getQueries());  
        
    //Sales Channel Group     
    testSCG = new Sales_Channel_Group__c (Name = 'Test SCG', Group_ID__c = '12345', Segment_Name__c = 'FED');
    insert testSCG;
    system.debug('@@@@@ 7. Limits.getQueries() - ' + Limits.getQueries());  
    
    //Account
    Account testAcc = new Account(Name = 'Test Account', Sales_Channel__c = testSCG.Id);
    insert testAcc;
    system.debug('@@@@@ 8. Limits.getQueries() - ' + Limits.getQueries());  
    
    //Opportunity
    testOpp = new Opportunity(Name='Test Opp', recordtypeid='012A0000000Tehs', Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Discover - 10%', CloseDate = System.today() + 30,
                Primary_Product_Delivery_Address_Region__c = 'APJ', Primary_Product_Delivery_Address_Country__c = 'MALAYSIA', AccountId = testAcc.Id, CurrencyISOCode = 'USD');
    //insert testOpp;
    system.debug('@@@@@ 9. Limits.getQueries() - ' + Limits.getQueries());  
    
    //Opportunity
    testOpp2 = new Opportunity(Name='Test Opp with OLI', recordtypeid='012A0000000Tehs', Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Discover - 10%', CloseDate = System.today() + 30,
                Primary_Product_Delivery_Address_Region__c = 'APJ', Primary_Product_Delivery_Address_Country__c = 'MALAYSIA', AccountId = testAcc.Id, CurrencyISOCode = 'USD');
   // insert testOpp2;
   
    testOppList.add(testOpp);
    testOppList.add(testOpp2);
    
    //Test.startTest(); //4.0 Fix too many SOQL
    Database.insert(testOppList);
    //Test.stopTest();  //4.0 Fix too many SOQL
    system.debug('@@@@@ 10. Limits.getQueries() - ' + Limits.getQueries());  
    
    
    TriggerExecutionController.setSkipAllTriggers(false);
    TriggerExecutionController.setSkipAccountTriggers(true);
    TriggerExecutionController.setSkipOpportunityTriggers(true);        
    TriggerExecutionController.setskipSnPVendorTriggers(true);
    
    }
    
    private static void createOppLineItem(Boolean isTestOppLineItemCreation){
    
        testOLIList2.add(new OpportunityLineItem(PriceBookEntryId = pbeList[0].Id, OpportunityId=testOppList[1].Id, quantity=4, UnitPrice=100, Mrgn__c = 1 )); //Adobe:Acrobat
        testOLIList2.add(new OpportunityLineItem(PriceBookEntryId = pbeList[2].Id, OpportunityId=testOppList[1].Id, quantity=4, UnitPrice=100, Mrgn__c = 1 )); //Adobe:Creative Suites
    
    TriggerExecutionController.setSkipAllTriggers(false);
    TriggerExecutionController.setSkipAccountTriggers(true);
    TriggerExecutionController.setSkipOpportunityTriggers(true);        
   TriggerExecutionController.setskipSnPVendorTriggers(true);
        
        if(isTestOppLineItemCreation) Test.startTest();   //4.0 Fix too many SOQL
            insert testOLIList2;
        if(isTestOppLineItemCreation) Test.stopTest();    //4.0 Fix too many SOQL
        
        system.debug('@@@@@ 11. Limits.getQueries() - ' + Limits.getQueries());  
        //  Test.stopTest();
        System.debug('########## END TestDataCreation ##########');        
       
    
    }
    
    private static void TestDataCreationForDellPrinter() {
      //Product      
      List<Product2> testProdList = new List<Product2>();    
    testProdList.add(new Product2(Name='Dell 1130', Product_Line_Desc__c = 'Personal Laser Printer', Description = 'Imaging', S_P_Registerable__c = true, ProductCode = 'Software', Family = 'S&P'));
    testProdList.add(new Product2(Name='Dell 1133', Product_Line_Desc__c = 'Personal Laser Printer', Description = 'Imaging', S_P_Registerable__c = true, ProductCode = 'Software', Family = 'S&P'));    
    insert testProdList;

    PriceBook2 standardPB = [SELECT Id FROM PriceBook2 WHERE IsStandard = TRUE];
    
    PriceBook2 testPB = new PriceBook2(Name='Test PriceBook');
    insert testPB;

    List<PriceBookEntry> stdpbeList = new List<PriceBookEntry>();  
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = testProdList[0].Id, IsActive=TRUE, UnitPrice = 8));
    stdpbeList.add(new PriceBookEntry(PriceBook2Id=standardPB.Id, Product2Id = testProdList[1].Id, IsActive=TRUE, UnitPrice = 8));
    insert stdpbeList;
        
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[0].Id, IsActive=TRUE, UnitPrice = 8));
    pbeList.add(new PriceBookEntry(PriceBook2Id=testPB.Id, Product2Id = testProdList[1].Id, IsActive=TRUE, UnitPrice = 8));
    insert pbeList;

    Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        
        for (integer i=0; i<10;i++){
            User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
                                Alias = 'test'+i, 
                                Email='test'+ i +'@dell.com', 
                                FirstName='Tfirst'+i, 
                                LastName='TLast'+i,
                                ProfileId = userProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='TEST12345'+i );
                
            testUserList.add(user);   
        } 
        insert testUserList;              
  
    //Criteria
    Id criteriaByCountryRecTypeId = IdLookupUtils.getRecordTypeId('Criteria by Country', 'S_P_DR_Criteria__c', true);  
    Id criteriaByRegionRecTypeId = IdLookupUtils.getRecordTypeId('Criteria by Region', 'S_P_DR_Criteria__c', true);  
    
    List<S_P_DR_Criteria__c> testCriteriaList = new List<S_P_DR_Criteria__c>();
    testCriteriaList.add(new S_P_DR_Criteria__c(Name = '1130:PLP;FED', Region__c = 'APJ', Country_Name__c = 'MALAYSIA',  Segment__c = 'FED', Segment_Required__c = true, CurrencyISOCode = 'USD',
                                Primary_Record__c = true, Min_Qty__c = 2.00, Min_days_before_Book_Date__c = 10, Min_NET__c = 100.00, Product_Line_Desc__c = 'Personal Laser Printer',
                                Brand_Desc__c = 'Dell 1130',  
                                Special_Instructions__c = 'Testing', RecordTypeId = criteriaByCountryRecTypeId));
    
    testCriteriaList.add(new S_P_DR_Criteria__c(Name = '1133:PLP;FED', Region__c = 'APJ', Segment__c = 'BSD', Segment_Required__c = true, CurrencyISOCode = 'USD',
                                Primary_Record__c = true, Min_Qty__c = 2.00, Min_days_before_Book_Date__c = 10, Min_NET__c = 100.00, Product_Line_Desc__c = 'Personal Laser Printer',
                                Brand_Desc__c = 'Dell 1133',  
                                RecordTypeId = criteriaByRegionRecTypeId));
    
    insert testCriteriaList;
        
    //Sales Channel Group     
    testSCG = new Sales_Channel_Group__c (Name = 'Test SCG', Group_ID__c = '12345', Segment_Name__c = 'FED');
    insert testSCG;
    
    //Account
    Account testAcc = new Account(Name = 'Test Account', Sales_Channel__c = testSCG.Id);
    insert testAcc;
            
    //Opportunity
    testOpp = new Opportunity(Name='Test Opp', recordtypeid='012A0000000Tehs', Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Discover - 10%', CloseDate = System.today() + 30,
                Primary_Product_Delivery_Address_Region__c = 'APJ', Primary_Product_Delivery_Address_Country__c = 'MALAYSIA', AccountId = testAcc.Id, CurrencyISOCode = 'USD');
    Test.startTest();
    insert testOpp;
    Test.stopTest();
    System.debug('########## END TestDataCreationForDellPrinter ##########');
    }
    
    
    //SNWL:CR7326 : Code Start:Test Method for SNWL product Insert.
    static testMethod void insertSNWLproducts() {
    
        //TriggerExecutionController.setSkipAllTriggers(true);
        //4.2 Execute only the triggers that should be excuted on after update and insert of Opportunity and OLI.
  
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
              'BeforeUpdate' => new List<Boolean>{true, true, false, false, false},
              'BeforeInsert' => new List<Boolean>{true, false, true, false, false},
              'BeforeDelete' => new List<Boolean>{true, false, false, true, false}
        };

        for(String strEvent : mapEvents.keySet()) {
                if(strEvent=='BeforeUpdate'){
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBU"},';
           }
           if(strEvent=='BeforeInsert'){
               strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBI"},'; 
           } 
           if(strEvent=='BeforeDelete'){
               strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunityLineItemTriggerHandlerBD"},';
           } 
           }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';  
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        //4.2 ENDS
        SnPVendorsUtilities.isTest = true;
        ProcessFlowTriggerController.isTest = true;
        
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');        
        insert testAccount;        
        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                StageName='Discover - 10%',
                                                CloseDate = System.Today() + 30 ); 
                                                       
        insert testOppty;   
        
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        
        Id pbk1 = Test.getStandardPricebookId();
              
        Product2 newSNWLPrdct = new Product2(Name = 'SonicWall Product',
                                         Product_Line_Desc__c = 'SonicWall', Product_ID__c = 'TestProd 1',
                                         IsActive = TRUE);
        insert newSNWLPrdct;
        
        PricebookEntry SNWLPBE= new PricebookEntry (Product2ID=newSNWLPrdct.id,
                                                Pricebook2ID=pbk1 ,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert SNWLPBE;
        
        OpportunityLineItem  testSNWLLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=SNWLPBE.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   );   
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.startTest();
        insert testSNWLLineItem ;
        Test.stopTest();
        
        OpportunityLineItem oppItem = [select id, Product_Brand_for_rollup__c from OpportunityLineItem where Id = :testSNWLLineItem.Id];
        /* reverting changes as per v4.1*/
        /* 4.0
        *Commented due to CR10826 disabling all existing configuration and code related with the Dell SFDC- SNWL opportunity integration
        */
        //System.Assertequals(oppItem.Product_Brand_for_rollup__c , 'SonicWall');
        //System.Assertequals(null, oppItem.Product_Brand_for_rollup__c); 
        
    }
    //SNWL:CR7326 : Code End:Test Method for SNWL product Insert.   
   
}