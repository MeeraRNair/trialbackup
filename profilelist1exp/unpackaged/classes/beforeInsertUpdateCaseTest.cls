@istest
private class beforeInsertUpdateCaseTest {
    
    public static  List<AccountTeamMember> atmList = new List<AccountTeamMember>();
    public static List<Case> ListCase = new List<Case>();
    //Test Class for beforeInsertUpdateCase Trigger
   /* static testMethod void CaseTest() {
    List<Contact> ListCon = new List<Contact>();
    
    
   
    Case updatec1 = new Case();
    List <Case> testCase = new List<Case>();
    //CMAP Account -------------
    Id Acc_Id = IdLookupUtils.getRecordTypeId('Partner Account','Account', TRUE);
    system.debug('RRRRR:::'+Acc_Id);
    Account cmapAccount = new Account(Name = 'CMAP Test', Account_Country_Code__c = 'US',Account_Country__c ='UNITED STATES');
    insert cmapAccount;
    
    System.debug('cmapAccount:::'+cmapAccount);
    //
   Account cAccount = new Account(Name = 'C Account Test', Account_Country_Code__c = 'US',Account_Country__c ='UNITED STATES');
    insert cAccount;
    
    System.debug('### cAccount:' +cAccount.Id);
    
    
    RecordType PartnerPortal = [select id,Name from RecordType where SobjectType='Case' and Name Like '%Partner%' Limit 1];
    
    // DP 1 Feb CR 7913        
    Country__c country = new Country__c(Name = 'UNITED STATES', Region__c = 'NA',code__C='US');
    insert country;
    // DP 1 Feb CR 7913
     //CMAP Con ----------------
     Contact cmapContact = new Contact(status__c = 'Prospect',FirstName = 'CMAP Test', LastName = 'Summers', AccountId = cmapAccount.Id, Decision_Making_Role__c = 'End User', Email = 'rakesh_muppiri@dell.com');
    ListCon.add(cmapContact);   
    system.debug('cmapContact::'+cmapContact);     
     //    
    
 //--   User u = [SELECT Id FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name like '%Sales Mgr%') AND isActive = TRUE LIMIT 1];
    //public Contact cContact {set;get;}
//--    AccountShare AcShare = new AccountShare(AccountAccessLevel='Read',OpportunityAccessLevel ='Read', AccountId=cAccount.Id,UserOrGroupId=u.Id );
 //--   insert AcShare;
 //--   System.debug('ACCCsha'+AcShare);
    Contact  cContact = new Contact(status__c = 'Prospect', FirstName = 'C Scott', LastName = 'Summers', AccountId = cAccount.Id, Decision_Making_Role__c = 'End User', Email = 'Cyclops@Xmen.com');
    System.debug('AAA'+cAccount.ID);
 //--   System.RunAs(u){
        ListCon.add(cContact);
    
        insert ListCon;
 //--   }
    
     Profile p = [select id from profile 
                     where usertype = : 'PowerPartner' 
                     limit 1];   
     
      User testUser2 = new User(Username='testvaliduser02' +'@dell.com',
                        Alias = 'Test', 
                        Email='Test1'+'@dell.com',            
                        LastName='Test1',
                        Title='GCC Program Manager', 
                        ProfileId = p.Id, 
                        ContactId = cContact.id,
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8',
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='Test'+System.currentTimeMillis());
                        
    insert testUser2;  
         
         AccountTeamMember atm = new AccountTeamMember();    
                atm.AccountId = cAccount.Id;
                atm.UserId = testUser2.Id;
                atm.TeamMemberRole = 'Account Executive';
    insert atm;
    System_Behavior_Bypasser__c vr = new System_Behavior_Bypasser__c();
             vr.Bypass_Case_VRs__c = true;
             insert vr;
    
    Case c = new Case();
    c.AccountId = cAccount.Id;
    c.ContactId = cContact.Id;
    //c1.Status = 'Open';
    c.Origin = 'Partner Portal';
    c.RecordTypeId = PartnerPortal.id;
    c.Sub_Type_Internal_User__c = 'Password Reset';
    c.Subject = 'Test Case Class 1';
    c.Description = 'This is a test';                                                    
    c.Priority = 'Medium';
    c.Alternate_Phone__c='123456789';
    // DP 1 Feb CR 7913
    c.Case_Category__c = 'Partner';
    c.Country_Area__c = 'UNITED STATES';        
    // DP 1 Feb CR 7913         
    //testCase.add(c1);
        //Insert Case 1
        //System.debug('###Before Insert: case - ' +c1.Id);
        
        insert c;
    
    
                 
    //Profile P = [SELECT id, Name FROM Profile where name = 'GBL PRM Operations'
    
   // User U1 = new user(FirstName = 'Sponge', LastName = 'Bob', Alias = 'Sbob', Email = 'SB@Cartoons.com',
      //        UserName = 'SB@Cartoons.com', ProfileId = P.Id, emailencodingkey = 'UTF-8', languagelocalekey = 'en_US',
     //         localesidkey = 'en_US', timezonesidkey = 'America/Los_Angeles');
   // insert U1;          
                
    //Create Case
        //Case 1
    
    Test.startTest();   
    
    System.runAs(testUser2) {
    
    Case c1 = new Case();
    c1.AccountId = cAccount.Id;
    c1.ContactId = cContact.Id;
    //c1.Status = 'Open';
    c1.Origin = 'Partner Portal';
    c1.RecordTypeId = PartnerPortal.id;
    c1.Sub_Type_Internal_User__c = 'Password Reset';
    c1.Subject = 'Test Case Class 1';
    c1.Description = 'This is a test';                                                  
    c1.Priority = 'Medium';
    c1.Alternate_Phone__c='123456789';
    // DP 1 Feb CR 7913
    c1.Country_Area__c = 'UNITED STATES';           
    c1.Case_Category__c = 'Partner'; 
    // DP 1 Feb CR 7913    
    //testCase.add(c1);
        //Insert Case 1
        //System.debug('###Before Insert: case - ' +c1.Id);
        insert c1;
        
     
     }   
    
        //Retrieve Case 1
        //c1 = [SELECT Region__c FROM Case WHERE Id =: c1.Id];
        //System.debug('### Before Insert: case - region -' +c1.Id);
        
    //Case 2
       
    Case c2 = new Case();
    // DP 1 Feb CR 7913
    //c2.AccountId = cAccount.Id
    // c2.ContactId = cContact.Id;
    c2.Case_Category__c = 'Internal';
    c2.Country_Area__c = 'UNITED STATES';   
    // DP 1 Feb CR 7913
    
    //c2.Status = 'Open';
    c2.Origin = 'Phone';
    c2.RecordTypeId = PartnerPortal.id;
    c2.Sub_Type_Internal_User__c = 'Catalog Request';
    c2.Subject = 'Test Case Class 2';
    c2.Description = 'This is also a test';
    c2.Alternate_Phone__c='123898789'; 
    c2.Priority = 'Low';
    c2.Status = 'Open'; // Added DP CR 7913 1 Feb 
        
    //cmap Case-----------------
    //CMAP----------------------
    List<Campaign> ListCamp = new List<Campaign>();
    Id CampRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);
        Campaign CMAPtestCampaign = new Campaign(Name='CMAP Campaign',
                                        Campaign_Objective__c = 'LOB Conversion',
                                        Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
                                        StartDate=System.Today() - 10,
                                        EndDate=System.Today(),
                                        Description='This is Test Campaign',
                                        IsActive=true,
                                        RecordTypeID= CampRTId,
                                        partner_Inquiry_Case_Owner__c = 'Account Owner');
         Campaign CMAPtestCampaign1 = new Campaign(Name='CMAP Campaign',
                                        Campaign_Objective__c = 'LOB Conversion',
                                        Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
                                        StartDate=System.Today() - 10,
                                        EndDate=System.Today(),
                                        Description='This is Test Campaign',
                                        IsActive=true,
                                        RecordTypeID= CampRTId,
                                        partner_Inquiry_Case_Owner__c = 'Account Executive');
    ListCamp.add(CMAPtestCampaign);
    ListCamp.add(CMAPtestCampaign1);
    insert ListCamp;
    System.debug('CMAPtestCampaign:::'+CMAPtestCampaign);
    // 
        Id PartnerCaseRTId= IdLookupUtils.getRecordTypeId('Partner Inquiries','Case',true);
        Case pcse = new Case();
        pcse.RecordTypeId = PartnerCaseRTId;
        pcse.AccountId = cmapAccount.Id;
        pcse.ContactId = cmapContact.Id;
        pcse.Campaign_Name__c= CMAPtestCampaign.Id;
        pcse.Alternate_Phone__c = '2323';
        pcse.Status = 'Open';
        pcse.Priority = 'Medium';
        pcse.Origin = 'Phone';
        pcse.Subject = 'New Case';
        pcse.Description = 'test new case';
        
        Case pcse1 = new Case();
        pcse1.RecordTypeId = PartnerCaseRTId;
        pcse1.AccountId = cmapAccount.Id;
        pcse1.ContactId = cmapContact.Id;
        pcse1.Campaign_Name__c = CMAPtestCampaign1.Id;
        pcse1.Alternate_Phone__c = '2323';
        pcse1.Status = 'Open';
        pcse1.Priority = 'Medium';
        pcse1.Origin = 'Phone';
        pcse1.Subject = 'New Case';
        pcse1.Description = 'test new case';
        testCase.add(pcse);
        testCase.add(pcse1);
        //
    //testCase.add(c2);
    //insert testCase;
    testCase.add(c2);
    insert testCase;
      ///
      //CMAP
        
 //Start: Dipin
 //   Id campRTId= IdLookupUtils.getRecordTypeId('Campaign 2.0','Campaign',true);
    Id lead2RTId = IdLookupUtils.getRecordTypeId('Talk to Dell','Lead',true);
    Id PLMCaseRTId= IdLookupUtils.getRecordTypeId('Global Lead Management Intake','Case',true);
  
    Lead SLead = new Lead(LastName = 'Test Sales Lead', 
            Lead_Type__c = 'Inbound',
            RecordTypeId =lead2RTId, 
            Email = 'testcmap@test.com',
            Status = 'Accepted',
            Phone = '88967544',
            Country = 'US',
            Campaign__c = CMAPtestCampaign.Id,
            Company = 'Test Company',
            LeadSource='Partner',
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');
    insert SLead;
    
    Case PartnerLMCase = new Case();
    
        PartnerLMCase.RecordTypeId=PLMCaseRTId;
        PartnerLMCase.Subject = 'Test Partner LM Intake Case';
        PartnerLMCase.Description = 'Test Partner LM Intake Case';                                                  
        PartnerLMCase.Priority = 'Medium';
        PartnerLMCase.Requesting_Country__c = 'India';
        PartnerLMCase.Requesting_Region__c = 'APJ';
        PartnerLMCase.Sub_Type_Internal_User__c='Lead Load Request';
        PartnerLMCase.Lead_Type__c='Inbound Lead';
        PartnerLMCase.Alternate_Phone__c='1234656';
        PartnerLMCase.Lead_ID__c=SLead.Id;
    
    insert PartnerLMCase;
//End: Dipin          
      ////
    Test.stopTest();
        
    //Bulk/
    
    
    
    
    //Case updateCaseList = [SELECT Id, Status, OwnerId, RecordTypeId, Sub_Type_Internal_User__c FROM Case WHERE Id =: CaseList[0].Id];
    
    //updateCaseList.Status = 'Working';
    //update updateCaseList;
    
    //Case updatec2 = [SELECT Id, Status, OwnerId, RecordTypeId, Sub_Type_Internal_User__c FROM Case WHERE Id =: c2.Id];
    //updatec2.Status = 'Closed';
    //update updatec2 ;  
    
    //Test.stopTest();
    
    //Case resultC1 = [Select Id, Status FROM Case WHERE Id =: CaseList[0].Id]; 
    
    //Case resultC2 = [Select Id, Status FROM Case WHERE Id=: CaseList[3].Id];
            //System.assertEquals(resultC1.Status,'Working');
        Case c3 = [select Status from Case where Id =: c2.Id];
        System.assertEquals(c3.Status,'Open');
        c2.Alternate_Phone__c='123898789';
        update c2;
        }*/
    static testMethod void CaseTest_EMEA() {
        //Country
        Country__c con = new Country__c(Name = 'AUSTRIA', Region__c = 'EMEA',code__C='AT');
        insert con;
        
        //Account
        Account Acc = new Account(Name = 'test_cAcc', Account_Country_Code__c = 'AT',Account_Country__c ='AUSTRIA');
        insert Acc;
        
        Contact cont = new Contact(status__c = 'Prospect',FirstName = 'testUsr', LastName = 'tst', AccountId = Acc.Id, Decision_Making_Role__c = 'End User', Email = 'testusr@test.com');
        insert cont;
    
        //Case
        Id CaseRTId= IdLookupUtils.getRecordTypeId('Partner Lead Management','Case',true);
        Case cse = new Case();
        cse.RecordTypeId = CaseRTId;
        cse.AccountId = Acc.Id;
        cse.ContactId = cont.Id;
        cse.Alternate_Phone__c = '2323';
        cse.Case_Category__c = 'Internal';
        cse.Status = 'Open';
        cse.Priority = 'Medium';
        cse.Origin = 'Phone';
        cse.Sub_Type_Internal_User__c = 'Access Issues';
        cse.Subject = 'New Case';
        cse.Description = 'test new case';
        ListCase.add(cse);
        
        Test.startTest();
        insert ListCase;
        Test.stopTest();
         
    }
}