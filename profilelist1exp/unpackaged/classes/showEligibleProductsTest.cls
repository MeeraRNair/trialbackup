@isTest
public class showEligibleProductsTest{
    
    Static testmethod void testEvaluationMethod1(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
                 
      List<Deal_Program__c> dealProgramList = new List<Deal_Program__c>();
      List<Custom_Partner_Accounts__c> customPartnerAccList = new List<Custom_Partner_Accounts__c>();
        
      Deal_program__c testDealProgram3 = new Deal_program__c(Deal_Program_Name__c = 'testDealProgram3'+System.currentTimeMillis(),
                                                            Benefit_Type__c = 'test',
                                                            Business_Unit__c = 'test',
                                                            Active__c = True,
                                                            Deal_Program_Description__c = 'test Program',
                                                            Start_Date__c = system.today(),
                                                            End_Date__c = system.today().adddays(10),                                                            
                                                            USD_Threshold__c = 400,
                                                            Fulfilment_Path__c = 'Direct fulfilment',
                                                            Partner_Type__c = 'US Federal',
                                                            Partner_Relationships__c = 'Registered',
                                                            Partner_Tiers__c = 'Indirect Partner Purchase;Tier 1;Tier 2',
                                                            Partner_Account_Regions__c = 'APJ;LATAM;NA',
                                                            Partner_Account_Countrys__c = 'UNITED STATES',
                                                            Exclude_Sales_Channels__c = 'FED;TEST',
                                                            Include_Sales__c = 'WEST;Test',
                                                            Stack_Ranking__c = 2000,
                                                            End_User_Account_Regions__c = 'APJ;LATAM;NA',
                                                            End_User_Account_Countrys__c = 'UNITED STATES',
                                                            Coverage__c =  'DELL CHANNEL',
                                                            Exclude_Unassigned_End_User_Accounts__c = True);
        insert testDealProgram3;
                
    /******Regarding Products********/
      Id pricebookId = Test.getStandardPricebookId();   
      List<String> prodCodeList = new List<String> {'Workstations','Notebooks','Storage Systems','PowerEdge Servers','Networking Software'};      
      List<Product2> prodList = new List<Product2>();
      List<PricebookEntry> pricBookList = new List<PricebookEntry>();
      List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
      for(Integer j=0;j < prodCodeList.size();j++){      
         Product2 prod = new Product2(Name = prodCodeList[j],ProductCode = prodCodeList[j],
                                       Family = 'Hardware',
                                     Channel_Product_LOB__c = 'NETWORKING', isActive = true ,Product_ID__c = 'P1' + j);
         prodList.add(prod);
      }
      for(Integer j=0;j < prodCodeList.size();j++){      
         Product2 undefinedProd = new Product2(Name = prodCodeList[j],Family = 'Hardware',Product_ID__c = 'P2' + j);
         prodList.add(undefinedProd);
      }
      insert prodList;
      
        Custom_Products__c cp1 = new Custom_Products__c(Include__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware', Product__c = null);
        Custom_Products__c cp2 = new Custom_Products__c(Exclude__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = 'Product Group', Criteria__c = 'Hardware',  Product__c = null);
        Custom_Products__c cp3 = new Custom_Products__c(Include__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = null, Criteria__c = null, Product__c = prodList[0].id);
        Custom_Products__c cp4 = new Custom_Products__c(Exclude__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = null, Criteria__c = null, Product__c = prodList[1].id);
        Custom_Products__c cp5 = new Custom_Products__c(Include__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = 'NBI Eligible', Criteria__c = 'true', Product__c = null);
        Custom_Products__c cp6 = new Custom_Products__c(Exclude__c = true, Deal_Program__c = testDealProgram3.id, Filter_type__c = 'NBI Eligible', Criteria__c = 'true', Product__c = null);

        
        List<Custom_Products__c> cplist = new List<Custom_Products__c>();
        cplist.add(cp1);
        cplist.add(cp2);
        cplist.add(cp3);
        cplist.add(cp4);
        cplist.add(cp5);
        cplist.add(cp6);
        insert cplist;
              
    /******Regarding Products********/
        PageReference pageRef123 = Page.showEligibleProducts;
        Test.setCurrentPage(pageRef123);
        
        ApexPages.Standardcontroller sc123 = new ApexPages.Standardcontroller(testDealProgram3);
        ApexPages.currentPage().getParameters().put('Did',testDealProgram3.id);
        showEligibleProducts AEP = new showEligibleProducts(sc123);   
        AEP.back();
        AEP.ToExcel(); 
      }
}