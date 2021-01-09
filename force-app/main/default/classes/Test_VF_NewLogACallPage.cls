@isTest(SeeAllData = false)
private class Test_VF_NewLogACallPage{
 
  public static  testmethod void testMethod1(){
    
    Account acc = new Account();
    acc.Name = 'testAccount';
    insert acc;
    
    Contact con = new Contact();
    con.LastName  = 'conLastName';
    con.Email = 'test@test.com';
    con.AccountId = acc.Id;
    insert con;
    
    Campaign camp = new Campaign();
    camp.Name = 'testCamp';
    camp.IsActive = true;
    insert camp;
    
    Lead lead = new Lead();
    lead.lastName = 'testLeadLastName';
    lead.Company = 'testCompany';
    lead.Phone = '1234567891';
    insert lead;
    
    CampaignMember cm = new CampaignMember();
    cm.LeadId = lead.Id;
    cm.CampaignId = camp.Id;
    insert cm;
    /* Uncomment once error resolves
    Profile p = [select id from profile where name='System Administrator'];
    User sysAdmin = new User();
    sysAdmin.Alias = 'testAl';
    sysAdmin.CommunityNickname = 'testCommName';
    sysAdmin.Email = 'test@dell.com';
    sysAdmin.LastName = 'testLastName';
    sysAdmin.UserName = 'testLogACall@test.com';
    sysAdmin.TimeZoneSidKey = 'GMT';
    sysAdmin.LocaleSidKey = 'en_US';
    sysAdmin.EmailEncodingKey = 'UTF-8';
    sysAdmin.ProfileId = p.Id;
    sysAdmin.Enable_Partner_Lead_Management__c = false;
    sysAdmin.LanguageLocaleKey = 'en_US';
    sysAdmin.isActive = true;
    insert sysAdmin;
    */
    
    User sysadmin = [Select Id,Name from User Where Profile.Name ='System Administrator' LIMIT 1]; // Comment once error resolves
    
    List<Event> callEventList = new List<Event>();
    Id callEventRecordType =  [SELECT Id FROM RecordType WHERE SobjectType = 'Event' AND Name LIKE '%Call Plan%' LIMIT 1].Id;
    
    Event callEvent1  = new Event(); 
    callEvent1.OwnerId = sysAdmin.Id;
    callEvent1.Subject = 'testSubject';
    callEvent1.Type = 'testType';
    callEvent1.WhatId = acc.Id;
    callEvent1.WhoId = con.Id;
    callEvent1.StartDateTime = System.Now();
    callEvent1.EndDateTime = System.Now();
    callEvent1.End_in_Mind__c = 'testEnd';
    callEvent1.Description ='testDescription';
    callEvent1.RecordTypeId = callEventRecordType; 
    callEventList.add(callEvent1);
    
    Event callEvent2  = new Event(); 
    callEvent2.OwnerId = sysAdmin.Id;
    callEvent2.Subject = 'testSubject';
    callEvent2.Type = 'testType';
    //callEvent2.WhatId = acc.Id;
    callEvent2.WhoId = lead.Id;
    callEvent2.StartDateTime = System.Now();
    callEvent2.EndDateTime = System.Now();
    callEvent2.End_in_Mind__c = 'testEnd';
    callEvent2.Description ='testDescription';
    callEvent2.RecordTypeId = callEventRecordType; 
    callEventList.add(callEvent2);
   
    insert callEventList;
    
    
    PageReference pageRef1 =Page.NewLogACallPage;
    Test.setCurrentPage(pageRef1);
    ApexPages.currentPage().getParameters().put('EventId',callEventList[0].Id);
    VF_NewLogACallPage controller1 = new VF_NewLogACallPage();
    controller1.sendNotificationEmail1 = true;
    controller1.sendNotificationEmail2 = true;
    controller1.cancel();
    controller1.save();
      
   
    PageReference pageRef2 =Page.NewLogACallPage;
    Test.setCurrentPage(pageRef2);
    ApexPages.currentPage().getParameters().put('EventId',callEventList[1].Id);
    VF_NewLogACallPage controller2 = new VF_NewLogACallPage();
    controller2.sendNotificationEmail1 = false;
    controller2.sendNotificationEmail2 = false;
    controller2.cancel();
    controller2.save();
    
    controller2.callRecord2.Subject = 'testSubject';
    controller2.save();
    controller2.callRecord2.ActivityDate = System.Today();
    controller2.callRecord2.Type = 'testType';
    controller2.save();
   
    
    List<Event> exportedEvent  = [Select Id from Event];
    system.assertEquals(2,exportedEvent.size());
    
  }
}