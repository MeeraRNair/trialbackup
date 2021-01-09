/************************************************************
 * 
 * Name          : VfCntrl_RequestEscalationTest
 * Description   : Test class to "VfCntrl_RequestEscalation" 
 * ----------------------------------------------------------
 * Revision  Name            Date                 CR                                         
 * 1.0       Srikanth      06.08.2017            14488                          
 ************************************************************/

@isTest
public class VfCntrl_RequestEscalationTest {

 public static testMethod void orderSuport() {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);

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

 // system.runAs(partnerUserGC) {
   insert newCase;

   PageReference pageRef = Page.RequestEscalationForCase;
   Test.setCurrentPage(pageRef);
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(newCase);
   ApexPages.currentPage().getParameters().put('Id', newCase.id);
   
   VfCntrl_RequestEscalation reqEscPage = new VfCntrl_RequestEscalation(sc);
   newCase.Escalation_Justification__c = 'Test Escalation';
   newCase.Request_Escalation__c = True;
   reqEscPage.okSave();
   

//Code coverage  Info Message 
   ApexPages.Standardcontroller scp = new ApexPages.Standardcontroller(newCase);
   ApexPages.currentPage().getParameters().put('Id', newCase.id);
   VfCntrl_RequestEscalation reqEscPage1 = new VfCntrl_RequestEscalation(scp);    
   
 // }
 }
 
 public static testMethod void orderSuportTest() {
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
   PageReference pageRef = Page.RequestEscalationForCase;
   Test.setCurrentPage(pageRef);
   ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(caseObjct);
   ApexPages.currentPage().getParameters().put('Id', caseObjct.id);
   VfCntrl_RequestEscalation reqEscPage = new VfCntrl_RequestEscalation(sc);
   caseObjct.Escalation_Justification__c = 'Test Escalation';
   caseObjct.Request_Escalation__c = True; 
   caseObjct.Status = 'In Progress';
   reqEscPage.okSave(); 
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
   pageRef = Page.RequestEscalationForCase;
   Test.setCurrentPage(pageRef);
    ApexPages.Standardcontroller sc1 = new ApexPages.Standardcontroller(caseObjct);
   ApexPages.currentPage().getParameters().put('Id', caseObjct.id);
   VfCntrl_RequestEscalation reqEscPage1 = new VfCntrl_RequestEscalation(sc1);
   caseObjct.Escalation_Justification__c = 'Test Escalation';
   caseObjct.Request_Escalation__c = True; 
   caseObjct.Status = 'In Progress';
   reqEscPage.okSave();     
     
 }
}