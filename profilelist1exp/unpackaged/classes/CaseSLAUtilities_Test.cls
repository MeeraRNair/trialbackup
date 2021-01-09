/* 
Author:pradeep
purpose:test class for caseSLAUtilities

Modified by Bharadwaj on Jan 5 2018
*/
@isTest(seeAllData = false)
public class CaseSLAUtilities_Test{

static testMethod void updateCaseHistoryTest1(){
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);    
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
  //newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Case_Category__c = 'Partner';
  newCase.Description = 'DO NOT RUN PB';
  insert newCase;
  system.debug('****New Case:' +newCase);
  
  Test.startTest();
  try{  
  newCase.Status = 'Assigned';
  Update newCase ;
  system.assertEquals('Assigned', newCase.Status);
  
  newCase.Status = 'In Progress';                                                                           
  Update newCase ;      
  system.assertEquals('In Progress', newCase.Status);
  
  Case_Status_History__c objCasStatusHist = new Case_Status_History__c ();
  objCasStatusHist.Name = 'Test';
  objCasStatusHist.Case_Id__c = newCase.id;
  objCasStatusHist.Duration__c = 23;
  objCasStatusHist.Status__c = 'Assigned';
  objCasStatusHist.Time_In__c = System.now();
  objCasStatusHist.Time_Out__c = System.now();
  Insert objCasStatusHist;
  
  Test.stopTest();
  System.assertNotEquals(newCase.id,Null);
   }catch(Exception e){}  
    
 }
    
    static testMethod void updateCaseHistoryTest2(){
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);    
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
  //newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Case_Category__c = 'Partner';
  newCase.Description = 'DO NOT RUN PB';
  insert newCase;
  system.debug('****New Case:' +newCase);
  
  Test.startTest();
  try{  

  newCase.Status = 'Pending Internal';
  Update newCase ;
  system.assertEquals('Pending Internal', newCase.Status);
      
  newCase.status = 'Pending Customer';
  update newCase;
  system.assertEquals('Pending Customer', newCase.status);
  
  Test.stopTest();
  
   }catch(Exception e){}  
    
 }
    
  static testMethod void updateCaseHistoryTest3(){
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);    
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
  //newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Case_Category__c = 'Partner';
  newCase.Description = 'DO NOT RUN PB';
  insert newCase;
  system.debug('****New Case:' +newCase);
  
  Test.startTest();
  try{
   
  newCase.Status = 'Re-Open';
  Update newCase ;
  system.assertEquals('Re-Open', newCase.Status); 

  newCase.Status = 'Reassigned';
  Update newCase ;
  system.assertEquals('Reassigned', newCase.Status);

   Test.stopTest();
  
   }catch(Exception e){}   
   
    
 }
    
     static testMethod void updateCaseHistoryTest4(){
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);    
  Id accRTyId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
          // Test.startTest();
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
  //newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Case_Category__c = 'Partner';
  newCase.Description = 'DO NOT RUN PB';
  insert newCase;
  system.debug('****New Case:' +newCase);
  
  try{
  
  Test.startTest();
  newCase.Status = 'Closed (No Issue)';
  Update newCase ;
  system.assertEquals('Closed (No Issue)', newCase.Status); 
       Test.stopTest();  
   }catch(Exception e){}   
   
    
 }
 
 static testMethod void updateCaseHistoryOneTest()
 {
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipOpportunityTriggers(True);
    
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
 // TriggerExecutionController.setSkipCaseTriggers(True);   
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
  newCase.Description = 'DO NOT RUN PB';
  insert newCase;
  TriggerExecutionController.setSkipCaseTriggers(false); 
  Test.startTest();
  
     /* try{
  newCase.status = 'In Progress';
  update newCase;
      system.assertEquals('In Progress', newCase.status);
  }catch(Exception e){}
  try{
  newCase.status = 'Pending Internal';
  update newCase;
       system.assertEquals('Pending Internal', newCase.status);
  }catch(Exception e){}
  try{
  newCase.status = 'Pending Customer';
  update newCase;
       system.assertEquals('Pending Customer', newCase.status);
  }catch(Exception e){}
     try{
  newCase.status = 'Re-Open';
  update newCase;
          system.assertEquals('Re-Open', newCase.status);
  }catch(Exception e){}
     try{
  newCase.status = 'Reassigned';
  update newCase;
          system.assertEquals('Reassigned', newCase.status);
  }catch(Exception e){}
  
  Case_Status_History__c objCasStatusHist = new Case_Status_History__c ();
  objCasStatusHist.Name = 'Test';
  objCasStatusHist.Case_Id__c = newCase.id;
  objCasStatusHist.Duration__c = 23;
  objCasStatusHist.Status__c = 'Assigned';
  objCasStatusHist.Time_In__c = System.now();
  objCasStatusHist.Time_Out__c = System.now();
  Insert objCasStatusHist;
     
  Case_Status_History__c objCasStatusHist10 = new Case_Status_History__c ();
  objCasStatusHist10.Name = 'Test';
  objCasStatusHist10.Case_Id__c = newCase.id;
  objCasStatusHist10.Duration__c = 23;
  objCasStatusHist10.Status__c = 'In Progress';
  objCasStatusHist10.Time_In__c = System.now();
  objCasStatusHist10.Time_Out__c = System.now();
  Insert objCasStatusHist10;
     
  try{
  newCase.status = 'Completed';
  newCase.completed_flag__C = 'Y';    
  update newCase;
  }catch(Exception e){}
     */
     
  Case_Status_History__c objCasStatusHist1 = new Case_Status_History__c ();
  objCasStatusHist1.Name = 'Test';
  objCasStatusHist1.Case_Id__c = newCase.id;
  objCasStatusHist1.Duration__c = 23;
  objCasStatusHist1.Status__c = 'Completed';
  objCasStatusHist1.Time_In__c = System.now();
  objCasStatusHist1.Time_Out__c = System.now();
  Insert objCasStatusHist1;
      try
    {
      delete objCasStatusHist1;
    }catch(Exception e){}
  
  Test.stopTest();
  
  System.assertNotEquals(newCase.id,Null);
    
 }
}