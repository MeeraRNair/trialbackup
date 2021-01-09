/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestAgendaBuilder {

    private static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                   Active__c=true,Engagement_Type__c='DSC',
                                                   Offer_Catering__c='Yes',Offer_Transportation__c='Yes',
                                                   Email__c='test_user@dell.com',
                                                   recordTypeid=rtSite);
        insert testSite;
                
        Id rt=IdLookupUtils.getRecordTypeId('Rooms','Event_Location__c',true);
        Event_Location__c testRoom=new Event_Location__c(Name='testRoom',Room_Occupancy__c='15',Select_Site__c=testSite.Id,recordTypeid=rt);
        insert testRoom;
        
        Id calrt=IdLookupUtils.getRecordTypeId('Primary Calendar RT','Calendar_Management__c',true);
        Calendar_Management__c newCal=new Calendar_Management__c(Room__c=testRoom.Id,Site__c=testSite.Id,Date__c=System.today()+30,Start_Date__c =System.today()+30,End_Date__c =System.today()+30, Status__c='Pending');
        insert newCal;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE7',Requestor_Name__c = testUser.Id,
                                         Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes',
                                         Calendar_Management__c=newCal.Id);
        insert testCE1;
        Customer_Engagement__c testCE2 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');

        insert testCE2;        
        
        Id subjectRt=IdLookupUtils.getRecordTypeId('Subject','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions', RecordTypeId =subjectRt);
        insert testAgendaConObj;
        Id topicRt=IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true);
        
        Agenda_Content__c testAgendaConObj2 = new Agenda_Content__c(Name = 'Test Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,
        Duration_minutes__c = 45,Apply_to_Site__c=testSite.Id,Engagement_Type__c = 'EBC',Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj2;
        
        Test.startTest();
        Id atopicRt=IdLookupUtils.getRecordTypeId('Agenda Topic','Agenda_Topic__c',true);//RecordTypeId=atopicRt,
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology',Start_Date__c=System.today()+30, AE_Notes__c = 'AE Notes',Duration__c=45,
        Topics__c=testAgendaConObj2.Id,Customer_Engagement__c = testCE1.Id);
        insert testAgendaTopicObj;

        Agenda_Topic__c testAgendaTopicObj2 = new Agenda_Topic__c(Name = 'Test Blade Server Technology', AE_Notes__c = 'AE Notes',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=atopicRt,Start_Date__c=System.today()+30, Starting_Time__c='12:45PM', Ending_Time__c='01:45PM');
        insert testAgendaTopicObj2;
        
       /*Id topicExpertRt=IdLookupUtils.getRecordTypeId('Internal Topic Expert','Topic_Experts__c',true);
        Topic_Experts__c tExpert= new Topic_Experts__c(RecordTypeId=topicExpertRt,Type__c='Presenter',Presenter_Architect_Name__c=testUser.Id);
        insert tExpert;
        Id tExpertRt=IdLookupUtils.getRecordTypeId('Topic Expert','Attendees__c',true);
        Attendees__c newAtnd = new Attendees__c(RecordTypeId=tExpertRt, Customer_Engagement__c=testCE1.Id, Team_Member__c=tExpert.Id, Agenda_Topic__c=testAgendaTopicObj2.Id);
        insert newAtnd;*/
        
        Id caterRt=IdLookupUtils.getRecordTypeId('Catering','Agenda_Topic__c',true);
        Agenda_Topic__c testAgendaTopicObj3 = new Agenda_Topic__c(Name = 'new catering',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=caterRt,Start_Date__c=System.today()+30, Starting_Time__c='01:45PM', Ending_Time__c='02:45PM');
        insert testAgendaTopicObj3;
        
        Transportation__c newtrans= new Transportation__c(Name='Test Transportation',Travel_Type__c='Flight Arrival', Starting_Time__c='01.00AM', Ending_Time__c='03.00AM',Start_Date__c= system.today(), Customer_Engagement__c=testCE1.Id);
        insert newtrans;
        
        PageReference pageRef = new PageReference('/apex/AgendaBuilderPage?id='+testCE1.Id);
        Test.setCurrentPage(pageRef);
        
        AgendaBuilderController controller = new AgendaBuilderController(new ApexPages.StandardController(testCE1));
        pageReference customeragenda = controller.print1();
        System.assert(customeragenda!=NULL);    
        pageReference presenteragenda = controller.print2();
        System.assert(presenteragenda!=NULL);
        String startDate= controller.getstartDate();
        system.assertEquals(startDate,String.valueOf(newCal.Start_Date__c));
        String endDate= controller.getendDate();
        String room= controller.getRoom();
        system.assertEquals(room, testRoom.Name);
        String site= controller.getsite();
        system.assertEquals(site, testSite.Name);
        
        pageReference editAgenda = controller.getAgendaTopic();
        List<Attendees__c> atndes= controller.getAttendees();
        controller.setAttendees(atndes);
        pageReference addTopic = controller.AddTopics();
        pageReference Travel = controller.Travel();
        pageReference catrng = controller.Catering();
        
        List<Agenda_Topic__c> existTopic = controller.getexistingTopics();
        PageReference transDetail = controller.getTransportationDetails();
        List<Transportation__c> trans= controller.getexistingTravel();
        List<Agenda_Topic__c> unAssTopiclist=controller.getUnassignedTopics();

        Customer_Engagement__c CEDetails= controller.getCEdetails1();
        Boolean datelist= controller.getDateWiseList();
        Boolean itemList= controller.getitemexist();
        Boolean msg= controller.getmsg();
        controller.getTrans();
        controller.getagendaList();
        String removeTopicId=ApexPages.currentPage().getParameters().put('removeTopic',testAgendaTopicObj2.Id);        
        String removeTravelId=ApexPages.currentPage().getParameters().put('removeTravel',newtrans.Id);        
        controller.removeAssignedTopics();   

        controller.selectedDate=String.Valueof(system.Today()+30);
        PageReference cancel = controller.CancelButton();

        PageReference newpageRef = new PageReference('/apex/AgendaBuilderPage?id='+testCE2.Id);
        Test.setCurrentPage(newpageRef);
           
        Test.stopTest();
    }
}