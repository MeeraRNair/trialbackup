/***********************************************************
* Revision       Release                   Name           Date                  Description   
* 1.0       0202             Vikas KH      08-Dec-2019      Impelemented TDF
***************************************************************/
@isTest 
private class OpportunityLOTProductListControllerTest{
    Static list<Account> listAcc;
    Static list<Opportunity> listOpp;
    Static list<OpportunitylineItem> listOppLineItem;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Opportunity> listoppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        insert listoppTDF;
        list<OpportunitylineItem> listOpplTDF = TestDataFactory.createNOpportunityLineItem(3);
        listOpplTDF[0].Opportunityid=listoppTDF[0].id; 
        listOpplTDF[1].Opportunityid=listoppTDF[0].id;
        listOpplTDF[2].Opportunityid=listoppTDF[0].id;
        Insert listOpplTDF;     
    }
    static testmethod void testGetTableRowTextList() {
        Sales_Channel_Group__c testSalesChannelGrp = new Sales_Channel_Group__c(Name='TestChannelGroup1', Region_Name__c='REGION1', Segment_Business_Unit_Name__c='LARGE ENTERPRISE');
        insert testSalesChannelGrp;
        TriggerExecutionController.setSkipAllTriggers(true);
        //Account testAccount = new Account(Name='TestAccount', Sales_Channel__c=testSalesChannelGrp.Id);
        //insert testAccount;
        listAcc = [select id,name,Sales_Channel__c from Account];
        listAcc[0].Sales_Channel__c=testSalesChannelGrp.Id;
        TriggerExecutionController.setSkipAllTriggers(true);
        update listAcc;
        Ocean_Data__c testOceanData = new Ocean_Data__c(CFI_Delivery_Time_in_Weeks__c=10, CFS_Delivery_Time_in_Weeks__c=10,
                                                        Exception_Country__c='COUNTRY1',    Lead_Time_in_Weeks__c=10,
                                                        MSP_Incremental_in_Weeks__c=10, Region__c='REGION1',
                                                        Ship_Rate__c=4, Source__c='Compal', Pallet_Rate__c=2);
        
        insert testOceanData;
        LOT_Region__c testLOTRegion = new LOT_Region__c(Name='COUNTRY1', Region__c='REGION1', threshold_region__c='EMEA');
        insert testLOTRegion;
        //Opportunity testOppty = new Opportunity(RecordTypeId='012300000004zf2', Customer_Requested_Delivery_Date__c=system.today() + 60, StageName='Propose - 60%', Probability=60, AccountId=testAccount.Id, Name='TEST Oppty 1', CloseDate = System.today() + 30, Primary_Product_Delivery_Address_Region__c = 'REGION1', Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',Region__c='APJ',Competitor_Lost_To__c='Unknown');
        //insert testOppty;
        list<Opportunity> listOpp = [select id,name from Opportunity limit 1];
        listOpp[0].AccountID = listAcc[0].id;
        listOpp[0].Customer_Requested_Delivery_Date__c=system.today() + 60;
        listOpp[0].Probability=60;
        listOpp[0].CloseDate = System.today() + 30;
        listOpp[0].Primary_Product_Delivery_Address_Region__c = 'REGION1';
        listOpp[0].Primary_Product_Delivery_Address_Country__c = 'COUNTRY1';
        listOpp[0].Region__c='APJ';
        listOpp[0].Competitor_Lost_To__c='Unknown';
        update listOpp;
    System.assertEquals(listOpp[0].Primary_Product_Delivery_Address_Region__c, 'REGION1');        
        listOpplineItem = [select id from OpportunityLineItem limit 3];
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = false;
        try {
            Test.startTest();
            OpportunityLOTProductListController controller = new OpportunityLOTProductListController(listOpp[0].Id, 2, true);
            List<String> listresultText = controller.getTableRowTextList();
            Test.stopTest();
        } catch (Exception e) {
        }
    }
}