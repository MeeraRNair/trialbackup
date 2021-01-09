public without sharing class VOVisitNonSFCtrl{
    
    
    //@TestVisible Visit__c visitRecord;
    public VisitOps__Visit__c visitRecord{get;set;}
    
    Map<Id,String> accIdNameMap = new Map<Id,String>();

    //To ensure that Accounts/Opportunities/Attendees can be added to Visit even while creating the Visit(even when Visit record id is not there)
    
    public List<VisitOps__Company__c> companiesOfVisit{get;set;}
    public List<VisitOps__VisitBundle__c> oppsForVisit{get;set;}
    public List<VisitOps__Attendee__c> attendeesForVisit{get;set;}
    
    //public VisitNonSFCtrl(ApexPages.StandardController controller) {
    public VOVisitNonSFCtrl() {
        try{
            Id visitRecordId = ApexPages.currentPage().getParameters().get('Id');
            system.debug('visitRecordId---'+visitRecordId);
            
            attendeesForVisit = new List<VisitOps__Attendee__c>();
            oppsForVisit = new List<VisitOps__VisitBundle__c>();
            companiesOfVisit = new List<VisitOps__Company__c>();
            
            /*visitRecord = [select Customer_Business_Description__c,Customers_Relationship_with_Dell__c,
            Describe_Customer_s_Critical_Issues__c,Describe_Dells_Competitive_Threats__c,
            High_Level_Requirements__c,Are_NDAs_in_place_for_all_Accounts__c,Are_all_Accounts_Trade_Compliant__c,VisitOps__VisitOwner__r.Name, VisitOps__VisitCoordinator__r.Name, Owner.Name, 
            VisitOps__Submitted_Date__c, VisitOps__SubmitVisitFor__c, VisitOps__WhatElseDoWeNeedToKnow__c, VisitOps__VisitStatusName__c, 
            VisitOps__VisitType__r.Name, VisitOps__VisitType__r.VisitOps__Category__c, VisitOps__Room__r.Name, VisitOps__Room__r.VisitOps__Room_Capacity__c, 
            VisitOps__Location__r.Name, VisitOps__Location__r.VisitOps__TimeZoneIdentifierFormula__c, VisitOps__ArrivalDateTimeLocationTZ__c, 
            VisitOps__DepartureDateTimeLocationTZ__c, VisitOps__VisitOwner__c, VisitOps__Visit_Team_Notes__c, VisitOps__VisitType__c, 
            VisitOps__VisitTeamComments__c, VisitOps__VisitTeamAgendaComments__c, VisitOps__VisitStatus__c, VisitOps__VisitStatus__r.Name,
            VisitOps__VisitName__c, VisitOps__VisitManager__c, VisitOps__VisitCoordinator__c, VisitOps__Videographer_Status__c, 
            VisitOps__TotalNoOfAttendees__c, VisitOps__TopicsAndPeopleNeeded__c, VisitOps__Title__c, SystemModstamp, VisitOps__Strategy_Call_Status__c,
            VisitOps__Signage_Status__c, VisitOps__Security_Status__c, VisitOps__Room__c, VisitOps__Restaurant_Status__c, VisitOps__ReasonForYourVisit__c, 
            VisitOps__ReasonForCancellation__c, VisitOps__CancellationComments__c, VisitOps__Pre_Visit_Survey_Needed__c, 
            VisitOps__Pre_Survey_Status__c, VisitOps__Post_Visit_Survey_Needed__c, VisitOps__Post_Survey_Status__c, VisitOps__Photographer_Status__c,
            OwnerId, VisitOps__OurRelationshipWithAccounts__c, VisitOps__OffSiteLocationName__c, VisitOps__OffSiteContactPhone__c, 
            VisitOps__OffSiteContactName__c, VisitOps__OffSiteContactEmail__c, VisitOps__OffSiteAddress__c, Name, VisitOps__ModeOfTransportation__c,
            VisitOps__MeasureOfSuccess__c, VisitOps__Lodging_Status__c, VisitOps__Location__c, VisitOps__LocationNameFormula__c, 
            VisitOps__Line_of_Business__c, VisitOps__Leadership_Approval_Status__c, LastModifiedDate, LastModifiedById, 
            VisitOps__Items_to_Remember__c, VisitOps__IsVisitApproved__c, VisitOps__IsPreSurveyRequired__c, IsDeleted, 
            VisitOps__IsAgendaApprovedByOwner__c, VisitOps__IsAgendaApprovedByCustomer__c, Id, VisitOps__Ground_Transportation_Status__c, 
            VisitOps__Gifts_Status__c, VisitOps__Facilities_Status__c, VisitOps__Expenses__c, VisitOps__Email__c, VisitOps__DressCode__c,
            VisitOps__Divison__c, VisitOps__DetailAnyChangesToAgenda__c, VisitOps__DepartureDateTime__c, VisitOps__Decision_Survey_Needed__c,
            CreatedDate, CreatedById, VisitOps__Cost_Center_Department__c, VisitOps__Classification__c, VisitOps__CellPhone__c, 
            VisitOps__Catering_Status__c, VisitOps__ArrivalDateTime__c, VisitOps__ApproverName__c, VisitOps__ApproverComments__c, 
            VisitOps__Agenda__c, VisitOps__Agenda_Approval_Status__c, VisitOps__Arrival_Date_and_Time_LocationFormula__c, 
            VisitOps__Departure_Date_and_Time_LocationFormula__c, VisitOps__Portal_Visit__c, VisitOps__Owner_Portal__c from VisitOps__Visit__c where 
            id =:String.escapeSingleQuotes(visitRecordId)];*/
            visitRecord = [select Name, Customer_Business_Description__c,Customers_Relationship_with_Dell__c,Requestor_Name__c,
            Describe_Customer_s_Critical_Issues__c,Describe_Dells_Competitive_Threats__c,
            High_Level_Requirements__c,Are_NDAs_in_place_for_all_Accounts__c,Are_all_Accounts_Trade_Compliant__c,VisitOps__VisitOwner__r.Name, Owner.Name, 
            VisitOps__ArrivalDateTimeLocationTZ__c, VisitOps__DepartureDateTimeLocationTZ__c, VisitOps__VisitName__c,
            VisitOps__Arrival_Date_and_Time_LocationFormula__c,VisitOps__Departure_Date_and_Time_LocationFormula__c, VisitOps__VisitOwner__c,VisitOps__ReasonForYourVisit__c,
            VisitOps__Owner_Portal__c,VisitOps__Portal_Visit__c,Reason_for_Engagement__c,Subjects_to_Avoid__c,Challenges_and_Roadblocks__c,Financial_Priorities_Goals_Challenges__c  from VisitOps__Visit__c where 
            id =:String.escapeSingleQuotes(visitRecordId)];
            system.debug('after querying visitRecord---'+visitRecord);
                    
            if(String.isNotBlank(visitRecord.id)){
                populateCompaniesGrid();
                populateVisitOpportunitiesGrid();
                populateAttendeesGrid();
                
            }
        }catch(Exception ex){
            system.debug('Exception inside constructor--'+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while loading the page'));
        }
    }
    
    public PageReference populateVisitOpportunitiesGrid(){
        try{
            system.debug('inside populateVisitOpportunitiesGrid--');
            
            Id visitId = visitRecord.id;
            
            /*String queryString = 'SELECT id, Name, VisitOps__Opportunity__r.Deal_ID__c,VisitOps__Opportunity__r.VisitOps__Opportunity__r.Opportunity_Customer__c,VisitOps__Opportunity__c, VisitOps__Visit__c, VisitOps__Objective_for_this_Opportunity__c, VisitOps__Opportunity__r.Account.Name, VisitOps__Opportunity__r.Name, VisitOps__Opportunity__r.Owner.Name, VisitOps__Opportunity__r.Type, VisitOps__Opportunity__r.StageName, VisitOps__Opportunity__r.Probability, VisitOps__Opportunity__r.Amount, VisitOps__Opportunity__r.CloseDate, VisitOps__Opportunity__r.VisitOps__MainCompetitors__c,VisitOps__SF_Opportunity_ID__c  from VisitOps__VisitBundle__c';
            if(!String.isBlank(visitRecord.id)){
                queryString += ' Where VisitOps__Visit__c=:visitId';
            }
            queryString += ' order by createddate desc limit 10000';
            system.debug('queryString in populateVisitOpportunitiesGrid--'+queryString);
            oppsForVisit = Database.query(queryString);*/
            if(!String.isBlank(visitRecord.id)){
            oppsForVisit = [SELECT id, Name,
            VisitOps__Opportunity__r.Deal_ID__c,VisitOps__Opportunity__r.Opportunity_Customer__c,VisitOps__Opportunity__c,Opp_Amount__c,
            VisitOps__Visit__c, VisitOps__Objective_for_this_Opportunity__c, VisitOps__Opportunity__r.Account.Name,
            VisitOps__Opportunity__r.Name, VisitOps__Opportunity__r.Owner.Name, VisitOps__Opportunity__r.Type, 
            VisitOps__Opportunity__r.StageName, VisitOps__Opportunity__r.Probability, VisitOps__Opportunity__r.Amount, 
            VisitOps__Opportunity__r.CloseDate, VisitOps__Opportunity__r.VisitOps__MainCompetitors__c,
            VO_Opportunity_Deal_ID_Number__c,VisitOpsP__Opp_Name__c,VO_Opportunity_Owner__c,
            VisitOps__SF_Opportunity_ID__c  from VisitOps__VisitBundle__c Where VisitOps__Visit__c=:visitId order by createddate desc limit 10000];
            }
            if(oppsForVisit.isEmpty()){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Companies found for this Visit.'));
            }
        }catch(Exception ex){
            system.debug('Exception inside populateVisitOpportunitiesGrid--'+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while populating Opportunities Grid'));
        }
        return null;
    }
    
    public PageReference populateAttendeesGrid(){
        try{
            system.debug('inside populateAttendeesGrid--');
            
            Id visitId = visitRecord.id;
            //attendeesForVisit = [select id, Visit__c, Objectives_for_this_Attendee__c, IsPrimaryDecisionMakerForVisit__c, Title__c, Contact__r.Account.Name, FirstName__c, LastName__c, Phone__c, Email__c  from Attendee__c where Visit__c=:visitId limit 10000];
            if(!String.isBlank(visitRecord.id)){
                attendeesForVisit = [select id, Name, VisitOps__Attendee_Types__c,VisitOps__Attendee_Role__c,VisitOps__Visit__c, VisitOps__Company__c, VisitOps__TravelDetails__c,
                VisitOps__Objectives_for_this_Attendee__c, VisitOps__IsPrimaryDecisionMakerForVisit__c, VisitOps__Title__c,
                VisitOps__Contact__r.Account.Name, VisitOps__FirstName__c, VisitOps__LastName__c, VisitOps__Phone__c, 
                VisitOps__Email__c, VisitOps__LinkedInUrlFormula__c, VisitOps__LinkedIn_Url__c  from VisitOps__Attendee__c where VisitOps__Visit__c=:visitId order by VisitOps__Company__c asc limit 10000];
            }
            if(attendeesForVisit.isEmpty()){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Companies found for this Visit.'));
            }
        }catch(Exception ex){
            system.debug('Exception inside populateAttendeesGrid--'+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while populating Attendees Grid'));
        }
        return null;
    }
    
    public PageReference populateCompaniesGrid(){
        try{
            system.debug('inside populateCompaniesGrid--companyIdsforNewVisit--');
            
            Id visitId = visitRecord.id;
            //companiesOfVisit = [select id, ObjectiveForThisAccount__c, Visit__c, Account__c, Account__r.Name, Account__r.Site, Account__r.AnnualRevenue, Account__r.Owner.Name, Account__r.TickerSymbol, Account__r.Parent.Name, Account__r.Industry from Company__c where Visit__c=:visitId limit 10000];
            if(!String.isBlank(visitRecord.id)){                
                companiesOfVisit = [select id, Name, VisitOps__ObjectiveForThisAccount__c,VisitOps__Account_Name__c, VisitOps__Visit__c, VisitOps__VO_Account_Owner__c,VO_Account_Owner_Email__c,VisitOps__Company_Industry__c,VO_Account_Country__c,
                VisitOps__Account__c, VisitOps__Account__r.Name, VisitOps__Account__r.Site, VisitOps__Account__r.Website,VO_Account_Classification__c,
                VisitOps__Account__r.AnnualRevenue, VisitOps__Account__r.Owner.Name,VisitOps__Account__r.Owner.Email, VisitOps__Account__r.Account_Country__c,VisitOps__Account__r.Account_Classification__c, VisitOps__Account__r.TickerSymbol, 
                VisitOps__Account__r.Parent.Name, VisitOps__Account__r.Industry, VisitOps__Account__r.BillingCity, VisitOps__Company_Name__c,
                VisitOps__Account__r.BillingState from VisitOps__Company__c where VisitOps__Visit__c=:visitId order by createddate desc limit 10000];
            }
            if(companiesOfVisit.isEmpty()){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Companies found for this Visit.'));
            }
            
            accIdNameMap = (accIdNameMap != null) ? accIdNameMap : new Map<Id,String>();
            for(VisitOps__Company__c c:companiesOfVisit){
                accIdNameMap.put(c.VisitOps__Account__c, c.VisitOps__Account__r.Name);
            }
            system.debug('accIdNameMap--'+accIdNameMap);
            
        }catch(Exception ex){
            system.debug('Exception inside populateCompaniesGrid--'+ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while populating Companies Grid'));
        }
        return null;
    }
    
}