@isTest
private class SalesMotionPageCloneCtrlTest {
    
    static List<Sales_Motion__c> salesm = new List<Sales_Motion__c>();
    static List<Sales_Motion_Page__c> salespage = new List<Sales_Motion_Page__c>();
     static List<Sales_Motion_Page_Section__c> salessec = new List<Sales_Motion_Page_Section__c>();
    static List<Product2> testProdList = new List<Product2>();

    static testMethod void SalesMotionPageClnCtrlTest() {
        
        createdata();
        
        PageReference pageRef = Page.SalesMotionPageClone;
        Test.setCurrentPage(pageRef); 
        
        ApexPages.currentPage().getParameters().put('id', salespage[0].Id);
         
        SalesMotionPageCloneCtrl controller = new SalesMotionPageCloneCtrl(new ApexPages.StandardController(salespage[0]));
        
        controller.Save();
        controller.Cancel();
        
        List<SalesMotionPageCloneCtrl.SalesMotionPageSectionWrapper> SalesmotionWrapperRecsTemp=new List<SalesMotionPageCloneCtrl.SalesMotionPageSectionWrapper>();
        SalesMotionPageCloneCtrl.SalesMotionPageSectionWrapper smwrapper = new SalesMotionPageCloneCtrl.SalesMotionPageSectionWrapper();
        
        smwrapper.selected = true;     
        SalesmotionWrapperRecsTemp.add(smwrapper);
        
        controller.getSalesmotionPageSectionWrapperRecs();
        controller.setSalesmotionPageSectionWrapperRecs(SalesmotionWrapperRecsTemp);    

    }
    
     public static void createdata(){
        
        Product2 testProd3 = new Product2(Name='Test Product', Standard_OE_to_SC__c=70, Volume_to_Dollar_Ratio__c=2,EMEA__c=10, Container_Volume__c=30,Source__c='Compal', Pallet_Quantity__c=18,IsActive=true);
        testProdList.add(testProd3);
        
        insert testProdList;  
     
        for(Integer i = 0; i <3; i++){           
         salesm.add(            
               new Sales_Motion__c(  
                     Name ='SalesMotion', 
                     Domain__c ='EUC', 
                     SalesEdge_Category__c ='Test SalesEdge', 
                     Solution_Name__c = 'Test SolutionName'+i,
                     Solution_Type__c = 'Test Solution Type',
                     Product__c = testProdList[0].Id
               ) 
         );
     }
     insert salesm;
    
  
     for(Integer i = 0; i <3; i++){          
         salespage.add(            
               new Sales_Motion_Page__c(  
                     Name ='SalesMotionPage',
                     Sales_Motion_Name__c=salesm[i].Id
               ) 
         );
     }
     insert salespage;
      
     for(Integer i = 0; i <3; i++){          
         salessec.add(            
               new Sales_Motion_Page_Section__c(  
                     Name ='SalesMotionPageSection',  
                     Stage__c ='Test SalesEdge',
                     Section_Content__c='Test',
                     Sales_Motion_Page__c=salespage[i].Id 
               ) 
         );
     }
     insert salessec;          
     }
}