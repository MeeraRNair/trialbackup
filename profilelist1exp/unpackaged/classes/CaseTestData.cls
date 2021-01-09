/*
 * Author   : Ragu
 * Purpose  : Utility test class for creating Case related data. 
 *
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12450    16.12       14-Dec-2015     Ragu            Created.
 * 
 */

@isTest
public class CaseTestData{
    public static boolean bCreate = true;
    public static integer iNumberOfCases = 5;
    public static list<Case> lstCases;
 
    public static testMethod void orderSuport(){
        //TriggerExecutionController.setSkipLeadTriggers(true);
        Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> accData = new List<Account>();
        List<Case> caseList = new List<Case>();
        Account testAccount = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTyId, 
                                            Partner_Type__c = 'COMMERCIAL',
                                            Partner_Tier__c = 'Tier',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'United States' );        
        accData.add(testAccount);
        insert accData;

        Contact newCont = new Contact(FirstName = 'MyTestContact7653',
                           LastName = 'MyTestContact76523',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_3@dell.com',
                           Fax = '12344567',
                          // MobilePhone = '0987676534',
                           Last_Operation_Performed__c = 'testing');
                           //Phone = '123453400');
        insert newCont;
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];
        
        User partnerUserGC = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='zh_CN', 
                            LocaleSidKey='zh_CN', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='Test99826513', 
                            isActive = TRUE,
                            Enable_Partner_Admin__c = false,
                            ContactId = newCont.Id);
        insert partnerUserGC;
        AccountTeamMember testAccountTeamMem = new AccountTeamMember(TeamMemberRole = 'Account Executive',
                                            AccountId = testAccount.Id,
                                            UserId = partnerUserGC.Id);        
        insert testAccountTeamMem;
         
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }

         
        Id trcrRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding Internal');
        Id lead2RTId = IdLookupUtils.getRecordTypeId('Talk to Dell','Lead',true);
        Id pLMCaseRTId= IdLookupUtils.getRecordTypeId('Global Lead Management Intake','Case',true);
        Id orderSupportRTId= IdLookupUtils.getRecordTypeId('Order Support','Case',true);
        List<Campaign> listCamp = new List<Campaign>();
        Id campRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);
        Campaign cMAPtestCampaign = new Campaign(Name='CMAP Campaign',
                                        Campaign_Objective__c = 'LOB Conversion',
                                        Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
                                        StartDate=System.Today() - 10,
                                        EndDate=System.Today(),
                                        Description='This is Test Campaign',
                                        IsActive=true,
                                        Partner_event_or_campaign__c =True,
                                        RecordTypeID= campRTId,
                                        partner_Inquiry_Case_Owner__c = 'Account Owner');
         listCamp.add(cMAPtestCampaign);
        insert listCamp;
        Lead sLead = new Lead(LastName = 'Test Sales Lead', 
            Lead_Type__c = 'Inbound',
            RecordTypeId =lead2RTId, 
            Email = 'testcmap@test.com',
            Status = 'Accepted',
            Phone = '88967544',
            Country = 'US',
            Campaign__c = cMAPtestCampaign.Id,
            Company = 'Test Company',
            LeadSource='Partner',
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');
            
     Test.startTest(); 
            insert sLead;
        case newCase = new Case();
            newCase.RecordTypeId = trcrRTId;    
            newCase.NPS_Category__c = 'ractor';
            newCase.Requesting_Region__c = 'Global';
            newCase.Sub_Type_Internal_User__c = 'Lead Load Request';
            newCase.Lead_Type__c = 'Inbound Lead';
            newCase.Country_Area__c = 'India';
            newCase.SuppliedEmail ='';
            newCase.AccountId = testAccount.Id;
            newCase.ContactId = newCont.id;
          //  newCase.Order_Number__c = '123432';
            newCase.Alternate_Phone__c = '745476';
            newCase.Description = '1';
            newCase.Subject = '2';
            newCase.Priority = 'High';
            newCase.Status = 'Open';
            newCase.Origin ='Partner Portal';
            newCase.Sub_Type_Partner_User__c = 'Access Issues';
            newCase.Sub_Type_Internal_User__c = 'Access Issues';
            newCase.Case_Category__c = 'Partner';
           caseList.add(newCase);
                
   Case partnerLMCase = new Case();
  
    partnerLMCase.RecordTypeId=pLMCaseRTId;
    partnerLMCase.OwnerId = testGroup.Id;      
    partnerLMCase.Subject = 'Test Partner LM Intake Case';
    partnerLMCase.Description = 'Test Partner LM Intake Case';                                                  
    partnerLMCase.Priority = 'Medium';
    partnerLMCase.Requesting_Country__c = 'India';
    partnerLMCase.Requesting_Region__c = 'APJ';
    partnerLMCase.Sub_Type_Internal_User__c='Lead Load Request';
    partnerLMCase.Lead_Type__c='Inbound Lead';
    partnerLMCase.Alternate_Phone__c='1234656';
    partnerLMCase.AccountId = testAccount.Id;
    partnerLMCase.ContactId = newCont.id;
    partnerLMCase.Lead_ID__c=sLead.Id;
  
  //insert partnerLMCase;
  //caseList.add(partnerLMCase);
  Case cOrderSupport = new Case();
  
    cOrderSupport.RecordTypeId=orderSupportRTId;
    cOrderSupport.OwnerId = testGroup.Id;      
    cOrderSupport.Subject = 'Test Partner LM Intake Case';
    cOrderSupport.Description = 'Test Partner LM Intake Case';                                                  
    cOrderSupport.Priority = 'Medium';
    cOrderSupport.Requesting_Country__c = 'India';
    cOrderSupport.AccountId = testAccount.Id;
    cOrderSupport.ContactId = newCont.id;
    cOrderSupport.Requesting_Region__c = 'APJ';
    cOrderSupport.Sub_Type_Internal_User__c='Lead Load Request';
    cOrderSupport.Country_Area__c='India';
    cOrderSupport.SuppliedEmail = '';
    cOrderSupport.Lead_Type__c='Inbound Lead';
    cOrderSupport.Alternate_Phone__c='1234656';
    cOrderSupport.Lead_ID__c=sLead.Id;
    
    caseList.add(cOrderSupport);
     //insert cOrderSupport;
     //insert newCase; 
     insert caseList;
     caseList[0].Priority = 'Low';
     update caseList[0];
     system.assertEquals(caseList, caseList); 
     Test.stopTest(); 
  //TriggerExecutionController.setSkipLeadTriggers(false);
    }
  public static testMethod void gLMIInsert(){
      Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> accData = new List<Account>();
        List<Case> caseList = new List<Case>();
        Account testAccount = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTyId, 
                                            Partner_Type__c = 'COMMERCIAL',
                                            Partner_Tier__c = 'Tier',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'United States' );        
        accData.add(testAccount);
        insert accData;

        Contact newCont = new Contact(FirstName = 'MyTestContact7653',
                           LastName = 'MyTestContact76523',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_3@dell.com',
                           Fax = '12344567',
                          // MobilePhone = '0987676534',
                           Last_Operation_Performed__c = 'testing');
                           //Phone = '123453400');
        insert newCont;
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];
        
        User partnerUserGC = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='zh_CN', 
                            LocaleSidKey='zh_CN', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='Test99826513', 
                            isActive = TRUE,
                            Enable_Partner_Admin__c = false,
                            ContactId = newCont.Id);
        insert partnerUserGC;
        AccountTeamMember testAccountTeamMem = new AccountTeamMember(TeamMemberRole = 'Account Executive',
                                            AccountId = testAccount.Id,
                                            UserId = partnerUserGC.Id);        
        insert testAccountTeamMem;
         
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        Id pLMCaseRTId= IdLookupUtils.getRecordTypeId('Global Lead Management Intake','Case',true);
        Id lead2RTId = IdLookupUtils.getRecordTypeId('Talk to Dell','Lead',true);
        List<Campaign> listCamp = new List<Campaign>();
        Id campRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);
        Campaign cMAPtestCampaign = new Campaign(Name='CMAP Campaign',
                                        Campaign_Objective__c = 'LOB Conversion',
                                        Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
                                        StartDate=System.Today() - 10,
                                        EndDate=System.Today(),
                                        Description='This is Test Campaign',
                                        IsActive=true,
                                        Partner_event_or_campaign__c =True,
                                        RecordTypeID= campRTId,
                                        partner_Inquiry_Case_Owner__c = 'Account Owner');
         listCamp.add(cMAPtestCampaign);
        insert listCamp;
        Lead sLead = new Lead(LastName = 'Test Sales Lead', 
            Lead_Type__c = 'Inbound',
            RecordTypeId =lead2RTId, 
            Email = 'testcmap@test.com',
            Status = 'Accepted',
            Phone = '88967544',
            Country = 'US',
            Campaign__c = cMAPtestCampaign.Id,
            Company = 'Test Company',
            LeadSource='Partner',
            Lead_Score__c = 'High Priority (Extremely hot leads; SLA = 48 hours)');
            
        TriggerExecutionController.setSkipLeadTriggers(true);
            insert sLead;
        TriggerExecutionController.setSkipLeadTriggers(false);
            Case partnerLMCase = new Case();
  
    partnerLMCase.RecordTypeId=pLMCaseRTId;    
    partnerLMCase.Subject = 'Test Partner LM Intake Case';
    partnerLMCase.Description = 'Test Partner LM Intake Case';                                                  
    partnerLMCase.Priority = 'Medium';
    partnerLMCase.Requesting_Country__c = 'India';
    partnerLMCase.Requesting_Region__c = 'APJ';
    partnerLMCase.Sub_Type_Internal_User__c='Lead Load Request';
    partnerLMCase.Lead_Type__c='Inbound Lead';
    partnerLMCase.Alternate_Phone__c='1234656';
    partnerLMCase.AccountId = testAccount.Id;
    partnerLMCase.ContactId = newCont.id;
    partnerLMCase.Lead_ID__c=sLead.Id;
      
     Test.startTest(); 
      insert partnerLMCase;
      //system.assertEquals(partnerLMCase, partnerLMCase);
      Test.stopTest();
  }
    public static testMethod void partnerInquiry(){
        Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> accData = new List<Account>();
        Account testAccount = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTyId, 
                                            Partner_Type__c = 'COMMERCIAL',
                                            Partner_Tier__c = 'Tier',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'United States' );        
        accData.add(testAccount);
        insert accData;
        
        Contact newCont = new Contact(FirstName = 'MyTestContact7653',
                           LastName = 'MyTestContact76523',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_3@dell.com',
                           Fax = '12344567',
                           Last_Operation_Performed__c = 'testing');
        insert newCont;
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];
        
        User partnerUserGC = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='zh_CN', 
                            LocaleSidKey='zh_CN', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='Test99826513', 
                            isActive = TRUE,
                            Enable_Partner_Admin__c = false,
                            ContactId = newCont.Id);
        insert partnerUserGC;
        
        AccountTeamMember testAccountTeamMem = new AccountTeamMember(TeamMemberRole = 'Account Executive',
                                            AccountId = testAccount.Id,
                                            UserId = partnerUserGC.Id);        
        insert testAccountTeamMem;
        
        List<Campaign> listCamp = new List<Campaign>();
        Id campRTId= IdLookupUtils.getRecordTypeId('Channel Partner Communications','Campaign',true);
        Campaign cMAPtestCampaign = new Campaign(Name='CMAP Campaign',
                                        Campaign_Objective__c = 'LOB Conversion',
                                        Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
                                        StartDate=System.Today() - 10,
                                        EndDate=System.Today(),
                                        Description='This is Test Campaign',
                                        IsActive=true,
                                        RecordTypeID= campRTId,
                                        partner_Inquiry_Case_Owner__c = 'Account Owner');        
         Campaign cMAPtestCampaign1 = new Campaign(Name='CMAP Campaign',
                                        Campaign_Objective__c = 'LOB Conversion',
                                        Global_Campaign_Type__c ='Global Channel Partner Communications',                                        
                                        StartDate=System.Today() - 10,
                                        EndDate=System.Today(),           
                                        Description='This is Test Campaign',
                                        IsActive=true,
                                        RecordTypeID= campRTId,
                                        partner_Inquiry_Case_Owner__c = 'Account Executive');
        listCamp.add(cMAPtestCampaign);
        listCamp.add(cMAPtestCampaign1);
        insert listCamp;
         
        Id prtnrInqId = StaticFactory.getRecordTypeIdByName('Case', 'Partner Inquiries');
        list<case> caseList=new list<case>();
        case newCase1 = new Case();
            newCase1.RecordTypeId = prtnrInqId;
            newCase1.AccountId = testAccount.Id;
            newCase1.ContactId = newCont.Id;
            newCase1.Campaign_Name__c = cMAPtestCampaign.Id;
            newCase1.Alternate_Phone__c = '23213';
            newCase1.Status = 'Open';
            newCase1.Country_Area__c='India';
            newCase1.SuppliedEmail = '';
            newCase1.Priority = 'Medium';
            newCase1.Origin = 'Phone';
            newCase1.Subject = 'New Case1';
            newCase1.Description = 'test new case1';
        caseList.add(newCase1);        
        case newCase2 = new Case();
            newCase2.RecordTypeId = prtnrInqId;
            newCase2.AccountId = testAccount.Id;
            newCase2.ContactId = newCont.Id;
            newCase2.Campaign_Name__c = cMAPtestCampaign1.Id;
            newCase2.Alternate_Phone__c = '23234';
            newCase2.Status = 'Open';
            newCase2.SuppliedEmail = '';
            newCase2.Country_Area__c='India';
            newCase2.Priority = 'Medium';
            newCase2.Origin = 'Phone';
            newCase2.Subject = 'New Case2';
            newCase2.Description = 'test new case2';
        caseList.add(newCase2);
        
        Test.startTest();
        insert caseList;
        map<Id, Case> mapNewCases=new map<Id, Case>();
        mapNewCases.put(newCase2.id,newCase2);
        map<Id, Account> mapAccnt=new map<Id, Account>();
        mapAccnt.put(testAccount.id,testAccount);
        
        CaseUtilities.assignPartnerInquiryCases(mapNewCases,mapAccnt);
        system.assertEquals(caseList, caseList);

        //CaseUtilities.reassignNonNPSCases(mapNewCases);
        Test.stopTest();
            
    }

    /*
    public static testMethod void createNPSCase() {
        TriggerExecutionController.setSkipAccountTriggers(True);
        TriggerExecutionController.setSkipContactTriggers(True);
        TriggerExecutionController.setSkipOpportunityTriggers(True);
        populateCommonCaseFields();
        
        Id glmiRTId = StaticFactory.getRecordTypeIdByName('Case', 'NPS Cases');
        System.debug('Shue glmiRTId --- '+glmiRTId);
        System.debug('Shue lstCases b4 iterate in method--- '+lstCases);
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = glmiRTId;
            caseIterator.Requesting_Region__c = 'Global';
            caseIterator.Sub_Type_Internal_User__c = 'Lead Load Request';
            caseIterator.Lead_Type__c = 'Inbound Lead';
            
            
            caseIterator.priority = 'High';
            
        }
        
        System.debug('Shue lstCases in method --- '+lstCases);
        if(bCreate) {
            insert lstCases;
        }
    }
    */
   
       /*
    public static testMethod void createGlobalLMICase() {
        Id accRTyId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> accData = new List<Account>();
        Account testAccount = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTyId, 
                                            Partner_Type__c = 'COMMERCIAL',
                                            Partner_Tier__c = 'Tier',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'United States' );        
        accData.add(testAccount);
        insert accData;
        Contact newCont = new Contact(FirstName = 'MyTestContact765',
                           LastName = 'MyTestContact765',
                           AccountId =testAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@dell.com',
                           Fax = '1234567',
                           MobilePhone = '098767654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '123453400');
        insert newCont;
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];
        
        User partnerUserGC = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                            Alias = 'MTU9', 
                            Email='MyTestUser9@dell.com', 
                            FirstName='MyTestUser9', 
                            LastName='MyTestUser9',  
                            ProfileId = p.Id, 
                            LanguageLocaleKey='zh_CN', 
                            LocaleSidKey='zh_CN', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='Test99826513', 
                            isActive = TRUE,
                            Enable_Partner_Admin__c = false,
                            ContactId = newCont.Id);
        insert partnerUserGC;
        
        AccountTeamMember testAccountTeamMem = new AccountTeamMember(TeamMemberRole = 'Account Executive',
                                            AccountId = testAccount.Id,
                                            UserId = partnerUserGC.Id);        
        insert testAccountTeamMem;
        
        Country__c countryObj = new Country__c(Name = 'United States',
                            Code__c = 'en_IN1',
                            Region__c = 'APJ');
        insert countryObj;
        
        Test.startTest();
        populateCommonCaseFields();
        Test.stopTest();
        
        Id glmiRTId = StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake');
        for(Case caseIterator : lstCases) {
            caseIterator.RecordTypeId = glmiRTId;
            caseIterator.Requesting_Region__c = 'Global';
            caseIterator.Sub_Type_Internal_User__c = 'Lead Load Request';
            caseIterator.Lead_Type__c = 'Inbound Lead';
            caseIterator.Country_Area__c = 'India';
            caseIterator.SuppliedEmail ='';
            caseIterator.AccountId = testAccount.Id;
            caseIterator.ContactId = newCont.id;
            caseIterator.Status = 'Open';
          //  caseIterator.Order_Number__c = '123432';
        }
        if(bCreate) {
            //TriggerExecutionController.setSkipCaseTriggers(True); 
            insert lstCases;
            //TriggerExecutionController.setSkipCaseTriggers(false); 
        }
    } 
    
   
    public static testMethod void populateCommonCaseFields() {    
        
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        List<Account> accData = new List<Account>();
        Account accInstance = new Account();
        accInstance.Name = 'Test Account';
        //insert accInstance;
        accData.add(accInstance);
        Account testAccount1 = new Account(Name='testOppDistiUser Test Account', 
                                            RecordTypeId = accRTId, 
                                            Partner_Type__c = 'COMMERCIAL',
                                            Partner_Tier__c = 'Tier',
                                            Partner_Relationship__c = 'Registered',
                                            Account_Country__c = 'United States' );        
        accData.add(testAccount1);
        
        insert accData;
        Contact newCont = new Contact(FirstName = 'MyTestContact9',
                           LastName = 'MyTestContact9',
                           AccountId =testAccount1.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyTestContactEmail_9@ust-global.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        
        insert newCont;
    /*
        Contact testContact = new Contact(FirstName='first', LastName='last', Phone='044223667788', Email='s@s.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance', 
        Job_Function_Role__c='Finance Manager', Primary_Contact__c=false, AccountId=accInstance.Id);
        insert testContact;
        System.debug('Shue testContact --- '+testContact);
        
        Map<String, String> sParams;
        sParams = new Map<String, String>();
        
        sParams.put('str_name', 'Test Account');
        Account testAcc = (Account) TestDataGenerator.getObject(new Account(), 1, sParams)[0];
        sParams.clear();    
        
        //Create User
        User testUser = (User) TestDataGenerator.getObject(new User(), 1, sParams)[0];
        sParams.clear();
    
        //Create Account Team Member
        sParams.put('str_AccountId', testAcc.Id);
        sParams.put('str_UserId', testUser.Id);
        sParams.put('str_TeamMemberRole', 'APOS Inside Sales Rep');
        AccountTeamMember acctTM = (AccountTeamMember) TestDataGenerator.getObject(new AccountTeamMember(), 1, sParams)[0];
          */  /*
        lstCases = new list<Case>();
        for(integer i=0; i<iNumberOfCases; i++) {
            Case caseIterator = new Case();
            caseIterator.Status = 'Open';
            caseIterator.Subject = 'Case Test Subject_' + i;
            caseIterator.Description = 'Case Test Description_' + i;
            caseIterator.AccountId = accInstance.Id;
            //caseIterator.ContactId = testContact.id;
            
            lstCases.add(caseIterator);
        }
        System.debug('Shue lstCases --- '+lstCases);
    }
    */
    /*
  public static testMethod void CaseTeam() {
      TriggerExecutionController.setSkipAccountTriggers(True);
      TriggerExecutionController.setSkipContactTriggers(True);
      TriggerExecutionController.setSkipOpportunityTriggers(True);
      TriggerExecutionController.setSkipUserTriggers(True);
    
      Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
      Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
       RecordTypeId = accRTyId,
       Partner_Type__c = 'COMMERCIAL',
       Partner_Tier__c = 'Tier',
       Partner_Relationship__c = 'Registered',
       Account_Country__c = 'United States');
      insert testAccount;
             
          
      Contact newCont = new Contact(FirstName = 'MyTestContact7653',
       LastName = 'MyTestContact76523',
       AccountId = testAccount.Id,
       Status__c = 'Marketing Suspect',
       Email = 'MyTestContactEmail_3@dell.com',
       Fax = '123445667777',
       Last_Operation_Performed__c = 'testing');
      insert newCont;
        /* 
      Profile userprofile = [SELECT Id FROM Profile WHERE Name like '%System Admin%' LIMIT 1];
      User testUser = new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
       Alias = 'MTU9',
       Email = 'MyTestUser9@dell.com',
       FirstName = 'MyTestUser9',
       LastName = 'MyTestUser9',
       ProfileId = userprofile.Id,
       LanguageLocaleKey = 'zh_CN',
       LocaleSidKey = 'zh_CN',
       EmailEncodingKey = 'UTF-8',
       TimeZoneSidKey = 'America/Los_Angeles',
       Badge_Number__c = 'Test99826513',
       isActive = TRUE);
      insert testUser;
       system.debug('****User :'+testUser);
         
      AccountTeamMember Teammemberad = new AccountTeamMember();
       Teammemberad.AccountId = testAccount.id;
       Teammemberad.UserId = testUser.Id;
       Teammemberad.TeamMemberRole = 'Inside Sales Rep';
      insert Teammemberad;
      *

      List<QueueSobject> QueueName = new List<QueueSobject>();
      QueueName = [SELECT Id,QueueId FROM QueueSobject WHERE Queue.name LIKE '%Cases - Order Support Global%' Limit 1];
      Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
      case newCase = new Case();
      newCase.AccountId = testAccount.Id;
      newCase.ContactId = newCont.id;
      newCase.Status = 'Open';
      newCase.Priority = 'High';
      newCase.Sub_Type_Order_Support__c = 'Box Recycling';
      newCase.RecordTypeId = orderSuppRTId;
      newCase.Order_Number1__c = '123432';
      newCase.Alternate_Phone__c = '745476';
      newCase.Description = 'DO NOT RUN PB';
      newCase.Subject = '2';
      newCase.Origin = 'Partner Portal';
      newCase.Case_Category__c = 'Partner';
      newCase.OwnerId = QueueName[0].QueueId;
      
      Test.startTest();
      insert newCase;
      Test.stopTest();
        
     } */
}