@isTest
public class Batch_ChatterPostOnRequestEscalationTest {
public static testMethod void chatterPost1(){
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipcaseTriggers(True);
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
  
  /*Group qGroup=new Group(Name='Cases - Order Support Global Group',Type='QUEUE');
        insert qGroup;
  Group gp=new Group(Name='Cases - Order Support Global Group test',Type='QUEUE');
        insert gp;      
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
          QueuesObject q= new QueuesObject (SobjectType='Case',QueueId=qGroup.id); 
          insert q;
          groupmember g=new groupmember();
          g.UserOrGroupId=qGroup.id;
          g.GroupId=gp.id;
          insert g;
          
        }*/
    Case_Chatter_Notification_Queues__c CC = new Case_Chatter_Notification_Queues__c();
    CC.Queue_Name__c= 'Cases - On Boarding Global';
    CC.Name= 'Cases - On Boarding Global';
    insert CC;
    
  Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
  case newCase = new Case();
  newCase.AccountId = testAccount.Id;
  newCase.ContactId = newCont.id;
  newCase.Status = 'Open';
  newCase.Priority = 'High';
  newCase.Sub_Type_Order_Support__c = 'Box Recycling';
  newCase.RecordTypeId = orderSuppRTId;
  newCase.Post_to_Chatter__c= False;
  newCase.Request_Escalation__c = true;
  newCase.Order_Number1__c = '123432';
  newCase.Alternate_Phone__c = '745476';
  newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Case_Category__c = 'Partner';
  //newCase.ownerid=CaseOwnerid();
 insert newCase;
 
 Id dealRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'deal registration');
  case newCase1 = new Case();
  newCase1.AccountId = testAccount.Id;
  newCase1.ContactId = newCont.id;
  newCase1.Status = 'Open';
  newCase1.Priority = 'High';
  newCase1.Sub_Type_Order_Support__c = 'Technical Queries'; //'Deal Status & Dates';
  newCase1.Case_Reason_Order_Support__c='Other';
  newCase1.RecordTypeId = dealRegRTId;
  newCase1.Post_to_Chatter__c= False;
  newCase1.Request_Escalation__c = true;
  
  newCase1.Description = '2';
  newCase1.Subject = '3';
  newCase1.Origin = 'Partner Portal';
  newCase1.Case_Category__c = 'Partner';
  //newCase1.ownerid=CaseOwnerid();
 insert newCase1;
 
 case newCase2 = new Case();
  newCase2.AccountId = testAccount.Id;
  newCase2.ContactId = newCont.id;
  newCase2.Status = 'Open';
  newCase2.Priority = 'High';
  newCase2.Sub_Type_Order_Support__c = 'Technical Queries'; //'Deal Status & Dates';
  newCase1.Case_Reason_Order_Support__c='Other';
  newCase2.RecordTypeId = dealRegRTId;
  newCase2.Post_to_Chatter__c= False;
  newCase2.Request_Escalation__c = true;
  
  newCase2.Description = '2';
  newCase2.Subject = '3';
  newCase2.Origin = 'Partner Portal';
  newCase2.Case_Category__c = 'Partner';
  newCase2.ownerid=CaseOwnerid();
 insert newCase2;
  
  Id OBRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');
  case newCase3 = new Case();
  newCase3.AccountId = testAccount.Id;
  newCase3.ContactId = newCont.id;
  newCase3.Status = 'Open';
  newCase3.Priority = 'High';
  newCase3.Sub_Type_Order_Support__c = 'Tool issue';
  newCase3.Case_Reason_Order_Support__c= 'New user Access';
  newCase3.RecordTypeId = OBRegRTId;
  newCase3.Post_to_Chatter__c= False;
  newCase3.Request_Escalation__c = true;
  
  newCase3.Description = '2';
  newCase3.Subject = '3';
  newCase3.Origin = 'Partner Portal';
  newCase3.Case_Category__c = 'Partner';
  //newCase1.ownerid=CaseOwnerid();
 insert newCase3;
    
 Id OBIRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding Internal');
  case newCase4 = new Case();
  newCase4.AccountId = testAccount.Id;
  newCase4.ContactId = newCont.id;
  newCase4.Status = 'Open';
  newCase4.Priority = 'High';
  newCase4.Sub_Type_Order_Support__c = 'Partner grouping';
  newCase4.RecordTypeId = OBIRegRTId;
  newCase4.Post_to_Chatter__c= False;
  newCase4.Request_Escalation__c = true;
  
  newCase4.Description = '2';
  newCase4.Subject = '3';
  newCase4.Origin = 'Partner Portal';
  newCase4.Case_Category__c = 'Partner';
  //newCase1.ownerid=CaseOwnerid();
 insert newCase4;

 Test.startTest();    
  Batch_ChatterPost_Scheduler dr = new Batch_ChatterPost_Scheduler();
  String sch = '0 0 22 ? * SAT';
  System.schedule('Test',sch,dr);
 Test.stopTest();
}
public static testMethod void chatterPost2(){
  TriggerExecutionController.setSkipAccountTriggers(True);
  TriggerExecutionController.setSkipContactTriggers(True);
  TriggerExecutionController.setSkipcaseTriggers(True);
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
  
  /*Group qGroup=new Group(Name='Cases - Order Support Global Group',Type='QUEUE');
        insert qGroup;
  Group gp=new Group(Name='Cases - Order Support Global Group test',Type='QUEUE');
        insert gp;      
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
          QueuesObject q= new QueuesObject (SobjectType='Case',QueueId=qGroup.id); 
          insert q;
          groupmember g=new groupmember();
          g.UserOrGroupId=qGroup.id;
          g.GroupId=gp.id;
          insert g;
          
        }*/
    
  Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
  case newCase = new Case();
  newCase.AccountId = testAccount.Id;
  newCase.ContactId = newCont.id;
  newCase.Status = 'Open';
  newCase.Priority = 'High';
  newCase.Sub_Type_Order_Support__c = 'Box Recycling';
  newCase.RecordTypeId = orderSuppRTId;
  newCase.Post_to_Chatter__c= False;
  newCase.Request_Escalation__c = true;
  newCase.Order_Number1__c = '123432';
  newCase.Alternate_Phone__c = '745476';
  newCase.Description = '1';
  newCase.Subject = '2';
  newCase.Origin = 'Partner Portal';
  newCase.Case_Category__c = 'Partner';
  newCase.ownerid=CaseOwnerid();
 insert newCase;
 
 Id dealRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'deal registration');
  case newCase1 = new Case();
  newCase1.AccountId = testAccount.Id;
  newCase1.ContactId = newCont.id;
  newCase1.Status = 'Open';
  newCase1.Priority = 'High';
  newCase1.Sub_Type_Order_Support__c = 'Technical Queries';//'Deal Status & Dates';
  newCase1.Case_Reason_Order_Support__c='Other';
  newCase1.RecordTypeId = dealRegRTId;
  newCase1.Post_to_Chatter__c= False;
  newCase1.Request_Escalation__c = true;
  
  newCase1.Description = '2';
  newCase1.Subject = '3';
  newCase1.Origin = 'Partner Portal';
  newCase1.Case_Category__c = 'Partner';
  newCase1.ownerid=CaseOwnerid();
 insert newCase1;
 
 /*case newCase2 = new Case();
  newCase2.AccountId = testAccount.Id;
  newCase2.ContactId = newCont.id;
  newCase2.Status = 'Open';
  newCase2.Priority = 'High';
  newCase2.Sub_Type_Order_Support__c = 'Deal Status & Dates';
  //newCase2.RecordTypeId = dealRegRTId;
  newCase2.Post_to_Chatter__c= False;
  newCase2.Request_Escalation__c = true;
  
  newCase2.Description = '2';
  newCase2.Subject = '3';
  newCase2.Origin = 'Partner Portal';
  newCase2.Case_Category__c = 'Partner';
  newCase2.ownerid=CaseOwnerid();
 insert newCase2;*/

 Test.startTest();    
  Batch_ChatterPost_Scheduler dr = new Batch_ChatterPost_Scheduler();
  String sch = '0 0 22 ? * SAT';
  System.schedule('Test',sch,dr);
 Test.stopTest();
}
public static string CaseOwnerid(){
string groupid='';
list<group> grlist=[select Id,name from Group where developername= 'Cases_Partner_Support_APJ' and Type = 'Queue'];
if(!grlist.IsEmpty()){
groupid=grlist[0].id;
}
return groupid;
/*Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@dell.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser_Bijjam12@dell.com',Badge_Number__c='TD5kmtuerrty23e');
            insert u;
            
            return u;*/
}
}