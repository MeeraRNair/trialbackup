@isTest(SeeAllData=false)
private class LOB_AvailableCustomersTest {

    static testMethod void singleSelectLOB_AvailableCustomers(){
     Id endUserAccountRT = [select Name from RecordType where Name ='End-User Account' limit 1].Id;
     Id partnerAccountRT = [select Name from RecordType where Name ='Partner Account' limit 1].Id;

     Account EUacc = new Account();
     EUacc.Name = 'Test Account';
     EUacc.Type = 'Partner';
     EUacc.Participating_in_LOB_Program__c = true;
     EUacc.RecordTypeId = endUserAccountRT;
     EUacc.Account_Country__c = 'UNITED STATES';
     EUacc.ShippingStreet = '12';
     EUacc.ShippingCity = 'testStreet';
     EUacc.ShippingState = 'testTexas';
     EUacc.ShippingPostalCode = '1324';
     EUacc.Tax_Registration_Number__c = '124214';
     insert EUacc;
     
     Contact EUCon = new Contact();
     EUCon.FirstName = 'testFirstName';
     EUCon.LastName = 'testLastName';
     EUCon.Email = 'test@test.com';
     EUCon.Phone = '1234';
     EUCon.AccountId = EUacc.Id;
     insert EUCon;
     EUacc.Primary_Contact__c = EUCon.Id;
     update EUacc;
     
     Account partnerAcc = new Account();
     partnerAcc.Name = 'Test Account1';
     partnerAcc.Is_GTM_Partner__c = true;
     EUacc.Type = 'Partner';
     partnerAcc.RecordTypeId = partnerAccountRT;
     insert partnerAcc;
     system.debug('***'+partnerAcc);
    
     
     List<LOB_Registration__c> lobRegList = new List<LOB_Registration__c>();
                
     LOB_Registration__c lobRegClientRecord = new LOB_Registration__c ();
     lobRegClientRecord.LOB_Name__c ='Client';             
     lobRegClientRecord.Registered_End_User__c= EUacc.Id;
     lobRegClientRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
     lobRegClientRecord.LOB_registration_status__c = 'Partner(approved)';
     lobRegClientRecord.LOB_Award_Type__c = 'Account';
     lobRegClientRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;          
     lobRegClientRecord.City__c  ='testCity';
     lobRegClientRecord.State_Province_Region__c = 'testState';
     lobRegList.add(lobRegClientRecord);
     
     LOB_Registration__c lobRegServerRecord = new LOB_Registration__c ();
     lobRegServerRecord.LOB_Name__c ='Server';             
     lobRegServerRecord.Registered_End_User__c= EUacc.Id;
     lobRegServerRecord.LOB_Partner_Approved_Date__c =system.today().addDays(-1);
     lobRegServerRecord.LOB_registration_status__c = 'Partner(approved)';
     lobRegServerRecord.LOB_Award_Type__c = 'Account';
     lobRegServerRecord.City__c  ='testCity';
     lobRegServerRecord.State_Province_Region__c = 'testState';
     lobRegServerRecord.Preferred_GTM_Partner_Account__c = partnerAcc.Id;
     lobRegServerRecord.GTM_Linkage_Expiry_Date__c = system.today().addDays(365);           
     lobRegList.add(lobRegServerRecord);
     
     insert lobRegList;
                 
     PageReference pageRef = Page.LOB_AvailableCustomers;
     Test.setCurrentPage(pageRef);    
     pageRef.getParameters().put('id',partnerAcc.Id);
     pageRef.getParameters().put('00NA00000063WJM','Distibutor');
     pageRef.getParameters().put('00NA00000063WJM','');
       
     ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(lobRegList);
     LOB_AvailableCustomers lac = new LOB_AvailableCustomers();
     lac.getLOB_Registration();   
     lac.lobRecordList[0].selected = true;            
     lac.pageRedirect();                             
     lac.checkSelect();              
    }
             
    static testMethod void noSetConSelectLOB_AvailableCustomers(){
      
      Id partnerAccountRT = [select Name from RecordType where Name ='Partner Account' limit 1].Id;
      
      Account partnerAcc = new Account();
      partnerAcc.Name = 'Test Account1';
      partnerAcc.Is_GTM_Partner__c = true;
      partnerAcc.RecordTypeId = partnerAccountRT;
      insert partnerAcc;
          
      PageReference pageRef = Page.LOB_AvailableCustomers;
      Test.setCurrentPage(pageRef); 
      pageRef.getParameters().put('id',partnerAcc.Id);
      List<LOB_Registration__c> lobRegList= new List<LOB_Registration__c> ();         
      ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(lobRegList);      
      LOB_AvailableCustomers lac = new LOB_AvailableCustomers();
      lac.getLOB_Registration();             

    }
    
}