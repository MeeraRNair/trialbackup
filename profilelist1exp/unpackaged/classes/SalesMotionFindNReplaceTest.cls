@isTest    
private class SalesMotionFindNReplaceTest{        
static Sales_Motion__c SMObject=new Sales_Motion__c();  
    
    public static testMethod void SalesMotionFindNReplaceController() {
     
     //Boolean previousSalesmotion=true;
     //Boolean  previousSalesmotionPages=true;
     Boolean bool = true;
     List<Sales_Motion__c> salesm = new List<Sales_Motion__c>();
     List<Sales_Motion_Page_Section__c> salessec = new List<Sales_Motion_Page_Section__c>();
     List<Sales_Motion_Page__c> salespage = new List<Sales_Motion_Page__c>();
     List<String> strList = new List<string>();
     List<String> bsegment = new List <String>();
     List<String> SolnType = new List <String>();
     List<Sales_Motion__c> SalesMotionList=new List<Sales_Motion__c>(); 
     List<String> termsToAdd = new List <String>();
     List<String> ToRemove = new List <String>();
     List<String> pagesToAdd = new List <String>();
     List<String> stagesToAdd = new List <String>();
     List<String> stagesToRemove = new List <String>();
     Set<String>  allStages = new Set<String>();
     List<String> pagesToRemove = new List <String>();
     List<String> sectionsToAdd = new List <String>();
     List<String> sectionsToRemove = new List <String>();
     //String recsalesmotion = null;
     List<String> solution = new List <String>();
     List<String> selectedBSegs = new List<String>();
     List<SelectOption> selectedTandC = new List<SelectOption>();
     List<SelectOption> selectedProducts = new List<SelectOption>();
     List<SelectOption> availableProducts = new List<SelectOption>();
     List<String> productsToAdd=new List<String>();
     List<String> productsToRemove=new List<String>();


     String s = 's1';
     //List<String> domainlst = new List<String>();
     //domainlst[0] = 'EUC';  
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
   //SalesMotionList = [Select p.Id, p.Name, p.Domain__c, p.SalesEdge_Category__c, p.Solution_Name__c, p.Solution_Type__c from Sales_Motion__c p       
                                                  //  where Sales_Motion__c.Id = :salesm.Id]; 
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
     
    strList.add('EUC'); 
    bsegment.add('Segment1');
    bsegment.add('Segment2');
    SolnType.add('Solution Type1');
    SolnType.add('Solution Type2');
    termsToAdd.add('Add1');
    termsToAdd.add('Add2');
    ToRemove.add('To Remove1');
    ToRemove.add('To Remove2');
    pagesToAdd.add('Page Add1');
    pagesToAdd.add('Page Add2');
    stagesToAdd.add('Stage Add1');
    stagesToAdd.add('Stage Add2');
    stagesToRemove.add('Stages Remove1');  
    stagesToRemove.add('Stages Remove2');
    allStages.add('all stage'); 
    pagesToRemove.add('Page Remove1');
    pagesToRemove.add('Page Remove2');
    sectionsToAdd.add('Section Add1');
    sectionsToAdd.add('Section Add2');
    sectionsToRemove.add('Section Remove1');
    sectionsToRemove.add('Section Remove2');
    selectedTandC.add(new selectOption(salesm[0].Id,salesm[0].Name));
    solution.add('Solution1');
    solution.add('Solution2');
    selectedBSegs.add('NGCS');
    selectedBSegs.add('IDM');
    selectedBSegs.add('EUC');
    selectedBSegs.add('Networking');
    selectedBSegs.add('Non Domain');
    selectedBSegs.add('Software');
   
    
    String salesmotionname= salessec[0].Sales_Motion_Page__r.Sales_Motion_Name__r.name;
    String pagename= salessec[0].Sales_Motion_Page__r.name;    
     
    PageReference pageRef = Page.SMFindNReplace_DomainNSolnType;          
    Test.setCurrentPage(pageRef);
    SalesMotionFindNReplaceController controller = new SalesMotionFindNReplaceController();
    PageReference pageRef1 = Page.SMFindNReplace_SalesMotion;          
    Test.setCurrentPage(pageRef);
    PageReference pageRef2 = Page.SMFindNReplace_SMPages;          
    Test.setCurrentPage(pageRef);
    PageReference pageRef3 = Page.SMFindNReplace_SMStages;          
    Test.setCurrentPage(pageRef);
    PageReference pageRef4= Page.SMFindNReplace_SMPageSection;          
    Test.setCurrentPage(pageRef);
    PageReference pageRef5 = Page.SalesMotionFindNReplacePage;          
    Test.setCurrentPage(pageRef);
    
    
    controller.getDomainOptions();      
    controller.getDomainName();
    controller.setDomainName(strList);
    controller.getSelectedOptions();
    controller.getUnSelectedOptions(); 
    controller.PreviousPage2(); 
    controller.getSelected();
    controller.setSelected(selectedBSegs); 
    controller.doSelect();
    //controller.doUnSelect();
    //controller.getSelected();
    controller.getUnSelected();  
    controller.setUnSelected(bsegment);
    controller.doUnSelect();
    controller.getSolutionTypeOptions();
    controller.getSolutionType(); 
    controller.setSolutionType(solution);
    controller.getSelectedSolutionTypeOptions();
    controller.getUnSelectedSolutionTypeOptions();
    //controller.doSelectSolutionTypes();
    //controller.doUnSelectSolutionTypes();
    controller.getSelectedSolutionTypes();
    controller.setSelectedSolutionTypes(SolnType);
    controller.doSelectSolutionTypes();
    controller.getUnSelectedSolutionTypes(); 
    controller.setUnSelectedSolutionTypes(SolnType);
    controller.doUnSelectSolutionTypes();
    controller.getRecsalesmotion();
    controller.initializeSalesmotionSections();
    controller.getavailableStages();
    controller.getrectypes();
    controller.getSalesMotionInfo();
    Sales_Motion__c SalesMotionInfo = new Sales_Motion__c();
    controller.SetSalesMotionInfo(SalesMotionInfo);
    controller.getSalesmotionRecords();
    //System.assertEquals(null, controller.recsalesmotion);   
    controller.getshowMultiPickofTandC(); 
    controller.setshowMultiPickofTandC(True); 
    controller.PreviousPage3();
    //controller.addCurSelectedTandC();
    //controller.removeCurSelectedTandC();
    //controller.addCurSelectedPages();
    //controller.removeCurSelectedPages();
    controller.PreviousPage5();
    //controller.addCurSelectedStages();
    //controller.removeCurSelectedStages();
    //controller.addCurSelectedSections();
    //controller.removeCurSelectedSections();
    controller.getavailableTandC();
    controller.getavailablePages();
    controller.getselectedStages();
    controller.getselectedPages();
    controller.getselectedSections();
    controller.getfullavailableTandC();
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
    controller.addCurSelectedTandC(); 
    controller.gettermsToRemove();
    controller.settermsToRemove(ToRemove);
    controller.removeCurSelectedTandC();
    controller.getpagesToAdd();
    controller.setpagesToAdd(pagesToAdd);
    controller.addCurSelectedPages();
    controller.getstagesToAdd();
    controller.setstagesToAdd(stagesToAdd);
    controller.addCurSelectedStages();
    controller.getstagesToRemove();
    controller.setstagesToRemove(stagesToRemove);
    controller.removeCurSelectedStages(); 
    controller.getallStages();
    controller.setallStages(allStages); 
    controller.getaddedStages();
    controller.setaddedStages(allStages);
    controller.getpagesToRemove();
    controller.setpagesToRemove(pagesToRemove);
    controller.removeCurSelectedPages();
    controller.getsectionsToAdd();
    controller.setsectionsToAdd(sectionsToAdd);
    controller.addCurSelectedSections();
    controller.getsectionsToRemove();
    controller.setsectionsToRemove(sectionsToRemove);
    controller.removeCurSelectedSections();
    List<Sales_Motion__c> recsalesmotion = new List<Sales_Motion__c>();
    controller.setrecsalesmotion(recsalesmotion);
    controller.getSelectedTandC();
    controller.setselectedTandC(selectedTandC);
    controller.addCurSelectedProduct();
    controller.removeCurSelectedProduct();
    controller.getselectedProducts();
    controller.getavailableProducts();
    controller.getproductsToAdd();
    controller.getproductsToRemove();
    controller.setselectedProducts(selectedProducts);
    controller.setavailableProducts(availableProducts);
    controller.setproductsToAdd(productsToAdd);
    controller.setproductsToRemove(productsToRemove);
      
    List<selectOption> availableTandC=new List<SelectOption>(); 
    availableTandC.add(new selectOption(salesm[0].Id,salesm[0].Name));
    controller.setavailableTandC(availableTandC);     
    List<selectOption> fullavailableTandC= new List<SelectOption>(); 
    fullavailableTandC.add(new selectOption(salesm[0].Id,salesm[0].Name));
    controller.setfullavailableTandC(fullavailableTandC);      
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
    list<selectoption> stages= new List<SelectOption>();
    controller.setstages(stages);    
    list<selectoption> selectedStages= new List<SelectOption>();
    controller.setselectedStages(selectedStages);  
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
    
    
     controller.NextPage1();
     controller.NextPage2();
     controller.NextPage3();
     controller.NextPage4();
     controller.SelectAllSalesMotion();
     controller.SelectAllStages();
     controller.SelectAllPages(); 
     controller.SelectAllSections();
     //controller.PreviousPage2();
     controller.CancelPage2();
     //controller.PreviousPage3();
     controller.CancelPage3();
     controller.PreviousPage4();
     controller.CancelPage4();
     //controller.PreviousPage5();
     controller.CancelPage5(); 
     controller.queryRecords();
     controller.getSearchText();
     controller.setSearchText(s);
     controller.getReplaceText();
     controller.setReplaceText(s);
     controller.getSMPageSectionList();
       
    // controller.setSMPageSectionList(sectionList);
     controller.getUserMsg();
     controller.setUserMsg(bool);
     controller.getShowTbl();
     controller.setShowTbl(bool);
     controller.getShowSearch();
     controller.setShowSearch(bool);
     controller.searchSectionContent();
     controller.replaceSectionContent();
     controller.PreviousPage6();
     controller.ChangeFindNReplaceCriteria();
     controller.exit();
     controller.Submit();
     
    
}  
  
  }