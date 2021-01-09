/***********************************************************
    * Name          : Test_RecordTypeSelector
    * Description   : Test class for 'RecordTypeSelector' controller
    * ---------------------------------------------------------
    * Revision  Name       Date             Description
    * 1.0       Rahul     29. Nov. 2018     Test class for 'RecordTypeSelector' controller
************************************************************/

@isTest
private class Test_RecordTypeSelector {
  static list<Account> listAcc;
  static list<Sales_Channel_Group__c> listSalesChannel;
    @testSetup static void setup() {
        list<Sales_Channel_Group__c> listSalesChannelTDF = TestDataFactory.createNSalesChannelGroups(1);
        insert listSalesChannelTDF;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'End-user Account');
        listAccTDF[0].Sales_Channel__c=listSalesChannelTDF[0].Id;
        insert listAccTDF;  
    }  

    private static testMethod void validateRecordTypes() {
        
        
        Test.startTest();
        
        Opportunity objOpp;
        Ocean_Data__c objOceanData;
        LOT_REGION__c objLOTRegion;
        LOT_OCEAN_EMAIL__c objLOTOceanEmail;    
        Sales_Channel_Group__c objSalesChannelGrp;
        Account objAccount;
       /*
        objSalesChannelGrp = new Sales_Channel_Group__c();
        objSalesChannelGrp.Name = 'TestChannelGroup1';
        objSalesChannelGrp.Region_Name__c = 'REGION1';
        objSalesChannelGrp.Segment_Business_Unit_Name__c = 'LARGE ENTERPRISE';        
        insert objSalesChannelGrp;
        
        objAccount = new Account();
        objAccount.Name = 'TestAccount';
        objAccount.Sales_Channel__c = objSalesChannelGrp.Id;
        insert objAccount;
        */
        listAcc = [select id from Account limit 1];
        CTI_Call_Log__c objCTICL = new CTI_Call_Log__c();
        objCTICL.Account__c = listAcc[0].Id;
        insert objCTICL;
        
        Test.setCurrentPageReference(new PageReference('Page.RecordTypeSelection')); 
        System.currentPageReference().getParameters().put('paramval2', objCTICL.Id);
        

        
        apexPages.StandardController sc = new ApexPages.StandardController(objCTICL);
        RecordTypeSelector objRecordTypeSelector = new RecordTypeSelector(sc);
        
        
        objRecordTypeSelector.getRecordTypes();
        objRecordTypeSelector.getTasksRecordTypes();
        objRecordTypeSelector.testMethod1();
        objRecordTypeSelector.strSelectedTaskRecordType= '';
        system.assertEquals('',objRecordTypeSelector.strSelectedTaskRecordType);
        
    }

}