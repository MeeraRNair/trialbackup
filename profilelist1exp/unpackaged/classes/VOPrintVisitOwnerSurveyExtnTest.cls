@isTest
public class VOPrintVisitOwnerSurveyExtnTest {
    
    public testmethod static void testMethodConstructor()
    {
        try
        {
            User systemUser = [SELECT Name FROM User WHERE Profile.Name = 'System Administrator' and isactive=true LIMIT 1];
            System.assertNotEquals(systemUser, null);
            //Create Document for Dell logo
            Document documentLogo;
            documentLogo = new Document();
            documentLogo.Body = Blob.valueOf('Some Text');
            documentLogo.ContentType = 'application/pdf';
            documentLogo.DeveloperName = 'Survey_Logo';
            documentLogo.IsPublic = true;
            documentLogo.Name = 'Survey Logo';
            documentLogo.FolderId = [select id from folder where name = 'VisitOps'].id;
            insert documentLogo;         
            VisitOps__Visit__c visitInstance = new VisitOps__Visit__c(VisitOps__VisitName__c = 'Customer Test Survey', VisitOps__TotalNoOfAttendees__c = 1, VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 10, 12));
            VisitOps__Location__c visitOpsLocationInstance = new VisitOps__Location__c(VisitOps__Time_Zone__c = '(GMT+06:00) Bangladesh Time (Asia/Dhaka)', VisitOps__Location_Type__c = 'Other');
            insert(visitOpsLocationInstance);
            System.debug('***VisitLocation'+visitOpsLocationInstance);
            visitInstance.VisitOps__Location__c = visitOpsLocationInstance.Id;
            visitInstance.VisitOps__ArrivalDateTimeLocationTZ__c = '12-10-2018 Bangladesh';
            visitInstance.VisitOps__DepartureDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 11, 11);
            visitInstance.VisitOps__DepartureDateTimeLocationTZ__c = '2018-11-11 Bangladesh';
            VisitOps__VisitType__c visitType = new VisitOps__VisitType__c(VisitOps__Category__c = 'Event', VisitOps__Description__c = 'Small Event');
            insert visitType;
            system.debug('visitType::::'+visitType);
            visitInstance.VisitOps__VisitType__c = visitType.Id;
            visitInstance.VisitOps__VisitOwner__c = systemUser.Id;
            insert visitInstance;
            
            System.assertNotEquals(visitInstance, null);
            
            PageReference voPrintCustomerPostSurvey = Page.VOVisitOwnerPostSurvey;
            Test.setCurrentPageReference(voPrintCustomerPostSurvey);
            
            ApexPages.currentPage().getParameters().put('visitId',visitInstance.Id);
            ApexPages.StandardController standardControllerInstance = new ApexPages.StandardController(new VisitOps__Survey__c());
            
            Test.startTest();
            
            VOPrintVisitOwnerSurveyExtn vOOwnerPostSurveyExtensionInstance = new VOPrintVisitOwnerSurveyExtn(standardControllerInstance);
            vOOwnerPostSurveyExtensionInstance.getDocumentLogoUrl();
            vOOwnerPostSurveyExtensionInstance.getRadioOpts();
            vOOwnerPostSurveyExtensionInstance.getEngImpOptsNolabel();
            vOOwnerPostSurveyExtensionInstance.getEngImpOpts();
            vOOwnerPostSurveyExtensionInstance.getEngMetOpts();
            vOOwnerPostSurveyExtensionInstance.getEngProgOptsNolabel();
            vOOwnerPostSurveyExtensionInstance.getEngProgOpts();
            vOOwnerPostSurveyExtensionInstance.getExpEngOptsNolabel();
            vOOwnerPostSurveyExtensionInstance.getExpEngOpts();
            vOOwnerPostSurveyExtensionInstance.getLogisticsExpOptsNolabel();
            vOOwnerPostSurveyExtensionInstance.getRadioOptsNoLabel();
            vOOwnerPostSurveyExtensionInstance.getRadioRatingLabel();
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('***Exception at Line number '+e.getLineNumber()+' Exception Cause '+e.getCause()+' of '+e);
            throw e;
        }
    }
    
    /*@isTest
    public static void testAgendaSurveyCreation(){
        User systemUser = [SELECT Name FROM User WHERE Profile.Name = 'System Administrator' and isactive=true LIMIT 1];
        System.assertNotEquals(systemUser, null);         
        VisitOps__Visit__c visitInstance = new VisitOps__Visit__c(VisitOps__VisitName__c = 'Customer Test Survey', VisitOps__TotalNoOfAttendees__c = 1, VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 10, 12));
        VisitOps__Location__c visitOpsLocationInstance = new VisitOps__Location__c(VisitOps__Time_Zone__c = '(GMT+06:00) Bangladesh Time (Asia/Dhaka)', VisitOps__Location_Type__c = 'Other');
        insert(visitOpsLocationInstance);
        System.debug('***VisitLocation'+visitOpsLocationInstance);
        visitInstance.VisitOps__Location__c = visitOpsLocationInstance.Id;
        visitInstance.VisitOps__ArrivalDateTimeLocationTZ__c = '12-10-2018 Bangladesh';
        visitInstance.VisitOps__DepartureDateTime__c = DateTime.newInstance(2018, 11, 11);
        visitInstance.VisitOps__ArrivalDateTime__c = DateTime.newInstance(2018, 11, 11);
        visitInstance.VisitOps__DepartureDateTimeLocationTZ__c = '2018-11-11 Bangladesh';
        VisitOps__VisitType__c visitType = new VisitOps__VisitType__c(VisitOps__Category__c = 'Event', VisitOps__Description__c = 'Small Event');
        insert visitType;
        system.debug('visitType::::'+visitType);
        visitInstance.VisitOps__VisitType__c = visitType.Id;
        visitInstance.VisitOps__VisitOwner__c = systemUser.Id;
        insert visitInstance;
        VisitOps__Agenda__c agenda = new VisitOps__Agenda__c();
        agenda.VisitOps__Visit__c = visitInstance.Id;
        agenda.VisitOps__Agenda_Title__c = 'Test Agenda';
        agenda.VisitOps__Start_Time__c = system.now();
        agenda.VisitOps__End_Time__c = system.now().addHours(1);
        agenda.VisitOps__StartTimeLocationTZ__c = String.valueOf(system.now());
        agenda.VisitOps__EndTimeLocationTZ__c = String.valueOf(system.now().addHours(1));
        insert agenda;
        VisitOps__Survey__c survey = new VisitOps__Survey__c();
        survey.VisitOps__Visit__c = visitInstance.Id;
        survey.VisitOps__User__c = systemUser.id;
        survey.RecordTypeId = [Select id from RecordType where sObjectType = 'VisitOps__Survey__c' AND Name = 'Visit Owner Survey'].id;
        insert survey;
        PageReference voPrintCustomerPostSurvey = Page.VOVisitOwnerPostSurvey;
        Test.setCurrentPageReference(voPrintCustomerPostSurvey);
        
        ApexPages.currentPage().getParameters().put('visitId',visitInstance.Id);
        ApexPages.StandardController standardControllerInstance = new ApexPages.StandardController(new VisitOps__Survey__c());
        
        Test.startTest();
        
        VOPrintVisitOwnerSurveyExtn vOOwnerPostSurveyExtensionInstance = new VOPrintVisitOwnerSurveyExtn(standardControllerInstance);
        vOOwnerPostSurveyExtensionInstance.createAgendaSurveys();
        Test.stopTest();
        
    }*/
}