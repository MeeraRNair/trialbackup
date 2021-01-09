/***********************************************************
* Name          : VFCntrlr_SalesMotionTest
* Description   : VFCntrlr_SalesMotion Test class
* ---------------------------------------------------------
* Revision    Release     Name    Date            Description
* 1.0           13.1    Jessie    14.01.2012      Sales Motion 
        
************************************************************/

@isTest
private class VFCntrlr_SalesMotionTest {

  static VFCntrlr_SalesMotion controller;
  static Sales_Motion_Page__c testMarketingPage;
  static Sales_Motion_Page__c testSummaryPage;
  static Sales_Motion__c testSalesMotion;
  static opportunity OppDetails;
  static SalesEdgeDataProcesser salesEdgeDataProcesser;
  
  /*
  static testMethod void SalesMotion_SimulateFirstClickSalesMotionButtonOnOpp() {
  
      createTestData();
      createMappingTestData();
      simulateFirstClickSalesMotionButtonOnOpp();
     
  }
  
 
  static testMethod void SalesMotion_SimulateClickOnStageLink() {
  
      createTestData();
      createMappingTestData();
      simulateClickOnStageLink();
      
  }
*/
static testMethod void runGetterandSetter(){
    controller = new VFCntrlr_SalesMotion ();
    controller.getfullAvailableProducts ();
}
static testMethod void SalesMotion_smUsageTracker() {
  
      createTestData();
      createMappingTestData();
      smUsageTracker();
      
  }
  static testMethod void SalesMotion_SimulateClickOnSearchLink() {
  
      createTestData();
      createMappingTestData();
      simulateClickOnSearchLink();
      
  }
  
  static testMethod void SalesMotion_SimulateSearchWithoutEnoughSearchCriteria() {
  
      createTestData();
      createMappingTestData();
      simulateSearchWithoutEnoughSearchCriteria();
      
  }
  
  static testMethod void SalesMotion_SimulateSearchWithEnoughSearchCriteria() {
  
      createTestData();
      createMappingTestData();
      simulateSearchWithEnoughSearchCriteria();
      
  }
  
  static testMethod void SalesMotion_SimulateSearchWithNoSMFound() {
  
      createTestData();
      createMappingTestData();
      simulateSearchWithNoSMFound();
      
  }
  
  static testMethod void SalesMotion_SimulateSearchWithNoSMPageFound() {
  
      createTestData();
      createMappingTestData();
      simulateSearchWithNoSMPageFound();
      
  }
  
  static testMethod void SalesMotion_SimulateFirstClickSalesMotionButtonOnOppWithoutPages() {
  
      createTestData();
      createMappingTestData();
      deleteAllPages();
      simulateFirstClickSalesMotionButtonOnOppWithoutPages();     
      
  }
  
  static testMethod void SalesMotion_SimulateFirstClickSalesMotionButtonOnOppWithoutMarketingPage() {
  
      createTestData();
      createMappingTestData();
      simulateFirstClickSalesMotionButtonOnOppWithoutMarketingPage();     
      
  }
  
  static testMethod void SalesMotion_SimulateFirstClickSalesMotionButtonOnOppWithOnePage() {
  
      createTestData();
      createMappingTestData();
      simulateFirstClickSalesMotionButtonOnOppWithOnePage();     
      
  }
  
  static testMethod void SalesMotion_SimulateFirstClickSalesMotionButtonOnOppWithoutSM() {
  
      createTestData();
      createMappingTestData();
      simulateFirstClickSalesMotionButtonOnOppWithoutSM();     
      
  }
 
  static testMethod void SalesMotion_SimulateScenarioWithNoSalesEdgeRecordsFromSalesEdge() {
  
      createTestData();
      createMappingTestData();
      simulateScenarioWithNoSalesEdgeRecordsFromSalesEdge();
      
  }
 
  static testMethod void SalesMotion_SimulateScenarioWithRecordsFromSalesEdge() {
      
      createTestData();
      createMappingTestData();
      simulateScenarioWithRecordsFromSalesEdge();
      
  }
 
  static testMethod void SalesMotion_SimulateScenarioWithoutStageMapping() {
      
      createTestData();
      createMappingTestData();
      simulateScenarioWithoutStageMapping();
      
  }
  
  static testMethod void SalesMotion_SimulateScenarioWithExceptionHappenWhileAccessSalesEdge() {
  
      createTestData();
      createMappingTestData();
      simulateScenarioWithExceptionHappenWhileAccessSalesEdge();
      salesEdgeDataProcesser = new SalesEdgeDataProcesser(); 
      salesEdgeDataProcesser.getSectionData('AD-SFDCKey', 'ProposeStage');           
  }
  
  /*
  static testMethod void SalesMotion_simulateScenarioWithoutCountryMappingRecord() {
  
      createTestData();
      simulateScenarioWithoutCountryMappingRecord();
            
  }
  */
  /*
  static void simulateFirstClickSalesMotionButtonOnOpp(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Qualify - 30%');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      
      Test.stopTest();  
  
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());  
      System.assert(controller.stages.size() > 0);
       
      System.assert((controller.currentLeftSections == null || controller.currentLeftSections.size() ==0));  
      System.assert((controller.currentRightSections== null || controller.currentRightSections.size() ==0));  
      
      System.assertEquals(true, controller.isStagedEnabled);  
      
      System.assert(controller.smErrMsg==null); 
      
      System.assert(controller.smSearchMsg==null); 
      
  }
  
  */
  static void simulateFirstClickSalesMotionButtonOnOppWithoutPages(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      
      Test.stopTest();  
  
      System.assert(controller.salesMotion !=null);
      System.assert(controller.salesMotionPages==null || controller.salesMotionPages.size() ==0);  
      System.assert(controller.stages==null || controller.stages.size() == 0);
      
      System.assert(controller.currentLeftSections==null);  
      System.assert(controller.currentRightSections==null);  
      
      System.assertEquals('There is no Sales Motion pages available for the Sales Motion.', controller.smErrMsg); 
      
      System.assert(controller.smSearchMsg==null); 
      
  }
  
  static void smUsageTracker(){
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      
      Test.stopTest(); 
      controller.smUsagetracker();
      controller.ClosePopUp();
      controller.redirectSalesMotion();
  
  }
  
   
  static void simulateFirstClickSalesMotionButtonOnOppWithoutMarketingPage(){
  
      List<Sales_Motion_Page__c> salesMotionPages = [Select p.Id from Sales_Motion_Page__c p 
          where Sales_Motion_Name__c = :testSalesMotion.Id];
      
      List<Sales_Motion_Page__c> deletedPages = new List<Sales_Motion_Page__c>();
      
      for (Integer i=0; i<salesMotionPages.size(); i++){
          if(salesMotionPages[i].Id == testMarketingPage.Id)
              deletedPages.add(salesMotionPages[i]);
      }
      
      delete deletedPages; 
      
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      
      Test.stopTest();  
  
      //System.assert(controller.salesMotion !=null);
      System.assertEquals(3, controller.salesMotionPages.size()); // Uncommented  DP 12 June
      //System.assertEquals(1, controller.salesMotionPages.size()); // Commented  DP 12 June
      
  }
  
  static void simulateFirstClickSalesMotionButtonOnOppWithOnePage(){
  
      List<Sales_Motion_Page__c> salesMotionPages = [Select p.Id from Sales_Motion_Page__c p 
          where Sales_Motion_Name__c = :testSalesMotion.Id];
      
      List<Sales_Motion_Page__c> deletedPages = new List<Sales_Motion_Page__c>();
      
      for (Integer i=0; i<salesMotionPages.size(); i++){
          if(salesMotionPages[i].Id != testMarketingPage.Id)
              deletedPages.add(salesMotionPages[i]);
      }
      
      delete deletedPages; 
      
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
      
      
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      
      Test.stopTest();  
  
      System.assert(controller.salesMotion !=null);
      System.assertEquals(1, controller.salesMotionPages.size());  
      controller.getSupportRequest();
      controller.goback();
  }
  
  static void simulateFirstClickSalesMotionButtonOnOppWithoutSM(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name XXX');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      
      Test.stopTest();  
  
      System.assert(controller.salesMotion ==null);
      //System.assertEquals('Sales Motion is not currently available for this solution.', controller.smErrMsg); 
      
  }
  
  /*
  
  static void simulateClickOnStageLink(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
                 
      ApexPages.currentPage().getParameters().put('currentPage', testMarketingPage.Id);
      ApexPages.currentPage().getParameters().put('currentStage', 'Test SalesForce Stage');  
      
      controller.refreshSectionData();
      
      Test.stopTest();  
        
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());  
      System.assert(controller.stages.size() > 0);
      
      System.assertEquals(2, controller.currentLeftSections.size());  
      System.assertEquals(2, controller.currentRightSections.size());  
      
      System.assertEquals(true, controller.isStagedEnabled);  
      
      System.assert(controller.smErrMsg==null); 
      
      System.assert(controller.smSearchMsg==null);
      
  }
  
  static void simulateScenarioWithoutCountryMappingRecord(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Qualify - 30%');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
            
      controller.salesEdgeDataProcesser.isError = false;
      controller.salesEdgeDataProcesser.salesEdgeRecordMap = null;
            
      ApexPages.currentPage().getParameters().put('currentPage', testMarketingPage.Id);
      ApexPages.currentPage().getParameters().put('currentStage', 'Plan - 1%');  
      
      controller.refreshSectionData();
      
      Test.stopTest();  
        
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());  
      System.assert(controller.stages.size() > 0);
      
      System.assertEquals(2, controller.currentLeftSections.size());  
      System.assertEquals(2, controller.currentRightSections.size());  
      
      System.assertEquals(true, controller.isStagedEnabled);  
      
      System.assert(controller.smErrMsg==null); 
      
      System.assert(controller.smSearchMsg==null);
   
  }
  */
  static void simulateScenarioWithExceptionHappenWhileAccessSalesEdge(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      
      Map<String,List<SalesEdgeRecord>> testSalesEdgeRecordMap = new Map<String,List<SalesEdgeRecord>>();
      
      SalesEdgeException testException = new SalesEdgeException('error', 'error', 'test error message');
      
      SalesEdgeRecord record1 = new SalesEdgeRecord();
      record1.setSalesMotionId(testSalesMotion.Id);
      record1.setChronicleId('TestChronicleId');
      record1.setDescription('Test SalesEdge Record');
      record1.setTitle('Exception');
      record1.setClassification(new List<SalesEdgeClassification>());
      record1.setMetadata(new Map<string,string>());
      record1.setExceptions(new List<SalesEdgeException>{testException});
          
      testSalesEdgeRecordMap.put('Exception', new List<SalesEdgeRecord>{record1});
      salesEdgeDataProcesser =new SalesEdgeDataProcesser();

      salesEdgeDataProcesser.salesEdgeRecordMap = testSalesEdgeRecordMap;
            
      ApexPages.currentPage().getParameters().put('currentPage', testMarketingPage.Id);
      ApexPages.currentPage().getParameters().put('currentStage', 'Test SalesForce Stage');  
      
      controller.refreshSectionData();
      
      Test.stopTest();  
        
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());  //Uncommented  DP 12 June 
      //System.assertEquals(2, controller.salesMotionPages.size()); //Commented  DP 12 June  
      System.assert(controller.stages.size() > 0);
      
      //System.assertEquals(2, controller.currentLeftSections.size());  
      //System.assertEquals(2, controller.currentRightSections.size());  
      
      System.assertEquals(true, controller.isStagedEnabled);  
      
      //System.assert(controller.smErrMsg==null); 
      
      System.assert(controller.smSearchMsg==null);
      
  
  }
  
  static void simulateScenarioWithNoSalesEdgeRecordsFromSalesEdge(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      salesEdgeDataProcesser =new SalesEdgeDataProcesser();
      
      salesEdgeDataProcesser.isError = false;
      salesEdgeDataProcesser.salesEdgeRecordMap = null;
            
      ApexPages.currentPage().getParameters().put('currentPage', testMarketingPage.Id);
      ApexPages.currentPage().getParameters().put('currentStage', 'Test SalesForce Stage');  
      
      controller.refreshSectionData();
      
      Test.stopTest();  
        
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());  //Uncommented  DP 12 June 
      //System.assertEquals(2, controller.salesMotionPages.size()); //Commented  DP 12 June
      System.assert(controller.stages.size() > 0);
      
      //System.assertEquals(2, controller.currentLeftSections.size());  
      //System.assertEquals(2, controller.currentRightSections.size());  
      
      System.assertEquals(true, controller.isStagedEnabled);  
      
      //System.assert(controller.smErrMsg==null); 
      
      System.assert(controller.smSearchMsg==null);
   
  }
  
  static void simulateScenarioWithoutStageMapping(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      
      //SalesEdgeDataProcesser =new salesEdgeDataProcesser();
      salesEdgeDataProcesser =new SalesEdgeDataProcesser();
      
      //controller.salesEdgeDataProcesser.isError = false;
      salesEdgeDataProcesser.isError = false;

      Map<String,List<SalesEdgeRecord>> testSalesEdgeRecordMap = new Map<String,List<SalesEdgeRecord>>();
      
      SalesEdgeRecord record1 = new SalesEdgeRecord();
      record1.setSalesMotionId(testSalesMotion.Id);
      record1.setChronicleId('TestChronicleId');
      record1.setDescription('Test SalesEdge Record');
      record1.setTitle('Section_Category_3');
      
      List<SalesEdgeClassification> record1Classification = new List<SalesEdgeClassification>();
      record1Classification.add(new SalesEdgeClassification('Test-SalesEdge-Stage',  '',  '',  '',''));
      record1Classification.add(new SalesEdgeClassification('', 'Document Type',  'Document Type', '', ''));
      record1.setClassification(record1Classification );
      
      Map<String, String> record1Metadata = new Map<String, String>();
      record1Metadata.put('P_DocumentLanguage', 'en');
      record1Metadata.put('P_DocumentDate', '12/12/2012');
      record1Metadata.put('P_FullFormat', 'txt');
      record1Metadata.put('P_SizeBytes', '1023');
      record1.setMetaData(record1Metadata);
      
      testSalesEdgeRecordMap.put('Section Category 3', new List<SalesEdgeRecord>{record1});
      salesEdgeDataProcesser.salesEdgeRecordMap = testSalesEdgeRecordMap;
            
      ApexPages.currentPage().getParameters().put('currentPage', testMarketingPage.Id);
      ApexPages.currentPage().getParameters().put('currentStage', 'No mapping SalesForce Stage');  
      
      controller.refreshSectionData();
      
      Test.stopTest();  
        
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());  //Uncommented  DP 12 June 
      //System.assertEquals(2, controller.salesMotionPages.size());//Commented  DP 12 June
      System.assert(controller.stages.size() > 0);
      
      System.assertEquals(true, controller.isStagedEnabled);  
      
      //System.assert(controller.smErrMsg==null); 
      
      System.assert(controller.smSearchMsg==null);
  
  }
  
  static void simulateScenarioWithRecordsFromSalesEdge(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();
      
      Map<String,List<SalesEdgeRecord>> testSalesEdgeRecordMap = new Map<String,List<SalesEdgeRecord>>();
      
      SalesEdgeRecord record1 = new SalesEdgeRecord();
      record1.setSalesMotionId(testSalesMotion.Id);
      record1.setChronicleId('TestChronicleId');
      record1.setDescription('Test SalesEdge Record');
      record1.setTitle('Section_Category_1');
      
      List<SalesEdgeClassification> record1Classification = new List<SalesEdgeClassification>();
      record1Classification.add(new SalesEdgeClassification('Test-SalesEdge-Stage',  '',  '',  '',''));
      record1Classification.add(new SalesEdgeClassification('', 'Document Type',  'Document Type', '', ''));
      record1.setClassification(record1Classification );
      
      Map<String, String> record1Metadata = new Map<String, String>();
      record1Metadata.put('P_DocumentLanguage', 'en');
      record1Metadata.put('P_DocumentDate', '12/12/2012');
      record1Metadata.put('P_FullFormat', 'txt');
      record1Metadata.put('P_SizeBytes', '1023');
      record1.setMetaData(record1Metadata);
      
      SalesEdgeRecord record2 = new SalesEdgeRecord();
      record2.setSalesMotionId(testSalesMotion.Id);
      record2.setChronicleId('TestChronicleId');
      record2.setDescription('Test SalesEdge Record');
      record2.setTitle('Section Category 1');
      
      List<SalesEdgeClassification> record2Classification = new List<SalesEdgeClassification>();
      record2Classification.add(new SalesEdgeClassification('Test-SalesEdge-Stage',  '',  '',  '',''));
      record2Classification.add(new SalesEdgeClassification('', 'Document Type',  'Document Type', '', ''));
      record2.setClassification(record2Classification );
      
      Map<String, String> record2Metadata = new Map<String, String>();
      record2Metadata.put('P_DocumentLanguage', 'en');
      record2Metadata.put('P_DocumentDate', '12/12/2012');
      record2Metadata.put('P_FullFormat', 'txt');
      record2Metadata.put('P_SizeBytes', '1025');
      record2.setMetaData(record2Metadata);
      
      
      SalesEdgeRecord record3 = new SalesEdgeRecord();
      record3.setSalesMotionId(testSalesMotion.Id);
      record3.setChronicleId('TestChronicleId');
      record3.setDescription('Test SalesEdge Record');
      record3.setTitle('Section Category 3');
      
      List<SalesEdgeClassification> record3Classification = new List<SalesEdgeClassification>();
      record3Classification.add(new SalesEdgeClassification('Test-SalesEdge-Stage',  '',  '',  '',''));
      record3Classification.add(new SalesEdgeClassification('', 'Document Type',  'Document Type', '', ''));
      record3.setClassification(record3Classification );
      
      Map<String, String> record3Metadata = new Map<String, String>();
      record3Metadata.put('P_DocumentLanguage', 'en');
      record3Metadata.put('P_DocumentDate', '12/12/2012');
      record3Metadata.put('P_FullFormat', 'txt');
      record3Metadata.put('P_SizeBytes', '1048577');
      record3.setMetaData(record3Metadata);
            
      SalesEdgeRecord record4 = new SalesEdgeRecord();
      record4.setSalesMotionId(testSalesMotion.Id);
      record4.setChronicleId('TestChronicleId');
      record4.setDescription('Test SalesEdge Record');
      record4.setTitle('Section Category 3');
      
      List<SalesEdgeClassification> record4Classification = new List<SalesEdgeClassification>();
      record4Classification.add(new SalesEdgeClassification('Test-SalesEdge-Stage',  '',  '',  '',''));
      record4Classification.add(new SalesEdgeClassification('', 'Document Type',  'Document Type', '', ''));
      record4.setClassification(record4Classification );
      
      Map<String, String> record4Metadata = new Map<String, String>();
      record4Metadata.put('P_DocumentLanguage', 'en');
      record4Metadata.put('P_DocumentDate', '12/12/2012');
      record4Metadata.put('P_FullFormat', 'xxxxxxxxxxxxx');
      record4Metadata.put('P_SizeBytes', '1073741826');
      record4.setMetaData(record4Metadata);
      
      SalesEdgeRecord record5 = new SalesEdgeRecord();
      record5.setSalesMotionId(testSalesMotion.Id);
      record5.setChronicleId('TestChronicleId');
      record5.setDescription('Test SalesEdge Record');
      record5.setTitle('Section Category 3');
      
      List<SalesEdgeClassification> record5Classification = new List<SalesEdgeClassification>();
      record5Classification.add(new SalesEdgeClassification('Wrong-SalesEdge-Stage',  '',  '',  '',''));
      record5Classification.add(new SalesEdgeClassification('', 'Document Type',  'Document Type', '', ''));
      record5.setClassification(record5Classification );
      
      Map<String, String> record5Metadata = new Map<String, String>();
      record5Metadata.put('P_DocumentLanguage', 'en');
      record5Metadata.put('P_DocumentDate', '12/12/2012');
      record5Metadata.put('P_FullFormat', 'xxxxxxxxxxxxx');
      record5Metadata.put('P_SizeBytes', '1073741826');
      record5.setMetaData(record5Metadata);
                  
      testSalesEdgeRecordMap.put('Section Category 1', new List<SalesEdgeRecord>{record1, record2, record3, record4});
      testSalesEdgeRecordMap.put('Section Category 3', new List<SalesEdgeRecord>{record5});
      salesEdgeDataProcesser =new SalesEdgeDataProcesser();

      //controller.salesEdgeDataProcesser.isError = false;
      salesEdgeDataProcesser.isError = false;

      salesEdgeDataProcesser.salesEdgeRecordMap = testSalesEdgeRecordMap;
            
      ApexPages.currentPage().getParameters().put('currentPage', testMarketingPage.Id);
      ApexPages.currentPage().getParameters().put('currentStage', 'Test SalesForce Stage');  
      
      controller.refreshSectionData();
      
      Test.stopTest();  
        
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());   //Uncommented  DP 12 June 
      //System.assertEquals(2, controller.salesMotionPages.size()); //Commented  DP 12 June  
      System.assert(controller.stages.size() > 0);
      
      //System.assertEquals(2, controller.currentLeftSections.size());  
      //System.assertEquals(2, controller.currentRightSections.size());  
      
      System.assertEquals(true, controller.isStagedEnabled);  
      
      //System.assert(controller.smErrMsg==null); 
      
      System.assert(controller.smSearchMsg==null);
      
      
  }
  
  static void simulateClickOnSearchLink(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
        
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion (); 
      
      ApexPages.currentPage().getParameters().put('currentPage', 'Search');
      ApexPages.currentPage().getParameters().put('currentStage', '');  
      
      controller.refreshSectionData();
      
      Test.stopTest();  
       
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());  //Uncommented  DP 12 June 
      //System.assertEquals(2, controller.salesMotionPages.size());// Commented  DP 12 June
      System.assert(controller.stages.size() > 0);
            
      System.assert(controller.currentLeftSections==null);  
      System.assert(controller.currentRightSections==null);  
      
      //System.assertEquals(true, controller.isStagedEnabled);  
            
      //System.assert(controller.smErrMsg==null); 
      
      System.assert(controller.smSearchMsg==null);
  
  }
  
  static void simulateSearchWithoutEnoughSearchCriteria(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
      
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();    
      
      Opportunity salesMotionSearch = controller.getSalesMotionSearch();
      
      salesMotionSearch.Domain__c = '';
      salesMotionSearch.Solution_Type__c = '';
      salesMotionSearch.Solution_Name__c = '';
      
      controller.setSalesMotionSearch(salesMotionSearch);
      
      controller.searchSalesMotion();
      
      Test.stopTest();  
            
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());   //Uncommented  DP 12 June 
      //System.assertEquals(2, controller.salesMotionPages.size()); //Commented  DP 12 June 
      System.assert(controller.stages.size() > 0);
            
      System.assert(controller.currentLeftSections==null);  
      System.assert(controller.currentRightSections==null);  
      
      //System.assertEquals(true, controller.isStagedEnabled);  
            
      //System.assert(controller.smErrMsg==null); 
      
      System.assertEquals('Please enter all search criterias above.', controller.smSearchMsg);
     
  }
    
  static void simulateSearchWithEnoughSearchCriteria(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
      
      
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();  
      
      controller.salesMotionSearch.Domain__c = 'Test Domain';
      controller.salesMotionSearch.Solution_Type__c = 'Test Solution Type';
      controller.salesMotionSearch.Solution_Name__c = 'Test Solution Name';
      
      controller.searchSalesMotion();
      
      Test.stopTest();  
     
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());   //Uncommented  DP 12 June 
      //System.assertEquals(2, controller.salesMotionPages.size()); //Commented  DP 12 June    
      System.assert(controller.stages.size() > 0);
      
      System.assert(controller.currentLeftSections==null);  
      System.assert(controller.currentRightSections==null);  
      
      //System.assertEquals(true, controller.isStagedEnabled);  
      
      //System.assert(controller.smErrMsg==null); 
      
      System.assert(controller.smSearchMsg==null);  
  
  }
  
  static void simulateSearchWithNoSMFound(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
      
      
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();  
      
      controller.salesMotionSearch.Domain__c = 'Test Domain';
      controller.salesMotionSearch.Solution_Type__c = 'Test Solution Type XXX';
      controller.salesMotionSearch.Solution_Name__c = 'Test Solution Name';
      
      controller.searchSalesMotion();
      
      Test.stopTest();  
     
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());   //Uncommented  DP 12 June 
      //System.assertEquals(2, controller.salesMotionPages.size()); //Commented  DP 12 June   
      System.assert(controller.stages.size() > 0);
      
      System.assert(controller.currentLeftSections==null);  
      System.assert(controller.currentRightSections==null);  
      
      //System.assertEquals(true, controller.isStagedEnabled);  
      
      //System.assert(controller.smErrMsg==null); 
      
      //System.assertEquals('Sales Motion is not currently available for this solution.', controller.smSearchMsg);
      
  
  }
  
  static void simulateSearchWithNoSMPageFound(){
  
      PageReference pageRef = Page.SalesMotion;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('domain', 'Test Domain');
      ApexPages.currentPage().getParameters().put('soltype', 'Test Solution Type');  
      ApexPages.currentPage().getParameters().put('solname', 'Test Solution Name');
      ApexPages.currentPage().getParameters().put('country', 'Malaysia');
      ApexPages.currentPage().getParameters().put('stage', 'Another SalesForce Stage');
      
    
      Test.startTest();    
        
      controller = new VFCntrlr_SalesMotion ();  
      
      deleteAllPages();
      
      controller.salesMotionSearch.Domain__c = 'Test Domain';
      controller.salesMotionSearch.Solution_Type__c = 'Test Solution Type';
      controller.salesMotionSearch.Solution_Name__c = 'Test Solution Name';
      
      controller.searchSalesMotion();
      
      Test.stopTest();  
     
      System.assert(controller.salesMotion !=null);
      System.assertEquals(4, controller.salesMotionPages.size());   //Uncommented  DP 12 June 
      //System.assertEquals(2, controller.salesMotionPages.size()); //Commented  DP 12 June
      System.assert(controller.stages.size() > 0);
      
      System.assert(controller.currentLeftSections==null);  
      System.assert(controller.currentRightSections==null);  
      
      //System.assertEquals(true, controller.isStagedEnabled);  
      
      //System.assert(controller.smErrMsg==null); 
      
      //System.assertEquals('There is no Sales Motion pages available for the Sales Motion.', controller.smSearchMsg);
      
  
  }
  
  static void deleteAllPages(){
  
      List<Sales_Motion_Page__c> salesMotionPages = [Select p.Id from Sales_Motion_Page__c p 
          where Sales_Motion_Name__c = :testSalesMotion.Id];
      
      delete salesMotionPages;         
  
  }
    
  static void createTestData(){
  
      OppDetails=new opportunity(Name='testopp',StageName='Qualify - 30%',Region__c='APJ',Competitor_Lost_To__c='Unknown',CloseDate=system.today());
      insert OppDetails;
      
          
      
      
      
  
      testSalesMotion = new Sales_Motion__c(Name='Sales Motion Test', SalesEdge_Category__c='\test', 
          Domain__c='Test Domain', Solution_Type__c='Test Solution Type', Solution_Name__c='Test Solution Name',IsActive__c=true);
     
      insert testSalesMotion;
      
      testMarketingPage = [Select p.Stages_Enabled__c,p.IsActive__c from Sales_Motion_Page__c p 
          where Sales_Motion_Name__c = :testSalesMotion.Id and p.Name= 'Marketing/Sales ToolKit' limit 1];
          
      testMarketingPage.Stages_Enabled__c = true;
      testMarketingPage.IsActive__c = true;
      
      update testMarketingPage;
      testSummaryPage= [Select p.Stages_Enabled__c,p.IsActive__c from Sales_Motion_Page__c p 
          where Sales_Motion_Name__c = :testSalesMotion.Id and p.Name= 'Summary' limit 1];
          
      testSummaryPage.Stages_Enabled__c = false;
      testSummaryPage.IsActive__c = true;

      update testSummaryPage;
      
      String salesEdgeRecordTypeId = IdLookupUtils.getRecordTypeId('SalesEdge Content', 'Sales_Motion_Page_Section__c', true); 
      String staticRecordTypeId = IdLookupUtils.getRecordTypeId('Static Content', 'Sales_Motion_Page_Section__c', true); 
      
      List<Sales_Motion_Page_Section__c> sectionList = new List<Sales_Motion_Page_Section__c>();
              
      Sales_Motion_Page_Section__c testSection1 = new Sales_Motion_Page_Section__c( RecordTypeId =staticRecordTypeId, 
          Name = 'Test Content 1', Type__c = 'Static Content', Sales_Motion_Page__c = testMarketingPage.Id,
          Side_Bar__c = false, Stage__c = 'Test SalesForce Stage', Sort_Order__c =1,
          Section_Content__c = 'Test Content 1');
      
      sectionList.add(testSection1);
      
      Sales_Motion_Page_Section__c testSection2 = new Sales_Motion_Page_Section__c (RecordTypeId =salesEdgeRecordTypeId , 
          Name = 'Test Content 2', Type__c = 'SalesEdge Content', Sales_Motion_Page__c = testMarketingPage.Id,
          Side_Bar__c = false, Stage__c = 'Test SalesForce Stage', Sort_Order__c =2,          
          SalesEdge_Category__c ='Section Category 1');
      
      sectionList.add(testSection2);
          
      Sales_Motion_Page_Section__c testSection3 = new Sales_Motion_Page_Section__c( RecordTypeId =salesEdgeRecordTypeId , 
          Name = 'Test Content 3', Type__c = 'SalesEdge Content', Sales_Motion_Page__c = testMarketingPage.Id,
          Side_Bar__c = true, Country_List__c = 'Malaysia', Stage__c = 'Test SalesForce Stage', Sort_Order__c =1,
          SalesEdge_Category__c ='Section Category 2');
      
      sectionList.add(testSection3);  
        
      Sales_Motion_Page_Section__c testSection4 = new Sales_Motion_Page_Section__c( RecordTypeId =salesEdgeRecordTypeId , 
          Name = 'Test Content 4', Type__c = 'SalesEdge Content', Sales_Motion_Page__c = testMarketingPage.Id,
          Side_Bar__c = true, Country_List__c = 'Malaysia', Stage__c = 'Test SalesForce Stage', Sort_Order__c =2,
          SalesEdge_Category__c ='Section Category 3');
      
      sectionList.add(testSection4);        
      
      Sales_Motion_Page_Section__c testSection5 = new Sales_Motion_Page_Section__c( RecordTypeId =staticRecordTypeId, 
          Name = 'Test Content 5', Type__c = 'Static Content', Sales_Motion_Page__c = testSummaryPage.Id,
          Side_Bar__c = true, Country_List__c = 'Malaysia', Stage__c = 'Test SalesForce Stage', Sort_Order__c =2,
          Section_Content__c = 'Test Content 2');
      
      sectionList.add(testSection5); 
      
      Sales_Motion_Page_Section__c testSection6 = new Sales_Motion_Page_Section__c(RecordTypeId =salesEdgeRecordTypeId , 
          Name = 'Test Content 6', Type__c = 'SalesEdge Content', Sales_Motion_Page__c = testMarketingPage.Id,
          Side_Bar__c = true, Country_List__c = 'Malaysia', Stage__c = 'No mapping SalesForce Stage', Sort_Order__c =2,
          SalesEdge_Category__c ='Section Category 3');
      
      sectionList.add(testSection6); 
      
      Sales_Motion_Page_Section__c testSection7 = new Sales_Motion_Page_Section__c(RecordTypeId =staticRecordTypeId, 
          Name = 'Test Content 7', Type__c = 'Static Content', Sales_Motion_Page__c = testSummaryPage.Id,
          Side_Bar__c = true, Country_List__c = 'Test', Stage__c = 'No mapping SalesForce Stage', Sort_Order__c =2,Support_Request_Type__c = 'Request Contract Support',
          SalesEdge_Category__c ='Section Category 3');
      
      sectionList.add(testSection7); 
      
      insert sectionList;
      
    }
  
    static void createMappingTestData(){
      
      //String mappingCountryRecordTypeId = IdLookupUtils.getRecordTypeId('Sales Motion Country', 'Sales_Motion_Mappings__c', true); 
      String mappingStageRecordTypeId = IdLookupUtils.getRecordTypeId('Sales Motion Stage', 'Sales_Motion_Mappings__c', true); 
      
      //Sales_Motion_Mappings__c mappings = new Sales_Motion_Mappings__c(RecordTypeId=mappingCountryRecordTypeId, SalesEdge_Country__c='Malaysia', Salesforce_Country__c='Malaysia');
      Sales_Motion_Mappings__c mappings = new Sales_Motion_Mappings__c(Name = 'Test Stage', RecordTypeId=mappingStageRecordTypeId , SalesEdge_Opportunity_Stage__c='Test-SalesEdge-Stage', Salesforce_Opportunity_Stage__c='Test SalesForce Stage');
      
      insert mappings;
        
    }
    
}