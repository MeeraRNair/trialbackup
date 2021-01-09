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
private class TestCalenderManagementUtils{

    static testMethod void myUnitTest() {
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                   Active__c=true,Engagement_Type__c='EBC',
                                                   Offer_Catering__c='Yes',Offer_Transportation__c='Yes',
                                                   Email__c='test_user@dell.com',
                                                   recordTypeid=rtSite);
        insert testSite;
                
        Id rt=IdLookupUtils.getRecordTypeId('Rooms','Event_Location__c',true);
        Event_Location__c testRoom=new Event_Location__c(Name='testRoom',Room_Occupancy__c='15',Select_Site__c=testSite.Id,recordTypeid=rt);
        insert testRoom;
        
        Id calrt=IdLookupUtils.getRecordTypeId('Primary Calendar RT','Calendar_Management__c',true);
        Calendar_Management__c newCal=new Calendar_Management__c(Room__c=testRoom.Id,Site__c=testSite.Id,Start_Date__c =System.today()+17,
                                    End_Date__c =System.today()+18, Status__c='Pending',RecordTypeId=calrt,Date__c=System.today()+17);
        insert newCal;
        Id seccalrt=IdLookupUtils.getRecordTypeId('Secondary Calendar RT','Calendar_Management__c',true);
        Calendar_Management__c newSecCal=new Calendar_Management__c(Room__c=testRoom.Id,Site__c=testSite.Id,Date__c =System.today()+18,
                                    Calendar_Management_Record_ID__c=newCal.Id, Status__c='Pending',RecordTypeId=calrt);
        insert newSecCal;
        
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE7',Requestor_Name__c = testUser.Id,
                                         Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes',
                                         Calendar_Management__c=newCal.Id);
        insert testCE1;
               
        
        Id subjectRt=IdLookupUtils.getRecordTypeId('Subject','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions', RecordTypeId =subjectRt);
        insert testAgendaConObj;
        Id topicRt=IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true);
        
        Agenda_Content__c testAgendaConObj2 = new Agenda_Content__c(Name = 'Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,
        Duration_minutes__c = 45,Apply_to_Site__c=testSite.Id,Engagement_Type__c = 'EBC',Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj2;
        
        Id atopicRt=IdLookupUtils.getRecordTypeId('Agenda Topic','Agenda_Topic__c',true);//RecordTypeId=atopicRt,
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology',Start_Date__c=System.today()+17, AE_Notes__c = 'AE Notes',Duration__c=45,
        Topics__c=testAgendaConObj2.Id,Customer_Engagement__c = testCE1.Id);
        insert testAgendaTopicObj;
       
        Transportation__c newtrans= new Transportation__c(Name='Test Transportation',Travel_Type__c='Flight Arrival', Starting_Time__c='01.00AM', Ending_Time__c='03.00AM',Start_Date__c= system.today()+17, Customer_Engagement__c=testCE1.Id);
        insert newtrans;
               
        newCal.Start_Date__c=system.today()+20;
        newCal.End_Date__c=system.today()+21;
        update newCal;
        Agenda_Topic__c resultTopic = [select Id, Start_Date__c From Agenda_Topic__c where Id = :testAgendaTopicObj.Id];
        Transportation__c resultTravel = [select Id, Start_Date__c From Transportation__c where Id = :newtrans.Id];
        
        System.assertEquals(system.today()+20,resultTopic.Start_Date__c);
        System.assertEquals(system.today()+20,resultTravel.Start_Date__c );
    }
}