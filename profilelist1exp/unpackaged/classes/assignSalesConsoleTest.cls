@isTest
private class assignSalesConsoleTest {
   
   public static  testmethod void testMethod1(){
   
    GlobalVariables.SKIP_AssignSalesConsole_USR_TRG_InTest = false;  // use this variable to skip user trigger to assign Sales console license
    
    Profile p1 = [select id from profile where name like '%GBL Sales Mgr%' Order By CreatedDate desc limit 1];
    User salesRep = new User();
    salesRep.Alias = 'SC1';
    salesRep.CommunityNickname = 'SC1';
    salesRep.Email = 'SC1@dell.com';
    salesRep.LastName = 'LastName1';
    salesRep.UserName = System.currentTimeMillis() + '@dell.com';
    salesRep.Badge_Number__c = String.valueOf(Math.round(Math.random()*1000000000)) + '00' + system.now().millisecond(); //v1.1 v4.0
    salesRep.TimeZoneSidKey = 'GMT';
    salesRep.LocaleSidKey = 'en_US';
    salesRep.EmailEncodingKey = 'UTF-8';
    salesRep.ProfileId = p1.Id;
    salesRep.Enable_Partner_Lead_Management__c = false;
    salesRep.LanguageLocaleKey = 'en_US';
    salesRep.isActive = true;
    insert salesRep;   
    
    Test.startTest();    
    List<PermissionSetLicenseAssign> psLList = [select id from PermissionSetLicenseAssign 
                                                    where AssigneeId = :salesRep.id
                                                    and PermissionSetLicenseId = :System.Label.SalesConsole_PermissionSetLicenseId];
    
    List<PermissionSetAssignment> psList = [select id from PermissionSetAssignment
                                                    where AssigneeId = :salesRep.id
                                                    and PermissionSetId = :System.Label.SalesConsole_PermissionSetId];
       
    if(psList.size()!=0){                                                 
        Database.DeleteResult[] deletePSList = Database.delete (psList,false) ;
        
        if(psLList.size()!=0)
        Database.DeleteResult[] deletePSLList = Database.delete (psLList,false) ;
    }
    if(psLList.size()==0){
        list<PermissionSetLicenseAssign> lstInsertpsl = new list<PermissionSetLicenseAssign>();
        PermissionSetLicenseAssign psl = new PermissionSetLicenseAssign (AssigneeId = salesRep.id, PermissionSetLicenseId = System.Label.SalesConsole_PermissionSetLicenseId);
        lstInsertpsl.add(psl);
        Database.SaveResult[] insertpsl = database.insert(lstInsertpsl,false);  
        
    }
        
    if(psList.size()==0){
        list<PermissionSetAssignment> lstInsertpsa = new list<PermissionSetAssignment>();
        PermissionSetAssignment psa = new PermissionSetAssignment (AssigneeId = salesRep.id, PermissionSetId = System.Label.SalesConsole_PermissionSetId);
        lstInsertpsa.add(psa);
        Database.SaveResult[] insertpsa = database.insert(lstInsertpsa,false);  
    }
          
    salesRep.isActive = false;
    Profile p2 = [select id from profile where name like '%IT GBL%' Order By CreatedDate desc limit 1];
    salesRep.ProfileId = p2.Id;
    update salesRep;  

    
    Profile p3 = [select id from profile where name like '%JPN Sales Mgr%' Order By CreatedDate desc limit 1];
    salesRep.ProfileId = p3.Id;
    salesRep.isActive = true;
    update salesRep;
    
    Test.stopTest();
         
    GlobalVariables.SKIP_AssignSalesConsole_USR_TRG_InTest = true; 
    
  }
  
}