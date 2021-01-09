@isTest(seealldata = false)
private class CreateNewLobControllerTest{

  static testMethod void MethodValidRecord(){
    
    Account EUacc = createEndUserAccount();          
    LOB_Administration__c lobAdminRecord = createLOBAdmin();                
    LOB_Registration__c lobRegClientRecord = new LOB_Registration__c ();
    lobRegClientRecord.LOB_Name__c ='Client';             
    lobRegClientRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
    lobRegClientRecord.LOB_Award_Type__c = 'Account';    
    List<SelectOption> testLOB = new List<SelectOption>();
    testLOB.add(new SelectOption('Client','Client'));
    testLOB.add(new SelectOption('Storage','Storage'));
     
    PageReference pageRef = Page.CreateNewLob;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('accid',EUacc.Id);
    CreateNewLobController con = new CreateNewLobController(new ApexPages.StandardController(lobRegClientRecord));

    con.selectedLobRecords  = testLOB ;
    con.Save();
    con.Cancel();

  }
  
  static testMethod void MethodNoSelectedRecords(){
    
    Account EUacc = createEndUserAccount();          
    LOB_Administration__c lobAdminRecord = createLOBAdmin();                
    LOB_Registration__c lobRegClientRecord = new LOB_Registration__c ();
    lobRegClientRecord.LOB_Name__c ='Client';             
    lobRegClientRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
    lobRegClientRecord.LOB_Award_Type__c = 'Account';        
    PageReference pageRef = Page.CreateNewLob;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('accid',EUacc.Id);
    CreateNewLobController con = new CreateNewLobController(new ApexPages.StandardController(lobRegClientRecord));

    con.Save();
    con.Cancel();

  }
  
   static testMethod void MethodLocation(){
    
    Account EUacc = createEndUserAccount();          
    LOB_Administration__c lobAdminRecord = createLOBAdmin();                
    LOB_Registration__c lobRegClientRecord = new LOB_Registration__c ();
    lobRegClientRecord.LOB_Name__c ='Client';             
    lobRegClientRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
    lobRegClientRecord.LOB_Award_Type__c = 'Location';    
    lobRegClientRecord.City__c = null;    

    List<SelectOption> testLOB = new List<SelectOption>();
    testLOB.add(new SelectOption('Client','Client'));
    testLOB.add(new SelectOption('Storage','Storage'));
        
    PageReference pageRef = Page.CreateNewLob;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('accid',EUacc.Id);
    CreateNewLobController con = new CreateNewLobController(new ApexPages.StandardController(lobRegClientRecord));
    
    con.selectedLobRecords  = testLOB ;
    con.Save();
    con.Cancel();

  }
  
   static testMethod void MethodSubsidiary(){
    
    Account EUacc = createEndUserAccount();          
    LOB_Administration__c lobAdminRecord = createLOBAdmin();                
    LOB_Registration__c lobRegClientRecord = new LOB_Registration__c ();
    lobRegClientRecord.LOB_Name__c ='Client';             
    lobRegClientRecord.Subsidiary_Name__c = null;    

    lobRegClientRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
    lobRegClientRecord.LOB_Award_Type__c = 'Local Subsidiary';    
    List<SelectOption> testLOB = new List<SelectOption>();
    testLOB.add(new SelectOption('Client','Client'));
    testLOB.add(new SelectOption('Storage','Storage'));
        
    PageReference pageRef = Page.CreateNewLob;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('accid',EUacc.Id);
    CreateNewLobController con = new CreateNewLobController(new ApexPages.StandardController(lobRegClientRecord));

    con.selectedLobRecords  = testLOB ;
    con.Save();
    con.Cancel();

  }
  
  
  private static Account createEndUserAccount(){
    
    Id endUserAccountRT = [select Name from RecordType where Name ='End-User Account' limit 1].Id;
    Account EUacc = new Account();
    EUacc.Name = 'Test Account';
    EUacc.Participating_in_LOB_Program__c = true;
    EUacc.RecordTypeId = endUserAccountRT;
    EUacc.Account_Country__c = 'UNITED STATES';
    EUacc.ShippingStreet = '12';
    EUacc.ShippingCity = 'testStreet';
    EUacc.ShippingState = 'testTexas';
    EUacc.ShippingPostalCode = '1324';
    EUacc.Tax_Registration_Number__c = '124214';
    insert EUacc;
    return EUacc;
  }
  
  private Static LOB_Administration__c createLOBAdmin(){
    
    LOB_Administration__c lobAdminRecord = new LOB_Administration__c();
    lobAdminRecord.Name = 'Client';
    lobAdminRecord.LOB_Administration_Name_Unique__c ='Client';
    lobAdminRecord.Active__c = true;
    insert lobAdminRecord;
    return lobAdminRecord;

  }
  
  /************************************** Multi Select Picklist *******************************/
  
  static testMethod void MethodMultiSelect(){
    
    MultiselectController con = new MultiselectController();
    List<SelectOption> testLOB = new List<SelectOption>();
    testLOB.add(new SelectOption('Client','Client'));
    testLOB.add(new SelectOption('Storage','Storage'));
    con.leftOptions = testLOB;
    con.rightOptions = testLOB;
    con.leftOptionsHidden= 'Client';
    con.rightOptionsHidden ='Client & Storage';
    
  }
  
}