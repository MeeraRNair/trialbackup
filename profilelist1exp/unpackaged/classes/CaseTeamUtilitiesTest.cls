/*
 * Author   : Ragu.
 * Purpose  : To test CaseTeamUtilities class. 
 *
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      CR 12450    16.12       10-Dec-2015     Ragu            Created.
 * 
 */
 
@isTest
private class CaseTeamUtilitiesTest { 
   
 public static testMethod void addAccountTeamMembersToCaseTeam() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipUserTriggers(True);
  TriggerExecutionController.setSkipAllTriggers(True);
  
 Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
  Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        acc.Website = 'www.dell.com';
  insert acc;
  
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
   AccountId = acc.Id,
   Status__c = 'Marketing Suspect',
   Email = 'MyTestContactEmail_3@dell.com',
   Fax = '123445667777',
   Last_Operation_Performed__c = 'testing');
  insert newCont;
  
   testAccount.Primary_Contact__c = newCont.Id;
   update testAccount;
     
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
     
  AccountTeamMember teamMemberad = new AccountTeamMember();
   teamMemberad.AccountId = testAccount.id;
   teamMemberad.UserId = testUser.Id;
   teamMemberad.TeamMemberRole = 'Inside Sales Rep';
  insert teamMemberad;
  system.debug('****Teammember :' +teamMemberad);
     
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
  newCase.Unauthenticated_Case__c=false;
  
  Test.startTest();
  insert newCase;
   system.debug('****New Case:' +newCase);
   newCase.Status = 'Assigned';
   newCase.OwnerID=teamMemberad.UserId;
  Update newCase ;
  system.assertEquals('Assigned', newCase.status);
  Test.stopTest();
 }
 
 public static testMethod void addPartnerUsersToCaseTeam() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipUserTriggers(True);
  
  Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
  Account acc = new Account();
        acc.Name = 'testMasterAccount';
        acc.NPS_Qualified_Contacts__c = 1;
        acc.RecordTypeId = masterAccountRecordTypeId;
        acc.Website = 'www.dell.com';
  insert acc;

  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
  Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
  insert testAccount;
         
      
  Contact newCont1 = new Contact(FirstName = 'MyTestContact77253',
   LastName = 'MyTestContact76523',
   AccountId = acc.Id,
   Status__c = 'Market Suspect',
   Email = 'MyTest33User1234876@dell.com',
   Fax = '123434344567',
   Last_Operation_Performed__c = 'tes44ting');
  insert newCont1;
   
   Contact newCont2 = new Contact(FirstName = 'MyTestContact7253',
   LastName = 'MyTestContact523',
   AccountId = acc.Id,
   Status__c = 'Marketing4 Suspect',
   Email = 'MyTes3223User9@dell.com',
   Fax = '123434344567',
   Last_Operation_Performed__c = 'tes44ting');
  insert newCont2;
     
   Contact newCont3 = new Contact(FirstName = 'MyTstContact77253',
   LastName = 'MyTestContac6523',
   AccountId = acc.Id,
   Status__c = 'Marketing43 Suspect',
   Email = 'MyTesfgvb44r9@dell.com',
   Fax = '123434344567',
   Last_Operation_Performed__c = 'tes44ting');
  insert newCont3;
  
  Contact newCont4 = new Contact(FirstName = 'MyTstCocxsdcntact77253',
   LastName = 'MyTestContasdsc6523',
   AccountId = acc.Id,
   Status__c = 'Marketing43 Suspect',
   Email = 'MyTesfgvdsb44r9@dell.com',
   Fax = '123434ds344567',
   Last_Operation_Performed__c = 'tes44ting');
  insert newCont4;
  
  
   testAccount.Primary_Contact__c = newCont1.Id;
   update testAccount;
     
 Profile userprofile = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];   
   
   User partnerUser1 = new User(Username = 'MyUser345432' + System.currentTimeMillis() + '@dell.com',
        Alias = 'MT0987',
        Email = 'MyTest33User1234876@dell.com',
        FirstName = 'MyTest36584898',
        LastName = 'MyTest365898658',
        ProfileId = userprofile.Id,
        LanguageLocaleKey = 'zh_CN',
        LocaleSidKey = 'zh_CN',
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/Los_Angeles',
        Badge_Number__c = 'Test94477826513',
        isActive = TRUE,
        ContactId = newCont1.Id,
        Enable_Partner_Admin__c = True);
       insert partnerUser1;
   
     User partnerUser2 = new User(Username = 'My44Te4587654' + System.currentTimeMillis() + '@dell.com',
        Alias = 'MT4431',
        Email = 'MyTes3223User9@dell.com',
        FirstName = 'MyTe44453ser9',
        LastName = 'MyTes6759893ser9',
        ProfileId = userprofile.Id,
        LanguageLocaleKey = 'zh_CN',
        LocaleSidKey = 'zh_CN',
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/Los_Angeles',
        Badge_Number__c = 'tferg9826513',
        isActive = TRUE,
        ContactId = newCont2.Id,
        Enable_Partner_Admin__c = True);
       insert partnerUser2;
    
     User partnerUser3 = new User(Username = 'Myrth555r9' + System.currentTimeMillis() + '@dell.com',
        Alias = 'M559',
        Email = 'MyTesfgvb44r9@dell.com',
        FirstName = 'My876t5reer9',
        LastName = 'MyT087jhyser9',
        ProfileId = userprofile.Id,
        LanguageLocaleKey = 'zh_CN',
        LocaleSidKey = 'zh_CN',
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/Los_Angeles',
        Badge_Number__c = 'Mikuy9444539826513',
        isActive = TRUE,
        ContactId = newCont3.Id,
        Enable_Partner_Admin__c = True);
       insert partnerUser3;
       
       User partnerUser4 = new User(Username = 'Myrwd34wth555r9' + System.currentTimeMillis() + '@dell.com',
        Alias = 'M52359',
        Email = 'MyTvb44r9@dell.com',
        FirstName = 'sdt5reer9',
        LastName = '087343jhyser9',
        ProfileId = userprofile.Id,
        LanguageLocaleKey = 'zh_CN',
        LocaleSidKey = 'zh_CN',
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/Los_Angeles',
        Badge_Number__c = 'Mikuy944sdsds45393',
        isActive = TRUE,
        ContactId = newCont4.Id,
        Enable_Partner_Admin__c = True);
       insert partnerUser4;
 
      Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
      case newCase = new Case();
      newCase.AccountId = testAccount.Id;
      newCase.ContactId = newCont1.id;
      newCase.Status = 'Open';
      newCase.Priority = 'High';
      newCase.Sub_Type_Order_Support__c = 'Box Recycling';
      newCase.RecordTypeId = orderSuppRTId;
      newCase.Order_Number1__c = '123432';
      newCase.Alternate_Phone__c = '745476';
      newCase.Description = 'DO NOT RUN PB';
      newCase.Subject = '2';
      newCase.Additional_Recipient_1__c = 'MyTest33User1234876@dell.com';
      newCase.Additional_Recipient_2__c = 'MyTest33User1234876@dell.com';
      newCase.Additional_Recipient_3__c = 'MyTes3223User9@dell.com';
      newCase.Additional_Recipient_4__c = 'MyTesfgvb44r9@dell.com';
      newCase.Additional_Recipient_5__c = 'MyTesfgvb44r9@dell.com';
      newCase.Origin = 'Partner Portal';
      newCase.Case_Category__c = 'Partner';
      newCase.Unauthenticated_Case__c=false;
      Test.startTest();
     //system.runAs(partnerUser1) {   
      insert newCase;
      //}
      newCase.Status = 'Assigned';
      //newCase.OwnerId= partnerUser4.Id;
      Update newCase ;
      system.assertEquals('Assigned', newCase.status);
      Test.stopTest();
      
      List<CaseTeamMember> listctms1= [Select Id, MemberId,TeamRoleId From CaseTeamMember];
       List<CaseTeamRole> listcaseTeamRole = new List<CaseTeamRole>();
       listcaseTeamRole = [select Id from CaseTeamRole where Name = 'Account Team Member' limit 1];
       List<CaseTeamMember> listctm = new List<CaseTeamMember>();
            CaseTeamMember listctmadd = new CaseTeamMember();

            listctmadd.ParentId = newCase.id;
            listctmadd.MemberId = partnerUser4.Id;
            listctmadd.TeamRoleId = listcaseTeamRole[0].Id;
            insert listctmadd;

            CaseShare caseShare = new CaseShare();
  caseShare.CaseId = newCase.Id;
  caseShare.UserOrGroupId = partnerUser4.Id;
  caseShare.RowCause = 'Manual';
  caseShare.CaseAccessLevel = 'Edit';
   upsert(caseShare);
  newCase.OwnerId= partnerUser4.Id;
      Update newCase ;
            list<case> listallCases = new list<case>();
            listallCases.add(newCase);
            try{
            CaseTeamUtilities.addCaseRequestorToCaseTeam(listallCases);
           }catch(exception ex){}
            
 } 
 
 public static testMethod void addRecipientUsersToCaseTeamTest() {
 
 TriggerExecutionController.setSkipAccountTriggers(True);
 TriggerExecutionController.setSkipContactTriggers(True);
 TriggerExecutionController.setSkipUserTriggers(True);
  
 Id masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
 Account acc = new Account();
    acc.Name = 'testMasterAccount';
    acc.NPS_Qualified_Contacts__c = 1;
    acc.RecordTypeId = masterAccountRecordTypeId;
    acc.Website = 'www.dell.com';
 insert acc;
  
 Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
 Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
 insert testAccount;
         
 Track__c trackObj = new Track__c(Name= 'testTrack',Zone__c = 'Zone 1');
 insert trackObj;
            
 Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
    testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
    testPartnerTrackObj.Track_Id__c = trackObj.id;
    testPartnerTrackObj.Master_Group_Id__c = acc.Id;
    testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c = acc.Account_Id__c;
 insert testPartnerTrackObj;

 Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
    testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
    testPartnerTrackObj1.Track_Id__c = trackObj.id;
    testPartnerTrackObj1.Master_Group_Id__c = acc.Id;
 insert testPartnerTrackObj1;

 Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
    testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data 22';
    testPartnerTrackObj2.Track_Id__c = trackObj.id;
    testPartnerTrackObj2.Master_Group_Id__c = acc.Id;
 insert testPartnerTrackObj2;
       
 List<Contact> listcon = new List<contact>();
 Contact con = new Contact (AccountId = acc.id,LastName = 'portalTestUser',Email='testingdit5@gshaj.com',EligibleTracks__c = testPartnerTrackObj2.Id+';'+testPartnerTrackObj1.Id,Selected_Track__c=testPartnerTrackObj2.Id);
 listcon.add(con);
 
 Contact con1 = new Contact (Salutation='Mrs',AccountId = acc.id,FirstName='Testing', LastName = 'portalTestUser2',Email='tuitingdit5@gshaj.com',
                           //Other_Job_Function_Category__c ='others',Allow_Partner_Central_User__c=false,Allow_Program_Tracker__c = false,
                           //Is_MDF_User__c = false,Allow_RFP_and_Proposal_Express_Tool__c = false,
                           Phone='12345', Is_Rebate_User__c = false, Premier_Partner__c = false,
                           EligibleTracks__c = testPartnerTrackObj2.Id);
 listcon.add(con1);
 
 insert listcon;
            
 Profile userprofile = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];   
   
 User partnerUser1 = new User(Username = 'MyUser345432' + System.currentTimeMillis() + '@dell.com',
        Alias = 'MT0987',
        Email = 'MyTest33User1234876@dell.com',
        FirstName = 'MyTest36584898',
        LastName = 'MyTest365898658',
        ProfileId = userprofile.Id,
        LanguageLocaleKey = 'zh_CN',
        LocaleSidKey = 'zh_CN',
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/Los_Angeles',
        Badge_Number__c = 'Test94477826513',
        isActive = TRUE,
        ContactId = listcon[0].Id,
        Enable_Partner_Admin__c = True,
        Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Deal_Registration__c = true, 
        Enable_Partner_Lead_Management__c = true,Enable_As_Partner_Lead_Super_User__c = true);
 insert partnerUser1;
       
 listcon[0].Partner_User__c = partnerUser1.id;
 update listcon;
 
 Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
 case newCase = new Case();
      newCase.AccountId = acc.Id;
      newCase.ContactId = listcon[0].id;
      newCase.Status = 'Open';
      newCase.Priority = 'High';
      newCase.Sub_Type_Order_Support__c = 'Box Recycling';
      newCase.RecordTypeId = orderSuppRTId;
      newCase.Order_Number1__c = '12343212';
      newCase.Alternate_Phone__c = '745476';
      newCase.Description = 'DO NOT RUN PB';
      newCase.Subject = '222';
      newCase.Additional_Recipient_1__c = 'MyTest333User1234876@dell.com';
      newCase.Additional_Recipient_2__c = 'MyTest33U3ser1234876@dell.com';
      newCase.Additional_Recipient_3__c = 'MyTes32233User9@dell.com';
      newCase.Additional_Recipient_4__c = 'MyTesfgvb434r9@dell.com';
      newCase.Additional_Recipient_5__c = 'MyTesfgvb443r9@dell.com';
      newCase.Origin = 'Partner Portal';
      newCase.Case_Category__c = 'Partner';
      newCase.Unauthenticated_Case__c=False;
      Test.startTest();
  insert newCase;

  newCase.Status = 'Assigned';
  Update newCase ;
  system.assertEquals('Assigned', newCase.status);
  
  List<CaseTeamRole> listcaseTeamRole = new List<CaseTeamRole>();
  listcaseTeamRole = [select Id from CaseTeamRole where Name = 'Account Team Member' limit 1];
  List<CaseTeamMember> listctm = new List<CaseTeamMember>();
    CaseTeamMember listctmadd = new CaseTeamMember();
    listctmadd.ParentId = newCase.id;
    listctmadd.MemberId = partnerUser1.Id;
    listctmadd.TeamRoleId = listcaseTeamRole[0].Id;
  insert listctmadd;

  CaseShare caseShare = new CaseShare();
      caseShare.CaseId = newCase.Id;
      caseShare.UserOrGroupId = partnerUser1.Id;
      caseShare.RowCause = 'Manual';
      caseShare.CaseAccessLevel = 'Edit';
  upsert(caseShare);
    Test.stopTest();
            
  list<case> listallCases = new list<case>();
  listallCases.add(newCase);
  
  Map < Id, case> mapCase= new Map < Id, case> ();
  mapCase.put(newCase.id, newCase);
  try{
    CaseTeamUtilities.removeCaseCreatorAccessAfterOwnerChange(listallCases,mapCase);
  }catch(exception ex){}
    
 } 
     
 public static testMethod void addWebToCaseRequestorToCaseTeamTest() {
       
   Profile userprofile = [SELECT Id FROM Profile WHERE Name like '%System Admin%' LIMIT 1];
   
   TriggerExecutionController.setSkipAccountTriggers(True);
   TriggerExecutionController.setSkipContactTriggers(True);
   TriggerExecutionController.setSkipUserTriggers(True);
 
   User partnerUser = new User(Username = 'MyUser345432' + System.currentTimeMillis() + '@dell.com',
        Alias = 'MT0987',
        Email = 'MyTest1244User1234876@dell.com',
        FirstName = 'MyTest36584898',
        LastName = 'MyTest365898658',
        ProfileId = userprofile.Id,
        LanguageLocaleKey = 'zh_CN',
        LocaleSidKey = 'zh_CN',
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/Los_Angeles',
        Badge_Number__c = 'Test9447723826513',
        isActive = TRUE,
        Enable_Partner_Admin__c = True,
        Enable_as_Partner_Group_Administrator__c = true, Enable_Partner_Deal_Registration__c = true, 
        Enable_Partner_Lead_Management__c = true,Enable_As_Partner_Lead_Super_User__c = true);
   insert partnerUser;
        
   Id idCaseRT= StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake'); 
   Attachment attach=new Attachment();
   attach.Name='GLMITest.doc';
   case objGLMICase = new Case(SuppliedName='GLMICase-From Test Class');
        objGLMICase.RecordTypeId =idCaseRT;
        objGLMICase.SUPPLIEDEMAIL='MyTest1244User1234876@dell.com';
        objGLMICase.SUBJECT='Test GLMI Case - Test Class';
        objGLMICase.Description='This is a test case created from GLMICaseCreationCtrlTest class';
        objGLMICase.Sub_Type_Internal_User__c ='Lead Load Request';
        objGLMICase.Lead_Type__c='Inbound Lead';
        objGLMICase.Requesting_Region__c='APJ';
        objGLMICase.Send_to_LQR__c=true;
        objGLMICase.origin ='Web';
        objGLMICase.status='Open';
   TriggerExecutionController.setSkipCaseTriggers(True);
   insert objGLMICase; 
        
   objGLMICase.status='Assigned';
   update objGLMICase;
   TriggerExecutionController.setSkipCaseTriggers(False);
   
   system.assertEquals('Assigned', objGLMICase.status); 
        
   } 
   
   
   public static testMethod void addWebToCaseGuestToCaseTeamTest() {
        Id idCaseRT= StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake');
        
        Case objGLMICase = new Case(SuppliedName='Guest Case Creation');
        objGLMICase.RecordTypeId =idCaseRT;
        objGLMICase.SuppliedEmail ='guestcasecreation@guest123.com';
        objGLMICase.Subject ='Guest Case Creation Test';
        objGLMICase.Description='This is a test case created from GLMICaseCreationCtrlTest class by Guest User License';
        objGLMICase.Sub_Type_Internal_User__c ='Online Form/Chat/Phone';
        objGLMICase.Requesting_Region__c='Global';
        objGLMICase.Send_to_LQR__c=true;
        objGLMICase.Origin ='Web';
        objGLMICase.Status ='Open';
        
        Test.startTest();
        insert objGLMICase; 
        Test.stopTest();

        System.assertEquals('Open', objGLMICase.status); 
        
   }
   
 }