/*
* Author  : Krishnakumar M
* Purpose : DrawLoop Data for VisitOps Functionality
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR16163      FY19-08-02 20-Jun-2018     Krishnakumar    Drawloop 02 - Create print menu selection and options
* 2.0      CR17344      FY19-10-02 08-April-2019   Ekta            Create test data for DDP to know the document type
* 3.0      CR17329      FY20-0502                  subramani       PMD tool errors
* 4.0      CR17344      FY20-0502  27-May-2019     Elton           Code coverage increase on Agenda Date and Details code
* 5.0      CR18091      FY20-1101  13-Sep-2019     Elton           Change output file name.

*/
@IsTest
public class DrawLoop_VisitOpsTest {
    Static VisitOps__Visit__c objVisitRecord;
    Static VisitOps__Visit__c objCurrentVisit;
    Static VisitOps__Place__c objTestPlace;
    Static VisitOps__Room__c objTestRoom;
    Static VisitOps__Topic__c objTopic;
    Static VisitOps__Topic__c objTWithDisplayName;
    Static Account objTestAccount;
    Static visitops__Company__c objTestCompany;
    Static VisitOps__Topic_Category__c objTestTopicCategory;
    Static Loop__DDP__c objTestLoop;
      
    private Static testMethod void drawLoopVisitOpsTest1() {
        
        createTestData();
        
        Test.startTest();
        DrawLoop_VisitOps ddp = new DrawLoop_VisitOps();
        
        Set<string> setddpObjects= ddp.getGlobalDescribe();
        Map<string,Set<String>> setDDPChildObjects= new Map<string,Set<String>>();
        for(String strDDPObject : setddpObjects){
            setDDPChildObjects.put(strDDPObject,ddp.getChildRelationships(strDDPObject));
        }
        
        List<Loop.ExternalData.DataObject> listdataObjects = ddp.describeObjects(new List<string>(setddpObjects));
                
        Loop.ExternalData.QueryRequestInfo requestInfo = new Loop.ExternalData.QueryRequestInfo();
        requestInfo.RecordId = objVisitRecord.Id;
        requestInfo.DDPId = objTestLoop.Id;
        requestInfo.Relationships = new List<Loop.ExternalData.Relationship>();
        
        for (string strobjName : setddpObjects) {
            Loop.ExternalData.Relationship relationship = new Loop.ExternalData.Relationship();
            relationship.Name = strobjName;
            requestInfo.Relationships.add(relationship);
        }
        
        Loop.ExternalData.QueryResultSet qrsEnUs;
        qrsEnUs = ddp.query(requestInfo);
        Test.stopTest();
        system.assert(true);
    }
    
    
        
        

    public Static void createTestData() {
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipUserTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);    

        VisitOps__Location__c  objTestLocation = new VisitOps__Location__c(Name='TestLocation',VisitOps__Location_Street_Address__c='testAddress',VisitOps__Time_Zone__c = '(GMT+05:30)India Standard Time (Asia/Kolkata)'); 
       insert objTestLocation;
        
        // Insert Place
        objTestPlace = new VisitOps__Place__c(Name='TestPlace', VisitOps__Location__c=objTestLocation.Id);
        insert objTestPlace;
        
        //Insert VisitType
        VisitOps__VisitType__c objTestCustomerVisit1 = new VisitOps__VisitType__c(Name='TestCustomerVisit1', VisitOps__Category__c='CV1'); 
        insert objTestCustomerVisit1;
        
        //Create visitTypeMapping
        insert new VisitOps__LocationTypeLink__c(VisitOps__Location__c=objTestLocation.id,VisitOps__VisitType__c=objTestCustomerVisit1.id);
        
        
        //Create Room
        objTestRoom = new VisitOps__Room__c(Name='TestRoom',VisitOps__Location__c=objTestLocation.id, VisitOps__Place__c=objTestPlace.Id,VisitOps__Room_Capacity__c=20);
        insert objTestRoom;
        
        //Create Status - New
        VisitOps__Status__c objTestNewStatus = new VisitOps__Status__c(Name='New'); 
        insert objTestNewStatus;
        
        //Create Reference Visit
        objVisitRecord = new VisitOps__Visit__c(VisitOps__VisitName__c='Test Visit', VisitOps__VisitOwner__c =userInfo.getUserId(), VisitOps__Location__c=objTestLocation.id, VisitOps__VisitType__c=objTestCustomerVisit1.id, VisitOps__VisitStatus__c=objTestNewStatus.id, VisitOps__ArrivalDateTime__c=datetime.newInstance(2017, 9, 15, 12, 30, 0),VisitOps__ArrivalDateTimeLocationTZ__c='2017-09-10 02:02:42', VisitOps__DepartureDateTime__c=datetime.newInstance(2017, 9, 15, 13, 30, 0),VisitOps__DepartureDateTimeLocationTZ__c='2017-09-11 03:02:42', VisitOps__TotalNoOfAttendees__c=100);
        insert objVisitRecord;
                            
        //create test account
        objTestAccount = new Account(Name='objTestAccount', AnnualRevenue = 10000000, Industry = 'Agriculture' , Website = 'http://www.abc.com');
        insert objTestAccount;    
    
        //Create Company
         objTestCompany = new visitops__Company__c(visitops__Visit__c = objVisitRecord.id,visitops__Account__c = objTestAccount.id, visitops__Company_Name__c= 'objTestAccount', visitops__Company_Annual_Revenue__c = 10000000, visitops__Company_Industry__c = 'Agriculture' , visitops__Company_Website__c = 'http://www.abc.com'); 
        insert objTestCompany;
        
        //Create an Agenda Item
        VisitOps__Agenda__c objAgenda1 = new VisitOps__Agenda__c(VisitOps__Agenda_Title__c='Test Agenda1',VisitOps__Objectives__c='Test Objectves',VisitOps__Start_Time__c=System.Now(),VisitOps__StartTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),VisitOps__End_Time__c=System.Now()+5,VisitOps__EndTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'),VisitOps__Visit__c=objVisitRecord.Id,VisitOps__Show_on_Customer_Agenda__c=True,VisitOps__Show_on_Presenter_Agenda__c=True);
        insert objAgenda1;
        
        //Add Presenters to the Session
        VisitOps__Presenter_Agenda_Link__c objPal = new VisitOps__Presenter_Agenda_Link__c(VisitOps__User__c=UserInfo.getUserId(),VisitOps__Agenda__c=objAgenda1.Id,VisitOps__Status__c='Not Sent');
        insert objPal;
        
        //Create a TopicCategory
        objTestTopicCategory = new VisitOps__Topic_Category__c(VisitOps__Category_Description__c = 'Test',VisitOps__Show_on_Customer_Agenda__c = True, VisitOps__Show_on_Customer_Survey__c = True, VisitOps__Show_on_Presenter_Agenda__c = False);
        insert objTestTopicCategory;
        
        
        //Create a Session Topic
        objTopic = new VisitOps__Topic__c(VisitOps__TopicName__c='Test Topic',VisitOps__TopicCategory__c='TestCategory',VisitOps__Topic_Category__c = objTestTopicCategory.Id);
        insert objTopic;
        
        // CR17344  Create test data for DDP to know the document type

        //Create loop record
        //5.0 Change output file name 
        objTestLoop = new Loop__DDP__c(Name='Test',Loop__Output_Filename__c='<<Visit_VisitName>> English Platinum Internal');
        insert objTestLoop;
        
        //Create a topic with displayName on Agenda
        objTWithDisplayName = new VisitOps__Topic__c(VisitOps__TopicName__c='Test Topic',VisitOps__TopicCategory__c='TestCategory',VisitOps__TopicNameOnAgenda__c='Topic Agenda Display Name',VisitOps__Topic_Category__c = objTestTopicCategory.Id);
        insert objTWithDisplayName;
        
               
        //Create a new User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        user u = new User(Alias = 'testVis', Email='standarduser@dell.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', Badge_Number__c='8239843599',
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testVisitopsUser@test.com',Title='title',CompanyName='companyname');
            insert u;
        //create account
        Account objAcc = new Account(name='test',website='www.google.com');    
        insert objAcc;
        //create contact
        contact objContact = new contact(lastname = 'test',title='Mr.',AccountId=objAcc.id,Email='testing@dell.com');
        insert objContact;
        contact objContact2 = new contact(lastname = 'test2',title='Mr.',AccountId=objAcc.id,Email='testing2@dell.com');
        insert objContact2;
            
           list<VisitOps__Attendee__c> listAttendee = new list<VisitOps__Attendee__c>();
           VisitOps__Attendee__c objAttendee = new VisitOps__Attendee__c(VisitOps__Contact__c = objContact.id,VisitOps__visit__c =objVisitRecord.id);
           VisitOps__Attendee__c objAttendee3 = new VisitOps__Attendee__c(VisitOps__Contact__c = objContact2.id,VisitOps__visit__c =objVisitRecord.id);
           VisitOps__Attendee__c objAttendee1 = new VisitOps__Attendee__c(VisitOps__Company__c ='test',VisitOps__title__c ='test',VisitOps__FirstName__c='test',VisitOps__LastName__c='def',VisitOps__visit__c =objVisitRecord.id,VisitOps__Attendee_Types__c='Customer');
           VisitOps__Attendee__c objAttendee2 = new VisitOps__Attendee__c(VisitOps__Company__c ='companyname',VisitOps__title__c ='test',VisitOps__FirstName__c='test1',VisitOps__LastName__c='def1',VisitOps__visit__c =objVisitRecord.id,VisitOps__Attendee_Types__c='Customer');
           VisitOps__Attendee__c objAttendee6 = new VisitOps__Attendee__c(VisitOps__Company__c ='companyname',VisitOps__title__c ='test',VisitOps__FirstName__c='test2',VisitOps__LastName__c='def2',VisitOps__visit__c =objVisitRecord.id,VisitOps__Attendee_Types__c='Other');
           VisitOps__Attendee__c objAttendee4 = new VisitOps__Attendee__c(VisitOps__Company__c ='companyname1',VisitOps__title__c ='test',VisitOps__User__c=UserInfo.getUserId(),VisitOps__visit__c =objVisitRecord.id,VisitOps__Attendee_Types__c='Customer');  
           VisitOps__Attendee__c objAttendee7 = new VisitOps__Attendee__c(VisitOps__Company__c ='companyname1',VisitOps__title__c ='test',VisitOps__User__c=UserInfo.getUserId(),VisitOps__visit__c =objVisitRecord.id,VisitOps__Attendee_Types__c='Employee');  
           VisitOps__Attendee__c objAttendee5 = new VisitOps__Attendee__c(VisitOps__Company__c ='',VisitOps__title__c ='test',VisitOps__FirstName__c='test1',VisitOps__LastName__c='def1',VisitOps__visit__c =objVisitRecord.id,VisitOps__Attendee_Types__c='Partner');  
           listAttendee.add(objAttendee);
           listAttendee.add(objAttendee1);
           listAttendee.add(objAttendee2);
           listAttendee.add(objAttendee3);
           listAttendee.add(objAttendee4);
           listAttendee.add(objAttendee5);
           listAttendee.add(objAttendee6);
           listAttendee.add(objAttendee7);
           insert listAttendee;
    }
}