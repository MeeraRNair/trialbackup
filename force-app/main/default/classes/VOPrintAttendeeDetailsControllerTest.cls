@isTest(seeAllData=false)
private class VOPrintAttendeeDetailsControllerTest {
    
    static VisitOps__Location__c testLocation;
    static VisitOps__VisitType__c testCustomerVisit1;
    static VisitOps__Visit__c currentVisit;
    static VisitOps__Room__c testRoom;
    static VisitOps__Status__c testNewStatus;
    static VisitOps__Attendee__c testUserAttendee;
    static VisitOps__Attendee__c testContactAttendee;
    static contact testContact;
    static VisitOps__Agenda__c agendaRecord1;
    static VisitOps__Place__c Place;
    static List<VisitOps__Attendee__c> attendeesList = new List<VisitOps__Attendee__c>();
    
    static void createTestData() {
        testLocation = new VisitOps__Location__c(Name='TestLocation',VisitOps__Location_Street_Address__c='testAddress', VisitOps__Time_Zone__c = '(GMT+00:00) Greenwich Mean Time (GMT)'); 
        insert testLocation;
        Place =new VisitOps__place__c(name='testPlace',VisitOps__location__c=testLocation.id);  
           insert place;
        testCustomerVisit1 = new VisitOps__VisitType__c(Name='TestCustomerVisit1', VisitOps__Category__c='CV1'); 
        insert testCustomerVisit1;
        
        insert new VisitOps__LocationTypeLink__c(VisitOps__Location__c=testLocation.id,VisitOps__VisitType__c=testCustomerVisit1.id, VisitOps__IsRoomMandatory__c = true);
        
        Id RoomRecordTypeId = [select id from RecordType where sobjectType = 'VisitOps__Room__c' and name = 'Room'].id; 
        
        testRoom = new VisitOps__Room__c(VisitOps__Place__c=Place.Id,Name='TestRoom',VisitOps__Location__c=testLocation.id,VisitOps__Room_Capacity__c=200, recordtypeId=RoomRecordTypeId);
        insert testRoom;
        
        testNewStatus = new VisitOps__Status__c(Name='New'); 
        insert testNewStatus;
        
        currentVisit = new VisitOps__Visit__c(VisitOps__VisitName__c='testVisit', VisitOps__VisitOwner__c =userInfo.getUserId(), VisitOps__Location__c=testLocation.id, VisitOps__VisitType__c=testCustomerVisit1.id, VisitOps__VisitStatus__c=testNewStatus.id, VisitOps__VisitStatus__r=testNewStatus, VisitOps__ArrivalDateTime__c=system.now(), VisitOps__DepartureDateTime__c=system.now()+5, VisitOps__TotalNoOfAttendees__c=100, VisitOps__Room__c=testRoom.id,
                                        VisitOps__ArrivalDateTimeLocationTZ__c='11/26/2015 9:00 AM',VisitOps__DepartureDateTimeLocationTZ__c='11/26/2015 9:00 PM');
        insert currentVisit;
        
        testUserAttendee = new VisitOps__Attendee__c(VisitOps__Company__c='eretrw',VisitOps__visit__c = currentVisit.id,VisitOps__User__c = userInfo.getUserId(),VisitOps__FirstName__c='abc',VisitOps__LastName__c='def',VisitOps__Post_Survey_Sent__c=true,VisitOps__PreSurveySent__c=true,VisitOps__Email__c='abcdef@sdf.com',VisitOps__Pre_Survey_Required__c=true,VisitOps__Post_Survey_Required__c=true,VisitOps__SendPreSurvey__c = true,VisitOps__SendPostSurvey__c=true);
        attendeesList.add(testUserAttendee);
        
        Account testAccount = new Account(Name='Test Account',Type = 'End User' );
            insert testAccount;
        Contact testContact = new Contact(FirstName='first', LastName='last', Phone='044223667788',
                                            Email='s@s.com',
                                            AccountId=testAccount.Id);

        testContactAttendee = new VisitOps__Attendee__c(VisitOps__Company__c='eretrw',VisitOps__visit__c = currentVisit.id,VisitOps__Contact__c = testContact.id,VisitOps__FirstName__c='abc',VisitOps__LastName__c='def',VisitOps__Post_Survey_Sent__c=true,VisitOps__PreSurveySent__c=true,VisitOps__Email__c='abcdef@sdf.com',VisitOps__Pre_Survey_Required__c=true,VisitOps__Post_Survey_Required__c=true,VisitOps__SendPreSurvey__c = true,VisitOps__SendPostSurvey__c=true);
        attendeesList.add(testContactAttendee);
        
        insert attendeesList;
        
        //Create Expertise Area
        VisitOps__Expertise_Area__c exp = new VisitOps__Expertise_Area__c(Name='Test Area');
        insert exp;
        
        
        //Create a Session Topic
        VisitOps__Topic__c t = new VisitOps__Topic__c(VisitOps__TopicName__c='Test Topic',VisitOps__TopicCategory__c='TestCategory',VisitOps__Expertise_Area__c=exp.Id);
        insert t;
        
        //Create a new Agenda Record
        agendaRecord1 = new VisitOps__Agenda__c();
        agendaRecord1.VisitOps__Start_Time__c = System.NOW();
        agendaRecord1.VisitOps__End_Time__c = System.NOW() + 60;
        agendaRecord1.VisitOps__StartTimeLocationTZ__c = '11/26/2015 9:00 AM';
        agendaRecord1.VisitOps__EndTimeLocationTZ__c = '11/26/2015 10:00 AM';
        agendaRecord1.VisitOps__Agenda_Title__c = 'Test Agenda Title';
        agendaRecord1.VisitOps__Visit__c = currentVisit.Id;
        agendaRecord1.VisitOps__Topic__c = t.Id;
        insert agendaRecord1;
        
        //insert new List<VisitOps__Presenter_Agenda_Link__c>{new VisitOps__Presenter_Agenda_Link__c(VisitOps__Agenda__c = agendaRecord1.id, VisitOps__User__c = userInfo.getUserId(), VisitOps__Status__c='Accepted'),
            //new VisitOps__Presenter_Agenda_Link__c(VisitOps__Agenda__c = agendaRecord1.id, VisitOps__Attendee__c = testContactAttendee.id, VisitOps__Status__c='Accepted'),
            //new VisitOps__Presenter_Agenda_Link__c(VisitOps__Agenda__c = agendaRecord1.id, VisitOps__Presenter__c = pres.id, VisitOps__Status__c='Accepted')};
    }
    
    
    public static void loadTest(){
        createTestData();
        system.debug('inserted visit id--'+currentVisit.id + '--agendaRecord1--'+agendaRecord1.id);
        Test.setCurrentPageReference(new PageReference('Page.PrintAttendeeDetails'));
        System.currentPageReference().getParameters().put('VisitId', currentVisit.id);
        //System.currentPageReference().getParameters().put('AttendeeId', testUserAttendee.id);
        //PrintAttendeeDetailsController pa = new PrintAttendeeDetailsController();
        
        //Test.setCurrentPageReference(new PageReference('Page.PrintAttendeeDetails'));
        //System.currentPageReference().getParameters().put('AttendeeId', testUserAttendee.id);
        //PrintAttendeeDetailsController pa1 = new PrintAttendeeDetailsController();
        
        
    }
    
    static testMethod void testPresenterPAL(){
        loadTest();
        Test.startTest();
        //Create a Presenter
        VisitOps__Presenter__c pres = new VisitOps__Presenter__c(VisitOps__User__c=userInfo.getUserId(),VisitOps__Base_Location__c=testLocation.Id);
        insert pres;
        insert new VisitOps__Presenter_Agenda_Link__c(VisitOps__Agenda__c = agendaRecord1.id, VisitOps__Presenter__c = pres.id, VisitOps__Status__c='Accepted');
        system.debug('testPresenterPAL--Presenter empty company case');
        VOPrintAttendeeDetailsController pa1 = new VOPrintAttendeeDetailsController();

        system.debug('testPresenterPAL--Presenter testCompany case');
        pa1 = new VOPrintAttendeeDetailsController();
        String str = pa1.getLeftCompanyLogoUrl();
        str = pa1.getRightCompanyLogoUrl();
        System.assertEquals(null,null);
        Test.stopTest();
        
    }
    
    static testMethod void testUserPAL(){
        loadTest();
        update new user(id=userinfo.getUserId(),CompanyName='testCompany');
        insert new VisitOps__Presenter_Agenda_Link__c(VisitOps__Agenda__c = agendaRecord1.id, VisitOps__User__c = userInfo.getUserId(), VisitOps__Status__c='Accepted');
        system.debug('testUserPAL-- User testCompany case');
        VOPrintAttendeeDetailsController pa1 = new VOPrintAttendeeDetailsController();
    }
    static testMethod void testAttendeePAL(){
        loadTest();
        insert new VisitOps__Presenter_Agenda_Link__c(VisitOps__Agenda__c = agendaRecord1.id, VisitOps__Attendee__c = testContactAttendee.id, VisitOps__Status__c='Accepted');
        system.debug('testAttendeePAL-- Attendee empty firstname case');
        VOPrintAttendeeDetailsController pa1 = new VOPrintAttendeeDetailsController();
        
        update new VisitOps__Attendee__c(id=testContactAttendee.id, VisitOps__FirstName__c = 'testFirstName');
        insert new VisitOps__Presenter_Agenda_Link__c(VisitOps__Agenda__c = agendaRecord1.id, VisitOps__Attendee__c = testContactAttendee.id, VisitOps__Status__c='Accepted');
        system.debug('testAttendeePAL-- Attendee testFirstName case');
        pa1 = new VOPrintAttendeeDetailsController();
        
        VisitOps__Attendee__c testAdhocAttendee = new VisitOps__Attendee__c(VisitOps__Company__c='eretrw',VisitOps__visit__c = currentVisit.id,VisitOps__FirstName__c='abc',VisitOps__LastName__c='def',VisitOps__Post_Survey_Sent__c=true,VisitOps__PreSurveySent__c=true,VisitOps__Email__c='abcdef@sdf.com',VisitOps__Pre_Survey_Required__c=true,VisitOps__Post_Survey_Required__c=true,VisitOps__SendPreSurvey__c = true,VisitOps__SendPostSurvey__c=true);
        insert testAdhocAttendee;
        insert new VisitOps__Presenter_Agenda_Link__c(VisitOps__Agenda__c = agendaRecord1.id, VisitOps__Attendee__c = testAdhocAttendee.id, VisitOps__Status__c='Accepted');
        system.debug('testAttendeePAL-- Adhoc Attendee case');
        pa1 = new VOPrintAttendeeDetailsController();
    }
    
    
    
}