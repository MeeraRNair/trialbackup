/************************************************************
 * 
 * Name          : VfCntrl_RequestEscalationVFPageTest
 * Description   : Test class to "VfCntrl_RequestEscalationVFPage" 
 * ----------------------------------------------------------
 * Revision  Name            Date                 CR                                         
 * 1.0       Naresh      02.01.2018                                      
 ************************************************************/

@isTest
public class VfCntrl_RequestEscalationVFPageTest{

 public static testMethod void orderSuport() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);
  TriggerExecutionController.setSkipAllTriggers(True);

  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
  List < Account > accData = new List < Account > ();
  Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
  accData.add(testAccount);
  insert accData;

  Contact newCont = new Contact(FirstName = 'MyTestContact7653',
   LastName = 'MyTestContact76523',
   AccountId = testAccount.Id,
   Status__c = 'Marketing Suspect',
   Email = 'MyTestContactEmail_3@dell.com',
   Fax = '12344567',
   Last_Operation_Performed__c = 'testing');
  insert newCont;
  Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];
  Profile gblPRM = [SELECT Id FROM Profile WHERE Name like '%GBL PRM%' LIMIT 1];
  
  User gblPrmUser= new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
   Alias = 'MTU9',
   Email = 'MyTestUser9@dell.com',
   FirstName = 'MyTestUser9',
   LastName = 'MyTestUser9',
   ProfileId = gblPRM.Id,
   LanguageLocaleKey = 'zh_CN',
   LocaleSidKey = 'zh_CN',
   EmailEncodingKey = 'UTF-8',
   TimeZoneSidKey = 'America/Los_Angeles',
   Badge_Number__c = 'Test998uyu26513',
   isActive = TRUE);
   insert gblPrmUser;

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
  newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Order_Reference_Number_Type__c = 'Order Number';   
  newCase.Case_Category__c = 'Partner';
  newcase.Unauthenticated_Case__c =true;

 insert newCase;
   newCase.ownerid=gblPrmUser.id;
   update newcase;
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newCase);  
   VfCntrl_RequestEscalationVFPage re=new VfCntrl_RequestEscalationVFPage(sc);
   case tc=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c  from case where id=:newCase.id];
   re.CaseNumber=tc.CaseNumber;
   re.EscalateJustification='Test';
   //re.EscalateValidations();
   
   newCase.Escalation_Justification__c = 'Test Escalation';
   newCase.Request_Escalation__c = True;
   
   re.okSave();
   re.cancel();
   tc.status='Closed (Resolved)';
   tc.Case_Resolution_Details_Order_Support__c = '1234';
   //user us=CMuser();
   system.runAs(gblPrmUser) {
   update tc;
   }
   system.debug('check tc status' +tc.Status);
   
   
 }
 
  public static testMethod void orderSuport1() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);
  TriggerExecutionController.setSkipAllTriggers(True);

  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
  List < Account > accData = new List < Account > ();
  Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
  accData.add(testAccount);
  insert accData;

  Contact newCont = new Contact(FirstName = 'MyTestContact7653',
   LastName = 'MyTestContact76523',
   AccountId = testAccount.Id,
   Status__c = 'Marketing Suspect',
   Email = 'MyTestContactEmail_3@dell.com',
   Fax = '12344567',
   Last_Operation_Performed__c = 'testing');
  insert newCont;
  Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

  Profile gblPRM = [SELECT Id FROM Profile WHERE Name like '%GBL PRM%' LIMIT 1];
  
  User gblPrmUser= new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
   Alias = 'MTU9',
   Email = 'MyTestUser9@dell.com',
   FirstName = 'MyTestUser9',
   LastName = 'MyTestUser9',
   ProfileId = gblPRM.Id,
   LanguageLocaleKey = 'zh_CN',
   LocaleSidKey = 'zh_CN',
   EmailEncodingKey = 'UTF-8',
   TimeZoneSidKey = 'America/Los_Angeles',
   Badge_Number__c = 'Test998uyu26513',
   isActive = TRUE);
   insert gblPrmUser;


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
  newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Order_Reference_Number_Type__c = 'Order Number';   
  newCase.Case_Category__c = 'Partner';
  newcase.Unauthenticated_Case__c =true;

 // system.runAs(partnerUserGC) {
   insert newCase;
   newCase.ownerid=gblPrmUser.id;
   update newcase;
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newCase);  
   VfCntrl_RequestEscalationVFPage re=new VfCntrl_RequestEscalationVFPage(sc);
   case tc=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c  from case where id=:newCase.id];
   re.CaseNumber=tc.CaseNumber;
   re.EscalateJustification='Test';
   //re.EscalateValidations();
   
   newCase.Escalation_Justification__c = 'Test Escalation';
   newCase.Request_Escalation__c = True;
   //re.okSave();
   tc.status='Closed (Resolved)';
   tc.Case_Resolution_Details_Order_Support__c = '1234';
   user us=CMuser();
   system.runAs(gblPrmUser) {
   update tc;
   }
   system.debug('check tc status' +tc.Status);
   case tc1=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c,Unauthenticated_Case__c  from case where id=:newCase.id];
   system.debug('check tc1 status' +tc1.Status);
   ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(tc1);
   VfCntrl_RequestEscalationVFPage re1=new VfCntrl_RequestEscalationVFPage(sc1);
   re1.CaseNumber=tc.CaseNumber;
   re1.EscalateJustification='Test';
   //re1.EscalateValidations();
   re1.oksave();
   
 }
 
 public static testMethod void orderSuport2() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);
  TriggerExecutionController.setSkipAllTriggers(True);

  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
  List < Account > accData = new List < Account > ();
  Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
  accData.add(testAccount);
  insert accData;

  Contact newCont = new Contact(FirstName = 'MyTestContact7653',
   LastName = 'MyTestContact76523',
   AccountId = testAccount.Id,
   Status__c = 'Marketing Suspect',
   Email = 'MyTestContactEmail_3@dell.com',
   Fax = '12344567',
   Last_Operation_Performed__c = 'testing');
  insert newCont;
  Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

  User partnerUserGC = new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
   Alias = 'MTU9',
   Email = 'MyTestUser9@dell.com',
   FirstName = 'MyTestUser9',
   LastName = 'MyTestUser9',
   ProfileId = p.Id,
   LanguageLocaleKey = 'zh_CN',
   LocaleSidKey = 'zh_CN',
   EmailEncodingKey = 'UTF-8',
   TimeZoneSidKey = 'America/Los_Angeles',
   Badge_Number__c = 'Test99826513',
   isActive = TRUE,
   ContactId = newCont.Id);
  // insert partnerUserGC;

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
  newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Order_Reference_Number_Type__c = 'Order Number';   
  newCase.Case_Category__c = 'Partner';
  newcase.Unauthenticated_Case__c =true;

 // system.runAs(partnerUserGC) {
   insert newCase;
   
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newCase);  
   VfCntrl_RequestEscalationVFPage re=new VfCntrl_RequestEscalationVFPage(sc);
   case tc=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c  from case where id=:newCase.id];
   re.CaseNumber=tc.CaseNumber;
   re.EscalateJustification='Test';
   //re.EscalateValidations();
   
   newCase.Escalation_Justification__c = 'Test Escalation';
   newCase.Request_Escalation__c = True;
   //re.okSave();
   tc.status='Assigned';
   tc.Case_Resolution_Details_Order_Support__c = '1234';
   Update tc;
   system.debug('check tc status' +tc.Status);
   case tc1=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c,Unauthenticated_Case__c  from case where id=:newCase.id];
   system.debug('check tc1 status' +tc1.Status);
   ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(tc1);
   VfCntrl_RequestEscalationVFPage re1=new VfCntrl_RequestEscalationVFPage(sc1);
   re1.CaseNumber=tc.CaseNumber;
   re1.EscalateJustification='Test';
   re1.EscalateValidations();   
   
 }
 
 public static testMethod void orderSuport4() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);
  TriggerExecutionController.setSkipAllTriggers(True);

  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
  List < Account > accData = new List < Account > ();
  Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
  accData.add(testAccount);
  insert accData;

  Contact newCont = new Contact(FirstName = 'MyTestContact7653',
   LastName = 'MyTestContact76523',
   AccountId = testAccount.Id,
   Status__c = 'Marketing Suspect',
   Email = 'MyTestContactEmail_3@dell.com',
   Fax = '12344567',
   Last_Operation_Performed__c = 'testing');
  insert newCont;
  Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

  User partnerUserGC = new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
   Alias = 'MTU9',
   Email = 'MyTestUser9@dell.com',
   FirstName = 'MyTestUser9',
   LastName = 'MyTestUser9',
   ProfileId = p.Id,
   LanguageLocaleKey = 'zh_CN',
   LocaleSidKey = 'zh_CN',
   EmailEncodingKey = 'UTF-8',
   TimeZoneSidKey = 'America/Los_Angeles',
   Badge_Number__c = 'Test99826513',
   isActive = TRUE,
   ContactId = newCont.Id);
  // insert partnerUserGC;

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
  newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Order_Reference_Number_Type__c = 'Order Number';   
  newCase.Case_Category__c = 'Partner';
  newcase.Unauthenticated_Case__c =true;

 // system.runAs(partnerUserGC) {
   insert newCase;
   
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newCase);  
   VfCntrl_RequestEscalationVFPage re=new VfCntrl_RequestEscalationVFPage(sc);
   case tc=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c  from case where id=:newCase.id];
   re.CaseNumber=tc.CaseNumber;
   re.EscalateJustification='Test';
   //re.EscalateValidations();
   
   tc.Escalation_Justification__c = 'Test Escalation';
   tc.Request_Escalation__c = false;
   //re.okSave();
   tc.status='Completed';
   tc.Case_Resolution_Details_Order_Support__c = '1234';
   update tc;
   system.debug('check tc status' +tc.Status);
   case tc1=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c,Unauthenticated_Case__c  from case where id=:newCase.id];
   system.debug('check tc1 status' +tc1.Status);
   ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(tc1);
   VfCntrl_RequestEscalationVFPage re1=new VfCntrl_RequestEscalationVFPage(sc1);
   re1.CaseNumber=tc.CaseNumber;
    re1.EscalateJustification='Test';
   re1.EscalateValidations();   
   
 }
 
 public static testMethod void orderSuport3() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);
  TriggerExecutionController.setSkipAllTriggers(True);

  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
  List < Account > accData = new List < Account > ();
  Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
  accData.add(testAccount);
  insert accData;

  Contact newCont = new Contact(FirstName = 'MyTestContact7653',
   LastName = 'MyTestContact76523',
   AccountId = testAccount.Id,
   Status__c = 'Marketing Suspect',
   Email = 'MyTestContactEmail_3@dell.com',
   Fax = '12344567',
   Last_Operation_Performed__c = 'testing');
  insert newCont;
  Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

  User partnerUserGC = new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
   Alias = 'MTU9',
   Email = 'MyTestUser9@dell.com',
   FirstName = 'MyTestUser9',
   LastName = 'MyTestUser9',
   ProfileId = p.Id,
   LanguageLocaleKey = 'zh_CN',
   LocaleSidKey = 'zh_CN',
   EmailEncodingKey = 'UTF-8',
   TimeZoneSidKey = 'America/Los_Angeles',
   Badge_Number__c = 'Test99826513',
   isActive = TRUE,
   ContactId = newCont.Id);
  // insert partnerUserGC;

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
  newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Order_Reference_Number_Type__c = 'Order Number';   
  newCase.Case_Category__c = 'Partner';
  newcase.Unauthenticated_Case__c =true;

 // system.runAs(partnerUserGC) {
   insert newCase;
   
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newCase);  
   VfCntrl_RequestEscalationVFPage re=new VfCntrl_RequestEscalationVFPage(sc);
   case tc=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c  from case where id=:newCase.id];
   re.CaseNumber=tc.CaseNumber;
   re.EscalateJustification='Test';
   //re.EscalateValidations();
   
   tc.Escalation_Justification__c = 'Test Escalation';
   tc.Request_Escalation__c = True;
   //re.okSave();
   tc.status='In Progresss';
   tc.Case_Resolution_Details_Order_Support__c = '1234';
   update tc;
   system.debug('check tc status' +tc.Status);
   case tc1=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c,Unauthenticated_Case__c  from case where id=:newCase.id];
   system.debug('check tc1 status' +tc1.Status);
   ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(tc1);
   VfCntrl_RequestEscalationVFPage re1=new VfCntrl_RequestEscalationVFPage(sc1);
   re1.CaseNumber=tc.CaseNumber;
   re1.EscalateJustification='Test';
   re1.EscalateValidations();   
   
 }
 
 
 public static testMethod void orderSuport5() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);
  TriggerExecutionController.setSkipAllTriggers(True);

  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
  List < Account > accData = new List < Account > ();
  Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
  accData.add(testAccount);
  insert accData;

  Contact newCont = new Contact(FirstName = 'MyTestContact7653',
   LastName = 'MyTestContact76523',
   AccountId = testAccount.Id,
   Status__c = 'Marketing Suspect',
   Email = 'MyTestContactEmail_3@dell.com',
   Fax = '12344567',
   Last_Operation_Performed__c = 'testing');
  insert newCont;
  Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

  User partnerUserGC = new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
   Alias = 'MTU9',
   Email = 'MyTestUser9@dell.com',
   FirstName = 'MyTestUser9',
   LastName = 'MyTestUser9',
   ProfileId = p.Id,
   LanguageLocaleKey = 'zh_CN',
   LocaleSidKey = 'zh_CN',
   EmailEncodingKey = 'UTF-8',
   TimeZoneSidKey = 'America/Los_Angeles',
   Badge_Number__c = 'Test99826513',
   isActive = TRUE,
   ContactId = newCont.Id);
  // insert partnerUserGC;

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
  newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Order_Reference_Number_Type__c = 'Order Number';   
  newCase.Case_Category__c = 'Partner';
  newcase.Unauthenticated_Case__c =true;

 // system.runAs(partnerUserGC) {
   insert newCase;
   
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newCase);  
   VfCntrl_RequestEscalationVFPage re=new VfCntrl_RequestEscalationVFPage(sc);
   case tc=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c  from case where id=:newCase.id];
   re.CaseNumber=tc.CaseNumber;
   re.EscalateJustification='Test';
   //re.EscalateValidations();
   
   tc.Escalation_Justification__c = 'Test Escalation';
   tc.Request_Escalation__c = false;
   //re.okSave();
   tc.status='Completed';
   tc.Case_Resolution_Details_Order_Support__c = '1234';
   update tc;
   system.debug('check tc status' +tc.Status);
   case tc1=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c,Unauthenticated_Case__c  from case where id=:newCase.id];
   system.debug('check tc1 status' +tc1.Status);
   ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(tc1);
   VfCntrl_RequestEscalationVFPage re1=new VfCntrl_RequestEscalationVFPage(sc1);
   re1.CaseNumber=tc.CaseNumber;
    re1.EscalateJustification='Test';
   re1.EscalateValidations();   
   
 }
 
 public static testMethod void orderSuport6() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);
  TriggerExecutionController.setSkipAllTriggers(True);

  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
  List < Account > accData = new List < Account > ();
  Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
  accData.add(testAccount);
  insert accData;

  Contact newCont = new Contact(FirstName = 'MyTestContact7653',
   LastName = 'MyTestContact76523',
   AccountId = testAccount.Id,
   Status__c = 'Marketing Suspect',
   Email = 'MyTestContactEmail_3@dell.com',
   Fax = '12344567',
   Last_Operation_Performed__c = 'testing');
  insert newCont;
  Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

  User partnerUserGC = new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
   Alias = 'MTU9',
   Email = 'MyTestUser9@dell.com',
   FirstName = 'MyTestUser9',
   LastName = 'MyTestUser9',
   ProfileId = p.Id,
   LanguageLocaleKey = 'zh_CN',
   LocaleSidKey = 'zh_CN',
   EmailEncodingKey = 'UTF-8',
   TimeZoneSidKey = 'America/Los_Angeles',
   Badge_Number__c = 'Test99826513',
   isActive = TRUE,
   ContactId = newCont.Id);
  // insert partnerUserGC;

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
  newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Order_Reference_Number_Type__c = 'Order Number';   
  newCase.Case_Category__c = 'Partner';
  newcase.Unauthenticated_Case__c =true;

 // system.runAs(partnerUserGC) {
   insert newCase;
   
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newCase);  
   VfCntrl_RequestEscalationVFPage re=new VfCntrl_RequestEscalationVFPage(sc);
   case tc=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c  from case where id=:newCase.id];
   re.CaseNumber=tc.CaseNumber;
   re.EscalateJustification='Test';
   //re.EscalateValidations();
   
   tc.Escalation_Justification__c = 'Test Escalation';
   tc.Request_Escalation__c = true;
   //re.okSave();
   tc.status='Completed';
   tc.Case_Resolution_Details_Order_Support__c = '1234';
   update tc;
   system.debug('check tc status' +tc.Status);
   case tc1=[select id,casenumber,status,Case_Resolution_Details_Order_Support__c,Unauthenticated_Case__c  from case where id=:newCase.id];
   system.debug('check tc1 status' +tc1.Status);
   ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(tc1);
   VfCntrl_RequestEscalationVFPage re1=new VfCntrl_RequestEscalationVFPage(sc1);
   re1.CaseNumber=tc.CaseNumber;
    re1.EscalateJustification='Test';
   re1.EscalateValidations();   
   
 }
 
 public static user CMuser(){
  Profile p = [SELECT Id FROM Profile WHERE Name='GBL PRM Operations']; 
  User u = new User(Alias = 'standt', Email='standarduser@dell.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_NarehBijjam@dell.com',Badge_Number__c='TD5kmtuerrty1');
            insert u;
 
 return u;
 }
 
 /*public static testMethod void orderSuportTest() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);
  TriggerExecutionController.setSkipAllTriggers(True);
  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
  List < Account > accData = new List < Account > ();
  Account testAccount = new Account(Name = 'testOppDistiUser Test Account',
   RecordTypeId = accRTyId,
   Partner_Type__c = 'COMMERCIAL',
   Partner_Tier__c = 'Tier',
   Partner_Relationship__c = 'Registered',
   Account_Country__c = 'United States');
  accData.add(testAccount);
  insert accData;

  Contact newCont = new Contact(FirstName = 'MyTestContact7653',
   LastName = 'MyTestContact76523',
   AccountId = testAccount.Id,
   Status__c = 'Marketing Suspect',
   Email = 'MyTestContactEmail_3@dell.com',
   Fax = '12344567',
   Last_Operation_Performed__c = 'testing');
  insert newCont;
  Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' AND Name like '%PRM%' LIMIT 1];

  User partnerUserGC = new User(Username = 'MyTestUser9' + System.currentTimeMillis() + '@dell.com',
   Alias = 'MTU9',
   Email = 'MyTestUser9@dell.com',
   FirstName = 'MyTestUser9',
   LastName = 'MyTestUser9',
   ProfileId = p.Id,
   LanguageLocaleKey = 'zh_CN',
   LocaleSidKey = 'zh_CN',
   EmailEncodingKey = 'UTF-8',
   TimeZoneSidKey = 'America/Los_Angeles',
   Badge_Number__c = 'Test99826513',
   isActive = TRUE,
   ContactId = newCont.Id);
   // insert partnerUserGC;

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
      newCase.Description = '1';
      newCase.Subject = '2';
      newCase.Origin = 'Partner Portal';
      newCase.Case_Category__c = 'Partner';
      newCase.Order_Reference_Number_Type__c = 'Order Number';
   insert newCase;
     
   case caseObjct = [select id,Status from case where id =: newCase.Id ];
     caseObjct.Status = 'Closed (Resolved)';
     caseObjct.Case_Resolution_Details_Order_Support__c = '1234';
    Update caseObjct; 
     system.debug('***1***' +caseObjct.Request_Escalation__c);
     system.debug('***2***' +caseObjct.Status);
   PageReference pageRef = Page.RequestEscalationVFPage;
   Test.setCurrentPage(pageRef);
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(caseObjct);
   ApexPages.currentPage().getParameters().put('Id', caseObjct.id);
   VfCntrl_RequestEscalationVFPage reqEscPage = new VfCntrl_RequestEscalationVFPage(sc);
   caseObjct.Escalation_Justification__c = 'Test Escalation';
   caseObjct.Request_Escalation__c = True; 
   caseObjct.Status = 'In Progress';
   //reqEscPage.okSave(); 
     system.debug('***3***' +caseObjct.Status);
     system.debug('***4***' +caseObjct.Request_Escalation__c);
     
     
     
     caseObjct.Status = 'Closed (Resolved)';
     caseObjct.Re_Open_Status_Flag__c = true;
     caseObjct.Case_Resolution_Details_Order_Support__c = '9999';
     reqEscPage.requestEscalationCheck = false;
     reqEscPage.accountTeamMemberAccess = false;
     reqEscPage.statusCompltedReqEscaIsTrue = false;
     reqEscPage.statusCompltedReqEscaIsFalse = false;
     caseObjct.Request_Escalation__c = false; 
     Update caseObjct;      
   pageRef = Page.RequestEscalationVFPage;
   Test.setCurrentPage(pageRef);
    ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(caseObjct);
   ApexPages.currentPage().getParameters().put('Id', caseObjct.id);
   VfCntrl_RequestEscalationVFPage reqEscPage1 = new VfCntrl_RequestEscalationVFPage (sc1);
   caseObjct.Escalation_Justification__c = 'Test Escalation';
   caseObjct.Request_Escalation__c = True; 
   caseObjct.Status = 'In Progress';
   reqEscPage.okSave();     
     
 }*/
}