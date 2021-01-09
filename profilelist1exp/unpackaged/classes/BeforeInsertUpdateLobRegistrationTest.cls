@isTest
private class BeforeInsertUpdateLobRegistrationTest{

    static testMethod void TestBeforeInsertUpdateLobRegistration() {
    
         Id recTypeId = [Select Id From RecordType Where SObjectType ='Account' Limit 1][0].Id;
               
         Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
         User u = new User(LastName = 'Test', Badge_Number__c = '098879475',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
         insert u;
        
        
         Account acc = new account(name='test',Type ='End User', BillingCountry = 'United Kingdom', Participating_in_LOB_Program__c= true,OwnerId = u.Id, RecordTypeId = recTypeId);
         insert acc;
        
        
        AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Account Executive',AccountId = acc.Id,UserId = u.id);
        insert atbr;
        
        LOB_Registration__c lobObj = new LOB_Registration__c();
        lobObj.Registered_End_User__c = acc.Id;
        lobObj.Partner_Sales_Rep_Language__c = 'English'; 
        lobObj.City__c = 'Round Rock';
        lobObj.State_Province_Region__c = 'Texas';       
        insert lobObj;
        
        system.runAs(u){
            lobObj.Partner_Sales_Rep_Language__c = 'English';
            lobObj.LOB_registration_status__c = 'Partner(submit for approval)';
            update lobObj;
            
            lobObj.LOB_registration_status__c = 'Revoked';
            update lobObj;
            
        }
        
    }
    
    static testMethod void TestBeforeInsertUpdateLobRegistration2() {
    
         Id recTypeId = [Select Id From RecordType Where SObjectType ='Account' Limit 1][0].Id;
               
         Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
         User u = new User(LastName = 'Test', Badge_Number__c = '123879475',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
         insert u;        
        
         Account acc = new account(name='test',Type ='End User', BillingCountry = 'United Kingdom', Participating_in_LOB_Program__c= true,OwnerId = u.Id, RecordTypeId = recTypeId);
         insert acc;      
        
        AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Account Executive',AccountId = acc.Id,UserId = u.id);
        insert atbr;
    
        LOB_Registration__c lobObj2 = new LOB_Registration__c();
        lobObj2.Registered_End_User__c = acc.Id;
        lobObj2.GTM_Linkage_Expiry_Date__c= Date.Today()+1;
        lobObj2.City__c = 'Round Rock';
        lobObj2.State_Province_Region__c = 'Texas';
        insert lobObj2;
        
        LOB_Registration__c lobObj3 = new LOB_Registration__c();
        lobObj3.Registered_End_User__c = acc.Id;
        lobObj3.Partner_Sales_Rep_Language__c = 'English';        
        lobObj3.LOB_registration_status__c = 'Rejected';
        lobObj3.City__c = 'Round Rock';
        lobObj3.State_Province_Region__c = 'Texas';
        insert lobObj3;
   
    }
    
    static testMethod void LobAwardEmailNotificationTest() {
        list<Id> LOBlist = new list<Id>();
        Map<Id,List<AccountTeamMember>> acc2TMMap = new Map<Id,List<AccountTeamMember>>();
        list<AccountTeamMember> atmList = new list<AccountTeamMember>();
        
        Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
        User u = new User(LastName = 'Test', Badge_Number__c = '879475test',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
        insert u;
         
        Account acc = new account(name='test',Type ='End User', BillingCountry = 'United Kingdom', Participating_in_LOB_Program__c= true);
        insert acc; 
        
        AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Account Executive',AccountId = acc.Id,UserId = u.id);
        insert atbr;
        acc2TMMap.put(acc.id,atmList);
         
        Contact con = new contact(AccountId =acc.id, Email='test@test.com', lastName='test', Phone='23432',Mobilephone='2343',Eloqua_ID__c = '123');
        insert con;
        
        LOB_Registration__c lobObj2 = new LOB_Registration__c();
        lobObj2.Registered_End_User__c = acc.Id;
        lobObj2.GTM_Linkage_Expiry_Date__c= Date.Today()+1;
        lobObj2.City__c = 'Round Rock';
        lobObj2.State_Province_Region__c = 'Texas';
        insert lobObj2;
        LOBlist.add(lobObj2.Id);
        
        LOB_Registration__c lobObj3 = new LOB_Registration__c();
        lobObj3.Registered_End_User__c = acc.Id;
        lobObj3.Partner_Sales_Rep_Language__c = 'English';        
        lobObj3.LOB_registration_status__c = 'Rejected';
        lobObj3.City__c = 'Round Rock';
        lobObj3.State_Province_Region__c = 'Texas';
       // insert lobObj3;
        //LOBlist.add(lobObj3.Id);
        
        system.runas(u){
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'Email to GCC When LOB is Partner Approved';
            validEmailTemplate.DeveloperName = u.Name;
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
    
           // insert validEmailTemplate;
        }
                 
        LOBAwardEmailNotification LOBclass = new LOBAwardEmailNotification ();
        LOBclass.sendEmail(LOBlist,acc2TMMap);
    
    }
    
    static testMethod void LobAwardEmailNotificationTest2() {
        list<Id> LOBlist = new list<Id>();
        Map<Id,List<AccountTeamMember>> acc2TMMap = new Map<Id,List<AccountTeamMember>>();
        list<AccountTeamMember> atmList = new list<AccountTeamMember>();
        
        Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
        User u = new User(LastName = 'Test', Badge_Number__c = '879475test',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
        insert u;
         
        Account acc = new account(name='test',Type ='Partner Account', BillingCountry = 'United Kingdom', Participating_in_LOB_Program__c= true, Is_GTM_Partner__c = true);
        insert acc; 
        
        AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Account Executive',AccountId = acc.Id,UserId = u.id);
        insert atbr;
        acc2TMMap.put(acc.id,atmList);
         
        Contact con = new contact(AccountId =acc.id, Email='test@test.com', lastName='test', Phone='23432',Mobilephone='2343',Eloqua_ID__c = '123');
        insert con;
        
        Id partnerApprovedId = [Select Id from RecordType where  SobjectType = 'LOB_Registration__c' AND DeveloperName = 'LOB_registration_Partner_Approved'].Id;
         
        LOB_Registration__c lobObj2 = new LOB_Registration__c();
        lobObj2.Registered_End_User__c = acc.Id;
        lobObj2.GTM_Linkage_Expiry_Date__c= Date.Today()+1;
        lobObj2.City__c = 'Round Rock';
        lobObj2.State_Province_Region__c = 'Texas';
        lobObj2.RecordTypeId = partnerApprovedId;
        lobObj2.LOB_registration_status__c = 'Partner(approved)';
        lobObj2.Preferred_GTM_Partner_Account__c = acc.Id;
        try{
        insert lobObj2;
        LOBlist.add(lobObj2.Id);
        }catch(exception e){}
        LOB_Registration__c lobObj3 = new LOB_Registration__c();
        lobObj3.Registered_End_User__c = acc.Id;
        lobObj3.Partner_Sales_Rep_Language__c = 'English';        
        lobObj3.LOB_registration_status__c = 'Rejected';
        lobObj3.City__c = 'Round Rock';
        lobObj3.State_Province_Region__c = 'Texas';
        lobObj3.RecordTypeId = partnerApprovedId;
       // insert lobObj3;
        //LOBlist.add(lobObj3.Id);
        
        system.runas(u){
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'Email to GCC When LOB is Partner Approved';
            validEmailTemplate.DeveloperName = u.Name;
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
    
           // insert validEmailTemplate;
        }
                 
        LOBAwardEmailNotification LOBclass = new LOBAwardEmailNotification ();
        LOBclass.sendEmail(LOBlist,acc2TMMap);
    
    }
    
    static testMethod void TestBeforeInsertUpdateLobRegistration_Partner_RSM_Email() {
    
         Id recTypeId = [Select Id From RecordType Where SObjectType ='Account' Limit 1][0].Id;
               
         Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
         User u = new User(LastName = 'Test', Badge_Number__c = '9865879475',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
         insert u;
        
        
         Account acc = new account(name='test',Type ='End User', BillingCountry = 'United Kingdom', Participating_in_LOB_Program__c= true,OwnerId = u.Id, RecordTypeId = recTypeId);
         insert acc;
        
        
        AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Account Executive',AccountId = acc.Id,UserId = u.id);
        insert atbr;
        
        LOB_Registration__c lobObj = new LOB_Registration__c();
        lobObj.Registered_End_User__c = acc.Id;
        lobObj.Partner_Sales_Rep_Language__c = 'English'; 
        lobObj.City__c = 'Round Rock';
        lobObj.State_Province_Region__c = 'Texas';       
        insert lobObj;
        
        system.runAs(u){
            lobObj.Partner_RSM_Email__c = 'test@lob.com';            
            update lobObj;
            
            
        }
        
    }
    
    static testMethod void TestBeforeInsertUpdateLobRegistration_validations() {
    
         Id recTypeId = [Select Id From RecordType Where SObjectType ='Account' Limit 1][0].Id;
               
         Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
         User u = new User(LastName = 'Test', Badge_Number__c = '7654879475',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
         insert u;
        
        
         Account acc = new account(name='test',Type ='End User', BillingCountry = 'United Kingdom', Participating_in_LOB_Program__c= true,OwnerId = u.Id, RecordTypeId = recTypeId);
         insert acc;
        
        
        AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Account Executive',AccountId = acc.Id,UserId = u.id);
        insert atbr;
        
        
        
        system.runAs(u){
            try{
                LOB_Registration__c lobObj = new LOB_Registration__c();
                lobObj.Registered_End_User__c = acc.Id;
                lobObj.Partner_Sales_Rep_Language__c = 'English'; 
                lobObj.City__c = 'Round Rock';
                lobObj.State_Province_Region__c = 'Texas';
                lobObj.LOB_registration_status__c = 'Partner(approved)'; 
                lobObj.GTM_Linkage_Expiry_Date__c = System.Today();      
                insert lobObj;
                }catch(Exception e){
                    system.debug('Validation error');
                }            
            
        }
        
    }
static testMethod void TestBeforeInsertUpdateLobRegistration_ExpiryDefault() {  
    
    Map<string,String> maplobnames=new  Map<string,String>();
    Map<String,Decimal> MaplobDetails=New Map<String,Decimal>();
    Id recTypeId = [Select Id From RecordType Where SObjectType ='Account' Limit 1][0].Id;
    Profile myProf = [SELECT Id FROM Profile WHERE Name = 'Standard User'];//or whatever profile you want
    User u = new User(LastName = 'Test', Badge_Number__c = '879475test',email = 'test@dell.com.sit', Alias = 'myAlias', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testdit4@dell.com.sit', profileId = myProf.Id);
    insert u;
    
   Account acc = new account(name='test',Type ='End User', BillingCountry = 'United Kingdom', Participating_in_LOB_Program__c= true,OwnerId = u.Id, RecordTypeId = recTypeId);
    insert acc; 
    
    AccountTeamMember atbr = new AccountTeamMember(TeamMemberRole = 'Account Executive',AccountId = acc.Id,UserId = u.id);
    insert atbr;
        
    //Id partnerApprovedId = [Select Id from RecordType where  SobjectType = 'LOB_Registration__c' AND DeveloperName = 'LOB_registration_Partner_Approved'].Id;
    
    LOB_Registration__c lobObj2 = new LOB_Registration__c();
        lobObj2.LOB_registration_status__c ='Partner(approved)';
        lobObj2.LOB_Name__c ='Storage';
        lobObj2.LOB_Partner_Approved_Date__c =System.Today();
        lobObj2.GTM_Linkage_Expiry_Date__c =null;
//        lobObj2.Partner_Sales_Rep_Language__c = 'English'; 
        lobObj2.City__c = 'Round Rock';
        lobObj2.State_Province_Region__c = 'Texas';
        lobObj2.Registered_End_User__c = acc.Id;
      //  lobObj2.RecordTypeId = partnerApprovedId;
        lobObj2.LOB_registration_status__c = 'Partner(approved)';
        lobObj2.Preferred_GTM_Partner_Account__c = acc.Id;
        try{
        insert lobObj2;
        }
        catch(exception e){}
    maplobnames.put(lobObj2.id,lobObj2.LOB_Name__c);
    
    LOB_Administration__c locAdmin = new LOB_Administration__c();
    locAdmin.Name='Storage';
    locAdmin.LOB_Administration_Name_Unique__c='Storage';
    locAdmin.Linkage_Expiry_Default__c=730;
    insert locAdmin;
    
    MaplobDetails.put(locAdmin.Name,locAdmin.Linkage_Expiry_Default__c);
    
    System.runAs(u){ 
    
        lobObj2.GTM_Linkage_Expiry_Date__c =lobObj2.LOB_Partner_Approved_Date__c.addDays(Integer.valueof(MaplobDetails.get(lobObj2.LOB_Name__c)));
      //  lobObj2.Id= locAdmin.id;
       // update lobObj2;
    
        
    
    }

}    
    
}