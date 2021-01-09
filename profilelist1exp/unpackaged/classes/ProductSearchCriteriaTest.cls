@isTest(SeeAllData=true)
public class ProductSearchCriteriaTest{
    static testmethod  void ProductSearchCriteriaMethod() {
        PageReference pageRef = Page.ProductSearchCriteria;
        Test.setCurrentPage(pageRef);  
        string optionsSelected = 'Product Group';
        set<string>str = new set<string>();
        string str1 = 'test';
        string str2 = 'test2';
        str.add(str1);
        str.add(str2);
        list<string>  str3 = new  list<string>();
        string str4 = 'Prodcut Id';
        string str5 = 'Product Group';
        str3.add(str4);
        str3.add(str5);
        // Deal program test data
        Deal_Program__c dealPgm = new Deal_Program__c();
        dealPgm.Deal_Program_Name__c ='test12234';
        dealPgm.Deal_Program_Description__c ='test1';
        dealPgm.Stackable__c = 'Yes';
        dealPgm.Start_Date__c = Date.Today() - 1;
        dealPgm.End_Date__c = Date.Today() + 1;
        dealPgm.Benefit_Type__c = 'test2';
        dealPgm.Business_Unit__c = 'test3';
        dealPgm.Program_Region__c = 'EMA';
        dealPgm.Partner_Account_Regions__c = 'EMA';
        dealPgm.End_User_Account_Regions__c = 'EMA';
        
        insert dealPgm;
        //Product Test Data
        Product2 pr = new Product2();
        pr.Name = 'test7';
        pr.Prod_ID__c = '1234';
        pr.Product_ID__c = '123546';
        pr.CurrencyIsoCode = 'AED';
        pr.IsActive = true;    
        insert pr;
        Product2 pr1 = new Product2();
        pr1.Name = 'test7';
        pr1.Prod_ID__c = '123';
        pr1.Product_ID__c = '01123546';
        pr1.CurrencyIsoCode = 'AED';
        pr1.IsActive = true;    
        insert pr1;
        //Custom Product Test Data
        Custom_Products__c csp = new Custom_Products__c();
        csp.Criteria__c = 'test,test1';
        csp.Product__c = pr1.id;
        csp.Deal_Program__c = dealPgm.id;
        csp.Filter_Type__c = 'test5';
        csp.Include__c = true;
        insert csp;
        Custom_Products__c csp1 = new Custom_Products__c();
        csp1.Criteria__c = 'Business Process Outsourcing';
        
        csp1.Deal_Program__c = dealPgm.id;
        csp1.Filter_Type__c = 'Product Group';
        csp1.Include__c = true;
        insert csp1;
        Custom_Products__c csp2 = new Custom_Products__c();
        csp2.Criteria__c = '';
        csp2.Product__c = pr.id;
        csp2.Deal_Program__c = dealPgm.id;
        csp2.Filter_Type__c = '';
        csp2.Include__c = true;
        insert csp2;
        
        
        pageRef.getParameters().put('pid', String.valueOf(dealPgm.Id));
        pageRef.getParameters().put('Type','Include');
        //pageRef.getparameters().put('id',csp1.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(dealPgm);
        ProductSearchCriteria productSearch= new ProductSearchCriteria (sc);
        
        System.assertEquals(true,optionsSelected != '' );
         productSearch.optionsSelected = 'Product Group';
        productSearch.datacopertina = Date.today();
        productSearch.datetest = true;
        productSearch.SelectedProduct = 'Fast_Track__c';
        productSearch.ProdFamily = str;
        productsearch.listStrings = str3;
        productSearch.datesearch = date.today();
        //productSearch.options = 'str3';
        productSearch.dpg = dealPgm;
        productSearch.searchString = 'Product Group';
        productSearch.type= 'Boolean';
        productSearch.ProductCriteriaId = csp.id;
        productSearch.showSearchResults = true;
        productSearch.onPageLoad();
        
        
       // productSearch.keywordNull();
        productSearch.close();
        productSearch.show = true;
        productSearch.datacopertina = date.today();
        productSearch.optionsSelected = 'EMC_CRUD_Behavior__c';
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'Fast_Track__c';
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'EOL_Date_LATAM__c';
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'Dell_Business_Model__c';
        productSearch.fetchResults();
        productSearch.optionsSelected = 'EMC_Product_ID__c';
        productSearch.fetchResults();
        productSearch.optionsSelected = 'Description';
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'Productcode';
        //productSearch.prodList.add('Business Process Outsourcing');
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'IsActive';
        productSearch.fetchResults(); 
        productSearch.prodList =str3;
        productSearch.saveFunction();
        productSearch.keywordNull();
        productSearch.addmoreoption();
                
           /*productSearch.Custprod = null;
        productSearch.saveFunction();
        productSearch.keywordNull();
        productSearch.addmoreoption();
        productSearch.cprid = null;
        
        productSearch.fetchResults();
        productSearch.saveFunction();*/
        
     
        
    }
    static testmethod  void ProductSearchCriteriaMethod1() {
        PageReference pageRef = Page.ProductSearchCriteria;
        Test.setCurrentPage(pageRef);  
        string optionsSelected = 'Product Group';
        set<string>str = new set<string>();
        string str1 = 'test';
        string str2 = 'test2';
        str.add(str1);
        str.add(str2);
        list<string>  str3 = new  list<string>();
        string str4 = 'Prodcut Id';
        string str5 = 'Product Group';
        str3.add(str4);
        str3.add(str5);
        // Deal program test data
        Deal_Program__c dealPgm = new Deal_Program__c();
        dealPgm.Deal_Program_Name__c ='test12234';
        dealPgm.Deal_Program_Description__c ='test1';
        dealPgm.Stackable__c = 'Yes';
        dealPgm.Start_Date__c = Date.Today() - 1;
        dealPgm.End_Date__c = Date.Today() + 1;
        dealPgm.Benefit_Type__c = 'test2';
        dealPgm.Business_Unit__c = 'test3';
        dealPgm.Program_Region__c = 'EMA';
        dealPgm.Partner_Account_Regions__c = 'EMA';
        dealPgm.End_User_Account_Regions__c = 'EMA';
        
        insert dealPgm;
        //Product Test Data
        Product2 pr = new Product2();
        pr.Name = 'test7';
        pr.Prod_ID__c = '1234';
        pr.Product_ID__c = '123546';
        pr.CurrencyIsoCode = 'AED';
        pr.IsActive = true;    
        insert pr;
        Product2 pr1 = new Product2();
        pr1.Name = 'test7';
        pr1.Prod_ID__c = '123';
        pr1.Product_ID__c = '01123546';
        pr1.CurrencyIsoCode = 'AED';
        pr1.IsActive = true;    
        insert pr1;
        //Custom Product Test Data
        Custom_Products__c csp = new Custom_Products__c();
        csp.Criteria__c = 'test,test1';
        csp.Product__c = pr.id;
        csp.Deal_Program__c = dealPgm.id;
        csp.Filter_Type__c = 'test5';
        csp.Include__c = true;
        insert csp;
        Custom_Products__c csp1 = new Custom_Products__c();
        csp1.Criteria__c = 'Business Process Outsourcing';
        
        csp1.Deal_Program__c = dealPgm.id;
        csp1.Filter_Type__c = 'Product Group';
        csp1.Include__c = true;
        insert csp1;
        Custom_Products__c csp2 = new Custom_Products__c();
        csp2.Criteria__c = '';
        csp2.Product__c = pr1.id;
        csp2.Deal_Program__c = dealPgm.id;
        csp2.Filter_Type__c = '';
        csp2.Include__c = true;
        insert csp2;
        
        
        pageRef.getParameters().put('pid', String.valueOf(dealPgm.Id));
        pageRef.getParameters().put('Type','Include');
        pageRef.getparameters().put('id',csp1.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(dealPgm);
        ProductSearchCriteria productSearch= new ProductSearchCriteria (sc);
        
        System.assertEquals(true,optionsSelected != '' );
         productSearch.optionsSelected = 'Product Group';
        productSearch.datacopertina = Date.today();
        productSearch.datetest = true;
        productSearch.SelectedProduct = 'Fast_Track__c';
        productSearch.ProdFamily = str;
        productsearch.listStrings = str3;
        productSearch.datesearch = date.today();
        //productSearch.options = 'str3';
        productSearch.dpg = dealPgm;
        productSearch.searchString = 'Product Group';
        productSearch.type= 'Boolean';
        productSearch.ProductCriteriaId = csp.id;
        productSearch.showSearchResults = true;
        productSearch.onPageLoad();
        
        
       // productSearch.keywordNull();
        productSearch.close();
        productSearch.show = true;
        productSearch.datacopertina = date.today();
        productSearch.optionsSelected = 'EMC_CRUD_Behavior__c';
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'Fast_Track__c';
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'EOL_Date_LATAM__c';
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'Dell_Business_Model__c';
        productSearch.fetchResults();
        productSearch.optionsSelected = 'EMC_Product_ID__c';
        productSearch.fetchResults();
        productSearch.optionsSelected = 'Description';
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'Productcode';
        //productSearch.prodList.add('Business Process Outsourcing');
        productSearch.fetchResults(); 
        productSearch.optionsSelected = 'IsActive';
        productSearch.fetchResults(); 
        productSearch.prodList =str3;
        productSearch.saveFunction();
        productSearch.keywordNull();
        productSearch.addmoreoption();
                
         
     
        
    }


}