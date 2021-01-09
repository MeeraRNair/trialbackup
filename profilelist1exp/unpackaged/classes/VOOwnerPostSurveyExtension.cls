public with sharing class VOOwnerPostSurveyExtension {
    
    public string rating{get;set;}
    public string visitId {get;set;}
    public String attendeeId {get;set;}
    public String userId {get;set;}
    private String existingSurveyId {get;set;}
    public Boolean showSubmitButton {get;set;}
    private List<VisitOps__Visit__c> visitList{get;set;}
    public VisitOps__Visit__c visitRecord {get;set;}
    public VisitOps__Attendee__c attendeeRecord {get;set;}
    public User userRecord {get;set;}
    public VisitOps__Survey__c surveyRecord {get;set;}
    public VisitOps__Survey__c preSurveyRecord {get;set;}
    public String coordinatorName {get;set;}
    public String visitOwnerName {get;set;}
    public boolean flag{get;set;}
    public string newString{get;set;}
    public boolean flag1{get;set;}
    public List<AgendaPresenterWrapper> agendaPresenterWrapperList {get;set;}
    /* Used in rendering the Question Required messages*/
    public Boolean requiredQ1Flag{get;set;}
    public Boolean requiredQ2Flag{get;set;}
    public Boolean requiredQ3Flag{get;set;}
    public Boolean requiredQ4Flag{get;set;}
    public Boolean requiredQ5Flag{get;set;}
    public Boolean requiredQ6Flag{get;set;}
    public Boolean requiredQAgendaFlag{get;set;}
    public String VisitOps_Recommendation_Strategy_Buffer{get;set;}
    public List<VisitOps__Attendee__c> listOfAttendees{get;set;}
	public String strSelectedLang{get;set;}
    public List<selectoption> listOfLang {get;set;}
	
    public string getDocumentFooterUrl()
    {
        
        list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName = 'Survey_Footer']; 
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        //newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
        newString = fullFileURL +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
        return newString;
    } 
    public VOOwnerPostSurveyExtension(ApexPages.StandardController controller) {
        listOfLang = new List<selectOption>();

        Schema.DescribeFieldResult fieldResult = VisitOps__Attendee__c.VisitOps__Survey_Language__c.getDescribe();
        List<Schema.PicklistEntry> listPicklistEntries = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry picklistEntry : listPicklistEntries){
            listOfLang.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }

        strSelectedLang = ApexPages.currentPage().getParameters().get('lang');
        //constructorCode();
    }
	
	public PageReference constructorCode(){
		try {
            flag=false;
            flag1=false;
            requiredQ1Flag = false;
            requiredQ2Flag = false;
            requiredQ3Flag = false;
            requiredQ4Flag = false;
            requiredQ5Flag = false;
            requiredQ6Flag = false;
            requiredQAgendaFlag = false;
            VisitOps_Recommendation_Strategy_Buffer = null;
            agendaPresenterWrapperList = new List<AgendaPresenterWrapper>();
            visitId = ApexPages.currentPage().getParameters().get('visitId');
            if(visitId!=null && visitId!='') {visitId = String.escapeSingleQuotes(visitId);}
            else {throw new ErrorOccuredException();}
            
            attendeeId = ApexPages.currentPage().getParameters().get('attendeeId');
            if(attendeeId!=null && attendeeId!='') {attendeeId = String.escapeSingleQuotes(attendeeId);}
            
            userId = ApexPages.currentPage().getParameters().get('userId');
            if(userId!=null && userId!='') {userId = String.escapeSingleQuotes(userId);}
            
            if((userId==null||userId=='') && (attendeeId==null||attendeeId==''))
                {throw new ErrorOccuredException();}
            
            visitList = [select Id,Name,VisitOps__VisitName__c,VisitOps__ArrivalDateTime__c,VisitOps__DepartureDateTime__c,VisitOps__ArrivalDateTimeLocationTZ__c,VisitOps__DepartureDateTimeLocationTZ__c,
                         VisitOps__VisitType__c,VisitOps__Location__c,VisitOps__Location__r.Name,VisitOps__VisitManager__c,VisitOps__VisitCoordinator__c,VisitOps__VisitCoordinator__r.Name,
                         Owner.Name,VisitOps__VisitOwner__r.Name,VisitOps__VisitOwner__c, Child_Visit__c from VisitOps__Visit__c where Id=:visitid];
            if(visitList!=null && visitList.size()>0) {
                visitRecord = visitList[0];
                coordinatorName = visitList[0].VisitOps__VisitCoordinator__r.Name;
                visitOwnerName = visitList[0].VisitOps__VisitOwner__r.Name; 
            }
            else {throw new ErrorOccuredException();}
            listOfAttendees = [SELECT VisitOps__TotalNoOfAttendees__c, (SELECT VisitOps__Name__c, Name FROM VisitOps__Attendees__r) FROM VisitOps__Visit__c WHERE Id = :visitid ].VisitOps__Attendees__r;
            List<VisitOps__Attendee__c> attendeeList = [SELECT Id, Name,VisitOps__FirstName__c,VisitOps__LastName__c FROM VisitOps__Attendee__c WHERE Id = :attendeeId];
            if(attendeeList!=null && attendeeList.size()>0) {attendeeRecord = attendeeList[0];}
            
            List<User> userList = [select Id,Name from User where Id=:userId];
            if(userList!=null && userList.size()>0) {userRecord = userList[0];}
            
            if(attendeeRecord==null && userRecord==null)
                {throw new ErrorOccuredException();}
            
            List<VisitOps__Survey__c> surveyList = [select Id,VisitOps__Post_Survey_status__c,VisitOps__Biggest_Fear__c,VisitOps__Accomplishment_Owner_pre__c,
                                                    VisitOps__Satisfaction_Rating__c,VisitOps__Accomplishment_Owner_post__c,VisitOps__Biggest_fear_pick__c,VisitOps__Things_You_Would_Like_To_Change__c,VisitOps__Things_You_Would_Leave_The_Same__c,VisitOps__Recommendation_Strategy__c, CEP_Tools_Comments__c, VisitOps__Recommendation_Comments__c from VisitOps__Survey__c where VisitOps__Visit__c=:visitId AND VisitOps__Attendee__c=:attendeeId AND VisitOps__User__c=:userId limit 1] ;
            if(surveyList!=null && surveyList.size()>0) {
                if(surveyList[0].VisitOps__Post_Survey_status__c) {
                    throw new SurveyAlreadySubmittedException();
                }
                else {
                    existingSurveyId = surveyList[0].Id;
                    preSurveyRecord = surveyList[0];
                }
            }
            if(existingSurveyId==null){
                surveyRecord = new VisitOps__Survey__c();
                surveyRecord.VisitOps__Recommendation_Strategy__c = null;
            }else{
                surveyRecord = new VisitOps__Survey__c(id=existingSurveyId);
            }
            showSubmitButton = true;
            
            //List<Agenda__c> agendaList = [select Id,Agenda_Title__c,Topic__r.TopicCategory__c,Name,(select Id,Presenter_Name__c from Presenter_Agenda_Links__r where Status__c='Accepted') from Agenda__c where Visit__c= :visitId AND Topic__r.TopicCategory__c!='Instructions and Meals'];
            //Exclude Agendas of Type 'Instructions' from post surveys
            List<VisitOps__Agenda__c> agendaList = [select Id,VisitOps__Agenda_Title__c,VisitOps__Topic__r.VisitOps__TopicCategory__c,Name,(select Id,VisitOps__Presenter_Name__c from VisitOps__Presenter_Agenda_Links__r where VisitOps__Status__c='Accepted' and visitOps__attendee__c=null) from VisitOps__Agenda__c where VisitOps__Visit__c= :visitId AND VisitOps__Topic__r.VisitOps__TopicCategory__c!='Instructions'];
            
            AgendaPresenterWrapper agendaPresenterWrapperRecord;
            VisitOps__Agenda_Survey__c agendaSurveyRecord;
            VisitOps__Presenter_Survey__c tempPresenterSurveyRecord;
            List<VisitOps__Presenter_Survey__c> tempAgendaPresenterList;
            
            for(VisitOps__Agenda__c each : agendaList){
                agendaSurveyRecord = new VisitOps__Agenda_Survey__c(VisitOps__Agenda__r=each,VisitOps__Agenda__c=each.Id);
                tempAgendaPresenterList = null;
                if(each.VisitOps__Presenter_Agenda_Links__r!=null && each.VisitOps__Presenter_Agenda_Links__r.size()>0) {
                    tempagendaPresenterList = new List<VisitOps__Presenter_Survey__c>();
                    for(VisitOps__Presenter_Agenda_Link__c eachPresenterLink : each.VisitOps__Presenter_Agenda_Links__r) {
                        tempPresenterSurveyRecord = new VisitOps__Presenter_Survey__c(VisitOps__Presenter_Agenda_Link__r=eachPresenterLink,VisitOps__Presenter_Agenda_Link__c=eachPresenterLink.Id);
                        tempagendaPresenterList.add(tempPresenterSurveyRecord);
                    }
                }
                agendaPresenterWrapperRecord = new AgendaPresenterWrapper(agendaSurveyRecord,tempAgendaPresenterList);
                agendaPresenterWrapperList.add(agendaPresenterWrapperRecord);
            }           
        }catch (SurveyAlreadySubmittedException ex) {
            flag=true;            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,System.Label.VisitOps.Survey_Already_Submitted));
        }catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.VisitOps.Survey_Loading_Error));
            System.debug('Exception occured:'+ex.getMessage());
        }
		return null;
	}

public PageReference refreshPage() {
        constructorCode();
        return null;
    }
	
    public string getDocumentLogoUrl()
    {
        list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName = 'Survey_Logo'];
        System.Url fullFileURL = URL.getOrgDomainUrl();
        //newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
        newString = 'https://' + fullFileURL.getHost() +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
        return newString;
    }
    public List<SelectOption> getRadioOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('0','0'));
        options.add(new SelectOption('1','1'));
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
        options.add(new SelectOption('4','4'));  
        options.add(new SelectOption('5','5')); 
        options.add(new SelectOption('6','6')); 
        options.add(new SelectOption('7','7')); 
        options.add(new SelectOption('8','8')); 
        options.add(new SelectOption('9','9')); 
        options.add(new SelectOption('10','10')); 
        
        return options; 
    }
    
    public List<SelectOption> getEngImpOptsNolabel(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Did Not Help At All',''));
        options.add(new SelectOption('Helped very Little',''));
        options.add(new SelectOption('Neutral','')); 
        options.add(new SelectOption('Helped Somewhat','')); 
        options.add(new SelectOption('Helped Very Much',''));  
        options.add(new SelectOption('N/A','')); 
        return options; 
    }
    
    public List<SelectOption> getEngImpOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Did Not Help At All','Did Not Help At All'));
        options.add(new SelectOption('Helped very Little','Helped very Little'));
        options.add(new SelectOption('Neutral','Neutral')); 
        options.add(new SelectOption('Helped Somewhat','Helped Somewhat')); 
        options.add(new SelectOption('Helped Very Much','Helped Very Much'));  
        options.add(new SelectOption('N/A','N/A')); 
        return options; 
    }
    
    public List<SelectOption> getEngMetOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Did Not Meet Objectives',System.Label.VO_Did_Not_Meet_Objectives));
        options.add(new SelectOption('Met Part of Objectives',System.Label.VO_Met_Part_of_Objectives));
        options.add(new SelectOption('Neutral',System.Label.VO_Neutral)); 
        options.add(new SelectOption('Met Objectives',System.Label.VO_Met_Objectives)); 
        options.add(new SelectOption('Exceeded Objectives',System.Label.VO_Exceeded_Objectives));  
        return options; 
    }
    
    public List<SelectOption> getEngProgOptsNolabel(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Very Difficult',''));
        options.add(new SelectOption('Difficult',''));
        options.add(new SelectOption('Neutral','')); 
        options.add(new SelectOption('Easy','')); 
        options.add(new SelectOption('Very Easy',''));  
        return options; 
    }
    
    public List<SelectOption> getEngProgOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Very Difficult','Very Difficult'));
        options.add(new SelectOption('Difficult','Difficult'));
        options.add(new SelectOption('Neutral','Neutral')); 
        options.add(new SelectOption('Easy','Easy')); 
        options.add(new SelectOption('Very Easy','Very Easy'));
        return options; 
    }
    
    public List<SelectOption> getExpEngOptsNolabel(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Poor',''));
        options.add(new SelectOption('Fair',''));
        options.add(new SelectOption('Neutral','')); 
        options.add(new SelectOption('Good','')); 
        options.add(new SelectOption('Excellent',''));  
        return options; 
    }
    
    public List<SelectOption> getExpEngOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Poor','Poor'));
        options.add(new SelectOption('Fair','Fair'));
        options.add(new SelectOption('Neutral','Neutral')); 
        options.add(new SelectOption('Good','Good')); 
        options.add(new SelectOption('Excellent','Excellent'));  
        return options; 
    }
    
    public List<SelectOption> getLogisticsExpOptsNolabel(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('N/A','N/A'));
        options.add(new SelectOption('Poor',''));
        options.add(new SelectOption('Fair',''));
        options.add(new SelectOption('Neutral','')); 
        options.add(new SelectOption('Good','')); 
        options.add(new SelectOption('Excellent',''));
        
        return options; 
    }
    
    public List<SelectOption> getRadioOptsNoLabel(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('0',''));
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
        options.add(new SelectOption('4','4'));  
        options.add(new SelectOption('5','5')); 
       
        return options;  
              
       
    }
    public List<SelectOption> getRadioRatingLabel(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('N/A','N/A'));
        options.add(new SelectOption('Poor','')); 
        options.add(new SelectOption('','')); 
        options.add(new SelectOption('','')); 
        options.add(new SelectOption('',''));  
        options.add(new SelectOption('Excellent','')); 
       
        return options;  
              
       
    }
    /*public string getDocumentFooterUrl()
{

list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName = 'Survey_Footer']; 
System.Url fullFileURL = URL.getOrgDomainUrl();
//newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
newString = 'https://' + fullFileURL.getHost()  +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
return newString;
} 
public List<SelectOption> getRadioOpts(){
List<SelectOption> options = new List<SelectOption>(); 

options.add(new SelectOption('0','0'));
options.add(new SelectOption('1','1'));
options.add(new SelectOption('2','2')); 
options.add(new SelectOption('3','3')); 
options.add(new SelectOption('4','4'));  
options.add(new SelectOption('5','5')); 
options.add(new SelectOption('6','6')); 
options.add(new SelectOption('7','7')); 
options.add(new SelectOption('8','8')); 
options.add(new SelectOption('9','9')); 
options.add(new SelectOption('10','10')); 

return options; 
}


public List<SelectOption> getRadioOptsNoLabel(){
List<SelectOption> options = new List<SelectOption>(); 
options.add(new SelectOption('0',''));
options.add(new SelectOption('1',''));
options.add(new SelectOption('2','')); 
options.add(new SelectOption('3','')); 
options.add(new SelectOption('4','')); 
options.add(new SelectOption('5','')); 
options.add(new SelectOption('6','')); 
options.add(new SelectOption('7','')); 
options.add(new SelectOption('8','')); 
options.add(new SelectOption('9','')); 
options.add(new SelectOption('10','')); 

return options; 
}
*/
    public PageReference submitSurvey() {
        System.debug('in-----');
        Savepoint sp = Database.setSavepoint();
        if(Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__User_Type__c.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__User_Type__c.isUpdateable()){
            surveyRecord.VisitOps__User_Type__c='Owner';
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
            return null;
        }
        if(Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Post_Survey_status__c.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Post_Survey_status__c.isUpdateable()){
            surveyRecord.VisitOps__Post_Survey_status__c=true;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
            return null;
        }
        
        flag=true;
        flag1=true;    
        /*Making all the required question related flags false*/
        requiredQ1Flag = false;
        requiredQ2Flag = false;
        requiredQ3Flag = false;
        requiredQ4Flag = false;
        requiredQ5Flag = false;
        requiredQ6Flag = false;
        requiredQAgendaFlag = false;
        try{
            List<RecordType> rtList = [select Id,DeveloperName,Name from RecordType where DeveloperName='Visit_Owner_Survey' limit 1];
            
            if(rtList!=null && rtList.size()>0){ 
                if((Schema.SObjectType.VisitOps__Survey__c.Fields.RecordTypeId.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.RecordTypeId.isUpdateable())){
                    surveyRecord.RecordTypeId = rtList[0].Id;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
                    return null;
                }
            }
            
            if(visitId!= null && String.isNotEmpty(visitId) && (existingSurveyId==null)){
                surveyRecord.VisitOps__Visit__c = visitId;
            }
            if(attendeeId!= Null && String.isNotEmpty(attendeeId)){
                if(Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Attendee__c.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Attendee__c.isUpdateable()){
                    surveyRecord.VisitOps__Attendee__c = attendeeId;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
                    return null;
                }
            }
            if(userId!=null && String.isNotEmpty(userId)){
                if(Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__User__c.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__User__c.isUpdateable()){
                    surveyRecord.VisitOps__User__c = userId;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
                    return null;
                }
            }
            if(visitList!=null && visitList.size()>0){
                List<VisitOps__Survey__c> listSurvey = [select Id,VisitOps__Post_Survey_status__c from VisitOps__Survey__c where VisitOps__Visit__c=:visitId AND VisitOps__Attendee__c=:attendeeId AND VisitOps__User__c=:userId limit 1] ;
                if(listSurvey!=null && listSurvey.size()>0) {
                    if(listSurvey[0].VisitOps__Post_Survey_status__c) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.Label.VisitOps.Survey_Already_Submitted));
                        return null;
                    }
                }
                if((Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Visit_Owner__c.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Visit_Owner__c.isUpdateable())){
                    surveyRecord.VisitOps__Visit_Owner__c = visitList[0].VisitOps__VisitOwner__c;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
                    return null;
                }
            }
            Boolean requiredQuestionsFlag = false;
            System.debug('***'+VisitOps_Recommendation_Strategy_Buffer);
            System.debug('***VisitOps__Attendee__c'+surveyRecord.VisitOps__Attendee__c);
            /*Making the required question related flags true or false based on the field values*/
            System.debug('***VisitOps__Recommendation_Strategy__c'+surveyRecord.VisitOps__Recommendation_Strategy__c);
            if(VisitOps_Recommendation_Strategy_Buffer==null || VisitOps_Recommendation_Strategy_Buffer=='')
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'How likely are you to recommend a visit as part of a Sales strategy to other sales people?')); 
                requiredQuestionsFlag = true;   
                requiredQ1Flag = true;
            }
            System.debug('***Engagement_Met_Objectives__c'+surveyRecord.Engagement_Met_Objectives__c);
            if(surveyRecord.Engagement_Met_Objectives__c==null || surveyRecord.Engagement_Met_Objectives__c=='')
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Did the Engagement meet your objectives?')); 
                requiredQuestionsFlag = true;
                requiredQ2Flag = true;
            }
            System.debug('***Improved_Relationship_with_Customer__c'+surveyRecord.Improved_Relationship_with_Customer__c);
            if(surveyRecord.Improved_Relationship_with_Customer__c==null || surveyRecord.Improved_Relationship_with_Customer__c=='' || surveyRecord.Uncovered_new_opportunities__c==null || surveyRecord.Uncovered_new_opportunities__c=='' || surveyRecord.Expanded_deal_size__c==null || surveyRecord.Expanded_deal_size__c=='' || surveyRecord.Accelerated_close_of_deal__c==null || surveyRecord.Accelerated_close_of_deal__c=='')
            {
                System.debug('***Engagement_Impact__c'+surveyRecord.Engagement_Impact__c);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please identify the Engagement impact.')); 
                requiredQuestionsFlag = true;
                requiredQ3Flag = true;
            }
            if(surveyRecord.Requesting_an_engagement__c==null || surveyRecord.Linking_an_Opportunity__c==null || surveyRecord.Completing_Profile_POC_Questionnaire__c==null || surveyRecord.Requesting_an_engagement__c=='' || surveyRecord.Linking_an_Opportunity__c=='' || surveyRecord.Completing_Profile_POC_Questionnaire__c=='')
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please rate the ease of engaging with the Customer Engagement Program Tools.')); 
                requiredQuestionsFlag = true;
                requiredQ4Flag = true;
            }
            if(surveyRecord.Scheduling_Project_Management__c==null || surveyRecord.Logistics__c==null || surveyRecord.Briefing_Consultant_Solution_Architect__c==null || surveyRecord.Day_of_Support__c==null || surveyRecord.Scheduling_Project_Management__c=='' || surveyRecord.Logistics__c=='' || surveyRecord.Briefing_Consultant_Solution_Architect__c=='' || surveyRecord.Day_of_Support__c=='')
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please rate your experience with the Customer Engagement Staff.')); 
                requiredQuestionsFlag = true;
                requiredQ5Flag = true;
            }
            if(surveyRecord.Catering__c==null || surveyRecord.Transportation__c==null || surveyRecord.Evening_Events__c==null || surveyRecord.Hotel__c==null || surveyRecord.Catering__c=='' || surveyRecord.Transportation__c=='' || surveyRecord.Evening_Events__c=='' || surveyRecord.Hotel__c=='')
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please rate the Logistics Experience at your site, if offered.')); 
                /*requiredQuestionsFlag = true;
                requiredQ6Flag = true;*/
            }
            System.debug('***APW1'+agendaPresenterWrapperList);
            for(AgendaPresenterWrapper apw :agendaPresenterWrapperList)
            {
                System.debug('***agendaPresenterWrapperList'+apw.agendaSurvey.VisitOps__Session_Rating__c);
                if(apw.agendaSurvey.VisitOps__Session_Rating__c == null)
                {
                    requiredQuestionsFlag = true;
                    requiredQAgendaFlag = true;
                    break;
                }
                if(apw.presenterSurveyList != null)
                {
                    for(VisitOps__Presenter_Survey__c psl :apw.presenterSurveyList)
                    {
                        System.debug('***VisitOps__Presenter_Rating__c'+psl.VisitOps__Presenter_Rating__c);
                        
                        if(psl.VisitOps__Presenter_Rating__c == null)
                        {
                            requiredQuestionsFlag = true;
                            requiredQAgendaFlag = true;
                            break;
                        }
                    }
                }
            }
            System.debug('***requiredQuestionsFlag'+requiredQuestionsFlag);
            /*Making the flag variable for the disabled fields false if the error flag is made true*/
            if(requiredQuestionsFlag)
            {
                flag = false;
                return null;
            }
            surveyRecord.VisitOps__Recommendation_Strategy__c = Decimal.valueOf(VisitOps_Recommendation_Strategy_Buffer);
            if(existingSurveyId==null){
                if(!Schema.SObjectType.VisitOps__Survey__c.isCreateable()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Survey_Create_Error_Message));
                    return null;
                }
                system.debug('***surveyRecord'+visitRecord.Child_Visit__c);
                if(visitRecord.Child_Visit__c)
                {
                    surveyRecord.VisitOps__User__c = null;
                }
                system.debug('***surveyRecord'+surveyRecord.VisitOps__User__c);
                insert surveyRecord;
            }else {
                if(!Schema.SObjectType.VisitOps__Survey__c.isUpdateable()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Survey_Update_Error_Message));
                    return null;
                }
                
                if(visitRecord.Child_Visit__c)
                {
                    surveyRecord.VisitOps__User__c = null;
                }
                system.debug('***surveyRecord'+surveyRecord);
                update surveyRecord;
            }       
            
            List<VisitOps__Agenda_Survey__c> agendaSurveyList = new List<VisitOps__Agenda_Survey__c>();
            List<VisitOps__Presenter_Survey__c> presenterSurveyList = new List<VisitOps__Presenter_Survey__c>();
            List<VisitOps__Presenter_Survey__c> tempPresenterSurveyList;
            Map<Id,List<VisitOps__Presenter_Survey__c>> agendaPresenterSurveyMap = new Map<Id,List<VisitOps__Presenter_Survey__c>>();
            for(AgendaPresenterWrapper each : agendaPresenterWrapperList) {
                if(Schema.SObjectType.VisitOps__Agenda_Survey__c.Fields.VisitOps__Survey__c.isCreateable() || Schema.SObjectType.VisitOps__Agenda_Survey__c.Fields.VisitOps__Survey__c.isUpdateable()){
                    each.agendaSurvey.VisitOps__Survey__c = surveyRecord.Id;
                    agendaSurveyList.add(each.agendaSurvey);
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
                    return null;
                }
                agendaPresenterSurveyMap.put(each.agendaSurvey.VisitOps__Agenda__r.Id,each.presenterSurveyList);
            }
            System.debug('agendaPresenterSurveyMap-->:'+agendaPresenterSurveyMap);
            if(agendaSurveyList!=null && agendaSurveyList.size()>0) {
                if(!Schema.SObjectType.VisitOps__Agenda_Survey__c.isCreateable()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Agenda_Survey_Error_Message));
                    return null;
                }
                insert agendaSurveyList;
                
                for(VisitOps__Agenda_Survey__c each : agendaSurveyList) {
                    tempPresenterSurveyList = agendaPresenterSurveyMap.get(each.VisitOps__Agenda__r.Id);
                    
                    if(tempPresenterSurveyList!=null && tempPresenterSurveyList.size()>0) {
                        for(VisitOps__Presenter_Survey__c pSurvey : tempPresenterSurveyList) {
                            if(Schema.SObjectType.VisitOps__Presenter_Survey__c.Fields.VisitOps__Agenda_Survey__c.isCreateable() || Schema.SObjectType.VisitOps__Presenter_Survey__c.Fields.VisitOps__Agenda_Survey__c.isUpdateable()){
                                pSurvey.VisitOps__Agenda_Survey__c = each.Id;
                                presenterSurveyList.add(pSurvey);
                            }else{
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
                                return null;
                            }
                        }   
                    }
                }
                
                if(presenterSurveyList!=null && presenterSurveyList.size()>0) {
                    if(!Schema.SObjectType.VisitOps__Presenter_Survey__c.isCreateable()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Presenter_Survey_Error_Message));
                        return null;
                    }
                    insert presenterSurveyList;
                }
            }
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.CONFIRM, System.Label.VisitOps.Survey_Success_Message));      
            showSubmitButton = false;
            system.debug('***showSubmitButton'+showSubmitButton);
            return null;        
        }
        
        catch(DMLException ex){
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getDmlMessage(0)));
            return null;        
        }
        catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.VisitOps.Survey_Committing_Error));          
            return null;
        }
        
    }
    
    
    //wrapper class for agendas
    
    public class AgendaPresenterWrapper{
        public VisitOps__Agenda_Survey__c agendaSurvey {get;set;}
        public List<VisitOps__Presenter_Survey__c> presenterSurveyList {get;set;}
        
        public AgendaPresenterWrapper(VisitOps__Agenda_Survey__c agendaSurvey, List<VisitOps__Presenter_Survey__c> presenterSurveyList){
            this.agendaSurvey = agendaSurvey;
            this.presenterSurveyList = presenterSurveyList;
        }
    }
    
    // Define Exception classes
    public class ErrorOccuredException extends Exception {
        
    }
    public class SurveyAlreadySubmittedException extends Exception {
        
    }
}