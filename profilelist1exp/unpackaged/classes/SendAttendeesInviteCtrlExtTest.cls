@isTest
private class SendAttendeesInviteCtrlExtTest {

    static testMethod void SendAttendeesInviteCtrlExtTest() {
        
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;
            
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',Active__c=true,recordTypeId=rtSite);
        insert testSite;
        
        Id rt=IdLookupUtils.getRecordTypeId('Rooms','Event_Location__c',true);
        Event_Location__c testRoom=new Event_Location__c(Name='testRoom',Room_Occupancy__c='15',Select_Site__c=testSite.Id,recordTypeId=rt);
        insert testRoom;
        
        Id calrt=IdLookupUtils.getRecordTypeId('Primary Calendar RT','Calendar_Management__c',true);
        Calendar_Management__c newCal=new Calendar_Management__c(Room__c=testRoom.Id,Site__c=testSite.Id,Date__c=System.today()+30,Start_Date__c =System.today()+30,End_Date__c =System.today()+30, Status__c='Pending');
        insert newCal;
        
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE7',Requestor_Name__c = testUser.Id, 
                                         Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes',
                                         Calendar_Management__c=newCal.Id,Event_Status__c='Approved');
        insert testCE1;
             
        Id subjectRt=IdLookupUtils.getRecordTypeId('Subject','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions', RecordTypeId =subjectRt);
        insert testAgendaConObj;
        
        Id topicRt=IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true);       
        Agenda_Content__c testAgendaConObj2 = new Agenda_Content__c(Name = 'Test Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,
        Duration_minutes__c = 45,Engagement_Type__c = 'EBC',Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj2;
        
        Agenda_Content__c testAgendaConObj1 = new Agenda_Content__c(Name = 'Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,
        Duration_minutes__c = 45,Engagement_Type__c = 'EBC',Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj1;
        
        Id atopicRt=IdLookupUtils.getRecordTypeId('Agenda Topic','Agenda_Topic__c',true);//RecordTypeId=atopicRt,
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology', AE_Notes__c = 'AE Notes',Duration__c=45,
                                            Topics__c=testAgendaConObj1.Id,Customer_Engagement__c = testCE1.Id,  Start_Date__c= system.today()+30);
        insert testAgendaTopicObj;
        
        Agenda_Topic__c testAgendaTopicObj2 = new Agenda_Topic__c(Name = 'Test Blade Server Technology', AE_Notes__c = 'AE Notes',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=atopicRt, Starting_Time__c='12:45PM', Ending_Time__c='01:45PM', Start_Date__c= system.today()+30);
        insert testAgendaTopicObj2;
        
        List<Attendees__c>attendeeList=new List<Attendees__c>();
        Id topicExpertRt=IdLookupUtils.getRecordTypeId('Internal Topic Expert','Topic_Experts__c',true);
        
        Topic_Experts__c tExpert= new Topic_Experts__c(RecordTypeId=topicExpertRt,Type__c='Presenter',Presenter_Architect_Name__c=testUser.Id);
        insert tExpert;
        Id tExpertRt=IdLookupUtils.getRecordTypeId('Topic Expert','Attendees__c',true);

        Attendees__c newAtnd = new Attendees__c(RecordTypeId=tExpertRt, Customer_Engagement__c=testCE1.Id, Team_Member__c=tExpert.Id, Agenda_Topic__c=testAgendaTopicObj2.Id);        
        attendeeList.add(newAtnd);
         
        Id accountTeamRt=IdLookupUtils.getRecordTypeId('Account Team','Attendees__c',true);        
        Attendees__c newAccAtnd = new Attendees__c(RecordTypeId=accountTeamRt, Account_Team__c= testUser.Id, Customer_Engagement__c=testCE1.Id,Attendee_Name__c='TestAccTeam',Role__c='Test Role');        
        attendeeList.add(newAccAtnd);   
                     
        Id cusTeamRt=IdLookupUtils.getRecordTypeId('Customer','Attendees__c',true);        
        Attendees__c newCusAtnd = new Attendees__c(RecordTypeId=cusTeamRt, Customer_Engagement__c=testCE1.Id,Customer_Attendee__c= con.Id,Attendee_Name__c='TestCustomer',Role__c='Test Role');        
        attendeeList.add(newCusAtnd);   
                     
        Id venTeamRt=IdLookupUtils.getRecordTypeId('Vendor/Partner','Attendees__c',true);        
        Attendees__c newVenAtnd = new Attendees__c(RecordTypeId=venTeamRt, Customer_Engagement__c=testCE1.Id,Customer_Attendee__c= con.Id,Attendee_Name__c='TestVendor',Role__c='Test Role');        
        attendeeList.add(newVenAtnd);
               
        Id dellIntRt=IdLookupUtils.getRecordTypeId('Dell Internal','Attendees__c',true);        
        Attendees__c newDellIntAtnd = new Attendees__c(RecordTypeId=dellIntRt, Customer_Engagement__c=testCE1.Id,Customer_Attendee__c= con.Id,Attendee_Name__c='TestDellInt',Role__c='Test Role');        
        attendeeList.add(newDellIntAtnd);
        insert attendeeList;

        PageReference pageRef = new PageReference('/apex/SendAttendeesInvite?id='+testCE1.Id);
        Test.setCurrentPage(pageRef);
        
        SendAttendeesInviteCtrlExt controller = new SendAttendeesInviteCtrlExt(new ApexPages.StandardController(testCE1));
        controller.getShowInvite();
        controller.getAttendeesToList();
        controller.getCustomerEngagement();
        controller.getDateOfEvent();
        controller.getSite();
        controller.getAttendeeCustomerList();
        controller.getAttendeeCustExtList();
        controller.getAttendeeAccTeamList();
        controller.getAttendeeDellIntList();
        controller.getAttendeeVendorList();
        controller.getShowMessage();
        controller.getevent();
        controller.getComments();
        controller.getMessage();
        controller.getSubjectEdit();
        controller.getAnalystEmail(); 
        controller.getCustomerAttFlag();
        controller.getAccTeamAttFlag();  
        controller.getcustAttendeeMap();
        controller.getaccTeamAttendeeMap();
        controller.getDellIntAttFlag();
        controller.getVendorAttFlag();
        PageReference  pageRefExpected = new PageReference('/'+testCE1.Id);
        controller.email = 'teck_kee_chin@dell.com';
        PageReference  pageRefActual = controller.sendinvite();              
        System.assertEquals(pageRefExpected.getURL(),pageRefActual.getURL());
    }
}