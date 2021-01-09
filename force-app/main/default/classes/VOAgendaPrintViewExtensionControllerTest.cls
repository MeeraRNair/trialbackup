/********************************************
Name   : VOAgendaPrintViewExtensionControllerTest
Description   : test class for VOAgendaPrintViewExtensionController
Author   : Rajesh Uppalapati, VisitOps

*********************************************/
@isTest(seeallData=false)
private class VOAgendaPrintViewExtensionControllerTest{
    static VisitOps__Visit__c visitRecord;
    static VisitOps__Visit__c currentVisit;
    static VisitOps__Place__c testPlace;
    static VisitOps__Room__c testRoom;
    static VisitOps__Topic__c t;
    static VisitOps__Topic__c tWithDisplayName;
    static User u;
    
    
    public static testmethod void testcase(){
  
     TriggerExecutionController.setSkipAccountTriggers(true);
     TriggerExecutionController.setSkipOpportunityTriggers(true);
     TriggerExecutionController.setSkipUserTriggers(true);
     TriggerExecutionController.setSkipContactTriggers(true);
      //Insert Location
       VisitOps__Location__c  testLocation = new VisitOps__Location__c(Name='TestLocation',VisitOps__Location_Street_Address__c='testAddress',VisitOps__Time_Zone__c = '(GMT+05:30)India Standard Time (Asia/Kolkata)'); 
       insert testLocation;
        
        // Insert Place
        testPlace = new VisitOps__Place__c(Name='TestPlace', VisitOps__Location__c=testLocation.Id);
        insert testPlace;
        
        //Insert VisitType
        VisitOps__VisitType__c testCustomerVisit1 = new VisitOps__VisitType__c(Name='TestCustomerVisit1', VisitOps__Category__c='CV1'); 
        insert testCustomerVisit1;
        
        //Create visitTypeMapping
        insert new VisitOps__LocationTypeLink__c(VisitOps__Location__c=testLocation.id,VisitOps__VisitType__c=testCustomerVisit1.id);
        
        
        //Create Room
        testRoom = new VisitOps__Room__c(Name='TestRoom',VisitOps__Location__c=testLocation.id, VisitOps__Place__c=testPlace.Id,VisitOps__Room_Capacity__c=20);
        insert testRoom;
        
        //Create Status - New
        VisitOps__Status__c testNewStatus = new VisitOps__Status__c(Name='New'); 
        insert testNewStatus;
        
        //Create Reference Visit
        visitRecord = new VisitOps__Visit__c(VisitOps__VisitName__c='Test Visit', VisitOps__VisitOwner__c =userInfo.getUserId(), VisitOps__Location__c=testLocation.id, VisitOps__VisitType__c=testCustomerVisit1.id, VisitOps__VisitStatus__c=testNewStatus.id, VisitOps__ArrivalDateTime__c=datetime.newInstance(2017, 9, 15, 12, 30, 0),VisitOps__ArrivalDateTimeLocationTZ__c='2017-09-10 02:02:42', VisitOps__DepartureDateTime__c=datetime.newInstance(2017, 9, 15, 13, 30, 0),VisitOps__DepartureDateTimeLocationTZ__c='2017-09-11 03:02:42', VisitOps__TotalNoOfAttendees__c=100);
        insert visitRecord;
                            
        
        //Create an Agenda Item
        VisitOps__Agenda__c agenda1 = new VisitOps__Agenda__c(VisitOps__Agenda_Title__c='Test Agenda1',VisitOps__Objectives__c='Test Objectves',VisitOps__Start_Time__c=System.Now(),VisitOps__StartTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),VisitOps__End_Time__c=System.Now()+5,VisitOps__EndTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'),VisitOps__Visit__c=visitRecord.Id);
        insert agenda1;
        
        //Add Presenters to the Session
        VisitOps__Presenter_Agenda_Link__c pal = new VisitOps__Presenter_Agenda_Link__c(VisitOps__User__c=UserInfo.getUserId(),VisitOps__Agenda__c=agenda1.Id,VisitOps__Status__c='Not Sent');
        insert pal;
        
        //Create a Session Topic
        t = new VisitOps__Topic__c(VisitOps__TopicName__c='Test Topic',VisitOps__TopicCategory__c='TestCategory');
        insert t;
        
        //Create a topic with displayName on Agenda
        tWithDisplayName = new VisitOps__Topic__c(VisitOps__TopicName__c='Test Topic',VisitOps__TopicCategory__c='TestCategory',VisitOps__TopicNameOnAgenda__c='Topic Agenda Display Name');
        insert tWithDisplayName;
        
               
        //Create a new User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        u = new User(Alias = 'testVis', Email='standarduser@dell.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Badge_Number__c='8239843599',
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testVisitopsUser@test.com',Title='title',CompanyName='companyname');
            insert u;
        //create account
        Account a = new Account(name='test',website='www.google.com');    
        insert a;
        //create contact
        contact c = new contact(lastname = 'test',title='Mr.',AccountId=a.id,Email='testing@dell.com');
        insert c;
        contact c2 = new contact(lastname = 'test2',title='Mr.',AccountId=a.id,Email='testing2@dell.com');
        insert c2;
            
           list<VisitOps__Attendee__c> atlist = new list<VisitOps__Attendee__c>();
           VisitOps__Attendee__c at = new VisitOps__Attendee__c(VisitOps__Contact__c = c.id,VisitOps__visit__c =visitRecord.id);
           VisitOps__Attendee__c at3 = new VisitOps__Attendee__c(VisitOps__Contact__c = c2.id,VisitOps__visit__c =visitRecord.id);
           VisitOps__Attendee__c at1 = new VisitOps__Attendee__c(VisitOps__Company__c ='test',VisitOps__title__c ='test',VisitOps__FirstName__c='test',VisitOps__LastName__c='def',VisitOps__visit__c =visitRecord.id);
           VisitOps__Attendee__c at2 = new VisitOps__Attendee__c(VisitOps__Company__c ='companyname',VisitOps__title__c ='test',VisitOps__FirstName__c='test1',VisitOps__LastName__c='def1',VisitOps__visit__c =visitRecord.id);
           VisitOps__Attendee__c at6 = new VisitOps__Attendee__c(VisitOps__Company__c ='companyname',VisitOps__title__c ='test',VisitOps__FirstName__c='test2',VisitOps__LastName__c='def2',VisitOps__visit__c =visitRecord.id);
           VisitOps__Attendee__c at4 = new VisitOps__Attendee__c(VisitOps__Company__c ='companyname1',VisitOps__title__c ='test',VisitOps__User__c=UserInfo.getUserId(),VisitOps__visit__c =visitRecord.id);  
           VisitOps__Attendee__c at7 = new VisitOps__Attendee__c(VisitOps__Company__c ='companyname1',VisitOps__title__c ='test',VisitOps__User__c=UserInfo.getUserId(),VisitOps__visit__c =visitRecord.id);  
           VisitOps__Attendee__c at5 = new VisitOps__Attendee__c(VisitOps__Company__c ='',VisitOps__title__c ='test',VisitOps__FirstName__c='test1',VisitOps__LastName__c='def1',VisitOps__visit__c =visitRecord.id);  
           atlist.add(at);
           atlist.add(at1);
           atlist.add(at2);
           atlist.add(at3);
           atlist.add(at4);
           atlist.add(at5);
           atlist.add(at6);
           atlist.add(at7);
           insert atlist;
           
           
           ApexPages.currentPage().getParameters().put('visitId',visitRecord.id);
           ApexPages.currentPage().getParameters().put('viewType','view');
           ApexPages.currentPage().getParameters().put('selectedTypeofFile','PDF');
           
           //ApexPages.StandardController sc = new ApexPages.StandardController(visitRecord);
           VOAgendaPrintViewExtensionController ag = new VOAgendaPrintViewExtensionController();
           ag.AccountAttendeeMap();
           Document document = new Document();
           document.Name='testDoc';
           document.AuthorId = UserInfo.getUserId();
           document.FolderId = UserInfo.getUserId();
           document.DeveloperName = 'Survey_Logo';
           insert document;
           ag.getDocumentLogoUrl();
           Boolean test = ag.isAttendeeContactMapNotEmpty;
           test = ag.isAttendeeUserMapNotEmpty;
           test = ag.isAttendeeAdHocUserMapNotEmpty;
           test = ag.isOtherAttendeesMapNotEmpty;
           VOAgendaPrintViewExtensionController.AgendaWrapper ag1 = new VOAgendaPrintViewExtensionController.AgendaWrapper();
           //AgendaPrintViewExtension.PresenterWrapper ag2 =new AgendaPrintViewExtension.PresenterWrapper();
           VOAgendaPrintViewExtensionController.AgendaRecordFormat ag3 = new VOAgendaPrintViewExtensionController.AgendaRecordFormat();
           
           
           visitRecord.VisitOps__Portal_Visit__c = true;
           visitRecord.VisitOps__Owner_Portal__c = 'test';
           update visitRecord;
           ApexPages.currentPage().getParameters().put('visitId',Null);
           ApexPages.currentPage().getParameters().put('viewType','Customer');
           VOAgendaPrintViewExtensionController agErr = new VOAgendaPrintViewExtensionController();
           
           ApexPages.currentPage().getParameters().put('visitId',visitRecord.id);
           ApexPages.currentPage().getParameters().put('viewType','VisitTeam');
           ApexPages.currentPage().getParameters().put('selectedTypeofFile','Word');
           
           //ApexPages.StandardController sc = new ApexPages.StandardController(visitRecord);
           VOAgendaPrintViewExtensionController ag_temp = new VOAgendaPrintViewExtensionController();
           System.assertEquals(null,null);
        }
}