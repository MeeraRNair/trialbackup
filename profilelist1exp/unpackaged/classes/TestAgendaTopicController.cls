@isTest
private class TestAgendaTopicController{
    
    public static testMethod void TestRelatedTopicTest() {
        String subject;
        // Date myDate =date.newinstance(2013, 12, 15);
        Date myDate = Date.Today().addDays(5);
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Customer_Engagement__c' and 
                                 name = 'Dell Solution Centers'];
        RecordType topicRec=[Select id,name,sObjectType from RecordType where name='Topic' and SobjectType='Agenda_Content__c' ];
        //TopicRecID=topicRec.Id;
        
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord1', LastName='ContactExcSafeWord1', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con; 
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id siteId=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='No',Offer_Transportation__c='No',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=siteId);
        insert testSite;                
        Customer_Engagement__c testCustEngObj = new Customer_Engagement__c(Name = 'Mytest CE',
                                                Requestor_Name__c = testUser.Id, 
                                               // Cost_Center__c = 'Prospecting', 
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = newaccount.Id,
                                                Primary_Contact__c = con.Id,
                                                NDA__c = 'No',
                                                Event_Status__c = 'Pending',
                                                Event_Type__c='Design Sessions',
                                                RecordTypeId = recordType.Id,
                                                GSL_start_Date__c=myDate,
                                                GSL_end_Date__c=myDate,
                                                Dell_Solution_Center_Site__c=testSite.Id);
        insert testCustEngObj;
      
        Agenda_Content__c testAgendaConSub = new Agenda_Content__c(Name = 'Dell Client Solutions');
        insert testAgendaConSub;                               
        Agenda_Content__c testAgendaConTopic1 = new Agenda_Content__c(Name = 'Client Products',
                                       Select_Subject__c = testAgendaConSub.Id,
                                       Apply_to_Site__c=testSite.Id,
                                       RecordTypeId =topicRec.Id,Active__c=true,
                                       Engagement_Type__c='DSC',Event_Type__c='Design Sessions',
                                       Duration_minutes__c=45,AE_Questions__c='Qualification',AE_Questions_Active__c=true,
                                    Analyst_Questions__c='Anayslts',Analyst_Questions_Active__c=true);
        insert testAgendaConTopic1;
        Agenda_Content__c testAgendaConTopic2 = new Agenda_Content__c(Name ='New Products',
                                    Select_Subject__c=testAgendaConSub.Id,RecordTypeId=topicRec.Id,
                                    Engagement_Type__c='DSC',Event_Type__c='Design Sessions',
                                    AE_Questions__c='Qualification',AE_Questions_Active__c=true,
                                    Analyst_Questions__c='Anayslts',Analyst_Questions_Active__c=true,
                                    Duration_minutes__c=45,Active__c=true,
                                    Apply_to_Site__c=testSite.Id);
        insert(testAgendaConTopic2); 
        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Topics__c = testAgendaConTopic2.Id, 
                                                                 Name = 'Blade Server Technology', 
                                                                 AE_Notes__c = 'AE Notes',Duration__c=45,
                                                                 Customer_Engagement__c = testCustEngObj.Id);
        insert testAgendaTopicObj;

        PageReference  pr = new PageReference('/apex/AnalystTopics?id='+testCustEngObj.Id+'&user=analyst');
        Test.setCurrentPage(pr);
        List<Agenda_Content__c> topicsDisplay=new List<Agenda_Content__c>();
        AgendaTopicController controller = new AgendaTopicController();
        subject='Dell Enterprise Solutions';
        AgendaTopicController.TopicDetails topicSelect= new AgendaTopicController.TopicDetails(testAgendaConTopic1);
        topicSelect.selected=true;
        controller.getTopicDisplayList();
        controller.getExistingTopicList();
        controller.getSubjectSelectList();
        controller.setSubject(subject);
        controller.subjSelected();
        controller.getDurationhrs();
        controller.getDisplayTopics();
        controller.getTopics();
        controller.getsubjectNewList();
        controller.gettopicSelection_List();
        Boolean noTopicsToDisplay=false;
        Boolean existFlag=false;
        controller.add();
        controller.gettopicSelection_List();
        controller.getDisplayAgenda();
        controller.save();
        controller.backToCustomer();
        String deleteTopicId = testAgendaTopicObj.Topics__c;
        PageReference  pageRefExpected=null;
        PageReference  pageRefActual=controller.deleteTopics();
        System.assertEquals(pageRefExpected,pageRefActual);
            
    }


    public static testMethod void TestRelatedTopicTest1() {
        String subject;
        // Date myDate =date.newinstance(2013, 12, 15);
        Date myDate = Date.today().addDays(5);
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Customer_Engagement__c' and 
                                 name = 'Dell Solution Centers'];
        RecordType topicRec=[Select id,name,sObjectType from RecordType where name='Topic' and SobjectType='Agenda_Content__c' ];
        
        Account newaccount= new Account(Name= 'Test Account');
        insert newaccount;    
        Contact con= new Contact(FirstName='ContactExcSafeWord2', LastName='ContactExcSafeWord2', AccountId=newaccount.Id,Phone='11111', Decision_Making_Role__c='Influencer', Job_Function__c='IT',Purchaser_Influence_over_Merged__c='Client-Desktops' );
        insert con; 
        User testUser=[SELECT id FROM USER WHERE Isactive=true limit 1];
        Id siteId=IdLookupUtils.getRecordTypeId('Sites','Event_Location__c',true);
        Event_Location__c testSite=new Event_Location__c(Name='testSite',Region__c='Americas',
                                                         Active__c=true,Engagement_Type__c='DSC',
                                                         Offer_Catering__c='No',Offer_Transportation__c='No',
                                                         Email__c='test_user@dell.com',
                                                         recordTypeid=siteId);
        insert testSite; 
        Agenda_Content__c testAgendaConSub = new Agenda_Content__c(Name = 'Dell Client Solutions');
        insert testAgendaConSub;               
        Agenda_Content__c testAgendaConTopic2 = new Agenda_Content__c(Name ='New Products',
                                    Select_Subject__c=testAgendaConSub.Id,RecordTypeId=topicRec.Id,
                                    Engagement_Type__c='DSC',Event_Type__c='Design Sessions',
                                    AE_Questions__c='Qualification',AE_Questions_Active__c=true,
                                    Analyst_Questions__c='Anayslts',Analyst_Questions_Active__c=true,
                                    Duration_minutes__c=45,Active__c=true,
                                    Apply_to_Site__c=testSite.Id);
        insert(testAgendaConTopic2);     
        Customer_Engagement__c testCustEngObj1 = new Customer_Engagement__c(Name = 'Mytest CE1',
                                                Requestor_Name__c = testUser.Id, 
                                               // Cost_Center__c = 'Prospecting', 
                                                Estimated_no_of_Customer_Attendees__c = 11,
                                                Primary_Account__c = newaccount.Id,
                                                Primary_Contact__c = con.Id,
                                                NDA__c = 'No',
                                                Event_Status__c = 'Pending',
                                                Event_Type__c='Design Sessions',
                                                RecordTypeId = recordType.Id,
                                                GSL_start_Date__c=myDate,
                                                GSL_end_Date__c=myDate+12,
                                                Confirmed_Date__c=myDate+2,
                                                Dell_Solution_Center_Site__c=testSite.Id);
        insert testCustEngObj1;        

        Agenda_Topic__c testAgendaTopicObj = new Agenda_Topic__c(Topics__c = testAgendaConTopic2.Id, 
                                                                 Name = 'Blade Server Technology', 
                                                                 AE_Notes__c = 'AE Notes',Duration__c=45,
                                                                 Customer_Engagement__c = testCustEngObj1.Id);
        insert testAgendaTopicObj;
       
        PageReference  pr = new PageReference('/apex/AnalystTopics?id='+testCustEngObj1.Id+'&user=analyst');
        Test.setCurrentPage(pr);
        AgendaTopicController controller = new AgendaTopicController();

    }

}