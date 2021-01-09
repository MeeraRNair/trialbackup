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
private class TestPrintAgendaController {

    private static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                   Active__c=true,Engagement_Type__c='DSC',
                                                   Offer_Catering__c='Yes',Offer_Transportation__c='Yes',
                                                   Email__c='test_user@dell.com',
                                                   recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');

        insert testCE1;
        Id subjectRt=IdLookupUtils.getRecordTypeId('Subject','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions', RecordTypeId =subjectRt);
        insert testAgendaConObj;
        Id topicRt=IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj2 = new Agenda_Content__c(Name = 'Test Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,
        Duration_minutes__c = 45,Apply_to_Site__c=testSite.Id,Engagement_Type__c = 'EBC',Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj2;
        Agenda_Content__c testAgendaConObj1 = new Agenda_Content__c(Name = 'Blade Server Technologyt',Select_Subject__c = testAgendaConObj.Id,
        Duration_minutes__c = 45,Engagement_Type__c = 'EBC',Apply_to_Site__c=testSite.Id,Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj1;
        Id atopicRt=IdLookupUtils.getRecordTypeId('Agenda Topic','Agenda_Topic__c',true);
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technologys', AE_Notes__c = 'AE Notes',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=atopicRt, Start_Date__c= system.today());
        insert testAgendaTopicObj;
        
        Test.startTest();
        
        Agenda_Topic__c testAgendaTopicObjt = new Agenda_Topic__c(Name = 'Blade Server Technologyo', AE_Notes__c = 'AE Notes',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=atopicRt, Starting_Time__c='12:45PM', Start_Date__c= system.today(),Ending_Time__c='01:45PM');
        insert testAgendaTopicObjt;
        Agenda_Topic__c testAgendaTopicObjs = new Agenda_Topic__c(Name = 'Blade Server Technologyp', AE_Notes__c = 'AE Notes',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=atopicRt, Starting_Time__c='12:45AM', Start_Date__c= system.today(),Ending_Time__c='01:45AM');
        insert testAgendaTopicObjs;
        
     /*   Id topicExpertRt=IdLookupUtils.getRecordTypeId('Internal Topic Expert','Topic_Experts__c',true);
        Topic_Experts__c tExpert= new Topic_Experts__c(RecordTypeId=topicExpertRt,Type__c='Presenter',Presenter_Architect_Name__c=testUser.Id);
        insert tExpert;
        
        Id tExpertRt=IdLookupUtils.getRecordTypeId('Topic Expert','Attendees__c',true);
        Attendees__c newAtnd = new Attendees__c(RecordTypeId=tExpertRt, Customer_Engagement__c=testCE1.Id, Team_Member__c=tExpert.Id, Agenda_Topic__c=testAgendaTopicObjt.Id);
        insert newAtnd;*/
        Id accountTeamRt=IdLookupUtils.getRecordTypeId('Account Team','Attendees__c',true);
        Attendees__c newAccAtnd = new Attendees__c(RecordTypeId=accountTeamRt, Account_Team__c= testUser.Id, Customer_Engagement__c=testCE1.Id);
        insert newAccAtnd;
        
        Id cusTeamRt=IdLookupUtils.getRecordTypeId('Customer','Attendees__c',true);
        Attendees__c newCusAtnd = new Attendees__c(RecordTypeId=cusTeamRt, Customer_Engagement__c=testCE1.Id,Customer_Attendee__c= con.Id);
        insert newCusAtnd;
        
        /*Id venTeamRt=IdLookupUtils.getRecordTypeId('Vendor/Partner','Attendees__c',true);
        Attendees__c newVenAtnd = new Attendees__c(RecordTypeId=venTeamRt, Customer_Engagement__c=testCE1.Id,Customer_Attendee__c= con.Id);
        insert newVenAtnd;*/
        
        
        
        Id caterRt=IdLookupUtils.getRecordTypeId('Catering','Agenda_Topic__c',true);
        Agenda_Topic__c testAgendaTopicObj3 = new Agenda_Topic__c(Name = 'new catering',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=caterRt, Starting_Time__c='01:45PM', Ending_Time__c='02:45PM', Start_Date__c= system.today());
        insert testAgendaTopicObj3;
        Transportation__c newtrans= new Transportation__c(Name='Test Transportation',Travel_Type__c='Flight Arrival', Starting_Time__c='01.00AM', Ending_Time__c='03.00AM',Start_Date__c= system.today(), Customer_Engagement__c=testCE1.Id);
        insert newtrans;
        
        Test.stopTest();
        
        PageReference pageRef = new PageReference('/apex/presenterAgenda?id='+testCE1.Id);
        Test.setCurrentPage(pageRef);
        
        printAgendaController controller = new printAgendaController(new ApexPages.StandardController(testCE1));
        
        
        Customer_Engagement__c CEDetails= controller.getCEdetails1();
        List<Attendees__c> attCus = controller.getCustomers();
        List<Attendees__c> attAccTeam= controller.getTeams();
        List<Attendees__c> attVendor= controller.getVendors();
        Boolean isAtt=controller.getisattendee();
        Boolean isAccTeam=controller.getisaccountteam();
        Boolean isVendor= controller.getisvendor();
        controller.getanalyst();
        controller.getanalyst();
        List<Attending_Accounts__c> attendingAcc= controller.getattendees();
        List<Agenda__c> assignedTopic= controller.getAssignedTopics();
        controller.add();
 
    }
}