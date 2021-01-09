/*
 * Revision CR Number   Release No  Date            Created/Modified By         Description
 * -------- ---------   ----------  -----------     ------------                -----------
 * 1.0     CR#14155      ----       19-Apr-2017     Venkateswarlu Chirala       Test class to cover all methods in LOBi_AutoAccSchDispatcher, LOBi_AutoAccSchDispatcherHandler
 *                                                                               LOBi_AutoIdentifyAccountBatch and LOBi_AutoIdentifyAccBusinessRules classes. 
 *   
 */
 
@isTest(seeAllData = false)
private class LOBi_SchDispatcher_Batch_RulesTest {

   /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description This method to cover creating common test records that are available for all test methods in the class. 
     *     
     *@param N/A
     */
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
     
       TriggerExecutionController.setSkipAllTriggers(True);
       Country__c testCountryObject = new Country__c(name = 'INDIA', Dell_Online_Country_Code__c = 'IN', Code__c = 'IN', Enabled_Auto_Renewal__c = True, Last_Operation_Performed__c = 'Test Data');
       insert testCountryObject;

        TriggerExecutionController.setSkipAllTriggers(True);
        Account  testAccountObj = new Account(name = 'Test-1', Account_Country_Code__c = 'IN', Account_Country__c = 'INDIA', Rating = 'T2A HIGH BP ACQ', CSG__c = False, Networking__c = false, Server__c = false, Storage__c = false);
        insert testAccountObj;
            
       Test.startTest();
       TriggerExecutionController.setSkipAllTriggers(True);
       update new Account(ID = testAccountObj.ID, CSG_Timestamp__c = NULL, Networking_Timestamp__c = NULL, Server_Timestamp__c = NULL, Storage_Timestamp__c = NULL);     
       
       Revenue__c revenue = new Revenue__c(Account__c = testAccountObj.ID, Client_QTR_Rev__c = 10, Networking_QTR_Rev__c = 10, Server_QTR_Rev__c = 10, Storage_QTR_Rev__c = 10,Fiscal_Quarter__c = 'Q02', Fiscal_Year__c = 'FY2017');      
        TriggerExecutionController.setSkipAllTriggers(True);
        insert revenue;      
        System.assertEquals(revenue.Fiscal_Quarter__c, 'Q02'); 
        
       Test.stopTest();  
    }
    
    /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description This method to cover the LOBi_AutoAccSchDispatcher class methods
     *     
     *@param N/A
     */
    @isTest static void LOBi_AutoAccSchDispatcherTestMethod() {
    
        Test.startTest();
       
        String CRON_EXP = '0 0 0 3 9 ? 2022';  // Schedule the test job
        String jobId = System.schedule('LOBi_AutoAccSchDispatcher', CRON_EXP, new LOBi_AutoAccSchDispatcher());       
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id =: jobId];// Get the information from the CronTrigger API object     
        System.assertEquals(0, ct.TimesTriggered);  // Verify the job has not run      
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime)); // Verify the next time the job will run
        
        Test.stopTest();
    }

    /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description This method to cover the LOBi_AutoIdentifyAccountBatch class methods
     *     
     *@param N/A
     */
    @isTest static void LOBi_AutoIdentifyAccountBatchTestMethod() {
          
        List < Fiscal_Years__c > custFY = new List < Fiscal_Years__c > ();
        custFY.add(new Fiscal_Years__c(Name = ' FY16Q1', Start_Date__c = Date.newInstance(2014, 1, 31), End_Date__c = Date.newInstance(2015, 5, 1)));
        custFY.add(new Fiscal_Years__c(Name = ' FY16Q2', Start_Date__c = Date.newInstance(2015, 5, 2), End_Date__c = Date.newInstance(2015, 7, 31)));
        custFY.add(new Fiscal_Years__c(Name = ' FY16Q3', Start_Date__c = Date.newInstance(2015, 8, 1), End_Date__c = Date.newInstance(2015, 10, 30)));
        custFY.add(new Fiscal_Years__c(Name = ' FY16Q4', Start_Date__c = Date.newInstance(2015, 10, 31), End_Date__c = Date.newInstance(2016, 4, 29)));
        custFY.add(new Fiscal_Years__c(Name = ' FY17Q1', Start_Date__c = Date.newInstance(2016, 1, 30), End_Date__c = Date.newInstance(2016, 4, 29)));
        custFY.add(new Fiscal_Years__c(Name = ' FY17Q2', Start_Date__c = Date.newInstance(2016, 4, 30), End_Date__c = Date.newInstance(2016, 7, 29)));
        custFY.add(new Fiscal_Years__c(Name = ' FY17Q3', Start_Date__c = Date.newInstance(2016, 7, 30), End_Date__c = Date.newInstance(2016, 10, 28)));
        custFY.add(new Fiscal_Years__c(Name = ' FY17Q4', Start_Date__c = Date.newInstance(2016, 10, 29), End_Date__c = Date.newInstance(2017, 2, 3)));

        Insert custFY;
        System.assertEquals(custFY.size()>0, TRUE);

        List <String> RTtypes = new List < String > {'GBL_Standard_RT'};
        Set <String> ratingSet = new Set < String > ();
        List <String> gcCountries = new List < String > ();
        List <String> gcCountryCodes = new List < String > ();
        List <String> usFed = new List < String > ();
        List<String> USFedCountries =     new List<String>(); // SalesChannelUS FED countries
        List<String> segmentName     =     new List<String>();// Exlude AMER US FED Channels Accounts

        for (List < LOBi_Business_Rules__mdt > lobiList: [SELECT ID, DeveloperName, Eligible_Rating_picklist_values__c FROM LOBi_Business_Rules__mdt WHERE Eligible_Rating_picklist_values__c != NULL LIMIT 100]) {
            if (lobiList.size() > 0) {
                for (LOBi_Business_Rules__mdt lobi: lobiList) {
                    for (String rating: lobi.Eligible_Rating_picklist_values__c.normalizeSpace().split(';'))
                        if (String.isNotBlank(rating.trim())) ratingSet.add(rating.trim());
                }
            }
        }


        if (System.Label.GCCountries.normalizeSpace() != 'NULL')
            for (String gc: System.Label.GCCountries.normalizeSpace().split(';'))
                if (String.isNotBlank(gc.trim())) gcCountries.add(gc.trim());


        if (System.Label.GCCountryCodes.normalizeSpace() != 'NULL')
            for (String gcCodes: System.Label.GCCountryCodes.normalizeSpace().split(';'))
                if (String.isNotBlank(gcCodes.trim())) gcCountryCodes.add(gcCodes.trim());


         //Get US federal from custom labels to add in Dynamic SOQL  
         if(System.Label.Sales_Channel_US_Countries.normalizeSpace() != 'NULL')
            for(String fed:System.Label.Sales_Channel_US_Countries.normalizeSpace().split(';'))
                if(String.isNotBlank(fed.trim())) USFedCountries.add(fed.trim());
        
        //Get US federal from custom labels to add in Dynamic SOQL  
         if(System.Label.Sales_Channel_Segment_Name.normalizeSpace() != 'NULL')
            for(String segName:System.Label.Sales_Channel_Segment_Name.normalizeSpace().split(';'))
                 if(String.isNotBlank(segName.trim())) segmentName.add(segName.trim());
             
          // Construct the dynamic SOQL query
            String soql = 'SELECT ID,Account_Country__c ,Account_Country_Code__c ,Rating,CSG__c,Networking__c,Server__c,Storage__c,CSG_Timestamp__c,Networking_Timestamp__c,Server_Timestamp__c,Storage_Timestamp__c FROM Account '; // Base query
                   soql = soql + ' WHERE Account_Country__c != NULL AND Account_Country_Code__c != NULL AND Rating != NULL AND RecordTypeID != NULL '; // NOT NULL checks
                   soql = soql + ' AND ( (CSG__c= FALSE AND CSG_Timestamp__c = NULL) OR ( Networking__c = FALSE AND Networking_Timestamp__c = NULL) OR ( Server__c= FALSE AND Server_Timestamp__c= NULL) OR (Storage__c= FALSE AND Storage_Timestamp__c= NULL) ) '; // Eligibility of Incumbency flags
                   soql = soql + ' AND RecordType.DeveloperName IN:RTtypes AND Rating IN:ratingSet '; //  inlcude End user RT & Rating
           
           if(!gcCountries.isEmpty()) soql = soql + ' AND Account_Country__c NOT IN: gcCountries '; // Exclude the GC countries names if contains
           if(!gcCountryCodes.isEmpty()) soql = soql + ' AND Account_Country_Code__c NOT IN: gcCountryCodes ';  // Exclude the GC countries code coutnires if contains
           if(!USFedCountries.isEmpty()) soql = soql + ' AND ( Country_Name_lookup__c NOT IN: USFedCountries '; // Exclude the SalesChannel US Fed countries //( NOT Sales_Channel__r.Name LIKE \'%'+salesChannelUSFed +'%\' ) '; // Exclude the US federa if contains
           if(!segmentName.isEmpty()) soql= soql + ' OR Segment_Name_lookup__c NOT IN: segmentName ) '; // Exlude the if SalesChannel Segmentname IN "FED"
           

       Test.startTest();
          LOBi_AutoIdentifyAccountBatch lobiBatch = new LOBi_AutoIdentifyAccountBatch(soql, RTtypes, gcCountries, gcCountryCodes, segmentName, ratingSet,USFedCountries ); 
        Database.executeBatch(lobiBatch, Integer.valueOf(System.Label.LOBi_BatchSize.trim()));

        Test.stopTest();

    }

    /** 
     * @author Venkateswarlu Chirala
     * @date  19-Apr-2017
     * @description This method to cover the LOBi_AutoIdentifyAccBusinessRules class methods
     *     
     *@param N/A
     */
    @isTest static void LOBi_AutoIdentifyAccBusinessRulesTestMethod() {

        Account testAccountObj =[SELECT ID,Account_Country__c ,Account_Country_Code__c ,Rating,CSG__c,Networking__c,Server__c,Storage__c,CSG_Timestamp__c,Networking_Timestamp__c,Server_Timestamp__c,Storage_Timestamp__c FROM Account WHERE Name='Test-1' LIMIT 1] ;
        Map < ID, Set < String >> autoEligAccIncumMap = new Map < ID, Set < String >> { testAccountObj.ID => new set < String > {'Client','Storage','Server','Networking'}};
        Set < String > last8QuartersSet = new Set < String > {'FY2017Q01','FY2017Q02'};
        Set < String > last4QuartsSet = new Set < String > {'FY2017Q01','FY2017Q02'};
        Map < ID, Account > accMap = new Map < ID, Account > ();
        accMap.put(testAccountObj.ID, testAccountObj);
        Set < String > Tiers_1a_5 = new Set < String > {'T1A HIGH SP R&D','T1B MED SP R&D','T1C','T2A HIGH BP ACQ','T2B MED BP ACQ','T3 MM','T4 CFL','T5 GREENFIELD'};
        Set < String > Tiers_2a_2b_5 = new Set < String > {'T2A HIGH BP ACQ','T2B MED BP ACQ','T3 MM','T4 CFL','T5 GREENFIELD'};
      
        Test.startTest();
        //Call Ruel 1
        LOBi_AutoIdentifyAccBusinessRules.endUserAccRevenueRuleCheck(autoEligAccIncumMap, last8QuartersSet, last4QuartsSet, accMap, Tiers_1a_5, Tiers_2a_2b_5);

        Map < ID, Set < String >> revSucMapAccID_IncmFlags = new Map < ID, Set < String >> {testAccountObj.ID => new set < String > {'Client','Storage','Server','Networking'}};
        Set < String > partnerRelSet = new Set < string > ();
        if (System.Label.partnerRelationTypes.normalizeSpace() != 'NULL')
            for (String pr: System.Label.partnerRelationTypes.normalizeSpace().split(';'))
                if (String.isNotBlank(pr.trim())) partnerRelSet.add(pr.trim());

         // Call rule 2
         Date lastQuarterStDate = System.today() - 90;  Date lastQuarterEndDate = System.today();     
        LOBi_AutoIdentifyAccBusinessRules.endUserAccPartOppRuleCheck(revSucMapAccID_IncmFlags, partnerRelSet, lastQuarterStDate, lastQuarterEndDate);
       
        TriggerExecutionController.setSkipAllTriggers(true);
        Opportunity testOppty = new Opportunity(Name = 'testOpportunityPlanLineItemSchedule Test Oppty',AccountId = testAccountObj.ID,StageName = 'Plan - 1%', Partner_Opportunity_Stage__c = 'Plan - 1%',CloseDate = System.Today());
        insert testOppty;
        
        TriggerExecutionController.setSkipAllTriggers(True);
        Pricebook2 pbk1 = new Pricebook2(Name = 'Custom Pricebook', isActive = true);
        insert pbk1;

        TriggerExecutionController.setSkipAllTriggers(true);
        Product2 clprod = new Product2(Product_ID__c = 'v1', Name = 'Test Product', ProductCode = 'WORKSTATIONS',Product_Line_Desc__c = 'Services Product',IsActive = TRUE,CanUseRevenueSchedule = TRUE);
       //insert clprod;
        Product2 nwProd = new Product2(Product_ID__c = 'v2', Name = 'Test Product1', ProductCode = 'NETWORKING',Product_Line_Desc__c = 'Services Product',IsActive = TRUE,CanUseRevenueSchedule = TRUE);
      // insert nwProd;

        Product2 srProd = new Product2(Product_ID__c = 'v3', Name = 'Test Product1', ProductCode = 'ENTERPRISE SYSTEMS', Product_Line_Desc__c = 'Services Product',IsActive = TRUE,CanUseRevenueSchedule = TRUE);
      // insert srProd;

        Product2 stProd = new Product2(Product_ID__c = 'v4', Name = 'Test Product1', ProductCode = 'STORAGE',Product_Line_Desc__c = 'Services Product',IsActive = TRUE,CanUseRevenueSchedule = TRUE);
      // insert stProd;

       List<Product2> prodLsit=new List<Product2>{clprod,nwProd,srProd,stProd};
       insert prodLsit;

        PricebookEntry PBE_Cl = new PricebookEntry(Product2ID = prodLsit[0].id,Pricebook2ID = Test.getStandardPricebookId(),isActive = true,useStandardPrice=false,UnitPrice = 50);
       // insert PBE_Cl;
        PricebookEntry PBE_NW = new PricebookEntry(Product2ID = prodLsit[1].id,Pricebook2ID = Test.getStandardPricebookId(),isActive = true,useStandardPrice = false,UnitPrice = 50);
       // insert PBE_NW;

        PricebookEntry PBE_SR = new PricebookEntry(Product2ID = prodLsit[2].id,Pricebook2ID = Test.getStandardPricebookId(),isActive = true,useStandardPrice = false,UnitPrice = 50);
       // insert PBE_SR;

        PricebookEntry PBE_ST = new PricebookEntry(Product2ID = prodLsit[3].id,Pricebook2ID = Test.getStandardPricebookId(),isActive = true,useStandardPrice = false,UnitPrice = 50);
        //insert PBE_ST;
        
        List<PricebookEntry> PBEList=new List<PricebookEntry>{PBE_Cl,PBE_NW,PBE_SR,PBE_ST};
        insert PBEList;
        System.assertEquals(PBEList.size()>0, TRUE);

        TriggerExecutionController.setSkipAllTriggers(true);

        OpportunityLineItem testLineItem_cl = new OpportunityLineItem(Opportunityid = testOppty.Id,pricebookEntryId = PBEList[0].id,Mrgn__c = 6,
            Discount_off__c = 7,UnitPrice = 100,Quantity = 2,Description = 'Line Description',Service_Support_US__c = 'ProSupport IT - Mission Critical');
        OpportunityLineItem testappLineItem_NW = new OpportunityLineItem(Opportunityid = testOppty.Id,pricebookEntryId = PBEList[1].id,Mrgn__c = 6,
            Discount_off__c = 7,UnitPrice = 100,Quantity = 2,Description = 'Line Description',Service_Support_US__c = 'ProSupport IT - Mission Critical');
        OpportunityLineItem testappLineItem_SR = new OpportunityLineItem(Opportunityid = testOppty.Id,pricebookEntryId = PBEList[2].id,Mrgn__c = 6,
            Discount_off__c = 7,UnitPrice = 100,Quantity = 2,Description = 'Line Description',Service_Support_US__c = 'ProSupport IT - Mission Critical');
        OpportunityLineItem testappLineItem_ST = new OpportunityLineItem(Opportunityid = testOppty.Id,pricebookEntryId = PBEList[3].id,Mrgn__c = 6,
            Discount_off__c = 7,UnitPrice = 100,Quantity = 2,Description = 'Line Description',Service_Support_US__c = 'ProSupport IT - Mission Critical');

        List < OpportunityLineItem > opplist = new List < OpportunityLineItem > {testLineItem_cl,testappLineItem_NW,testappLineItem_SR,testappLineItem_ST};
        TriggerExecutionController.setSkipAllTriggers(true);
        insert opplist;

        Map < ID, Set < ID >> oppSucMapAccID_OppSet = new Map < ID, Set < ID >> ();
        oppSucMapAccID_OppSet.put(testAccountObj.ID, new set < ID > {testOppty.ID});
        Set < String > ISG_1a_2a = new Set < String > (); 
        Set < string > ISG_1b_2b_3_5 = new Set < String > (); 
        Set < String > CSG_2a = new Set < String > (); 
        Set < String > CSG_2b_3_5 = new Set < String > ();

        if (System.Label.ISG_1a_2a.normalizeSpace() != 'NULL')
            for (String isg1a: System.Label.ISG_1a_2a.normalizeSpace().split(';'))
                if (String.isNotBlank(isg1a.trim())) ISG_1a_2a.add(isg1a.toUpperCase().trim());

        if (System.Label.ISG_1b_2b_3_5.normalizeSpace() != 'NULL')
            for (String isg1b_2b: System.Label.ISG_1b_2b_3_5.normalizeSpace().split(';'))
                if (String.isNotBlank(isg1b_2b.trim())) ISG_1b_2b_3_5.add(isg1b_2b.toUpperCase().trim());

        if (System.Label.CSG_2a.normalizeSpace() != 'NULL')
            for (String csg2a: System.Label.CSG_2a.normalizeSpace().split(';'))
                if (String.isNotBlank(csg2a.trim())) CSG_2a.add(csg2a.toUpperCase().trim());

        if (System.Label.CSG_2b_3_5.normalizeSpace() != 'NULL')
            for (String csg2b: System.Label.CSG_2b_3_5.normalizeSpace().split(';'))
                if (String.isNotBlank(csg2b.trim())) CSG_2b_3_5.add(csg2b.toUpperCase().trim());

        Map < ID, Set < String >> revSucMapAccID_IncmFlags1 = new Map < ID, Set < String >> {testAccountObj.ID => new set < String > {'Client','Storage','Networking','Server'}};
        Map < String, LOBi_Business_Rules__mdt > lobiCustMeta = new Map < String, LOBi_Business_Rules__mdt > ();
        for (List < LOBi_Business_Rules__mdt > lobiList: [SELECT ID, MasterLabel, DeveloperName, Eligible_Rating_picklist_values__c, Eligible_Product_codes__c FROM LOBi_Business_Rules__mdt LIMIT 100]) {
            if (lobiList.size() > 0)
                for (LOBi_Business_Rules__mdt lobi: lobiList) {
                    lobiCustMeta.put(lobi.DeveloperName, lobi);
                }
        }

        LOBi_AutoIdentifyAccBusinessRules.partOppProductsRevRuleCheck(oppSucMapAccID_OppSet, accMap, ISG_1a_2a, ISG_1b_2b_3_5, CSG_2a, CSG_2b_3_5, revSucMapAccID_IncmFlags1, lobiCustMeta);

        Map < ID, Double > totalISGRevenue = new Map < ID, Double > {testAccountObj.ID => 10};
        Map < ID, Set < String >> succMap_OppProdRev = new Map < ID, Set < String >> {testAccountObj.ID => new set < String > {'Client','Storage','Server','Networking'}};
        //Call Rule 4
        LOBi_AutoIdentifyAccBusinessRules.finalNewLogoRuleCheck(autoEligAccIncumMap, totalISGRevenue, succMap_OppProdRev);

        Test.stopTest();
    }
} //End of class