@isTest(seeAllData = false)
public class VOOwnerPostSurveyExtensionTest
{
    public testmethod static void testMethodConstructor()
    {
        try
        {
            User systemUser = [SELECT Name FROM User WHERE Profile.Name = 'System Administrator' and isactive=true LIMIT 1];
            System.assertNotEquals(systemUser, null);
            
            VisitOps__Visit__c visitInstance = new VisitOps__Visit__c(VisitOps__VisitName__c = 'Customer Test Survey', VisitOps__TotalNoOfAttendees__c = 1, VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 10, 12));
            VisitOps__Location__c VisitOps_LocationInstance = new VisitOps__Location__c(VisitOps__Time_Zone__c = '(GMT+06:00) Bangladesh Time (Asia/Dhaka)', VisitOps__Location_Type__c = 'Other');
            insert(VisitOps_LocationInstance);
            System.debug('***VisitLocation'+VisitOps_LocationInstance);
            visitInstance.VisitOps__Location__c = VisitOps_LocationInstance.Id;
            visitInstance.VisitOps__ArrivalDateTimeLocationTZ__c = '12-10-2018 Bangladesh';
            visitInstance.VisitOps__DepartureDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__DepartureDateTimeLocationTZ__c = '2018-11-11 Bangladesh';
            VisitOps__VisitType__c VisitType = new VisitOps__VisitType__c(VisitOps__Category__c = 'Event', VisitOps__Description__c = 'Small Event');
            insert VisitType;
            visitInstance.VisitOps__VisitType__c = VisitType.Id;
            visitInstance.VisitOps__VisitOwner__c = systemUser.Id;
            insert visitInstance;
            
            System.assertNotEquals(visitInstance, null);
            
            PageReference OwnerPostSurveyReference = Page.VOVisitOwnerPostSurvey;
            Test.setCurrentPageReference(OwnerPostSurveyReference);
            
            ApexPages.currentPage().getParameters().put('visitId',visitInstance.Id);
            ApexPages.currentPage().getParameters().put('userId',systemUser.Id);
            ApexPages.StandardController standardControllerInstance = new ApexPages.StandardController(new VisitOps__Survey__c());
            
            Test.startTest();
            
            VOOwnerPostSurveyExtension VOOwnerPostSurveyExtensionInstance = new VOOwnerPostSurveyExtension(standardControllerInstance);
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('***Exception at Line number '+e.getLineNumber()+' Exception Cause '+e.getCause()+' of '+e);
            throw e;
        }
    }
    public testmethod static void testMethodGetters()
    {
        try
        {
            Id folderId = [SELECT Id FROM Folder WHERE accessType = 'Public' AND Name = 'VisitOps' LIMIT 1].Id;
            System.debug('***folderId'+folderId);
            insert (new Document(Name = 'Footer', DeveloperName = 'Survey_Footer', IsPublic = true, FolderId = folderId));
            insert (new Document(Name = 'Footer', DeveloperName = 'Survey_Logo', IsPublic = true, FolderId = folderId));
            
            User systemUser = [SELECT Name FROM User WHERE Profile.Name = 'System Administrator' and isactive=true LIMIT 1];
            System.assertNotEquals(systemUser, null);
            
            VisitOps__Visit__c visitInstance = new VisitOps__Visit__c(VisitOps__VisitName__c = 'Customer Test Survey', VisitOps__TotalNoOfAttendees__c = 1, VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 10, 12));
            VisitOps__Location__c VisitOps_LocationInstance = new VisitOps__Location__c(VisitOps__Time_Zone__c = '(GMT+06:00) Bangladesh Time (Asia/Dhaka)', VisitOps__Location_Type__c = 'Other');
            insert(VisitOps_LocationInstance);
            System.debug('***VisitLocation'+VisitOps_LocationInstance);
            visitInstance.VisitOps__Location__c = VisitOps_LocationInstance.Id;
            visitInstance.VisitOps__ArrivalDateTimeLocationTZ__c = '12-10-2018 Bangladesh';
            visitInstance.VisitOps__DepartureDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__DepartureDateTimeLocationTZ__c = '2018-11-11 Bangladesh';
            VisitOps__VisitType__c VisitType = new VisitOps__VisitType__c(VisitOps__Category__c = 'Event', VisitOps__Description__c = 'Small Event');
            insert VisitType;
            visitInstance.VisitOps__VisitType__c = VisitType.Id;
            visitInstance.VisitOps__VisitOwner__c = systemUser.Id;
            insert visitInstance;
            
            System.assertNotEquals(visitInstance, null);
            
            PageReference OwnerPostSurveyReference = Page.VOVisitOwnerPostSurvey;
            Test.setCurrentPageReference(OwnerPostSurveyReference);
            
            ApexPages.currentPage().getParameters().put('visitId',visitInstance.Id);
            ApexPages.currentPage().getParameters().put('userId',systemUser.Id);
            ApexPages.StandardController standardControllerInstance = new ApexPages.StandardController(new VisitOps__Survey__c());
            
            Test.startTest();
            
            VOOwnerPostSurveyExtension VOOwnerPostSurveyExtensionInstance = new VOOwnerPostSurveyExtension(standardControllerInstance);
            VOOwnerPostSurveyExtensionInstance.getDocumentFooterUrl();
            VOOwnerPostSurveyExtensionInstance.getDocumentLogoUrl();
            VOOwnerPostSurveyExtensionInstance.getEngImpOpts();
            VOOwnerPostSurveyExtensionInstance.getEngImpOptsNolabel();
            VOOwnerPostSurveyExtensionInstance.getEngMetOpts();
            VOOwnerPostSurveyExtensionInstance.getEngProgOpts();
            VOOwnerPostSurveyExtensionInstance.getEngProgOptsNolabel();
            VOOwnerPostSurveyExtensionInstance.getExpEngOpts();
            VOOwnerPostSurveyExtensionInstance.getExpEngOptsNolabel();
            VOOwnerPostSurveyExtensionInstance.getLogisticsExpOptsNolabel();
            VOOwnerPostSurveyExtensionInstance.getRadioOpts();
            VOOwnerPostSurveyExtensionInstance.getRadioOptsNoLabel();
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('***Exception at Line number '+e.getLineNumber()+' Exception Cause '+e.getCause()+' of '+e);
            throw e;
        }
    }
    public testmethod static void testMethodSubmit()
    {
        try
        {
            User systemUser = [SELECT Name FROM User WHERE Profile.Name = 'System Administrator' and isactive=true LIMIT 1];
            System.assertNotEquals(systemUser, null);
            
            VisitOps__Visit__c visitInstance = new VisitOps__Visit__c(VisitOps__VisitName__c = 'Customer Test Survey', VisitOps__TotalNoOfAttendees__c = 1, VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 10, 12));
            VisitOps__Location__c VisitOps_LocationInstance = new VisitOps__Location__c(VisitOps__Time_Zone__c = '(GMT+06:00) Bangladesh Time (Asia/Dhaka)', VisitOps__Location_Type__c = 'Other');
            insert(VisitOps_LocationInstance);
            System.debug('***VisitLocation'+VisitOps_LocationInstance);
            visitInstance.VisitOps__Location__c = VisitOps_LocationInstance.Id;
            visitInstance.VisitOps__ArrivalDateTimeLocationTZ__c = '12-10-2018 Bangladesh';
            visitInstance.VisitOps__DepartureDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__DepartureDateTimeLocationTZ__c = '2018-11-11 Bangladesh';
            VisitOps__VisitType__c VisitType = new VisitOps__VisitType__c(VisitOps__Category__c = 'Event', VisitOps__Description__c = 'Small Event');
            insert VisitType;
            visitInstance.VisitOps__VisitType__c = VisitType.Id;
            visitInstance.VisitOps__VisitOwner__c = systemUser.Id;
            insert visitInstance;
            
            VisitOps__Agenda__c agendaInstance = new VisitOps__Agenda__c(VisitOps__Visit__c = visitInstance.Id, VisitOps__Start_Time__c = DateTime.newInstance(2018, 10, 12), VisitOps__End_Time__c = DateTime.newInstance(2018, 10, 13), VisitOps__Location__c = VisitOps_LocationInstance.Id, VisitOps__StartTimeLocationTZ__c = '12-10 Bangla', VisitOps__EndTimeLocationTZ__c = '13-10 Bangla', VisitOps__Agenda_Title__c = 'Test Session');
            insert agendaInstance;
            
            VisitOps__Presenter_Agenda_Link__c presenterAgendaInstance = new VisitOps__Presenter_Agenda_Link__c();
            presenterAgendaInstance.VisitOps__Agenda__c = agendaInstance.Id;
            presenterAgendaInstance.VisitOps__Base_Location__c = VisitOps_LocationInstance.Id;
            presenterAgendaInstance.VisitOps__Status__c = 'Accepted';
            insert presenterAgendaInstance;
            
            List<VisitOps__Agenda__c> agendaList = [select Id,VisitOps__Agenda_Title__c,VisitOps__Topic__r.VisitOps__TopicCategory__c,Name,(select Id,VisitOps__Presenter_Name__c from VisitOps__Presenter_Agenda_Links__r where VisitOps__Status__c='Accepted') from VisitOps__Agenda__c where VisitOps__Visit__c= :visitInstance.Id AND VisitOps__Topic__r.VisitOps__TopicCategory__c!='Instructions'];
            System.debug('***agendaList'+agendaList);
            
            System.assertNotEquals(visitInstance, null);
            
            PageReference OwnerPostSurveyReference = Page.VOVisitOwnerPostSurvey;
            Test.setCurrentPageReference(OwnerPostSurveyReference);
            
            ApexPages.currentPage().getParameters().put('visitId',visitInstance.Id);
            ApexPages.currentPage().getParameters().put('userId',systemUser.Id);
            ApexPages.StandardController standardControllerInstance = new ApexPages.StandardController(new VisitOps__Survey__c());
            
            Test.startTest();
            
            VOOwnerPostSurveyExtension VOOwnerPostSurveyExtensionInstance = new VOOwnerPostSurveyExtension(standardControllerInstance);
            VOOwnerPostSurveyExtensionInstance.constructorCode();
            VOOwnerPostSurveyExtensionInstance.VisitOps_Recommendation_Strategy_Buffer = '1';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Engagement_Met_Objectives__c = 'Did Not Meet Objectives';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Improved_Relationship_with_Customer__c = 'Did Not Help At All';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Uncovered_new_opportunities__c = 'Did Not Help At All';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Assisted_in_differentiating_a_product__c = 'Did Not Help At All';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Expanded_deal_size__c = 'Did Not Help At All';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Accelerated_close_of_deal__c = 'Did Not Help At All';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Requesting_an_engagement__c = 'Very Difficult';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Linking_an_Opportunity__c = 'Very Difficult';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Completing_Profile_POC_Questionnaire__c = 'Very Difficult';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Scheduling_Project_Management__c = 'Neutral';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Logistics__c = 'Neutral';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Briefing_Consultant_Solution_Architect__c = 'Neutral';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Day_of_Support__c = 'Neutral';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Catering__c = 'Neutral';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Transportation__c = 'Neutral';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Evening_Events__c = 'Neutral';
            VOOwnerPostSurveyExtensionInstance.surveyRecord.Hotel__c = 'Neutral';
            VOOwnerPostSurveyExtensionInstance.agendaPresenterWrapperList[0].agendaSurvey.VisitOps__Session_Rating__c = 1;
            VOOwnerPostSurveyExtensionInstance.agendaPresenterWrapperList[0].presenterSurveyList[0].VisitOps__Presenter_Rating__c = 1;
            VOOwnerPostSurveyExtensionInstance.submitSurvey();
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('***Exception at Line number '+e.getLineNumber()+' Exception Cause '+e.getCause()+' of '+e);
            throw e;
        }
    }
    public testmethod static void testMethodSubmitNegativeUseCase()
    {
        try
        {
            User systemUser = [SELECT Name FROM User WHERE Profile.Name = 'System Administrator' and isactive=true LIMIT 1];
            System.assertNotEquals(systemUser, null);
            
            VisitOps__Visit__c visitInstance = new VisitOps__Visit__c(VisitOps__VisitName__c = 'Customer Test Survey', VisitOps__TotalNoOfAttendees__c = 1, VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 10, 12));
            VisitOps__Location__c VisitOps_LocationInstance = new VisitOps__Location__c(VisitOps__Time_Zone__c = '(GMT+06:00) Bangladesh Time (Asia/Dhaka)', VisitOps__Location_Type__c = 'Other');
            insert(VisitOps_LocationInstance);
            System.debug('***VisitLocation'+VisitOps_LocationInstance);
            visitInstance.VisitOps__Location__c = VisitOps_LocationInstance.Id;
            visitInstance.VisitOps__ArrivalDateTimeLocationTZ__c = '12-10-2018 Bangladesh';
            visitInstance.VisitOps__DepartureDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__DepartureDateTimeLocationTZ__c = '2018-11-11 Bangladesh';
            VisitOps__VisitType__c VisitType = new VisitOps__VisitType__c(VisitOps__Category__c = 'Event', VisitOps__Description__c = 'Small Event');
            insert VisitType;
            visitInstance.VisitOps__VisitType__c = VisitType.Id;
            visitInstance.VisitOps__VisitOwner__c = systemUser.Id;
            insert visitInstance;
            
            System.assertNotEquals(visitInstance, null);
            
            PageReference OwnerPostSurveyReference = Page.VOVisitOwnerPostSurvey;
            Test.setCurrentPageReference(OwnerPostSurveyReference);
            
            ApexPages.currentPage().getParameters().put('visitId',visitInstance.Id);
            ApexPages.currentPage().getParameters().put('userId',systemUser.Id);
            ApexPages.StandardController standardControllerInstance = new ApexPages.StandardController(new VisitOps__Survey__c());
            
            Test.startTest();
            
            VOOwnerPostSurveyExtension VOOwnerPostSurveyExtensionInstance = new VOOwnerPostSurveyExtension(standardControllerInstance);
            VOOwnerPostSurveyExtensionInstance.constructorCode();
            VOOwnerPostSurveyExtensionInstance.submitSurvey();
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('***Exception at Line number '+e.getLineNumber()+' Exception Cause '+e.getCause()+' of '+e);
            throw e;
        }
    }
}