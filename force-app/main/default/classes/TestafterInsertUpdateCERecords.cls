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
private class TestafterInsertUpdateCERecords {

    static testMethod void myUnitTest1() {
                // TO DO: implement unit test
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Account dupAccount= new Account(Name= 'Test Accounts');
        insert dupAccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        Contact dupCon= new Contact(FirstName='ContactExcSafeWord2', LastName='ContactExcSafeWord2', AccountId=dupAccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert dupCon;
        
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='Yes',Offer_Transportation__c='Yes',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=rtSite);
        insert testSite;

        Event_Location__c testSitetest=new Event_Location__c(Name='testSitetest',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='Yes',Offer_Transportation__c='Yes',
                                                         Email__c='test_usertest@dell.com',
                                                         recordTypeid=rtSite);
        insert testSitetest;

        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        //Customer_Engagement__c testCE2 = new Customer_Engagement__c(Name = 'Mytest CE2',Cost_Center__c='1234-1234-123456',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes',GSL_End_Date__c = system.Today(), Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
       // insert testCE2;
        //testCE2.Primary_Account__c=dupAccount.Id;
       // testCE2.Primary_Contact__c=dupCon.Id;
        
        Customer_Engagement__c testCE = new Customer_Engagement__c(Name = 'Mytest CE',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today()+7,Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes',confirmed_date__c=system.today());
       
               
        Id subjectRt=IdLookupUtils.getRecordTypeId('Subject','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions', 
                                                RecordTypeId =subjectRt);
        insert testAgendaConObj;
        Id topicRt=IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true);
        
        Agenda_Content__c testAgendaConObj2 = new Agenda_Content__c(Name = 'Blade Server Technology',
                                                Select_Subject__c = testAgendaConObj.Id,Duration_minutes__c = 45,
                                                Apply_to_Site__c=testSite.Id,Engagement_Type__c = 'DSC',
                                                Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj2;
        
        Id atopicRt=IdLookupUtils.getRecordTypeId('Agenda Topic','Agenda_Topic__c',true);//RecordTypeId=atopicRt,

        Test.startTest();
        insert testCE1;
        insert testCE;
        //insert testCEn;
        
        RecordType rt1 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Sites' ];
        Event_Location__c testSite1=new Event_Location__c();
        Event_Location__c testRoom1=new Event_Location__c();
        Event_Location__c testRoom2=new Event_Location__c();
    
        List<Event_Location__c> testSiteRoomTour=new List<Event_Location__c>();
        testSite1=new Event_Location__c(Name='testSite11',Region__c='Americas',Engagement_Type__c='EBC',Event__c='Briefing;vEBC;IT Conference Call;Tour',recordTypeid=rt1.id,Active__c=true);
        testSiteRoomTour.add(testSite1);
        
        /*create test rooms*/
        RecordType rt2 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Rooms' ];
        testRoom1=new Event_Location__c(Name='testRoom1',Room_Occupancy__c='15',Room_Type__c='Single',Select_Site__c=testSite1.Id,recordTypeid=rt2.id,Active__c=true);
        testSiteRoomTour.add(testRoom1);
        testRoom2=new Event_Location__c(Name='testRoom2',Room_Occupancy__c='20',Room_Type__c='Double',Select_Site__c=testSite1.Id,recordTypeid=rt2.id,Active__c=true);
        testSiteRoomTour.add(testRoom2);
        insert testSiteRoomTour;
       
        Map<String, Id> recordTypeIdMap;
        List<RecordType> recordtypelist=[select id,name,SobjectType  from RecordType where SobjectType='Calendar_Management__c' and (name='Primary Calendar RT' or name='Secondary Calendar RT')];
        recordTypeIdMap= new Map<String, Id>();
        for(RecordType r:recordtypelist){
            recordTypeIdMap.put(r.name,r.Id);
        }       
        List<Calendar_Management__c> testCalendarManagements=new List<Calendar_Management__c>();
        
        Calendar_Management__c testCalendarManagement1;
        Calendar_Management__c testCalendarManagement2;
        Calendar_Management__c testCalendarManagement3;
        Calendar_Management__c testCalendarManagement4;
        Calendar_Management__c testCalendarManagement5;
        testCalendarManagement1=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',Start_Date__c=System.today()+30,End_Date__c=System.today()+31,recordTypeId=recordTypeIdMap.get('Primary Calendar RT'),Date__c=System.today()+30,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);
        
        testCalendarManagement2=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',recordTypeId=recordTypeIdMap.get('Secondary Calendar RT'),Date__c=System.today()+31,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement2);
        
        testCalendarManagement3=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',Start_Date__c=System.today()+40,End_Date__c=System.today()+42,recordTypeId=recordTypeIdMap.get('Primary Calendar RT'),Date__c=System.today()+42,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement3);
        
        testCalendarManagement4=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',recordTypeId=recordTypeIdMap.get('Secondary Calendar RT'),Date__c=System.today()+41,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement4);
        
        testCalendarManagement5=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',recordTypeId=recordTypeIdMap.get('Secondary Calendar RT'),Date__c=System.today()+42,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement5);
        insert testCalendarManagements;     
        
        Customer_Engagement__c testCE3 = new Customer_Engagement__c(Name = 'Mytest CE3',Calendar_Management__c=testCalendarManagement1.Id,Cost_Center__c='1234-1234-123456',Event_Type__c='Briefing',Event_Status__c = 'Pending',Requestor_Name__c = testUser.Id,Trade_Compliant__c='Yes',GSL_End_Date__c = system.Today(), Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE3;
        
		//Test.startTest();
        testCE3.Calendar_Management__c=testCalendarManagement3.Id;
        update testCE3;
        
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology',
                                                Start_Date__c=System.today(),AE_Notes__c = 'AE Notes',Duration__c=45,
                                                Topics__c=testAgendaConObj2.Id,Customer_Engagement__c = testCE1.Id);
        insert testAgendaTopicObj;
        
        Agenda_Topic__c testAgendaTopicObj1 = new Agenda_Topic__c(Name = 'BST',
                                                Start_Date__c=System.today(),AE_Notes__c = 'AE Notes',Duration__c=45,
                                                Topics__c=testAgendaConObj2.Id,Customer_Engagement__c = testCE.Id);
        insert testAgendaTopicObj1;
        
       
               
        Transportation__c newtrans= new Transportation__c(Name='Test Transportation',Travel_Type__c='Flight Arrival', 
                                        Starting_Time__c='01.00AM', Ending_Time__c='03.00AM',
                                        Start_Date__c= system.today(), Customer_Engagement__c=testCE1.Id);
        insert newtrans;
		Test.stopTest();
       // update testCE2;
        testCE1.GSL_Start_Date__c=system.today()+3;
        testCE1.GSL_End_Date__c=system.today()+3;
        update testCE1;
        
        Agenda_topic__c agendaresult = [select name,start_date__c from Agenda_topic__c where Customer_Engagement__c = :testCE.Id];
        system.debug('at----'+agendaresult);
        Attending_Accounts__c result1 = [select Account__c, Primary_Contact__c, Name, Customer_Engagement__c From Attending_Accounts__c where Customer_Engagement__c = :testCE1.Id ORDER BY LastModifiedDate DESC  LIMIT 1];
       // Attending_Accounts__c result2 = [select Account__c, Primary_Contact__c, Name, Customer_Engagement__c From Attending_Accounts__c where Customer_Engagement__c = :testCE2.Id ORDER BY LastModifiedDate DESC  LIMIT 1];
        //Test.stopTest();

        //System.assertEquals(testAgendaTopicObjn.Start_date__c ,testCEn.GSL_Start_Date__c);
        System.assertEquals(agendaresult.start_date__c , testCE.Confirmed_date__c);
        System.assertEquals(result1.Account__c, newaccount.Id);
        System.assertEquals(result1.Primary_Contact__c, con.Id);
        System.assertEquals(result1.Customer_Engagement__c, testCE1.Id );
        //System.assertEquals(result2.Account__c, dupAccount.Id);
        //System.assertEquals(result2.Primary_Contact__c, dupCon.Id);
        //System.assertEquals(result2.Customer_Engagement__c, testCE2.Id );       
      }
      static testMethod void myUnitTest2() {
                // TO DO: implement unit test
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Account dupAccount= new Account(Name= 'Test Accounts');
        insert dupAccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con;
        Contact dupCon= new Contact(FirstName='ContactExcSafeWord2', LastName='ContactExcSafeWord2', AccountId=dupAccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert dupCon;
        
        Id rtSite=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='Yes',Offer_Transportation__c='Yes',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=rtSite);
        insert testSite;

        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        //Customer_Engagement__c testCE1 = new Customer_Engagement__c(Name = 'Mytest CE1',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),GSL_End_Date__c = system.Today(),Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        
        Customer_Engagement__c testCE2 = new Customer_Engagement__c(Name = 'Mytest CE2',Cost_Center__c='1234-1234-123456',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today(),Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes',GSL_End_Date__c = system.Today(), Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        
		Test.startTest();
		insert testCE2;
        Customer_Engagement__c testCEn = new Customer_Engagement__c(Name = 'Mytest CEn',Event_Type__c='Solution Briefings',Event_Status__c = 'Canceled',Cost_Center__c='1234-1234-123456',Dell_Solution_Center_Site__c=testSite.Id,Trade_Compliant__c='Yes' ,Requestor_Name__c = testUser.Id, GSL_Start_Date__c=system.Today()+1,GSL_End_Date__c = system.Today()+7,Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes',confirmed_date__c=null);        
        insert testCEn;

        testCE2.Primary_Account__c=dupAccount.Id;
        testCE2.Primary_Contact__c=dupCon.Id;
        Id subjectRt=IdLookupUtils.getRecordTypeId('Subject','Agenda_Content__c',true);
        Agenda_Content__c testAgendaConObj = new Agenda_Content__c(Name = 'Dell Enterprise Solutions', 
                                                RecordTypeId =subjectRt);
        insert testAgendaConObj;
        Id topicRt=IdLookupUtils.getRecordTypeId('Topic','Agenda_Content__c',true);
        
        Agenda_Content__c testAgendaConObj2 = new Agenda_Content__c(Name = 'Blade Server Technology',
                                                Select_Subject__c = testAgendaConObj.Id,Duration_minutes__c = 45,
                                                Apply_to_Site__c=testSite.Id,Engagement_Type__c = 'DSC',
                                                Event_Type__c = 'Design Sessions', RecordTypeId=topicRt);
        insert testAgendaConObj2;
        
        Agenda_Topic__c testAgendaTopicObjn = new Agenda_Topic__c(Name = 'BSTn',
                                                Start_Date__c=System.today()+1,AE_Notes__c = 'AE Notes',Duration__c=45,
                                                Topics__c=testAgendaConObj2.Id,Customer_Engagement__c = testCEn.Id);
        insert testAgendaTopicObjn;
                      
        Id atopicRt=IdLookupUtils.getRecordTypeId('Agenda Topic','Agenda_Topic__c',true);//RecordTypeId=atopicRt,

        //Test.startTest();
        //insert testCE1;

        RecordType rt1 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Sites' ];
        Event_Location__c testSite1=new Event_Location__c();
        Event_Location__c testRoom1=new Event_Location__c();
        Event_Location__c testRoom2=new Event_Location__c();
    
        List<Event_Location__c> testSiteRoomTour=new List<Event_Location__c>();
        testSite1=new Event_Location__c(Name='testSite11',Region__c='Americas',Engagement_Type__c='EBC',Event__c='Briefing;vEBC;IT Conference Call;Tour',recordTypeid=rt1.id,Active__c=true);
        testSiteRoomTour.add(testSite1);
        
        /*create test rooms*/
        RecordType rt2 = [SELECT id,sObjectType FROM RecordType WHERE sObjectType='Event_Location__c' and name='Rooms' ];
        testRoom1=new Event_Location__c(Name='testRoom1',Room_Occupancy__c='15',Room_Type__c='Single',Select_Site__c=testSite1.Id,recordTypeid=rt2.id,Active__c=true);
        testSiteRoomTour.add(testRoom1);
        testRoom2=new Event_Location__c(Name='testRoom2',Room_Occupancy__c='20',Room_Type__c='Double',Select_Site__c=testSite1.Id,recordTypeid=rt2.id,Active__c=true);
        testSiteRoomTour.add(testRoom2);
        insert testSiteRoomTour;
       
        Map<String, Id> recordTypeIdMap;
        List<RecordType> recordtypelist=[select id,name,SobjectType  from RecordType where SobjectType='Calendar_Management__c' and (name='Primary Calendar RT' or name='Secondary Calendar RT')];
        recordTypeIdMap= new Map<String, Id>();
        for(RecordType r:recordtypelist){
            recordTypeIdMap.put(r.name,r.Id);
        }       
        List<Calendar_Management__c> testCalendarManagements=new List<Calendar_Management__c>();
        
        Calendar_Management__c testCalendarManagement1;
        Calendar_Management__c testCalendarManagement2;
        Calendar_Management__c testCalendarManagement3;
        Calendar_Management__c testCalendarManagement4;
        Calendar_Management__c testCalendarManagement5;
        testCalendarManagement1=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',Start_Date__c=System.today()+30,End_Date__c=System.today()+31,recordTypeId=recordTypeIdMap.get('Primary Calendar RT'),Date__c=System.today()+30,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement1);
        
        testCalendarManagement2=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',recordTypeId=recordTypeIdMap.get('Secondary Calendar RT'),Date__c=System.today()+31,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement2);
        
        testCalendarManagement3=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',Start_Date__c=System.today()+40,End_Date__c=System.today()+42,recordTypeId=recordTypeIdMap.get('Primary Calendar RT'),Date__c=System.today()+42,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement3);
        
        testCalendarManagement4=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',recordTypeId=recordTypeIdMap.get('Secondary Calendar RT'),Date__c=System.today()+41,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement4);
        
        testCalendarManagement5=new Calendar_Management__c(Site__c=testSite1.Id,Event_Record_type__c='Briefing',recordTypeId=recordTypeIdMap.get('Secondary Calendar RT'),Date__c=System.today()+42,Status__c='Pending');
        testCalendarManagements.add(testCalendarManagement5);
        insert testCalendarManagements;     
        
        Customer_Engagement__c testCE3 = new Customer_Engagement__c(Name = 'Mytest CE3',Calendar_Management__c=testCalendarManagement1.Id,Cost_Center__c='1234-1234-123456',Event_Type__c='Briefing',Event_Status__c = 'Pending',Requestor_Name__c = testUser.Id,Trade_Compliant__c='Yes',GSL_End_Date__c = system.Today(), Estimated_no_of_Customer_Attendees__c = 11,Primary_Account__c=newaccount.Id,Primary_Contact__c=con.Id,NDA__c='Yes');
        insert testCE3;
        
        testCE3.Calendar_Management__c=testCalendarManagement3.Id;
        update testCE3;
        
        //Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Name = 'Blade Server Technology',
                    //                            Start_Date__c=System.today(),AE_Notes__c = 'AE Notes',Duration__c=45,
                        //                        Topics__c=testAgendaConObj2.Id,Customer_Engagement__c = testCE1.Id);
        //insert testAgendaTopicObj;
        //Transportation__c newtrans= new Transportation__c(Name='Test Transportation',Travel_Type__c='Flight Arrival', 
               //                         Starting_Time__c='01.00AM', Ending_Time__c='03.00AM',
                //                        Start_Date__c= system.today(), Customer_Engagement__c=testCE1.Id);
       // insert newtrans;
        update testCE2;
       // testCE1.GSL_Start_Date__c=system.today()+3;
       //testCE1.GSL_End_Date__c=system.today()+3;
       // update testCE1;
                
        //Attending_Accounts__c result1 = [select Account__c, Primary_Contact__c, Name, Customer_Engagement__c From Attending_Accounts__c where Customer_Engagement__c = :testCE1.Id ORDER BY LastModifiedDate DESC  LIMIT 1];
        Attending_Accounts__c result2 = [select Account__c, Primary_Contact__c, Name, Customer_Engagement__c From Attending_Accounts__c where Customer_Engagement__c = :testCE2.Id ORDER BY LastModifiedDate DESC  LIMIT 1];
        Test.stopTest();
        System.assertEquals(testAgendaTopicObjn.Start_date__c ,testCEn.GSL_Start_Date__c);
        //System.assertEquals(result1.Account__c, newaccount.Id);
        //System.assertEquals(result1.Primary_Contact__c, con.Id);
        //System.assertEquals(result1.Customer_Engagement__c, testCE1.Id );
        System.assertEquals(result2.Account__c, dupAccount.Id);
        System.assertEquals(result2.Primary_Contact__c, dupCon.Id);
        System.assertEquals(result2.Customer_Engagement__c, testCE2.Id );       
      }
      
}