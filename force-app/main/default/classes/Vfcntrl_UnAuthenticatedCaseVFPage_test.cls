/*
Author:Pradeep
Purpose:Test class for Vfcntrl_UnAuthenticatedCaseVFPage
*/
  @isTest
  public class Vfcntrl_UnAuthenticatedCaseVFPage_test{
  public static testmethod void UnAuthenticatedCaseVFPage(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'India';
    cc.Region__c='APJ';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='India';
    Ca.Region__c='APJ';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support');
   // ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'General Query';
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@test.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='Application Support';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
    
    }
    
   

  public static testmethod void UnAuthenticatedCaseVFPage1(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'United States';
    cc.Region__c='NA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='United States';
    Ca.Region__c='NA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Distribution');
   // ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'SPL Tech query';
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= null;
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='Distribution';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
    
    }
    
    public static testmethod void UnAuthenticatedCaseVFPageNull(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'United States';
    cc.Region__c='NA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='United States';
    Ca.Region__c='NA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Distribution');
   // ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= null;
    Ca.Unauthenticated_Contact_Email__c= null;
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = null;
    Ca.Creator_Email__c= null;
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='Distribution';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
   vf.ClearSubtypeOptions();
    
    vf.getCategory();
    
    }
    
    public static testmethod void UnAuthenticatedCaseVFPage3(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'Brazil';
    cc.Region__c='LATAM';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='Brazil';
    Ca.Region__c='LATAM';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Application Support');
   // ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'General Query';
    Ca.Case_Reason_Order_Support__c=null;
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= null;
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='Application Support';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
    
    }
    
    public static testmethod void UnAuthenticatedCaseVFPage4(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'UNITED KINGDOM';
    cc.Region__c='EMEA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='UNITED KINGDOM';
    Ca.Region__c='EMEA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');
    ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'Company name change';
    Ca.Case_Reason_Order_Support__c = 'Address change';
    Ca.Original_Or_Incorrect_Address__c = null;
    Ca.New_Address__c= null;
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@dell.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='On Boarding';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
    
    }
    
    public static testmethod void UnAuthenticatedCaseVFPage5(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'UNITED KINGDOM';
    cc.Region__c='EMEA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='UNITED KINGDOM';
    Ca.Region__c='EMEA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Distribution');
    ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'SPL Tech query';
    Ca.Case_Reason_Order_Support__c = null;
    
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@dell.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='Distribution';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    //vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
    
    }
    
    public static testmethod void UnAuthenticatedCaseVFPage7(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'UNITED KINGDOM';
    cc.Region__c='EMEA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='UNITED KINGDOM';
    Ca.Region__c='EMEA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');
    ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'Company name change';
    Ca.Case_Reason_Order_Support__c = 'Name & Address change';
    Ca.Original_Or_Incorrect_Address__c = null;
    Ca.New_Address__c= null;
    Ca.New_Name__c= null;
    Ca.Original_Name__c=null;
    Ca.Current_TaxID__c= null ;
    Ca.New_TaxID__c= null;
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@dell.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='On Boarding';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
    
    }
    
    public static testmethod void UnAuthenticatedCaseVFPage8(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'UNITED KINGDOM';
    cc.Region__c='EMEA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='UNITED KINGDOM';
    Ca.Region__c='EMEA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');
    ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'Company name change';
    Ca.Case_Reason_Order_Support__c = 'Name & Address change with no tax ID change';
    Ca.Original_Or_Incorrect_Address__c = null;
    Ca.New_Address__c= null;
    Ca.New_Name__c= null;
    Ca.Original_Name__c=null;
    //Ca.Current_TaxID__c= null ;
    //Ca.New_TaxID__c= null;
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@dell.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='On Boarding';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
}

public static testmethod void UnAuthenticatedCaseVFPage9(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'UNITED KINGDOM';
    cc.Region__c='EMEA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='UNITED KINGDOM';
    Ca.Region__c='EMEA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');
    ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'Company name change';
    Ca.Case_Reason_Order_Support__c =  'Tax ID change';
   /* Ca.Original_Or_Incorrect_Address__c = null;
    Ca.New_Address__c= null;
    Ca.New_Name__c= null;
    Ca.Original_Name__c=null;*/
    Ca.Current_TaxID__c= null ;
    Ca.New_TaxID__c= null;
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@dell.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='On Boarding';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
  	vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
}

public static testmethod void UnAuthenticatedCaseVFPage10(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'UNITED STATES';
    cc.Region__c='NA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='UNITED STATES';
    Ca.Region__c='NA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Order Support');
    ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'Change of Address - Post Shipment';
    //Ca.Case_Reason_Order_Support__c =  'Tax ID change';
    Ca.Original_Or_Incorrect_Address__c = null;
    Ca.New_Address__c= null;
   /* Ca.New_Name__c= null;
    Ca.Original_Name__c=null;*/
    Ca.Current_TaxID__c= null ;
    Ca.New_TaxID__c= null;
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@dell.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='Order Support';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
}

public static testmethod void UnAuthenticatedCaseVFPage11(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'UNITED STATES';
    cc.Region__c='NA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='UNITED STATES';
    Ca.Region__c='NA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Order Support');
    ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'Missing';
    //Ca.Case_Reason_Order_Support__c =  'Tax ID change';
    Ca.Original_Or_Incorrect_Address__c = null;
    Ca.New_Address__c= null;
   /* Ca.New_Name__c= null;
    Ca.Original_Name__c=null;*/
    Ca.Current_TaxID__c= null ;
    Ca.New_TaxID__c= null;
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@dell.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    ca.Delivery_Address__c='test';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='Order Support';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
}

public static testmethod void UnAuthenticatedCaseVFPage12(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'UNITED STATES';
    cc.Region__c='NA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='UNITED STATES';
    Ca.Region__c='NA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Order Support');
    ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'Return Request';
    //Ca.Case_Reason_Order_Support__c =  'Tax ID change';
    Ca.Original_Or_Incorrect_Address__c = null;
    Ca.New_Address__c= null;
   /* Ca.New_Name__c= null;
    Ca.Original_Name__c=null;*/
    Ca.Current_TaxID__c= null ;
    ca.Pick_Up_Address__c='test';
    Ca.New_TaxID__c= null;
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@dell.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    ca.Delivery_Address__c='test';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='Order Support';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
}

public static testmethod void UnAuthenticatedCaseVFPage13(){
    TriggerExecutionController.setSkipAllTriggers(true); 
    Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
    
   //String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Case' and Name = 'Application Support'].Id;
     
    Country__c cc = new Country__c();
    cc.Name= 'UNITED STATES';
    cc.Region__c='NA';
    cc.Is_Active_in_Affinity__c = true;
    cc.Code__c='test12';
    
    Insert cc;
    
    Case Ca=new Case();
    Ca.Country_Area__c='UNITED STATES';
    Ca.Region__c='NA';
    Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Order Support');
    ca.RecordTypeId=orderSuppRTId ;
    Ca.Sub_Type_Order_Support__c= 'Wrong/Damaged';
    //Ca.Case_Reason_Order_Support__c =  'Tax ID change';
    Ca.Original_Or_Incorrect_Address__c = null;
    Ca.New_Address__c= null;
   /* Ca.New_Name__c= null;
    Ca.Original_Name__c=null;*/
    Ca.Current_TaxID__c= null ;
    ca.Pick_Up_Address__c='test';
    Ca.New_TaxID__c= null;
    Ca.Unauthenticated_Contact_Email__c= 'test@test.com';
    Ca.Subject= 'test';
    Ca.Description= 'test';
    Ca.Case_Category__c = 'Internal User';
    Ca.Creator_Email__c= 'Test@dell.com';
    ca.Unauthenticated_Case__c=true;
    ca.priority='High';
    ca.Delivery_Address__c='test';
    insert Ca;
    
    
    ApexPages.currentPage().getParameters().put('id', String.valueOf(Ca.Id));

    Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
    vf.selectedvalue ='Order Support';
    
    
    vf.ca=ca;
     //vf.selectedvalue ='Application Support';
   
    vf.countryRegion();
    vf.editcase();
    vf.flag = true;
    vf.save();
    vf.getDi_SubTypeList();
    vf.DistiCaseReasons();
    vf.cancel();
   // vf.ClearCaseType();
  // vf.ClearSubtypeOptions();
    
    vf.getCategory();
}
   public static testmethod void unAuthenticatedCaseVFPage14(){
        TriggerExecutionController.setSkipAllTriggers(true); 
        Pagereference webpage = page.UnAuthenticatedCaseVFPage;
        Test.setCurrentPage(webpage);
         
        Country__c cc = new Country__c();
        cc.Name= 'UNITED STATES';
        cc.Region__c='NA';
        cc.Is_Active_in_Affinity__c = true;
        cc.Code__c='test12';
        
        Insert cc;
        
        Case ca = new Case();
        ca.Country_Area__c='UNITED STATES';
        ca.Region__c='NA';
        Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk');
        ca.RecordTypeId=orderSuppRTId ;
        ca.Sub_Type_Order_Support__c= 'Wrong/Damaged';
        ca.Original_Or_Incorrect_Address__c = null;
        ca.New_Address__c= null;
        ca.Current_TaxID__c= null ;
        ca.Pick_Up_Address__c='test';
        ca.New_TaxID__c= null;
        ca.Unauthenticated_Contact_Email__c= 'test@test.com';
        ca.Subject= 'test';
        ca.Description= 'test';
        ca.Case_Category__c = 'Internal User';
        ca.Creator_Email__c= 'Test@dell.com';
        ca.Unauthenticated_Case__c=true;
        ca.priority='High';
        ca.Delivery_Address__c='test';
        ca.Partner_Motion__c = 'Channel';
    
        Vfcntrl_UnAuthenticatedCaseVFPage vf= new Vfcntrl_UnAuthenticatedCaseVFPage();
        vf.attach1 = new Attachment(Name = 'Unit Test Attachment1', body = Blob.valueOf('Unit Test Attachment Body1'));     
        vf.attach2 = new Attachment(Name = 'Unit Test Attachment2', body = Blob.valueOf('Unit Test Attachment Body2'));
        vf.attach3 = new Attachment(Name = 'Unit Test Attachment3', body = Blob.valueOf('Unit Test Attachment Body3'));     
        vf.attach4 = new Attachment(Name = 'Unit Test Attachment4', body = Blob.valueOf('Unit Test Attachment Body4'));
        vf.attach5 = new Attachment(Name = 'Unit Test Attachment5', body = Blob.valueOf('Unit Test Attachment Body5'));
        vf.selectedvalue ='Channel Services Helpdesk';
        vf.ca=ca;   
        vf.flag = true;
        vf.save();
		
		Case cas = [SELECT Id FROM Case];
		System.assert(cas != null);
    }
}