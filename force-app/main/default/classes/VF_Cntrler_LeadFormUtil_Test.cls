@isTest
private class VF_Cntrler_LeadFormUtil_Test {

	    
        
        /*  ---   TEST METHODS   ---   */ 
    
    
    //***********Test Method 1***********************
    public static testMethod void testVF_Cntrler_LeadFormUtilgetsetMethods() {
        
        System.debug('#MN:START of testVF_Cntrler_LeadFormUtilgetsetMethods()');
        
        PageReference pageRef = Page.TalkToDellWebForm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('c', 'uk');
        ApexPages.currentPage().getParameters().put('s', 'gen');
        ApexPages.currentPage().getParameters().put('cs', 'cs');
        ApexPages.currentPage().getParameters().put('l', 'en-us');
        ApexPages.currentPage().getParameters().put('cid', '52499');//Added as a part of CR#1823. [Ambily 30-Apr-2010]
        
        // Instantiate a new controller 
        VF_Cntrler_LeadFormUtil controller = new VF_Cntrler_LeadFormUtil();
        
        //getLeadItem
        Lead testLead=controller.getLeadItem();
        System.assertNotEquals(null,testLead);
       
        //getPreferredLanguageCode
        System.assertEquals('en-us',controller.getPreferredLanguageCode());
        
        //testDataCenterOptimizationList get and set methods
        String[] DataCenterOptimizationList=new String[]{'testDCO1','testDCO2'};
        controller.setDataCenterOptimizationList(DataCenterOptimizationList);
        String[] resultDCO=controller.getDataCenterOptimizationList();
        System.assertEquals(resultDCO,DataCenterOptimizationList);
        
        //testDCO get and set methods
        String[] EndUserProductivityList=new String[]{'testEUP1','testEUP2'};
        controller.setEndUserProductivityList(EndUserProductivityList);
        String[] resultEUP=controller.getEndUserProductivityList();
        System.assertEquals(resultEUP,EndUserProductivityList); 
        
        //testIPS get and set methods
        String[] ITProcessSimplificationList=new String[]{'testIPS1','testIPS2'};
        controller.setITProcessSimplificationList(ITProcessSimplificationList);
        String[] resultIPS=controller.getITProcessSimplificationList();
        System.assertEquals(resultIPS,ITProcessSimplificationList);
        
        //4.0
        String[] IndustryVerticalNeedList =new String[]{'testIVN1','testIVN2'};
        controller.setIndustryVerticalNeedList(IndustryVerticalNeedList );
        String[] resultIVN=controller.getIndustryVerticalNeedList();
        System.assertEquals(resultIVN,IndustryVerticalNeedList );
        
        //test getItemsDataCenterOptimizationList
        List<SelectOption> items=controller.getItemsDataCenterOptimizationList();
        System.assertNotEquals(null,items);  
        
        //test getItemsEup
        List<SelectOption> ItemsEup=controller.getItemsEndUserProductivityList();
        System.assertNotEquals(null,ItemsEup); 
        
        //test getItemsIps
        List<SelectOption> ItemsITProcessSimplificationList=controller.getItemsITProcessSimplificationList();
        System.assertNotEquals(null,ItemsITProcessSimplificationList);        
        
        //4.0
        List<SelectOption> ItemsIndustryVerticalNeedList=controller.getItemsIndustryVerticalNeedList();
        System.assertNotEquals(null,ItemsIndustryVerticalNeedList);   
        
        System.debug('#MN:END of testVF_Cntrler_LeadFormUtilgetsetMethods()');
    }
    
    
     //***********Test Method 2***********************
     public static testMethod void testVF_Cntrler_LeadFormUtil_Convert_To_MultiPicklist() {
        
        System.debug('#MN:START of testVF_Cntrler_LeadFormUtil_Convert_To_MultiPicklist()');
        PageReference pageRef = Page.TalkToDellWebForm;
        Test.setCurrentPage(pageRef);
        
        // Instantiate a new controller 
        VF_Cntrler_LeadFormUtil controller = new VF_Cntrler_LeadFormUtil();
        
        //prepare test data
        String[] testList=new String[]{'test1','test2'};
        System.debug('#MN:END of testVF_Cntrler_LeadFormUtil_Convert_To_MultiPicklist()');
    }
    
    
    //***********Test Method 3***********************
    public static testMethod void testVF_Cntrler_LeadFormUtil_SaveLead_Success() {
        
        System.debug('#MN:START of testVF_Cntrler_LeadFormUtil_SaveLead_Success()');
        //prepare test data
        PageReference pageRef = Page.TalkToDellWebForm;
        Test.setCurrentPage(pageRef);
        //set page parameters
        ApexPages.currentPage().getParameters().put('c', 'uk');
        ApexPages.currentPage().getParameters().put('s', 'gen');
        ApexPages.currentPage().getParameters().put('cs', 'cs');
        ApexPages.currentPage().getParameters().put('cid', '52499');//Added as a part of CR#1823. [Ambily 30-Apr-2010]
        
        //Create controller instance
        VF_Cntrler_LeadFormUtil controller = new VF_Cntrler_LeadFormUtil();
        
        String[] DataCenterOptimizationList=new String[]{'testDCO1','testDCO2'};
        controller.setDataCenterOptimizationList(DataCenterOptimizationList);
        String[] EndUserProductivityList=new String[]{'testEUP1','testEUP2'};
        controller.setEndUserProductivityList(EndUserProductivityList);
        String[] ITProcessSimplificationList=new String[]{'testIPS1','testIPS2'};
        controller.setITProcessSimplificationList(ITProcessSimplificationList);
        
        //4.0
        String[] IndustryVerticalNeedList =new String[]{'testIVN1','testIVN2'};
        controller.setIndustryVerticalNeedList(IndustryVerticalNeedList );
        
        Lead testLead=controller.getLeadItem();
        testLead.LastName='testName';
        testLead.Company='Dell';
        String nextPage = controller.SaveLead().getUrl();
        System.debug('URL'+nextPage);
        System.assert(nextPage.contains('/apex/TalkToDellWebFormUnavailable'));
        System.debug('#MN:END of testVF_Cntrler_LeadFormUtil_SaveLead_Success()');
    }
    
    
    //***********Test Method 4***********************
    public static testMethod void testVF_Cntrler_LeadFormUtil_SaveLead_Error() {
        
        System.debug('#MN:START of testVF_Cntrler_LeadFormUtil_SaveLead_Error()');
        //prepare test data
        PageReference pageRef = Page.TalkToDellWebForm;
        Test.setCurrentPage(pageRef);
        //set page parameters
        ApexPages.currentPage().getParameters().put('c', 'country_code');
        ApexPages.currentPage().getParameters().put('s', 'segment_code');
        ApexPages.currentPage().getParameters().put('cs', 'ref_code');
        ApexPages.currentPage().getParameters().put('cid', 'cid_code');//Added as a part of CR#1823. [Ambily 30-Apr-2010]
        
        //Create controller instance
        VF_Cntrler_LeadFormUtil controller = new VF_Cntrler_LeadFormUtil();
        
        String[] DataCenterOptimizationList=new String[]{'testDCO1','testDCO2'};
        controller.setDataCenterOptimizationList(DataCenterOptimizationList);
        String[] EndUserProductivityList=new String[]{'testEUP1','testEUP2'};
        controller.setEndUserProductivityList(EndUserProductivityList);
        String[] ITProcessSimplificationList=new String[]{'testIPS1','testIPS2'};
        controller.setITProcessSimplificationList(ITProcessSimplificationList);
        
        //4.0
        String[] IndustryVerticalNeedList =new String[]{'testIVN1','testIVN2'};
        controller.setIndustryVerticalNeedList(IndustryVerticalNeedList );
        
        
        Lead testLead=controller.getLeadItem();
        //commenting out the Last Name value; which is a required field
        //testLead.LastName='testName';
        testLead.Company='Dell';
        //Goes to the default error page on exception
        System.assert(controller.SaveLead().getUrl().contains('/apex/TalkToDellWebFormUnavailable'));
        System.debug('#MN:END of testVF_Cntrler_LeadFormUtil_SaveLead_Error()');
    }

}