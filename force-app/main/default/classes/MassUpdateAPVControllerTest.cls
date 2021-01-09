@isTest
private class MassUpdateAPVControllerTest{

  static testMethod void Test_MassUpdate_other(){
      String Name='';
       Marketing_Plan__c marketingPlan = new Marketing_Plan__c();
       marketingPlan.name='MP-001';
    // marketingPlan.Vendor__c=vendorList[0].Id;
       marketingPlan.Fiscal_Quarter__c='FY12Q1';
       marketingPlan.Region__c='Americas';
       marketingPlan.Contract_Type__c='Volume Based';
    // marketingPlan.RecordTypeId=marketingPlanRT.Id;
    // marketingPlan.invoice__c=invoiceObj.Id;
       insert marketingPlan; 
  
      ApexPages.CurrentPage().getParameters().put('id', marketingPlan.Id); 
      List<Associated_Programs_Vendors__c> listAsso=new List<Associated_Programs_Vendors__c>();
      //Associated_Programs_Vendors__c objAssProgam = new Associated_Programs_Vendors__c();
      for(integer i=0;i>2040;i++){
          listAsso.add(new Associated_Programs_Vendors__c(
          Status__c ='Pending',                     
          Rate_Card_Price__c=896542,
          Budgeted_Price__c=56932+i,
          Invoice_Amount__c=98980+i,      
          Marketing_Plan__c=marketingPlan.Id 
          ));         
      }
      insert listAsso;
           
      //ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listAsso);
      //Associated_Programs_Vendors__c assoprm = new Associated_Programs_Vendors__c(); 
          
      PageReference pageRef = Page.MassUpdateAPV; 
      Test.setCurrentPage(pageRef); 
      ApexPages.currentPage().getParameters().put('id',marketingPlan.Id);
      ApexPages.currentPage().getParameters().put('alpha','Other');
      MassUpdateAPVController objMassUpdate = new MassUpdateAPVController();      
      objMassUpdate.standardSetCon = null;
      objMassUpdate.getCurrentList();
      objMassUpdate.standardSetCon = new ApexPages.StandardSetController(listAsso);      
      objMassUpdate.getCurrentList();
      objMassUpdate.massUpdateAPVRecrods();
      objMassUpdate.lstOfEditedAPVRecords=listAsso;       
      objMassUpdate.CancelAction();
      objMassUpdate.getDisplaySelectedList();      
      objMassUpdate.getHost();      
      objMassUpdate.getServerName();
      objMassUpdate.setServerName('host');
      objMassUpdate.totalPages=5;
      objMassUpdate.mplanErr=true;
      objMassUpdate.sortExp='Program_Name__c';
      objMassUpdate.sortDirection='ASC';
      objMassUpdate.setsortDirection('ASC');
      objMassUpdate.getsortDirection();            
      objMassUpdate.RefreshList2();
      objMassUpdate.sortField=null;
      objMassUpdate.APCList=listAsso;
      objMassUpdate.sorting();   
           
  }
  
  static testMethod void Test_MassUpdate_All(){
      String Name='';
       Marketing_Plan__c marketingPlan = new Marketing_Plan__c();
       marketingPlan.name='MP-001';
    // marketingPlan.Vendor__c=vendorList[0].Id;
       marketingPlan.Fiscal_Quarter__c='FY12Q1';
       marketingPlan.Region__c='Americas';
       marketingPlan.Contract_Type__c='Volume Based';
    // marketingPlan.RecordTypeId=marketingPlanRT.Id;
    // marketingPlan.invoice__c=invoiceObj.Id;
       insert marketingPlan; 
  
      ApexPages.CurrentPage().getParameters().put('id', marketingPlan.Id); 
      List<Associated_Programs_Vendors__c> listAsso=new List<Associated_Programs_Vendors__c>();
      //Associated_Programs_Vendors__c objAssProgam = new Associated_Programs_Vendors__c();
      for(integer i=0;i>2040;i++){
          listAsso.add(new Associated_Programs_Vendors__c(
          Status__c ='Pending',                     
          Rate_Card_Price__c=896542,
          Budgeted_Price__c=56932+i,
          Invoice_Amount__c=98980+i,      
          Marketing_Plan__c=marketingPlan.Id 
          ));         
      }
      insert listAsso;
           
      //ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listAsso);
      //Associated_Programs_Vendors__c assoprm = new Associated_Programs_Vendors__c(); 
          
      PageReference pageRef = Page.MassUpdateAPV; 
      Test.setCurrentPage(pageRef); 
      ApexPages.currentPage().getParameters().put('id',marketingPlan.Id);
      ApexPages.currentPage().getParameters().put('alpha','All');
      MassUpdateAPVController objMassUpdate = new MassUpdateAPVController();      
      objMassUpdate.standardSetCon = null;
      objMassUpdate.getCurrentList();
      objMassUpdate.standardSetCon = new ApexPages.StandardSetController(listAsso);      
      objMassUpdate.getCurrentList();
      objMassUpdate.massUpdateAPVRecrods();
      objMassUpdate.lstOfEditedAPVRecords=listAsso;       
      objMassUpdate.CancelAction();
      objMassUpdate.getDisplaySelectedList();
      objMassUpdate.RefreshList2();
      objMassUpdate.getHost();      
      objMassUpdate.getServerName();
      objMassUpdate.setServerName('host');
      objMassUpdate.totalPages=5;
      objMassUpdate.mplanErr=true;
      objMassUpdate.sortExp='Program_Name__c';
      objMassUpdate.sortDirection='DESC';
      objMassUpdate.getsortDirection();
      objMassUpdate.setsortDirection('DESC');
      objMassUpdate.sortField=null;
      objMassUpdate.sorting();      
      objMassUpdate.APCList=listAsso;           
  }
  
  static testMethod void Test_MassUpdate_AtoZ(){
      String Name='';
       Marketing_Plan__c marketingPlan = new Marketing_Plan__c();
       marketingPlan.name='MP-001';
    // marketingPlan.Vendor__c=vendorList[0].Id;
       marketingPlan.Fiscal_Quarter__c='FY12Q1';
       marketingPlan.Region__c='Americas';
       marketingPlan.Contract_Type__c='Volume Based';
    // marketingPlan.RecordTypeId=marketingPlanRT.Id;
    // marketingPlan.invoice__c=invoiceObj.Id;
       insert marketingPlan; 
  
      ApexPages.CurrentPage().getParameters().put('id', marketingPlan.Id); 
      List<Associated_Programs_Vendors__c> listAsso=new List<Associated_Programs_Vendors__c>();
      //Associated_Programs_Vendors__c objAssProgam = new Associated_Programs_Vendors__c();
      for(integer i=0;i>2040;i++){
          listAsso.add(new Associated_Programs_Vendors__c(
          Status__c ='Pending',                     
          Rate_Card_Price__c=896542,
          Budgeted_Price__c=56932+i,
          Invoice_Amount__c=98980+i,      
          Marketing_Plan__c=marketingPlan.Id 
          ));         
      }
      insert listAsso;
           
      //ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(listAsso);
      //Associated_Programs_Vendors__c assoprm = new Associated_Programs_Vendors__c(); 
          
      PageReference pageRef = Page.MassUpdateAPV; 
      Test.setCurrentPage(pageRef); 
      ApexPages.currentPage().getParameters().put('id',marketingPlan.Id);
      ApexPages.currentPage().getParameters().put('alpha','A');
      MassUpdateAPVController objMassUpdate = new MassUpdateAPVController();      
      objMassUpdate.standardSetCon = null;
      objMassUpdate.getCurrentList();
      objMassUpdate.standardSetCon = new ApexPages.StandardSetController(listAsso);      
      objMassUpdate.getCurrentList();
      objMassUpdate.massUpdateAPVRecrods();
      objMassUpdate.lstOfEditedAPVRecords=listAsso;       
      objMassUpdate.CancelAction();
      objMassUpdate.getDisplaySelectedList();
      objMassUpdate.RefreshList2();
      objMassUpdate.getHost();      
      objMassUpdate.getServerName();
      objMassUpdate.setServerName('host');
      objMassUpdate.totalPages=5;
      objMassUpdate.mplanErr=true;
      objMassUpdate.sortExp='Program_Name__c';
      objMassUpdate.sortDirection='ASC';
      objMassUpdate.getsortDirection();
      objMassUpdate.setsortDirection('ASC');
      objMassUpdate.sortField=null;
      objMassUpdate.sorting();      
      objMassUpdate.APCList=listAsso;
         
  }
  
}