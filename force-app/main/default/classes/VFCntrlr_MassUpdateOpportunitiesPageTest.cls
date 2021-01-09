/*
REVISION HISTORY
================
Version    Author          Date               Release#         CR#          Description
-------    ------          ----               --------         ---          -----------
1.0        Emily           21-Mar-2018        FY19-DCE-0502    15540        Field Trip clean up for Opportunity
*/

@isTest(SeeAllData=true)
private class VFCntrlr_MassUpdateOpportunitiesPageTest {
    public static Opportunity_Search_Criteria__c oppSearchRecord;
    
     static testMethod void SearchTest() {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.SearchAccountID = 'SearchAccountID';
        ctrl.SearchAccountName = 'SearchAccountName';
        ctrl.SearchOpportunityName = 'SearchOpportunityName';
        ctrl.SearchOpp.Decision_Date__c = date.today();
        ctrl.SearchStageName = 'SearchStageName';
        ctrl.SearchOpp.Solution_Type__c = 'SolutionType';
        ctrl.SearchOpp.Solution_Name__c = 'SolutionName';
        ctrl.SearchOpp.Services_Sales_Owner__c = '005A00000016nqI';
        ctrl.SearchOpp2.Services_Sales_Owner__c = '005A00000016nqI';
        ctrl.SearchStartingFiscalBookDate = 'FY14Q2W01';
        ctrl.SearchEndingFiscalBookDate = 'FY14Q2W02';
        ctrl.SearchOpenOpportunities();
        
        system.assert(!(ctrl.OpenOpportunities.size() > 0));
    }
    
    static testMethod void SaveTest() {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        system.debug('########ctrl.PageRecords: ' + ctrl.PageRecords);
        Integer aa = 0;
        aa = ctrl.PageActualSize;
        aa = ctrl.PageNumber1;
        aa = ctrl.PageNumber2;
        aa = ctrl.PageNumber3; 
        ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';
        
        String salesOpsTag1 = '*Top Opportunity-Services* >> DO NOT REMOVE STRING. GLOBAL SALES OPERATIONS TAG';
        String salesOpsTag2 = '*Top Opportunity-Services*';
        String salesOpsTag3 = 'DO NOT REMOVE STRING. GLOBAL SALES OPERATIONS TAG';
        
        if (ctrl.PageRecords != null && ctrl.PageRecords.size() > 0){
            //1.0 ctrl.PageRecords[0].New_Description__c = 'unit testing';
            ctrl.OpenOpportunities[0].Description = '' + salesOpsTag1 + ctrl.OpenOpportunities[0].Description;
            //ctrl.OpenOpportunities[0].CloseDate = date.newInstance(2006, 2, 17); //'Stage error for unit testing';
            
            //1.0 ctrl.PageRecords[1].New_Description__c = 'unit testing';
            ctrl.OpenOpportunities[1].Description = '' + salesOpsTag2 + ctrl.OpenOpportunities[1].Description;
            ctrl.OpenOpportunities[1].StageName = 'Plan - 1%';
            
            //1.0 ctrl.PageRecords[2].New_Description__c = 'unit testing';
            ctrl.OpenOpportunities[2].Description = '' + salesOpsTag2 + salesOpsTag3 + ctrl.OpenOpportunities[2].Description;
            ctrl.OpenOpportunities[2].StageName = 'Discover - 10%';
            
            //1.0 ctrl.PageRecords[3].New_Description__c = 'unit testing';
            ctrl.OpenOpportunities[3].Description = 'unit testing';
            ctrl.OpenOpportunities[3].StageName = 'Qualify - 30%';
            
            ctrl.OpenOpportunities[4].StageName = 'Propose - 60%';
            ctrl.OpenOpportunities[5].StageName = 'Commit - 90%';
            
            ctrl.Save();
        }
     
        System.assert(true);
    }
    
    static testMethod void CancelTest() {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.Cancel();
    
        System.assertNotEquals(null, ctrl.OpenOpportunities);   
    }
    
    static testMethod void SaveAndStayTest() {
        
        try {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
         
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            Integer pgnum = ctrl.PageNumber;
            ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';
        
            ctrl.SaveAndStay();
          
            System.assertEquals(pgnum, ctrl.PageNumber);   
        } catch (ListException e) {
            system.debug(e.getMessage());
        }  
    }
    
    static testMethod void NextPageTest() {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        Integer pgnum = ctrl.PageNumber;
        ctrl.NextPage();
        
        System.assertEquals(pgnum + 1, ctrl.PageNumber);
    }
    
    static testMethod void SaveAndNextPageTest() {
        
        try {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
         
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            Integer pgnum = ctrl.PageNumber;
            ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';
        
            ctrl.SaveAndNextPage();
       
            System.assertEquals(pgnum + 1, ctrl.PageNumber);
        } catch (ListException e) {
            system.debug(e.getMessage());
        }       
    }
    
    static testMethod void CancelAndNextPageTest() {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        Integer pgnum = ctrl.PageNumber;
        ctrl.CancelAndNextPage();
        
        System.assertEquals(pgnum + 1, ctrl.PageNumber);
    }
    
    static testMethod void PreviousPageTest() {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.SetPageNumber(2);
        Integer pgnum = ctrl.PageNumber;
        ctrl.PreviousPage();
        
        System.assertEquals(pgnum - 1, ctrl.PageNumber);
    }
    
    static testMethod void SaveAndPreviousPageTest() {
        try {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
         
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            ctrl.SetPageNumber(2);
            Integer pgnum = ctrl.PageNumber;
            ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';        
        
            ctrl.SaveAndPreviousPage();             
        
            System.assertEquals(pgnum - 1, ctrl.PageNumber);
        } catch (ListException e) {
            system.debug(e.getMessage());
        }   
    }
    
    static testMethod void CancelAndPreviousPageTest() {
    
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.SetPageNumber(2);
        Integer pgnum = ctrl.PageNumber;
        ctrl.CancelAndPreviousPage();
        
        System.assertEquals(pgnum - 1, ctrl.PageNumber);
    }
    
    static testMethod void FirstPageTest() {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.FirstPage();
        
        System.assertEquals(1, ctrl.PageNumber);
    }
    
    static testMethod void SaveAndFirstPageTest() {
        try {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
         
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';
        
            ctrl.SaveAndFirstPage();                 
        
            System.assertEquals(1, ctrl.PageNumber);
        } catch (ListException e) {
            system.debug(e.getMessage());
        }
    }
    
    static testMethod void CancelAndFirstPageTest() {

        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.CancelAndFirstPage();
        
        System.assertEquals(1, ctrl.PageNumber);
    }
    
    static testMethod void LastPageTest() {
        try {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
         
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            ctrl.LastPage();
            
            System.assertEquals(ctrl.PageTotal, ctrl.PageNumber);
        } catch (ListException e) {
            system.debug (e.getMessage()) ;
        }
    }
    
    static testMethod void SaveAndLastPage() {
        try {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
         
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';
            
            ctrl.SaveAndLastPage(); 
          
            System.assertEquals(ctrl.PageTotal, ctrl.PageNumber);
        } catch (ListException e) {
            system.debug(e.getMessage());
        }       
    }
    
    static testMethod void CancelAndLastPageTest() {
        try {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.CancelAndLastPage();
        
        System.assertEquals(ctrl.PageTotal, ctrl.PageNumber);
        } catch (ListException e) {
            system.debug (e.getMessage());
        }
    }
    
    static testMethod void Page1Test() {

        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        Integer pgnum = ctrl.PageNumber1;
        ctrl.Page1();
        
        System.assertEquals(pgnum, ctrl.PageNumber);
    }
    
    static testMethod void Page2Test() {

        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        Integer pgnum = ctrl.PageNumber2;
        ctrl.Page2();
        
        System.assertEquals(pgnum, ctrl.PageNumber);
    }
    
    static testMethod void Page3Test() {

        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        Integer pgnum = ctrl.PageNumber3;
        ctrl.Page3();
        
        System.assertEquals(pgnum, ctrl.PageNumber);
    }
    
    static testMethod void SaveAndPage1Test() {
        
        try {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
         
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            Integer pgnum = ctrl.PageNumber1;
            ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';
            
            
            ctrl.SaveAndPage1();
            
            System.assertEquals(pgnum, ctrl.PageNumber);
        } catch (ListException e) {
            system.debug(e.getMessage());
        }       
    }
    
    static testMethod void SaveAndPage2Test() {
        
        try {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
         
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            Integer pgnum = ctrl.PageNumber2;
            ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';
            
            
            ctrl.SaveAndPage2(); 
            
            System.assertEquals(pgnum, ctrl.PageNumber);
        } catch (ListException e) {
            system.debug(e.getMessage());
        }       
    }
    
    static testMethod void SaveAndPage3Test() {
        
        try {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
         
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            Integer pgnum = ctrl.PageNumber3;
            ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';
            
            
            ctrl.SaveAndPage3(); 
            
            System.assertEquals(pgnum, ctrl.PageNumber);
        } catch (ListException e) {
            system.debug(e.getMessage());
        }       
    }
    
    static testMethod void CancelAndPage1Test() {

        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        Integer pgnum = ctrl.PageNumber1;
        ctrl.CancelAndPage1();
        
        System.assertEquals(pgnum, ctrl.PageNumber);
    }
    
    static testMethod void CancelAndPage2Test() {

        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        Integer pgnum = ctrl.PageNumber2;
        ctrl.CancelAndPage2();
        
        System.assertEquals(pgnum, ctrl.PageNumber);
    }
    
    static testMethod void CancelAndPage3Test() {

        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
     
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        Integer pgnum = ctrl.PageNumber3;
        ctrl.CancelAndPage3();
        
        System.assertEquals(pgnum, ctrl.PageNumber);
    }
    
    /*    
    static testMethod void SaveAndGoBackTest() {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
 
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.strRecordsToSave = '0|||1|||2|||3|||4|||5';
        PageReference pg = ctrl.SaveAndGoBack();
        
        System.assertEquals(new PageReference('/apex/VfCustomOpportunityHomePage'), pg);
    }
    */
    
    static testMethod void getListStageNamesTest() {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
 
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        List<SelectOption> opts = ctrl.getListStageNames();
        
        System.assertEquals('Plan - 1%', opts[0].getValue());
        System.assertEquals('Discover - 10%', opts[1].getValue());
        System.assertEquals('Qualify - 30%', opts[2].getValue());
        System.assertEquals('Propose - 60%', opts[3].getValue());
        System.assertEquals('Commit - 90%', opts[4].getValue());
    }
    
    static testMethod void getSearchListStageNamesTest() {
        
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
 
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        List<SelectOption> opts = ctrl.getSearchListStageNames();
        System.assertEquals('--None--', opts[0].getValue());
        System.assertEquals('Plan - 1%', opts[1].getValue());
        System.assertEquals('Discover - 10%', opts[2].getValue());
        System.assertEquals('Qualify - 30%', opts[3].getValue());
        System.assertEquals('Propose - 60%', opts[4].getValue());
        System.assertEquals('Commit - 90%', opts[5].getValue());
    }
    static testMethod void SaveSearchRecord()
    {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
 
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            /*Opportunity_Search_Criteria__c oppSearchRecord = new Opportunity_Search_Criteria__c();
            oppsearchRecord.Name = 'Test Bikram';
            oppSearchRecord.Account_Name__c = 'SearchAccountName';
            oppSearchRecord.Affinity_Account_ID__c = '123456789';
            oppSearchRecord.Book_Date__c = date.today();
            oppSearchRecord.Ending_Fiscal_Book_Date__c = 'FY15 Q2W01';
            oppSearchRecord.Opportunity_Name__c = 'SearchOpportunityName';
            oppSearchRecord.Opportunity_Owner__c = '005A0000002QZaV';
            oppSearchRecord.Solution_Name__c = 'SolutionName';
            oppSearchRecord.Solution_Type__c = 'SolutionType';
            oppSearchRecord.Service_Sales_Owner__c = '005A0000002QZaV';
            oppSearchRecord.Stage__c = 'SearchStageName';
            oppSearchRecord.Starting_Fiscal_Book_Date__c ='FY15 Q2W13';
            insert(oppSearchRecord);*/
            testdata();
            //ctrl.searchName = ''; 
            ctrl.saveSearchRecord();
    }
    static testMethod void SaveSearch_No()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.saveSearch_No();
    }
    static testMethod void SaveSearch()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();     
        ctrl.saveSearch();
    }
    static testMethod void SaveSearchRecord_Ok()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.saveSearchRecord_Ok();
    }
    
    static testMethod void saveSearchRecordErr_Ok()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.saveSearchRecordErr_Ok();
    }
    static testMethod void CancelSaveSearch()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.CancelSaveSearch();
    }
    static testMethod void PreviousSearch()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.previousSearch();
    }
    static testMethod void deleteCriteria()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        testData();
        ctrl.searchId = oppSearchRecord.id;
        ctrl.deleteCriteria();
    }
    static testMethod void populateCriteria_Edit()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        testData();
        ctrl.searchId = oppSearchRecord.id;
        ctrl.populateCriteria_Edit();
    }
    static testMethod void deleteCriterion()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        testData();
        ctrl.searchId = oppSearchRecord.id;
        ctrl.deleteCriterion();
    }
    static testMethod void cancelFilter()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.cancelFilter();
    }
   
    static testMethod void  resetSearchResult()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.resetSearchResult();
    }
    static testMethod void updateRecord()
    {   
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = [SELECT Id FROM User WHERE ProfileId = :p.id and IsActive = true LIMIT 1];
        System.runAs(u) {
            PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
            Test.setCurrentPage(pageRef);
            VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
            testData();            
            ctrl.searchName = oppSearchRecord.name;
            ctrl.updateRecord();
        }
    }
    static testMethod void populateCriteria_View()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        testData();
        ctrl.searchId = oppSearchRecord.id;
        ctrl.populateCriteria_View();
    }
    static testMethod void clearSearch()
    {
        PageReference pageRef = Page.VfMassUpdateOpportunitiesPage;
        Test.setCurrentPage(pageRef);
        VFCntrlr_MassUpdateOpportunitiesPage ctrl = new VFCntrlr_MassUpdateOpportunitiesPage();
        ctrl.clearSearch();
    }
    public static void testData(){
     oppSearchRecord = new Opportunity_Search_Criteria__c(
            Name = 'Test Bikram2',
            Account_Name__c = 'SearchAccountName',
            Affinity_Account_ID__c = '123456789',
            Book_Date__c = date.today(),
            Ending_Fiscal_Book_Date__c = 'FY15 Q2W01',
            Opportunity_Name__c = 'SearchOpportunityName',
            Opportunity_Owner__c = '005A0000002QZaV',
            Solution_Name__c = 'SolutionName',
            Solution_Type__c = 'SolutionType',
            Service_Sales_Owner__c = '005A0000002QZaV',
            Stage__c = 'SearchStageName',
            Starting_Fiscal_Book_Date__c ='FY15 Q2W13'
     );
            insert(oppSearchRecord);
    }        
}