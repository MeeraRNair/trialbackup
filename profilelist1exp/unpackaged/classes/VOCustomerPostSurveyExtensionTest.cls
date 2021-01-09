@isTest(seeAllData=false)
private class VOCustomerPostSurveyExtensionTest{
    
    //Variable declaration
    static ApexPages.StandardController standardControllerObject;
    static voCustomerPostSurveyExtension controllerObject;
    static visitops__Visit__c referenceVisit;
    
    static visitops__Room__c testRoom;
    static visitops__Location__c testLocation;
    static visitops__VisitType__c testCustomerVisit1;
    static visitops__Status__c testNewStatus;
    
    static Account testAccount;
    static visitops__company__c testCompany;
    static Contact testContact;
    static visitops__Visit__c currentVisit;
    static sobject testOpportunity;
    static sobject testVisitOppLink;
    static visitops__Attendee__c testContactAttendee,testUserAttendee;
    static visitops__Survey__c testSurvey,testSurvey1;
    static visitops__Agenda__c agenda1,parkedAgenda;
    static visitops__Presenter_Agenda_Link__c pal;
    
    
    static final Boolean isOpportunityAvailable;
    static final Boolean isOpportunityAccessible;
    
    
    static{
        try{
            isOpportunityAccessible=true;
            isOpportunityAvailable=true;
        }catch(Exception ex){
            system.debug('Exception inside static block while determining isOpportunityAvailable and isOpportunityAccessible--'+ex.getMessage());
        }
    }
    
    
    //Create test data for testmethods
    static void createTestData() {
            TriggerExecutionController.setSkipAccountTriggers(true);
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            TriggerExecutionController.setSkipUserTriggers(true);
        //Insert Location
        testLocation = new visitops__Location__c(Name='TestLocation',visitops__Location_Street_Address__c='testAddress', visitops__Time_Zone__c = '(GMT+00:00) Greenwich Mean Time (GMT)'); 
        insert testLocation;
        
        //Insert VisitType
        testCustomerVisit1 = new visitops__VisitType__c(Name='TestCustomerVisit1', visitops__Category__c='CV1'); 
        insert testCustomerVisit1;
        
        //Create visitTypeMapping
        insert new visitops__LocationTypeLink__c(visitops__Location__c=testLocation.id,visitops__VisitType__c=testCustomerVisit1.id,visitops__Hide_Presenters_on_Survey__c=true);
        
        visitops__Place__c testPlace = new visitops__Place__c(Name='TestPlace', visitops__Location__c=testLocation.Id);
        insert testPlace;
        
        //Create Room
        testRoom = new visitops__Room__c(Name='TestRoom',visitops__Location__c=testLocation.id,VisitOps__Place__c=testPlace.id, VisitOps__Room_Capacity__c=10);
        insert testRoom;
        
        //Create Status - New
        testNewStatus = new visitops__Status__c(Name='New'); 
        insert testNewStatus;
        
        referenceVisit=new visitops__Visit__c(visitops__VisitName__c='ReferenceVisit - DoNotDelete', visitops__VisitOwner__c =userInfo.getUserId(), visitops__Location__c=testLocation.id, visitops__VisitType__c=testCustomerVisit1.id, visitops__VisitStatus__c=testNewStatus.id, visitops__VisitStatus__r=testNewStatus, visitops__ArrivalDateTime__c=system.now(), visitops__DepartureDateTime__c=system.now()+5, visitops__TotalNoOfAttendees__c=100,
                                              visitops__ArrivalDateTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),visitops__DepartureDateTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'));
        insert(referenceVisit);
        
    }
    
    // Preparing data for Positive Testing
    static void createTestVisitAndRelatedData() {
        try{
            system.debug('inside createTestVisitAndRelatedData');
            TriggerExecutionController.setSkipAccountTriggers(true);
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            TriggerExecutionController.setSkipUserTriggers(true);
            TriggerExecutionController.setSkipAllTriggers(true);
            
            //Create New Account
            testAccount = new Account(Name='testAccount');
            insert testAccount;
            
            //Create New Visit
            currentVisit = new visitops__Visit__c(visitops__VisitName__c='testVisit', visitops__VisitOwner__c =userInfo.getUserId(), visitops__Location__c=testLocation.id, visitops__VisitType__c=testCustomerVisit1.id, visitops__VisitStatus__c=testNewStatus.id, visitops__VisitStatus__r=testNewStatus, visitops__ArrivalDateTime__c=system.now(), visitops__DepartureDateTime__c=system.now()+5, visitops__TotalNoOfAttendees__c=100, visitops__Room__c=testRoom.id,
                                                  visitops__ArrivalDateTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),visitops__DepartureDateTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'));
            insert currentVisit;
            
            //Create Company
            testCompany = new visitops__company__c(visitops__Visit__c = currentVisit.id, visitops__Account__c = testAccount.id); 
            insert testCompany;
            
            //Create Contact
            testContact = new Contact(LastName = 'testContact', Email = 'testContact@abc.com', AccountId = testAccount.id);
            insert testContact;
            
            //Create Attendee - Contact type
            testContactAttendee = new visitops__Attendee__c(visitops__Visit__c = currentVisit.id, visitops__Contact__c = testContact.id);
            insert testContactAttendee;
            
            //Create Attendee - User type
            testUserAttendee = new visitops__Attendee__c(visitops__Visit__c = currentVisit.id, visitops__User__c = userInfo.getUserId());
            insert testUserAttendee;
            
            //Create Survey for Negative Testing
            testSurvey1= new visitops__Survey__c( visitops__Post_Survey_Status__c=false,VisitOps__Satisfaction_Rating__c=1, VisitOps__Likely_To_Recommend_Post__c=1,Understood_Your_Objectives_Before__c='Neutral',Met_Your_Objectives_During__c='Neutral',Digital_Transformation_Journey__c='Other',Confidence_Before_Engagement__c='Neutral',Confidence_After_Engagement__c='Neutral',Cloud_Native_Applications__c=true,visitops__Things_to_Accomplish__c='Things to accomplish', visitops__Likely_To_Recommend__c=8, visitops__Visit__c=currentVisit.Id, visitops__Attendee__c=testContactAttendee.Id);
            insert testSurvey1;
            
            //Create an Agenda Item
            agenda1 = new visitops__Agenda__c(visitops__Agenda_Title__c='Test Agenda1',visitops__Objectives__c='Test Objectves',visitops__Start_Time__c=System.Now(),visitops__End_Time__c=System.Now()+5,visitops__StartTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),visitops__EndTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'),visitops__Visit__c=currentVisit.Id,visitops__Room__c=testRoom.Id);
            insert agenda1;
            
            //Create a parked Agenda Item
            parkedAgenda = new visitops__Agenda__c(visitops__Agenda_Title__c='Test Agenda1', visitops__IsParked__c=true, visitops__Objectives__c='Test Objectves',visitops__Start_Time__c=System.Now(),visitops__End_Time__c=System.Now()+20,visitops__StartTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),visitops__EndTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'),visitops__Visit__c=currentVisit.Id);
            insert parkedAgenda;
            
            //Add Presenters to the Session
            pal = new visitops__Presenter_Agenda_Link__c(visitops__User__c=UserInfo.getUserId(),visitops__Agenda__c=agenda1.Id,visitops__Status__c='Accepted');
            insert pal;
            
            //Create New Opportunity if Org has Opportunity
            
            if(isOpportunityAvailable && isOpportunityAccessible){
                testOpportunity = Schema.getGlobalDescribe().get('Opportunity').newSObject();
                testOpportunity.put('Name','testOpportunity');
                testOpportunity.put('AccountId',testAccount.id);
                testOpportunity.put('CloseDate',system.today()+2);
                testOpportunity.put('StageName','Plan - 1%');
                testOpportunity.put('ForecastCategoryName','Omitted');
                testOpportunity.put('Forecast_Category_Override__c','Omitted');
                testOpportunity.put('Probability',0.01);
                testOpportunity.put('EMC_Opportunity_Number__c','12312');
                
                insert testOpportunity;
                
            }
            testVisitOppLink = new visitops__VisitBundle__c(visitops__Visit__c = currentVisit.id);
            testVisitOppLink.put('visitops__Opportunity__c', testOpportunity.id); 
            insert testVisitOppLink;
            TriggerExecutionController.setSkipAllTriggers(false);
            
        }catch(Exception ex){
            system.debug('Exception inside createTestVisitAndRelatedData'+ex.getMessage());
            throw ex;
        }
    }
    
    // Preparing Data for Negative Testing
    static void createTestVisitAndRelatedNegativeData() {
        try{
            system.debug('inside createTestVisitAndRelatedData');
            TriggerExecutionController.setSkipAccountTriggers(true);
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            TriggerExecutionController.setSkipUserTriggers(true);
            //Create New Account
            testAccount = new Account(Name='testAccount');
            insert testAccount;
            
            //Create New Visit
            currentVisit = new visitops__Visit__c(visitops__VisitName__c='testVisit', visitops__VisitOwner__c =userInfo.getUserId(), visitops__Location__c=testLocation.id, visitops__VisitType__c=testCustomerVisit1.id, visitops__VisitStatus__c=testNewStatus.id, visitops__VisitStatus__r=testNewStatus, visitops__ArrivalDateTime__c=system.now(), visitops__DepartureDateTime__c=system.now()+5, visitops__TotalNoOfAttendees__c=100, visitops__Room__c=testRoom.id,
                                                  visitops__ArrivalDateTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),visitops__DepartureDateTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'));
            insert currentVisit;
            
            //Create Company
            testCompany = new visitops__company__c(visitops__Visit__c = currentVisit.id, visitops__Account__c = testAccount.id); 
            insert testCompany;
            
            //Create Contact
            testContact = new Contact(LastName = 'testContact', Email = 'testContact@abc.com', AccountId = testAccount.id);
            insert testContact;
            
            //Create Attendee - Contact type
            testContactAttendee = new visitops__Attendee__c(visitops__Visit__c = currentVisit.id, visitops__Contact__c = testContact.id);
            insert testContactAttendee;
            
            //Create Attendee - User type
            testUserAttendee = new visitops__Attendee__c(visitops__Visit__c = currentVisit.id, visitops__User__c = userInfo.getUserId());
            insert testUserAttendee;
            
            //Create Survey for Negative Testing
            testSurvey1= new visitops__Survey__c( visitops__Post_Survey_Status__c=false,VisitOps__Satisfaction_Rating__c=1, VisitOps__Likely_To_Recommend_Post__c=1,Understood_Your_Objectives_Before__c='Neutral',Met_Your_Objectives_During__c='Neutral',Digital_Transformation_Journey__c='Other',Confidence_Before_Engagement__c='Neutral',Confidence_After_Engagement__c='Neutral',Cloud_Native_Applications__c=true,visitops__Things_to_Accomplish__c='Things to accomplish', visitops__Likely_To_Recommend__c=8, visitops__Visit__c=currentVisit.Id, visitops__Attendee__c=testContactAttendee.Id);
            //insert testSurvey1;
            
            //Create an Agenda Item
            agenda1 = new visitops__Agenda__c(visitops__Agenda_Title__c='Test Agenda1',visitops__Objectives__c='Test Objectves',visitops__Start_Time__c=System.Now(),visitops__End_Time__c=System.Now()+5,visitops__StartTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),visitops__EndTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'),visitops__Visit__c=currentVisit.Id,visitops__Show_on_Customer_Survey__c=true);
            insert agenda1;
            
            //Create a parked Agenda Item
            parkedAgenda = new visitops__Agenda__c(visitops__Agenda_Title__c='Test Agenda1', visitops__IsParked__c=true, visitops__Objectives__c='Test Objectves',visitops__Start_Time__c=System.Now(),visitops__End_Time__c=System.Now()+20,visitops__StartTimeLocationTZ__c=system.now().format('yyyy-MM-dd HH:mm:ss'),visitops__EndTimeLocationTZ__c=system.now().addDays(5).format('yyyy-MM-dd HH:mm:ss'),visitops__Visit__c=currentVisit.Id);
            insert parkedAgenda;
            
            //Add Presenters to the Session
            pal = new visitops__Presenter_Agenda_Link__c(visitops__User__c=UserInfo.getUserId(),visitops__Agenda__c=agenda1.Id,visitops__Status__c='Accepted');
            insert pal;
            
            //Create New Opportunity if Org has Opportunity
            if(isOpportunityAvailable && isOpportunityAccessible){
                testOpportunity = Schema.getGlobalDescribe().get('Opportunity').newSObject();
                testOpportunity.put('Name','testOpportunity');
                testOpportunity.put('AccountId',testAccount.id);
                testOpportunity.put('CloseDate',system.today()+2);
                testOpportunity.put('StageName','Plan - 1%');
                testOpportunity.put('ForecastCategoryName','Omitted');
                testOpportunity.put('Forecast_Category_Override__c','Omitted');
                testOpportunity.put('Probability',0.01);
            }
            testVisitOppLink = new visitops__VisitBundle__c(visitops__Visit__c = currentVisit.id);
            testVisitOppLink.put('visitops__Opportunity__c', testOpportunity.get('Id')); 
            insert testVisitOppLink;
            
        }catch(Exception ex){
            system.debug('Exception inside createTestVisitAndRelatedData'+ex.getMessage());
            throw ex;
        }
    }
    
    // Preparing data for Positive Testing
    static void createTestDocumentData() {
        
        Document document = new Document();
        document.Name='testDoc';
        document.AuthorId = UserInfo.getUserId();
        document.FolderId = UserInfo.getUserId();
        document.DeveloperName = 'Survey_Logo';
        insert document;
        
        Document document1 = new Document();
        document1.Name='testDoc1';
        document1.AuthorId = UserInfo.getUserId();
        document1.FolderId = UserInfo.getUserId();
        document1.DeveloperName = 'Survey_Footer';
        insert document1;
        
        
    }
    
    static testMethod void testCustomPostSurvey(){
        
        try{
            
            system.debug('inside testConstructor');
            
            //Create Test Data           
            createTestData();
            createTestVisitAndRelatedData();
            createTestDocumentData();
            Test.startTest();
            //Set Current Page
            PageReference pageRef = Page.voCustomerPostSurvey;
            Test.setCurrentPage(pageRef);
            
            //Set Parameters for the page
            ApexPages.currentPage().getParameters().put('visitId',currentVisit.Id);
            ApexPages.currentPage().getParameters().put('attendeeId',testContactAttendee.Id);
            
            //New Survey Case
            standardControllerObject = new ApexPages.StandardController(new visitops__Survey__c());
            controllerObject = new voCustomerPostSurveyExtension(standardControllerObject);
            controllerObject.constructorCode();
            controllerObject.getRadioOpts();
            controllerObject.getPercentRadioOpts();
            controllerObject.getRadio();
            controllerObject.getRadioOptions();
            controllerObject.getEngProgOptsNolabel();
            controllerObject.getRadioOpts1();
            controllerObject.getRadioOpts2();
            controllerObject.getsatRadioOpts();
            
            controllerObject.agendaPresenterWrapperList=new List<voCustomerPostSurveyExtension.AgendaPresenterWrapper>();
            visitops__Agenda_Survey__c agendaSurveyRecord = new visitops__Agenda_Survey__c(visitops__Agenda__c=agenda1.Id);
            List<visitops__Presenter_Survey__c> psList;
            if(agenda1.visitops__Presenter_Agenda_Links__r!=null && agenda1.visitops__Presenter_Agenda_Links__r.size()>0) {
                psList = new List<visitops__Presenter_Survey__c>();
                for(visitops__Presenter_Agenda_Link__c eachPresenterLink : agenda1.visitops__Presenter_Agenda_Links__r) {
                    visitops__Presenter_Survey__c tempPresenterSurveyRecord = new visitops__Presenter_Survey__c(visitops__Presenter_Agenda_Link__r=eachPresenterLink,visitops__Presenter_Agenda_Link__c=eachPresenterLink.Id);
                    psList.add(tempPresenterSurveyRecord);
                }
            }
            voCustomerPostSurveyExtension.AgendaPresenterWrapper apWrapper=new voCustomerPostSurveyExtension.AgendaPresenterWrapper(agendaSurveyRecord,psList);
            controllerObject.agendaPresenterWrapperList.add(apWrapper);
            controllerObject.surveyRecord= new visitops__Survey__c();
            controllerObject.SubmitSurvey();
            
            controllerObject.getDocumentLogoUrl();
            controllerObject.getDocumentFooterUrl();
            
            system.assertEquals(null,null);
            Test.stopTest();
            
        }catch(Exception ex){
            system.debug('Exception inside testConstructor'+ex.getMessage());
            throw ex;
        }
        
    }
    
    // Negative Testing for Controller
    static testMethod void testCustomPostSurveyNegative(){
        
        try{
            
            system.debug('inside testConstructor');
            
            //Create Test Data           
            createTestData();
            createTestVisitAndRelatedNegativeData();
            Test.startTest();
            //Set Current Page
            PageReference pageRef = Page.voCustomerPostSurvey;
            Test.setCurrentPage(pageRef);
            
            //Test for new survey
            ApexPages.currentPage().getParameters().put('visitId',currentVisit.id);
            ApexPages.currentPage().getParameters().put('attendeeId',testContactAttendee.Id);
            standardControllerObject = new ApexPages.StandardController(testsurvey1);
            controllerObject = new voCustomerPostSurveyExtension(standardControllerObject);
            controllerObject.constructorCode();
            controllerObject.surveyRecord=testsurvey1;
            controllerObject.SubmitSurvey();
            
            //Test without visitid
            ApexPages.currentPage().getParameters().put('visitId','');
            standardControllerObject = new ApexPages.StandardController(new visitops__Survey__c());
            controllerObject = new voCustomerPostSurveyExtension(standardControllerObject);
            controllerObject.constructorCode();
            
            //Test without attendeeid
            ApexPages.currentPage().getParameters().put('visitId',currentVisit.id);
            ApexPages.currentPage().getParameters().put('attendeeId','');
            standardControllerObject = new ApexPages.StandardController(new visitops__Survey__c());
            controllerObject = new voCustomerPostSurveyExtension(standardControllerObject);
            controllerObject.constructorCode();
            
            //Test for No Visits Exception
            ApexPages.currentPage().getParameters().put('visitId',testContactAttendee.id);
            ApexPages.currentPage().getParameters().put('attendeeId',testContactAttendee.Id);
            standardControllerObject = new ApexPages.StandardController(new visitops__Survey__c());
            controllerObject = new voCustomerPostSurveyExtension(standardControllerObject);
            controllerObject.constructorCode();
            
            //Test for No Attendees Exception
            ApexPages.currentPage().getParameters().put('visitId',currentVisit.id);
            ApexPages.currentPage().getParameters().put('attendeeId',currentVisit.Id);
            standardControllerObject = new ApexPages.StandardController(new visitops__Survey__c());
            controllerObject = new voCustomerPostSurveyExtension(standardControllerObject);
            controllerObject.constructorCode();
            
            system.assertEquals(null,null);
            Test.stopTest();
            
        }catch(Exception ex){
            system.debug('Exception inside testConstructor'+ex.getMessage());
            throw ex;
        }
        
    }
}