@isTest(seeAllData=false)
private class VOVisitTriggerTest {
    
    static Account testAccount;
    static visitops__Visit__c currentVisit;
    static visitops__Visit__c currentVisit1;
    static visitops__Attendee__c testUserAttendee;
    static visitops__Location__c testLocation;
    static visitops__VisitType__c testCustomerVisit1;
    static visitops__Status__c testNewStatus;
    static visitops__Status__c testNewStatus1;
    static User testUser;
    static Contact testContact;
    static visitops__Attendee__c testContactAttendee;
    static visitops__Presenter__c testContactPresenter;
    static visitops__Presenter_Agenda_Link__c testAgendaLink;
    static visitops__Agenda__c testAgenda;
    static visitops__Room__c testRoom;
    static visitops__Room_Schedule__c testRoomSchedule;
    static visitops__Place__c testPlace;
    
    //Create test data for testmethods
    static testMethod void createTestData() {
            
            //Insert Location
            testLocation = new visitops__Location__c(Name='TestLocation',visitops__Location_Street_Address__c='testAddress', visitops__Time_Zone__c = '(GMT+00:00) Greenwich Mean Time (GMT)'); 
            insert testLocation;
            
            // Insert Place
            testPlace = new visitops__Place__c(Name='TestPlace', visitops__Location__c=testLocation.Id);
            insert testPlace;
            
            //Insert VisitType
            testCustomerVisit1 = new visitops__VisitType__c(Name='TestCustomerVisit1', visitops__Category__c='CV1'); 
            insert testCustomerVisit1;
            
            //Create Status - New
            testNewStatus = new visitops__Status__c(Name='New'); 
            insert testNewStatus;
            
            testNewStatus1 = new visitops__Status__c(Name='Cancelled'); 
            insert testNewStatus1;
            
            
            currentVisit1 = new visitops__Visit__c(visitops__VisitName__c='testVisit', visitops__VisitOwner__c =userInfo.getUserId(), visitops__VisitType__c=testCustomerVisit1.id, visitops__Location__c=testLocation.id, VisitOps__VisitStatus__c	=testNewStatus.id,visitops__ArrivalDateTime__c=system.now(),visitops__DepartureDateTime__c=system.now()+5, visitops__TotalNoOfAttendees__c=100,
                          visitops__ArrivalDateTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),visitops__DepartureDateTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'));
            insert currentVisit1;
            
            currentVisit = new visitops__Visit__c(visitops__VisitName__c='testVisit', visitops__VisitOwner__c =userInfo.getUserId(), visitops__VisitType__c=testCustomerVisit1.id, visitops__Location__c=testLocation.id, VisitOps__VisitStatus__c	=testNewStatus.id,visitops__ArrivalDateTime__c=system.now(), visitops__DepartureDateTime__c=system.now()+5,visitops__TotalNoOfAttendees__c=100,
                          visitops__ArrivalDateTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),visitops__DepartureDateTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'));
            insert currentVisit;
            
            testRoom = new visitops__Room__c(Name='TestRoom',visitops__Location__c=testLocation.id,visitops__Place__c=testPlace.Id,visitops__Room_Capacity__c=20); 
            insert testRoom;
            
            testRoomSchedule = new visitops__Room_Schedule__c(visitops__Room__c = testRoom.Id, visitops__Visit__c = currentVisit.id, visitops__Start_DateTime__c=system.now(), visitops__EndDateTime__c=system.now()+5); 
            insert testRoomSchedule;
            
            //currentVisit.VisitStatusName__c = 'Submitted';
            update currentVisit;
            delete currentVisit;
            //create test account
         	testAccount = new Account(Name='testAccount', AnnualRevenue = 10000000, Industry = 'Agriculture' , Website = 'http://www.abc.com');
            insert testAccount;  
            
            //Create Contact
            testContact = new Contact(AccountId = testAccount.id, firstname = 'Test', lastname = 'Contact', title = 'contactTest', Visitops__Role__c = 'Director', email = 'kjkj@kjhkjh.com', phone = '9789878979', Visitops__LinkedInUrl__c = 'www.kjhkjh.com', Visitops__DietType__c = 'Diabetic', Visitops__DietaryRequirements__c = 'kljhkjhkjhkjhkjhllljhfkladjh');
            insert testContact;
            
            //Create Presenter - Contact type
            testContactPresenter = new visitops__Presenter__c(Visitops__Base_Location__c = testLocation.Id, Visitops__firstname__c = 'Test', Visitops__lastname__c = 'Contact', Visitops__Title__c = 'contactTest', Visitops__email__c = 'kjkj@kjhkjh.com', Visitops__phone__c = '9789878979',Visitops__Department__c = 'Revenue', Visitops__Mobile__c = '987987789');
            insert testContactPresenter;
            
            //Create Attendee - User type
            testUserAttendee = new visitops__Attendee__c(visitops__Visit__c = currentVisit1.id, Visitops__User__c = userInfo.getUserId(), Visitops__firstname__c = 'Test', Visitops__lastname__c = 'Contact', Visitops__Company__c = 'testCompany', Visitops__Title__c = 'contactTest', Visitops__email__c = 'kjkj@kjhkjh.com', Visitops__phone__c = '9789878979');
            insert testUserAttendee;
            
            //Create Attendee - Contact type
            testcontactAttendee = new visitops__Attendee__c(visitops__Visit__c = currentVisit1.id, Visitops__Contact__c = testContact.Id, Visitops__firstname__c = 'Test', Visitops__lastname__c = 'Contact', Visitops__Company__c = 'testCompany', Visitops__Title__c = 'contactTest', Visitops__email__c = 'kjkj@kjhkjh.com', Visitops__phone__c = '9789878979');
            insert testcontactAttendee;
            
            testAgenda =  new visitops__Agenda__c(Visitops__Agenda_Title__c = 'testAgendaSession', visitops__Visit__c = currentVisit1.id, visitops__Location__c = testLocation.Id, Visitops__Start_Time__c = system.now(), Visitops__End_Time__c = system.now()+1, Visitops__StartTimeLocationTZ__c = system.now().format('yyyy-MM-dd HH:mm:ss'), Visitops__EndTimeLocationTZ__c = system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'));
            insert testAgenda;
            
            testAgendaLink = new visitops__Presenter_Agenda_Link__c(visitops__Agenda__c = testAgenda.Id, visitops__Presenter__c = testContactPresenter.Id, Visitops__Presenter_Name__c ='AgendaPresenter', Visitops__Account_Name__c='AgendaCompany', Visitops__Title__c = 'AgendaTitle'); 
            insert testAgendaLink;
            
            testUserAttendee.visitops__firstname__c = 'UpdatedTest';
            testUserAttendee.visitops__LastName__c = 'updatedlast';
            update testUserAttendee;
            
            System.assertNotEquals(testUserAttendee,null);
            
    }
    
}