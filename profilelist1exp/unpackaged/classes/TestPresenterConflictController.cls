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
@isTest(seealldata = false)
private class TestPresenterConflictController {

    static testMethod void myUnitTest() {
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        /*Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;*/
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                   Active__c=true,Engagement_Type__c='DSC',
                                                   Offer_Catering__c='Yes',Offer_Transportation__c='Yes',
                                                   Email__c='test_user@dell.com',
                                                   recordTypeid=rtSite);
        insert testSite;
 
String Xpertinput = 'testXpert';
                
        Id rt=IdLookupUtils.getRecordTypeId('Rooms','Event_Location__c',true);
        Event_Location__c testRoom=new Event_Location__c(Name='testRoom',Room_Occupancy__c='15',Select_Site__c=testSite.Id,recordTypeid=rt);
        insert testRoom;
        
        Id calrt=IdLookupUtils.getRecordTypeId('Primary Calendar RT','Calendar_Management__c',true);
        Calendar_Management__c newCal=new Calendar_Management__c(Room__c=testRoom.Id,Site__c=testSite.Id,Date__c=System.today()+30,Start_Date__c =System.today()+30,End_Date__c =System.today()+30, Status__c='Pending');
        insert newCal;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        //Insert a CE Record
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE7',Requestor_Name__c = testUser.Id,
                                         Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,/*Primary_Contact__c=con.Id,*/NDA__c='Yes',
                                         Calendar_Management__c=newCal.Id);
        insert testCE1;
        
        Id subjectRt=IdLookupUtils.getRecordTypeId('Subject','Agenda_Content__c',true);
        //Insert a Subject in Agenda Content
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions', RecordTypeId =subjectRt);
        insert testAgendaConObj;
        
        Id topicRt=IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true);
        //Insert a topic in Agenda Content
        Agenda_Content__c testAgendaConObj2 = new Agenda_Content__c(Name = 'Test Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,
        Duration_minutes__c = 45,Apply_to_Site__c=testSite.Id,Engagement_Type__c = 'DSC',Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj2;
        
        //Insert a topic in Agenda Content
        Agenda_Content__c testAgendaConObj1 = new Agenda_Content__c(Name = 'Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,
        Duration_minutes__c = 45,Apply_to_Site__c=testSite.Id,Engagement_Type__c = 'DSC',Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj1;
        
        //Insert a topic in Agenda Topic
        Id atopicRt=IdLookupUtils.getRecordTypeId('Agenda Topic','Agenda_Topic__c',true);//RecordTypeId=atopicRt,
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology',Start_Date__c=System.today()+30, AE_Notes__c = 'AE Notes',Duration__c=45,
        Topics__c=testAgendaConObj1.Id,Customer_Engagement__c = testCE1.Id);
        insert testAgendaTopicObj;

        Id topicXprtRT=IdLookupUtils.getRecordTypeId('Internal Topic Expert','Topic_Experts__c',true);
        
        Topic_Experts__c listXperts2 = new Topic_Experts__c(Topic_Expert_Name__c='Test Expert',Presenter_Architect_Name__c=testUser.Id,
                                        Title__c='test title', Type__c='Presenter',RecordTypeId=topicXprtRT,InActive__c=FALSE,
                                        Specializing_In__c=testAgendaConObj1.Id);
        insert listXperts2;       

Topic_Experts__c testXpert= new Topic_Experts__c(Topic_Expert_Name__c='testXpert',Presenter_Architect_Name__c=testUser.Id,
                                        Title__c='test title1', Type__c='Presenter',RecordTypeId=topicXprtRT,InActive__c=FALSE,
                                        Specializing_In__c=testAgendaConObj1.Id);
insert testXpert;                                               
//Topic_Experts__c listExpert = [select Topic_Expert_Name__c from Topic_Experts__c where Topic_Expert_Name__c =: 'testXpert'];               

        PageReference pageRef = new PageReference('/apex/PresenterConflict?id='+testAgendaTopicObj.Id);
        system.debug('pageRef'+pageRef);
        Test.setCurrentPage(pageRef);
    
        PresenterConflictController controller = new PresenterConflictController();   
        
        controller.searchTopicName();
        controller.topicExpDisplayList[0].selected = true;
        controller.checkAvailability();
        controller.getListXperts();
        controller.getrecord_not_found();
        controller.getrecord_found();
        controller.Cancel();
        controller.gettopicExpSelected();
        controller.getcheckAvailabilityFlag();
        
        controller.getnewXpert();
        controller.getagendaTopic();
        controller.getagendaTopicFlag ();
        controller.getTopicExpDisplayList();
        
        String strTime = '09:00AM';
        controller.convertTime(strTime);
        List<Agenda_Topic__c>agendaTopicList=new List<Agenda_Topic__c>();
        agendaTopicList.add(testAgendaTopicObj);
        controller.presenterCheck(agendaTopicList);

        controller.setNextPrevious();
        controller.nextXpert();
        controller.previousXpert();
        controller.startXpert();
        controller.endXpert();
      
        controller.setnewXpert(listXperts2);
        controller.continueaction();
    }
}