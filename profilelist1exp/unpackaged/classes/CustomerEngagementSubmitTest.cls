@isTest
private class CustomerEngagementSubmitTest {

  //Test method for submitting Customer Engagement Object with status as 'Pending'
    static testMethod void testSubmitPending() {
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Customer_Engagement__c' and 
                                 name = 'Executive Briefing Center'];
        Account primaryAccount = new Account(Name = 'Test Account');
        insert primaryAccount;    
        Contact primaryContact = new Contact(FirstName = 'ContactExcSafeWord1', LastName = 'ContactExcSafeWord1', 
                                 AccountId = primaryAccount.Id, Phone = '11111', 
                                 Decision_Making_Role__c = 'Influencer', Job_Function__c = 'IT',
                                 Purchaser_Influence_over_Merged__c = 'Client-Desktops' );
        insert primaryContact;
        User testUser = [SELECT Id FROM USER WHERE Isactive=true limit 1];
        Customer_Engagement__c testCustEngObj = new Customer_Engagement__c(Name = 'Mytest CE',
                                                Requestor_Name__c = testUser.Id, 
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = primaryAccount.Id,
                                                Primary_Contact__c = primaryContact.Id,
                                                NDA__c = 'Yes',
                                                Event_Status__c = 'Pending',
                                                Submitted_Date__c = System.today(),
                                                RecordTypeId = recordType.Id);
        insert testCustEngObj;
        
        Id attendeeRecTypeId = IdLookupUtils.getRecordTypeId('Dell Internal','Attendees__c', true);
        Attendees__c testAttendee = new Attendees__c(Dell_Internal_Attendee__c = testUser.Id, 
                                    Customer_Engagement__c = testCustEngObj.Id,
                                    RecordTypeId = attendeeRecTypeId);
        insert testAttendee;
        List<Agenda_Content__c> agendaContentList = new List<Agenda_Content__c>();
        
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions');
        //insert testAgendaConObj;
        agendaContentList.add(testAgendaConObj);
        Agenda_Content__c testAgendaConObj1 = new Agenda_Content__c(Name = 'Blade Server Technology',
                                                                   Select_Subject__c = testAgendaConObj.Id,
                                                                   Duration_minutes__c = 45,
                                                                   Engagement_Type__c = 'EBC',
                                                                   Event_Type__c = 'Design Sessions');
        //insert testAgendaConObj1;     
        agendaContentList.add(testAgendaConObj1);
        insert agendaContentList;
        
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology', 
                                                                 AE_Notes__c = 'AE Notes',
                                                                 Customer_Engagement__c = testCustEngObj.Id);
        insert testAgendaTopicObj;
        
        Id recTypeSite = IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        
        List<Event_Location__c>  eventLocList = new List<Event_Location__c>();
        Event_Location__c testSite = new Event_Location__c(Name='Test Site',Region__c = 'Americas',
                                                           RecordTypeId = recTypeSite, Active__c=true);
        insert testSite;
        //eventLocList.add(testSite);
        Id recTypeSR = IdLookupUtils.getRecordTypeId('Rooms','Event_Location__c',true);
        Event_Location__c testSRoom = new Event_Location__c(Name = 'Test S Room', Room_Occupancy__c = '15',
                                                           Select_Site__c = testSite.Id, 
                                                           RecordTypeId = recTypeSR);
        //insert testSRoom;
        eventLocList.add(testSRoom);
        Event_Location__c testDRoom = new Event_Location__c(Name='Test D Room', Room_Occupancy__c = '20',
                                                            Room_Type__c='Single',
                                                            Select_Site__c=testSite.Id, 
                                                            RecordTypeId = recTypeSR);
        //insert testDRoom;
        eventLocList.add(testDRoom);
        insert eventLocList;
        Test.startTest();
        
        Id recTypeCalMgmt =IdLookupUtils.getRecordTypeId('Primary Calendar RT','Calendar_Management__c',true); 
        Calendar_Management__c testCalMgmtObj = new Calendar_Management__c(Room__c = eventLocList[1].Id,
                                                Site__c=testSite.Id, Date__c = System.today()+16,
                                                Status__c = 'Pending',
                                                RecordTypeId = recTypeCalMgmt,
                                                Customer_Engagement_Event__c = testCustEngObj.Id);
        insert testCalMgmtObj;
        Calendar_Management__c calMgmtObj = [SELECT Id, Name FROM Calendar_Management__c
                                             ORDER BY CreatedDate desc LIMIT 1];
        testCustEngObj.Calendar_Management__c = calMgmtObj.Id;
        update testCustEngObj;
        PageReference  pr = new PageReference('/apex/CustomerEngagementSubmit?id='+testCustEngObj.Id);
        Test.setCurrentPage(pr);
        CustomerEngagementSubmitCtrl controller = new CustomerEngagementSubmitCtrl
                                                  (new ApexPages.StandardController(testCustEngObj));
        PageReference  pageRefActual = controller.validateRelatedLists();
        testCustEngObj.Event_Status__c = 'Requested';
        update testCustEngObj;
        Test.stopTest();
       // controller.validateRelatedLists();
        PageReference pRef = controller.validateRelatedLists();
    }
    
    //Test method for submitting Customer Engagement Object with status as 'Completed'
    static testMethod void testSubmitCompleted() {
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Customer_Engagement__c' and 
                                 name = 'Executive Briefing Center'];
        Account primaryAccount = new Account(Name = 'Test Account');
        insert primaryAccount;    
        Contact primaryContact = new Contact(FirstName = 'ContactExcSafeWord1', LastName = 'ContactExcSafeWord1', 
                                 AccountId = primaryAccount.Id, Phone = '11111', 
                                 Decision_Making_Role__c = 'Influencer', Job_Function__c = 'IT',
                                 Purchaser_Influence_over_Merged__c = 'Client-Desktops' );
        insert primaryContact;
        User testUser = [SELECT Id FROM USER WHERE Isactive=true limit 1];
        Customer_Engagement__c testCustEngObj = new Customer_Engagement__c(Name = 'Mytest CE',
                                                Requestor_Name__c = testUser.Id, 
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = primaryAccount.Id,
                                                Primary_Contact__c = primaryContact.Id,
                                                NDA__c = 'Yes',
                                                Event_Status__c = 'Completed',
                                                Submitted_Date__c = System.today(),
                                                RecordTypeId = recordType.Id);
        insert testCustEngObj;
        
        Id attendeeRecTypeId = IdLookupUtils.getRecordTypeId('Dell Internal','Attendees__c', true);
       /* Attendees__c testAttendee = new Attendees__c(Dell_Internal_Attendee__c = testUser.Id, 
                                    Customer_Engagement__c = testCustEngObj.Id,
                                    RecordTypeId = attendeeRecTypeId);
        insert testAttendee;*/

        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions');
        insert testAgendaConObj;
        Agenda_Content__c testAgendaConObj1 = new Agenda_Content__c(Name = 'Blade Server Technology',
                                                                   Select_Subject__c = testAgendaConObj.Id,
                                                                   Duration_minutes__c = 45,
                                                                   Engagement_Type__c = 'EBC',
                                                                   Event_Type__c = 'Design Sessions');
        insert testAgendaConObj1;
        /*Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology', 
                                                                 AE_Notes__c = 'AE Notes',
                                                                 Customer_Engagement__c = testCustEngObj.Id);
        insert testAgendaTopicObj;*/
        
        Id recTypeSite = IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true); 
        Event_Location__c testSite = new Event_Location__c(Name='Test Site',Region__c = 'Americas',
                                                           RecordTypeId = recTypeSite, Active__c=true);
        insert testSite;
        Id recTypeSR = IdLookupUtils.getRecordTypeId('Rooms','Event_Location__c',true);
        Event_Location__c testSRoom = new Event_Location__c(Name = 'Test S Room', Room_Occupancy__c = '15',
                                                           Select_Site__c = testSite.Id, 
                                                           RecordTypeId = recTypeSR);
        insert testSRoom;
        Event_Location__c testDRoom = new Event_Location__c(Name='Test D Room', Room_Occupancy__c = '20',
                                                            Room_Type__c='Single',
                                                            Select_Site__c=testSite.Id, 
                                                            RecordTypeId = recTypeSR);
        insert testDRoom;
         Id recTypeCalMgmt =IdLookupUtils.getRecordTypeId('Primary Calendar RT','Calendar_Management__c',true);
         Calendar_Management__c testCalMgmtObj = new Calendar_Management__c(Room__c = testDRoom.Id,
                                                Site__c=testSite.Id, Date__c = System.today()+16,
                                                Status__c = 'Pending',
                                                RecordTypeId = recTypeCalMgmt,
                                                Customer_Engagement_Event__c = testCustEngObj.Id);
        insert testCalMgmtObj;
        Calendar_Management__c calMgmtObj = [SELECT Id, Name FROM Calendar_Management__c
                                             ORDER BY CreatedDate desc LIMIT 1];
        testCustEngObj.Calendar_Management__c = calMgmtObj.Id;
        update testCustEngObj;
        PageReference  pr = new PageReference('/apex/CustomerEngagementSubmit?id='+testCustEngObj.Id);
        Test.setCurrentPage(pr);
        CustomerEngagementSubmitCtrl controller = new CustomerEngagementSubmitCtrl
                                                  (new ApexPages.StandardController(testCustEngObj));
       // controller.validateRelatedLists();
        PageReference pRef = controller.validateRelatedLists();
    }
    
    //Test method for submitting Customer Engagement Object with Calendar Mgmnt status as 'Expired'
    static testMethod void testSubmitExpired() {
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Customer_Engagement__c' and 
                                 name = 'Executive Briefing Center'];
        Account primaryAccount = new Account(Name = 'Test Account');
        insert primaryAccount;    
        Contact primaryContact = new Contact(FirstName = 'ContactExcSafeWord1', LastName = 'ContactExcSafeWord1', 
                                 AccountId = primaryAccount.Id, Phone = '11111', 
                                 Decision_Making_Role__c = 'Influencer', Job_Function__c = 'IT',
                                 Purchaser_Influence_over_Merged__c = 'Client-Desktops' );
        insert primaryContact;
        User testUser = [SELECT Id FROM USER WHERE Isactive=true limit 1];
        Customer_Engagement__c testCustEngObj = new Customer_Engagement__c(Name = 'Mytest CE',
                                                Requestor_Name__c = testUser.Id, 
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = primaryAccount.Id,
                                                Primary_Contact__c = primaryContact.Id,
                                                NDA__c = 'Yes',
                                                Event_Status__c = 'Pending',
                                                Submitted_Date__c = System.today(),
                                                RecordTypeId = recordType.Id);
        insert testCustEngObj;
        
        Id attendeeRecTypeId = IdLookupUtils.getRecordTypeId('Dell Internal','Attendees__c', true);
        /*Attendees__c testAttendee = new Attendees__c(Dell_Internal_Attendee__c = testUser.Id, 
                                    Customer_Engagement__c = testCustEngObj.Id,
                                    RecordTypeId = attendeeRecTypeId);
        insert testAttendee;*/
        
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions');
        insert testAgendaConObj;
        Agenda_Content__c testAgendaConObj1 = new Agenda_Content__c(Name = 'Blade Server Technology',
                                                                   Select_Subject__c = testAgendaConObj.Id,
                                                                   Duration_minutes__c = 45,
                                                                   Engagement_Type__c = 'EBC',
                                                                   Event_Type__c = 'Design Sessions');
        insert testAgendaConObj1;
        /*Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology', 
                                                                 AE_Notes__c = 'AE Notes',
                                                                 Customer_Engagement__c = testCustEngObj.Id);
        insert testAgendaTopicObj;*/
        
        Id recTypeSite = IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true); 
        Event_Location__c testSite = new Event_Location__c(Name='Test Site',Region__c = 'Americas',
                                                           RecordTypeId = recTypeSite,Active__c=true);
        insert testSite;
        Id recTypeSR = IdLookupUtils.getRecordTypeId('Rooms','Event_Location__c',true); 
        Event_Location__c testSRoom = new Event_Location__c(Name = 'Test S Room', Room_Occupancy__c = '15',
                                                           Select_Site__c = testSite.Id, 
                                                           RecordTypeId = recTypeSR);
        insert testSRoom;
        Event_Location__c testDRoom = new Event_Location__c(Name='Test D Room', Room_Occupancy__c = '20',
                                                            Room_Type__c='Single',
                                                            Select_Site__c=testSite.Id, 
                                                            RecordTypeId = recTypeSR);
        insert testDRoom;
        Id recTypeCalMgmt =IdLookupUtils.getRecordTypeId('Primary Calendar RT','Calendar_Management__c',true);
        Calendar_Management__c testCalMgmtObj = new Calendar_Management__c(Room__c = testDRoom.Id,
                                                Site__c=testSite.Id, Date__c = System.today()+16,
                                                Status__c = 'Expired',
                                                RecordTypeId = recTypeCalMgmt,
                                                Customer_Engagement_Event__c = testCustEngObj.Id);
        insert testCalMgmtObj;
        Calendar_Management__c calMgmtObj = [SELECT Id, Name FROM Calendar_Management__c
                                             ORDER BY CreatedDate desc LIMIT 1];
        testCustEngObj.Calendar_Management__c = calMgmtObj.Id;
        update testCustEngObj;
        PageReference  pr = new PageReference('/apex/CustomerEngagementSubmit?id='+testCustEngObj.Id);
        Test.setCurrentPage(pr);
        CustomerEngagementSubmitCtrl controller = new CustomerEngagementSubmitCtrl
                                                  (new ApexPages.StandardController(testCustEngObj));
//        controller.validateRelatedLists();
        PageReference pRef = controller.validateRelatedLists();
    }
    
    //Test method for submitting Customer Engagement Object with status as 'Waitlisted'
    static testMethod void testSubmitWaitlisted() {
        Test.StartTest(); // added to fix too many SOQL error
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Customer_Engagement__c' and 
                                 name = 'Executive Briefing Center'];
        Account primaryAccount = new Account(Name = 'Test Account');
        insert primaryAccount;    
        Contact primaryContact = new Contact(FirstName = 'ContactExcSafeWord1', LastName = 'ContactExcSafeWord1', 
                                 AccountId = primaryAccount.Id, Phone = '11111', 
                                 Decision_Making_Role__c = 'Influencer', Job_Function__c = 'IT',
                                 Purchaser_Influence_over_Merged__c = 'Client-Desktops' );
        insert primaryContact;
        Test.StopTest();
        
        User testUser = [SELECT Id FROM USER WHERE Isactive=true limit 1];
        Customer_Engagement__c testCustEngObj = new Customer_Engagement__c(Name = 'Mytest CE',
                                                Requestor_Name__c = testUser.Id, 
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = primaryAccount.Id,
                                                Primary_Contact__c = primaryContact.Id,
                                                NDA__c = 'Yes',
                                                Event_Status__c = 'Waitlisted',
                                                Submitted_Date__c = System.today(),
                                                RecordTypeId = recordType.Id);
        insert testCustEngObj;
        
        Id attendeeRecTypeId = IdLookupUtils.getRecordTypeId('Dell Internal','Attendees__c', true);
        Attendees__c testAttendee = new Attendees__c(Dell_Internal_Attendee__c = testUser.Id, 
                                    Customer_Engagement__c = testCustEngObj.Id,
                                    RecordTypeId = attendeeRecTypeId);
        insert testAttendee;
        
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions');
        insert testAgendaConObj;
        Agenda_Content__c testAgendaConObj1 = new Agenda_Content__c(Name = 'Blade Server Technology',
                                                                   Select_Subject__c = testAgendaConObj.Id,
                                                                   Duration_minutes__c = 45,
                                                                   Engagement_Type__c = 'EBC',
                                                                   Event_Type__c = 'Design Sessions');
        insert testAgendaConObj1;
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology', 
                                                                 AE_Notes__c = 'AE Notes',
                                                                 Customer_Engagement__c = testCustEngObj.Id);
        insert testAgendaTopicObj;
        
        Id recTypeSite = IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true); 
        Event_Location__c testSite = new Event_Location__c(Name='Test Site',Region__c = 'Americas',
                                                           RecordTypeId = recTypeSite, Active__c=true);
        insert testSite;
        Id recTypeSR = IdLookupUtils.getRecordTypeId('Rooms','Event_Location__c',true); 
        Event_Location__c testSRoom = new Event_Location__c(Name = 'Test S Room', Room_Occupancy__c = '15',
                                                           Select_Site__c = testSite.Id, 
                                                           RecordTypeId = recTypeSR);
        insert testSRoom;
        Event_Location__c testDRoom = new Event_Location__c(Name='Test D Room', Room_Occupancy__c = '20',
                                                            Room_Type__c='Single',
                                                            Select_Site__c=testSite.Id, 
                                                            RecordTypeId = recTypeSR);
        insert testDRoom;
        Id recTypeCalMgmt =IdLookupUtils.getRecordTypeId('Primary Calendar RT','Calendar_Management__c',true);
        Calendar_Management__c testCalMgmtObj = new Calendar_Management__c(Room__c = testDRoom.Id,
                                                Site__c=testSite.Id, Date__c = System.today()+16,
                                                Status__c = 'Pending',
                                                RecordTypeId = recTypeCalMgmt,
                                                Customer_Engagement_Event__c = testCustEngObj.Id);
        insert testCalMgmtObj;
        Calendar_Management__c calMgmtObj = [SELECT Id, Name FROM Calendar_Management__c
                                             ORDER BY CreatedDate desc LIMIT 1];
        testCustEngObj.Calendar_Management__c = calMgmtObj.Id;
        update testCustEngObj;
        PageReference  pr = new PageReference('/apex/CustomerEngagementSubmit?id='+testCustEngObj.Id);
        Test.setCurrentPage(pr);
        CustomerEngagementSubmitCtrl controller = new CustomerEngagementSubmitCtrl
                                                  (new ApexPages.StandardController(testCustEngObj));
       // controller.validateRelatedLists();
        controller.validateRelatedLists();
    }
}