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
private class TestAfterinsertupdatetopicexpert {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='No',Offer_Transportation__c='No',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE1;        
        List<Agenda_Content__c> agendaContentList = new List<Agenda_Content__c>();
        
        Id subjectRt=IdLookupUtils.getRecordTypeId('Subject','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions', RecordTypeId =subjectRt);
        //insert testAgendaConObj;
        agendaContentList.add(testAgendaConObj);
        
        Id topicRt=IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj2 = new Agenda_Content__c(Name = 'Test Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,
        Duration_minutes__c = 45,Engagement_Type__c = 'DSC',Apply_to_Site__c=testSite.Id,Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        //insert testAgendaConObj2;
        agendaContentList.add(testAgendaConObj2);
        insert agendaContentList;
        
        Id atopicRt=IdLookupUtils.getRecordTypeId('Agenda Topic','Agenda_Topic__c',true);
        Agenda_Topic__c testAgendaTopicObj2 = new Agenda_Topic__c(Name = 'Test Blade Server Technology', AE_Notes__c = 'AE Notes',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=atopicRt, Start_Date__c= system.today());
        insert testAgendaTopicObj2;
        Id topicExpertRt=IdLookupUtils.getRecordTypeId('Internal Topic Expert','Topic_Experts__c',true);
        Topic_Experts__c tExpert= new Topic_Experts__c(RecordTypeId=topicExpertRt,Type__c='Presenter',Presenter_Architect_Name__c=testUser.Id);
        insert tExpert;
               
        Id tExpertRt=IdLookupUtils.getRecordTypeId('Topic Expert','Attendees__c',true);
        List<Attendees__c> attendeeList = new List<Attendees__c>();
        Attendees__c newAtnd = new Attendees__c(RecordTypeId=tExpertRt, Customer_Engagement__c=testCE1.Id, Team_Member__c=tExpert.Id, Agenda_Topic__c=testAgendaTopicObj2.Id);
        //insert newAtnd;
        attendeeList.add(newAtnd);
        
        testAgendaTopicObj2.Starting_Time__c='12:45PM';
        testAgendaTopicObj2.Ending_Time__c='01:45PM';
        update testAgendaTopicObj2;
        
        
        
        
        Attendees__c attnd = new Attendees__c(RecordTypeId=tExpertRt, Customer_Engagement__c=testCE1.Id, Team_Member__c=tExpert.Id, Agenda_Topic__c=testAgendaTopicObj2.Id, Attendee_Name__c='Test Attendee');
        //insert attnd;     
        attendeeList.add(attnd);
        
        
        
        Attendees__c attnde = new Attendees__c(RecordTypeId=tExpertRt, Customer_Engagement__c=testCE1.Id, Team_Member__c=tExpert.Id, Agenda_Topic__c=testAgendaTopicObj2.Id);
        //insert attnde;
        attendeeList.add(attnde);
        
        insert attendeeList;
        
        
        Attendees__c newAtnde = new Attendees__c(RecordTypeId=tExpertRt, Customer_Engagement__c=testCE1.Id, Team_Member__c=tExpert.Id, Agenda_Topic__c=testAgendaTopicObj2.Id);
        attnd.Attendee_Name__c ='Attendee';
        
        Test.startTest();
        insert newAtnde;
        delete attnde;
        update attnd;
        delete newAtnd;
        Test.stopTest();
        
        List<Attendees__c> attObjstest = [Select Id From Attendees__c where Id = :newAtnd.Id and  Customer_Engagement__c =:testCE1.Id];
        system.assertequals(attObjstest.size(),0);
        
        List<Attendees__c> attndObjstest = [Select Id From Attendees__c where Id = :attnd.Id and  Customer_Engagement__c =:testCE1.Id];
        system.assertequals(attndObjstest.size(),1);
        
        List<Agenda__c> upagendaList=[select id, Travel_Id__c from Agenda__c where Presenter_Id__c = :attnd.Id ];
        system.assertequals(upagendaList.size(),1);
                
    }
}