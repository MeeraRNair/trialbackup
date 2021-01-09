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
private class TestAfterupdateTopics {
    public static List<Agenda_Content__c> testAgendaConList = new List<Agenda_Content__c>();
    public static List<Topic_Experts__c> testTopicExpList = new List<Topic_Experts__c>();
    public static List<Attendees__c> testAttendeesList = new List<Attendees__c>();

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        User testUser2=[SELECT id FROM USER WHERE Isactive=true and Id != :testUser.Id limit 1];
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                           Active__c=true,Engagement_Type__c='DSC',
                                                           Offer_Catering__c='No',Offer_Transportation__c='No',
                                                           Email__c='test_user@dell.com',
                                                           recordTypeid=rtSite);
        insert testSite;
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE1;        
        
        Id subjectRt=IdLookupUtils.getRecordTypeId('Subject','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions', RecordTypeId =subjectRt);
        insert testAgendaConObj;
        
        Id topicRt=IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj2 = new Agenda_Content__c(Name = 'Test Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,Duration_minutes__c = 45,Engagement_Type__c = 'DSC',Apply_to_Site__c=testSite.Id,Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        //insert testAgendaConObj2;
        testAgendaConList.add(testAgendaConObj2);
        
        Agenda_Content__c testAgendaConObj1 = new Agenda_Content__c(Name = 'Blade Server Technology',Select_Subject__c = testAgendaConObj.Id,Duration_minutes__c = 45,Engagement_Type__c = 'DSC',Apply_to_Site__c=testSite.Id,Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        //insert testAgendaConObj1;
        testAgendaConList.add(testAgendaConObj1);
        
        Agenda_Content__c testAgendaConObjins = new Agenda_Content__c(Name = 'Blade Server Technology2',Select_Subject__c = testAgendaConObj.Id,Duration_minutes__c = 45,Engagement_Type__c = 'DSC',Event_Type__c = 'Design Sessions',Apply_to_Site__c=testSite.Id, RecordTypeId=topicRt);
        //insert testAgendaConObjins;
        testAgendaConList.add(testAgendaConObjins);
        insert testAgendaConList;
        
        Id atopicRt=IdLookupUtils.getRecordTypeId('Agenda Topic','Agenda_Topic__c',true);
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology', AE_Notes__c = 'AE Notes',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=atopicRt,Start_Date__c= system.today());
        insert testAgendaTopicObj;
        testAgendaTopicObj.Ending_Time__c='01:45PM';
        testAgendaTopicObj.Starting_Time__c='01:15PM';
        
        Agenda_Topic__c testAgendaTopicObj2 = new Agenda_Topic__c(Name = 'Test Blade Server Technology', AE_Notes__c = 'AE Notes',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=atopicRt, Start_Date__c= system.today());
        insert testAgendaTopicObj2;
      
        Id topicExpertRt=IdLookupUtils.getRecordTypeId('Internal Topic Expert','Topic_Experts__c',true);
        Topic_Experts__c tExpert= new Topic_Experts__c(RecordTypeId=topicExpertRt,Type__c='Presenter',Presenter_Architect_Name__c=testUser.Id);
        //insert tExpert;
        testTopicExpList.add(tExpert);
      
        Topic_Experts__c tExprt= new Topic_Experts__c(RecordTypeId=topicExpertRt,Type__c='Presenter',Presenter_Architect_Name__c=testUser2.Id);
        //insert tExprt;
        testTopicExpList.add(tExprt);
        insert testTopicExpList;
        
        Id tExpertRt=IdLookupUtils.getRecordTypeId('Topic Expert','Attendees__c',true);
        Attendees__c newAtnd = new Attendees__c(RecordTypeId=tExpertRt, Customer_Engagement__c=testCE1.Id, Team_Member__c=testTopicExpList[0].Id, Agenda_Topic__c=testAgendaTopicObj2.Id,Presenter_Confirmed__c=false);
        //insert newAtnd;
        testAttendeesList.add(newAtnd);
        
        Attendees__c newAtnde = new Attendees__c(RecordTypeId=tExpertRt, Customer_Engagement__c=testCE1.Id, Team_Member__c=testTopicExpList[1].Id, Agenda_Topic__c=testAgendaTopicObj2.Id,Presenter_Confirmed__c=true);
        //insert newAtnde;
        testAttendeesList.add(newAtnde);
        insert testAttendeesList;
        
        testAgendaTopicObj2.Starting_Time__c='12:45PM';
        testAgendaTopicObj2.Ending_Time__c='01:45PM';
        update testAgendaTopicObj2;
        
        testAgendaTopicObj2.Starting_Time__c='12:15PM';
        testAgendaTopicObj2.Ending_Time__c='01:15PM';
        
        Agenda_Topic__c testAgendaTopicObjts = new Agenda_Topic__c(Name = 'Blade Server Technology2',Start_Date__c= system.today(), AE_Notes__c = 'AE Notes',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=atopicRt);
        insert testAgendaTopicObjts;
        
        Id caterRt=IdLookupUtils.getRecordTypeId('Catering','Agenda_Topic__c',true);
        Agenda_Topic__c testAgendaTopicObj3 = new Agenda_Topic__c(Name = 'new catering',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=caterRt, Start_Date__c= system.today(),Starting_Time__c='01:45PM', Ending_Time__c='02:45PM');

        Agenda_Topic__c testCatering = new Agenda_Topic__c(Name = 'new catering test',
        Customer_Engagement__c = testCE1.Id, RecordTypeId=caterRt, Start_Date__c= system.today());      
        insert testCatering;
        testCatering.Starting_Time__c='12:45PM';
        testCatering.Ending_Time__c='01:45PM';
        
        Test.startTest();
        update testAgendaTopicObj;
        update testAgendaTopicObj2;
        delete testAgendaTopicObjts;
        update testCatering;
        insert testAgendaTopicObj3;
        //Test.stopTest();
        
        List<Agenda_Topic__c> agendaTopicObjtstest = [Select Id From Agenda_Topic__c where Name = 'Blade Server Technology2' and  Customer_Engagement__c =:testCE1.Id and RecordTypeId=:atopicRt];
        system.assertequals(agendaTopicObjtstest.size(),0);
        List<Agenda__c> agendaList=[select id, Topic_Id__c from Agenda__c where Topic_Id__c = :testAgendaTopicObjts.Id ];
        system.assertequals(agendaList.size(),0);
      
        Agenda_Topic__c agendaTopicObjTest = [Select Id,Ending_Time__c,Starting_Time__c From Agenda_Topic__c where Name = 'Blade Server Technology' and  Customer_Engagement__c =:testCE1.Id and RecordTypeId=:atopicRt LIMIT 1];
        system.assertequals(agendaTopicObjTest.Starting_Time__c,'01:15PM');
        system.assertequals(agendaTopicObjTest.Ending_Time__c,'01:45PM');
      
        List<Agenda__c> agList=[select id,Start_Time__c,End_Time__c, Topic_Id__c from Agenda__c where Topic_Id__c = :testAgendaTopicObj.Id and Start_Time__c != NULL];
        for(Agenda__c ag : agList){
            system.assertequals(ag.Start_Time__c,'01:15PM');
            system.assertequals(ag.End_Time__c,'01:45PM');
        }
      
        Agenda_Topic__c agendaTopicObj2Test = [Select Id,Ending_Time__c,Starting_Time__c From Agenda_Topic__c where Name = 'Test Blade Server Technology' and  Customer_Engagement__c =:testCE1.Id and RecordTypeId=:atopicRt LIMIT 1];
        system.assertequals(agendaTopicObj2Test.Starting_Time__c,'12:15PM');
        system.assertequals(agendaTopicObj2Test.Ending_Time__c,'01:15PM');
      
        Agenda_Topic__c cateringtest = [Select Id,Ending_Time__c,Starting_Time__c From Agenda_Topic__c where Name = 'new catering test' and  Customer_Engagement__c =:testCE1.Id and RecordTypeId=:caterRt LIMIT 1];
        system.assertequals(cateringtest.Starting_Time__c,'12:45PM');
        system.assertequals(cateringtest.Ending_Time__c,'01:45PM');
      
        Agenda_Topic__c agendaTopicObj3test = [Select Id,Ending_Time__c,Starting_Time__c From Agenda_Topic__c where Name = 'new catering' and  Customer_Engagement__c =:testCE1.Id and RecordTypeId=:caterRt LIMIT 1];
        system.assertnotequals(agendaTopicObj3test,null);
        
        //Test.startTest();
        List<Agenda__c> agdList=[select id, Topic_Id__c from Agenda__c where Topic_Id__c = :testAgendaTopicObj.Id];
        System.assert(agdList.size()!=NULL);
        for(Agenda__c ag:agdList){
            system.assertequals(ag.Topic_Id__c,testAgendaTopicObj.Id);
        }
        Test.stopTest();
}
}