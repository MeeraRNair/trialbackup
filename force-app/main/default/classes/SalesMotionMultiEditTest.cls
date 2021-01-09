@isTest    
private class SalesMotionMultiEditTest{        
static Sales_Motion__c SMObject=new Sales_Motion__c();  
    
    public static testMethod void SalesMotion_MultiEditPageController() {
     
     Boolean previousSalesmotionPages = true;
     List<Sales_Motion__c> salesm = new List<Sales_Motion__c>();
     List<Sales_Motion_Page__c> salespage = new List<Sales_Motion_Page__c>();
     List<Sales_Motion_Page_Section__c> salessec = new List<Sales_Motion_Page_Section__c>();
     List<String> termsToAdd = new List <String>();
     List<String> termsToRemove = new List <String>();
     List<String> pagesToAdd = new List <String>();
     List<String> stagesAvailable = new List <String>();
     List<String> stagesAdded= new List <String>();
     List<String> domainsToAdd= new List <String>();
     List<String> domainsToRemove= new List <String>();
     List<String> solutionTypeToAdd= new List <String>();
     List<String> solutionTypeToRemove= new List <String>();
     List<String> pagesToRemove= new List <String>();
     List<String> sectionsToAdd= new List <String>();
     List<String> sectionsToRemove= new List <String>();
     List<String> productsToAdd= new List <String>();
     List<String> productsToRemove= new List <String>();
     List<selectoption> availableProducts=new List<selectoption>();
     List<selectoption> selectedProducts=new List<selectoption>();
           
     for(Integer i = 0; i <3; i++){          
         salesm.add(            
               new Sales_Motion__c(  
                     Name ='SalesMotion', 
                     Domain__c ='EUC', 
                     SalesEdge_Category__c ='Test SalesEdge', 
                     Solution_Name__c = 'Test SolutionName'+i,
                     Solution_Type__c = 'Test Solution Type'
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
     SalesMotion_MultiEditPageController controller = new SalesMotion_MultiEditPageController();
     controller.TandCDomain.add('EUC');
     controller.SelectAllSalesMotions();
     controller.TandCSolutionType.add('Mobility Solutions');
     controller.SelectAllSalesMotions();
     controller.TandCProducts.add('Claims');
     controller.SelectAllSalesMotions();
     termsToAdd.add('Add1');
     termsToAdd.add('Add2');
     termsToRemove.add('To Remove1');
     termsToRemove.add('To Remove2');
     pagesToAdd.add('Page Add1'); 
     pagesToAdd.add('Page Add2');
     stagesAvailable.add('Stage1'); 
     stagesAvailable.add('Stage2'); 
     stagesAdded.add('Stage Add1');
     stagesAdded.add('Stage Add2');
     domainsToAdd.add('Domain Add1');
     domainsToAdd.add('Domain Add2'); 
     domainsToRemove.add('Domain Remove1');
     domainsToRemove.add('Domain Remove2');
     solutionTypeToAdd.add('Solution Add1');
     solutionTypeToAdd.add('Solution Add1');
     solutionTypeToRemove.add('Solution Remove1');  
     solutionTypeToRemove.add('Solution Remove2');
     pagesToRemove.add('Pages Remove1');
     pagesToRemove.add('Pages Remove2');
     sectionsToAdd.add('Section Add1');
     sectionsToAdd.add('Section Add2');
     sectionsToRemove.add('Section Remove1');
     sectionsToRemove.add('Section Remove2');
          
     String salesmotionname= salessec[0].Sales_Motion_Page__r.Sales_Motion_Name__r.name;
     String pagename= salessec[0].Sales_Motion_Page__r.name;    

     PageReference pageRef = Page.SalesMotion_SelectDomainTypePage;          
     Test.setCurrentPage(pageRef);
     
     PageReference pageRef1 = Page.SalesMotion_SelectSM_VFpage;          
     Test.setCurrentPage(pageRef);
     PageReference pageRef2 = Page.SalesMotion_SelectSMPage_VF_Page;          
     Test.setCurrentPage(pageRef);
     PageReference pageRef3 = Page.SalesMotion_SelectStage_VF_Page;          
     Test.setCurrentPage(pageRef);
     PageReference pageRef4= Page.SalesMotion_SelectSMPageSection_VF_Page;          
     Test.setCurrentPage(pageRef);
     PageReference pageRef5 = Page.SalesMotionMultiEditPage;          
     Test.setCurrentPage(pageRef);
     
     controller.getavailableStages();
     controller.getavailableDomains();
     controller.getavailableSolutionType();
     controller.getSalesMotionInfo();
     Sales_Motion__c SalesMotionInfo = new Sales_Motion__c();
     controller.SetSalesMotionInfo(SalesMotionInfo);
     controller.PreviousPage3();
     controller.PreviousPage5();
     controller.PreviousPage2();
     controller.SelectAllSalesMotions();
     controller.SelectAllPages();
     controller.SelectAllSections();
     controller.getavailableSalesmotions();
     controller.getavailablePages();
     controller.getavailableStages();
     controller.getselectedStages();
     controller.getselectedDomains(); 
     controller.getselectedSolutionType();
     controller.getselectedPages();
     controller.getselectedSections();
     controller.getfullAvailableSalesmotions();
     controller.getfullavailablePages();
     controller.getfullavailableStages();
     controller.getfullavailableSections();
     controller.getavailableSections();
     controller.getavailableSalesmotionPages();
     controller.getavailableSalesmotionStages();
     controller.getselectedSalesmotionPages();
     controller.getselectedSalesmotionStages();    
     controller.getavailableSalesmotionSections();
     controller.getselectedSalesmotionSections();
     controller.gettermsToAdd();
     controller.settermsToAdd(termsToAdd);
     controller.addCurSalesmotions();
     controller.gettermsToRemove();
     controller.settermsToRemove(termsToRemove);
     controller.removeCurSalesmotions();
     controller.getpagesToAdd();
     controller.setpagesToAdd(pagesToAdd);
     controller.addCurSelectedPages();
     controller.SelectAllStages();
     controller.getstagesAvailable();
     controller.setstagesAvailable(stagesAvailable);
     controller.addCurSelectedStages();
     controller.getstagesAdded();
     controller.setstagesAdded(stagesAdded); 
     controller.removeCurSelectedStages();
     controller.getdomainsToAdd();
     controller.setdomainsToAdd(domainsToAdd);
     controller.addCurSelectedDomains();
     controller.initializeSalesmotions();
     controller.NextPage1();
     controller.getdomainsToRemove();
     controller.setdomainsToRemove(domainsToRemove);
     controller.removeCurSelectedDomains();
     controller.getsolutionTypeToAdd();
     controller.setsolutionTypeToAdd(solutionTypeToAdd);
     controller.addCurSelectedSolutionType(); 
     controller.getsolutionTypeToRemove();   
     controller.setsolutionTypeToRemove(solutionTypeToRemove); 
     controller.removeCurSelectedSolutionType();
     controller.getpagesToRemove();
     controller.setpagesToRemove(pagesToRemove);
     controller.removeCurSelectedPages();
     controller.getsectionsToAdd();
     controller.setsectionsToAdd(sectionsToAdd);
     controller.addCurSelectedSections();
     controller.getsectionsToRemove();
     controller.setsectionsToRemove(sectionsToRemove);
     controller.removeCurSelectedSections();
     controller.getselectedSalesmotions();
     controller.addCurSelectedProduct();
     controller.getproductsToAdd();
     controller.setproductsToAdd(productsToAdd);
     controller.getproductsToRemove();
     controller.setproductsToRemove(productsToRemove);
     controller.removeCurSelectedProduct();
     controller.getselectedProducts();
     controller.getavailableProducts();
     controller.setavailableProducts(availableProducts);
     controller.setselectedProducts(selectedProducts);
     
     List<selectOption> selectedSalesmotions=new List<SelectOption>(); 
     selectedSalesmotions.add(new selectOption(salesm[0].Id,salesm[0].Name));
     controller.setselectedSalesmotions(selectedSalesmotions);

     
     List<selectOption> availableSM=new List<SelectOption>(); 
     availableSM.add(new selectOption(salesm[0].Id,salesm[0].Name));
     controller.setavailableSalesmotions(availableSM);  
       
     List<selectOption> fullavailableSM= new List<SelectOption>(); 
     fullavailableSM.add(new selectOption(salesm[0].Id,salesm[0].Name));
     controller.setfullAvailableSalesmotions(fullavailableSM);  
        
     List<selectOption> fullavailablePages= new List<SelectOption>();  
     fullavailablePages.add(new selectOption(salespage[0].Id,salespage[0].Sales_Motion_Name__r.Name+':'+salespage[0].Name));    
     controller.setfullavailablePages(fullavailablePages);
          
     list<selectoption> fullavailableStages= new List<SelectOption>();
     controller.setfullavailableStages(fullavailableStages);      
    
     list<selectoption> fullavailableSections= new List<SelectOption>();
     fullavailableSections.add(new selectOption(salessec[0].id,salesmotionname+':'+pagename+':'+salessec[0].Name));
     controller.setfullavailableSections(fullavailableSections);
     list<selectoption> availableSections= new List<SelectOption>();
     availableSections.add(new selectOption(salessec[0].id,salesmotionname+':'+pagename+':'+salessec[0].Name));
     controller.setavailableSections(availableSections);
     list<selectoption> availablePages= new List<SelectOption>();
     availablePages.add(new selectOption(salespage[0].Id,salespage[0].Sales_Motion_Name__r.Name+':'+salespage[0].Name));
     controller.setavailablePages(availablePages); 
     list<selectoption> availableStages= new List<SelectOption>();
     controller.setavailableStages(availableStages);    
     list<selectoption> availableDomains= new List<SelectOption>();
     controller.setavailableDomains(availableDomains);    
     list<selectoption> availableSolutionType= new List<SelectOption>();
     controller.setavailableSolutionType(availableSolutionType);
     list<selectoption> stages= new List<SelectOption>();
     controller.setstages(stages);    
     list<selectoption> selectedStages= new List<SelectOption>();
     controller.setselectedStages(selectedStages);  
     list<selectoption> selectedDomains= new List<SelectOption>();
     controller.setselectedDomains(selectedDomains);
     list<selectoption> selectedSolutionType= new List<SelectOption>();
     controller.setselectedSolutionType(selectedSolutionType);       
     list<selectoption> selectedPages= new List<SelectOption>();
     selectedPages.add(new selectOption(salespage[0].Id,salespage[0].Sales_Motion_Name__r.Name+':'+salespage[0].Name));
     controller.setselectedPages(selectedPages);    
     list<selectoption> selectedSections= new List<SelectOption>();
     selectedSections.add(new selectOption(salessec[0].id,salesmotionname+':'+pagename+':'+salessec[0].Name));   
     controller.setselectedSections(selectedSections);    
     list<selectoption> availableSalesmotionPages= new List<SelectOption>();
     availableSalesmotionPages.add(new selectOption(salespage[0].Id,salespage[0].Sales_Motion_Name__r.Name+':'+salespage[0].Name));
     controller.setavailableSalesmotionPages(availableSalesmotionPages);    
     list<selectoption> availableSalesmotionStages= new List<SelectOption>();
     controller.setavailableSalesmotionStages(availableSalesmotionStages);
    
     list<selectoption> selectedSalesmotionPages= new List<SelectOption>();
     selectedSalesmotionPages.add(new selectOption(salespage[0].Id,salespage[0].Sales_Motion_Name__r.Name+':'+salespage[0].Name));
     controller.setselectedSalesmotionPages(selectedSalesmotionPages);
     list<selectoption> selectedSalesmotionStages= new List<SelectOption>();
     controller.setselectedSalesmotionStages(selectedSalesmotionStages);
     list<selectoption> availableSalesmotionSections= new List<SelectOption>();
     availableSalesmotionSections.add(new selectOption(salessec[0].id,salesmotionname+':'+pagename+':'+salessec[0].Name)); 
     controller.setavailableSalesmotionSections(availableSalesmotionSections);
     list<selectoption> selectedSalesmotionSections= new List<SelectOption>();                
     selectedSalesmotionSections.add(new selectOption(salessec[0].id,salesmotionname+':'+pagename+':'+salessec[0].Name));     
     controller.setselectedSalesmotionSections(selectedSalesmotionSections);
    
     controller.NextPage2();
     controller.TandCId.add('Networking1');
     controller.NextPage2();
     controller.NextPage3();
     controller.NextPage4(); 
     controller.previousSalesmotionSectionsedited=0;
     controller.NextPage4(); 
     controller.previousSalesmotionPagesedited=0;
     controller.NextPage2();
     controller.previousSalesmotionedited=0;
     controller.NextPage1();
     controller.CancelPage2();
     controller.CancelPage3();
     controller.PreviousPage4();
     controller.CancelPage4(); 
     controller.CancelPage5();
     controller.Submit();
     controller.ShowPageRecs();
     controller.HidePageRecs();
     controller.ShowSectionRecs();
     controller.HideSectionRecs();
     controller.queryRecords();
     controller.getSMtoSMPageList();
     controller.PreviousPage6(); 
     controller.CancelPage6(); 
              
   } 
     
}