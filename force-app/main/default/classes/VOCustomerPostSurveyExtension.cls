public with sharing class VOCustomerPostSurveyExtension {
    
    public string visitId {get;set;}
    public String attendeeId {get;set;}
    public String existingSurveyId {get;set;}
    private List<VisitOps__Visit__c> visitList {get;set;}
    public Boolean showSubmitButton {get;set;}
    public VisitOps__Visit__c visitRecord {get;set;}
    public VisitOps__Attendee__c attendeeRecord {get;set;}
    public VisitOps__Survey__c surveyRecord {get;set;}
    public String thingsToAccomplishPre {get;set;}
    public String coordinatorName {get;set;}
    public VisitOps__Survey__c preSurveyRecord{get;set;}
    public boolean flag{get;set;}
    public boolean flag1{get;set;}
    public string newString{get;set;}
    public String arrivalDate{get;set;}
    public List<AgendaPresenterWrapper> agendaPresenterWrapperList {get;set;}
    public boolean showPresentersGrid{get;set;}
    public Boolean isError{get;set;}
    public Boolean requiredQ1Flag{get;set;}
    public Boolean requiredQ2Flag{get;set;}
    public Boolean requiredQ3Flag{get;set;}
    public Boolean requiredQ4Flag{get;set;}
    public Boolean requiredQ5Flag{get;set;}
    public Boolean requiredQ6Flag{get;set;}
    public Boolean requiredQ7Flag{get;set;}
    public Decimal recommendPost;
	public String strSelectedLang{get;set;}
    public List<selectoption> listOfLang {get;set;}
    
    public VOCustomerPostSurveyExtension(ApexPages.StandardController controller) {
        listOfLang = new List<selectOption>();

        Schema.DescribeFieldResult fieldResult = VisitOps__Attendee__c.VisitOps__Survey_Language__c.getDescribe();
        List<Schema.PicklistEntry> listPickListEntries = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry picklistEntry : listPickListEntries){
            listOfLang.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }

        strSelectedLang = ApexPages.currentPage().getParameters().get('lang');
    }
	
	public PageReference constructorCode(){
		try {
            requiredQ1Flag = false;
            requiredQ2Flag = false;
            requiredQ3Flag = false;
            requiredQ4Flag = false;
            requiredQ5Flag = false;
            requiredQ6Flag = false;
            requiredQ7Flag = false;
            flag=false; 
            flag1=false;
            visitId = ApexPages.currentPage().getParameters().get('visitId');
            if(visitId!=null && visitId!='') {visitId = String.escapeSingleQuotes(visitId);}
            else {throw new ErrorOccuredException();}
            
            attendeeId =ApexPages.currentPage().getParameters().get('attendeeId');
            if(attendeeId!=null && attendeeId!='') {attendeeId = String.escapeSingleQuotes(attendeeId);}
            else {throw new ErrorOccuredException();}
            showPresentersGrid = true;
            visitList = [select Id,Name,VisitOps__VisitName__c,VisitOps__ArrivalDateTime__c,VisitOps__DepartureDateTime__c,VisitOps__ArrivalDateTimeLocationTZ__c,VisitOps__DepartureDateTimeLocationTZ__c,VisitOps__Location__c,VisitOps__VisitType__c,VisitOps__Location__r.Name,VisitOps__VisitManager__c,VisitOps__VisitCoordinator__c,VisitOps__VisitCoordinator__r.Name,Owner.Name,VisitOps__VisitOwner__c,VisitOps__VisitOwner__r.Name from VisitOps__Visit__c where Id=:visitid];
            if(visitList!=null && visitList.size()>0) {
                Map<String,String> monthNamesMap = new Map<String,String>{'01'=>'January','02'=>'February','03'=>'March','04'=>'April',
                    '05'=>'May','06'=>'June','07'=>'July','08'=>'August',
                    '09'=>'September','10'=>'October','11'=>'November','12'=>'December'};
                        visitRecord = visitList[0];
                coordinatorName = visitList[0].VisitOps__VisitCoordinator__r.Name;
                List<String> arrivalDateList = visitRecord.VisitOps__ArrivalDateTimeLocationTZ__c.split('-'); //yyyy-mm-dd hh:mm:ss
                if(!arrivalDateList.isEmpty()){
                    arrivalDate = monthNamesMap.get(arrivalDateList[1])+ ' '+ arrivalDateList[2].split(' ')[0] + ', '+ arrivalDateList[0]; //Month_Name Date, Year
                }
                List<VisitOps__LocationTypeLink__c> loctyp = [select VisitOps__Hide_Presenters_on_Survey__c from VisitOps__LocationTypeLink__c where VisitOps__Location__c=:visitRecord.VisitOps__Location__c AND VisitOps__VisitType__c=:visitRecord.VisitOps__VisitType__c];
                if(!loctyp.isEmpty() && loctyp[0].VisitOps__Hide_Presenters_on_survey__c){
                    showPresentersGrid = false;
                }
            }
            else {throw new ErrorOccuredException();}
            
            List<VisitOps__Attendee__c> attendeeList = [SELECT Id, Name,VisitOps__FirstName__c,VisitOps__LastName__c FROM VisitOps__Attendee__c WHERE Id = :attendeeId];
            if(attendeeList!=null && attendeeList.size()>0) {attendeeRecord = attendeeList[0];}
            else {throw new ErrorOccuredException();}
            
            List<VisitOps__Survey__c> surveyList = [select Id,VisitOps__isPrint__c,VisitOps__Post_Survey_status__c, WhatInfluencedYourDecision__c, VisitOps__Things_to_Accomplish__c,VisitOps__Likely_To_Recommend__c from VisitOps__Survey__c where VisitOps__Visit__c=:visitId AND VisitOps__Attendee__c=:attendeeId limit 1] ;
            if(surveyList!=null && surveyList.size()>0) {
                if(surveyList[0].VisitOps__Post_Survey_status__c && !surveyList[0].VisitOps__isPrint__c) {
                    throw new SurveyAlreadySubmittedException();
                }
                else {
                    existingSurveyId = surveyList[0].Id;
                    preSurveyRecord=surveyList[0];
                    thingsToAccomplishPre = surveyList[0].VisitOps__Things_to_Accomplish__c;
                }
            }
            if(existingSurveyId==null){
                surveyRecord = new VisitOps__Survey__c();
            }else{
                surveyRecord = new VisitOps__Survey__c(id=existingSurveyId);
            }
            showSubmitButton = true;    
            
            //List<VisitOps__Agenda__c> agendaList = [select Id,Agenda_Title__c,Name,(select Id,Presenter_Name__c from Presenter_Agenda_Links__r where Status__c='Accepted') from VisitOps__Agenda__c where VisitOps__Visit__c= :visitId];
            
            List<VisitOps__Agenda__c> agendaList = [select Id,VisitOps__Agenda_Title__c,Name,(select Id,VisitOps__Presenter_Name__c from VisitOps__Presenter_Agenda_Links__r where VisitOps__Status__c='Accepted' and visitops__attendee__c=null) from VisitOps__Agenda__c where VisitOps__Visit__c= :visitId AND VisitOps__Show_on_Customer_Survey__c = true order by VisitOps__Start_Time__c,VisitOps__Agenda_Title__c];
            
            AgendaPresenterWrapper agendaPresenterWrapperRecord;
            VisitOps__Agenda_Survey__c agendaSurveyRecord;
            VisitOps__Presenter_Survey__c tempPresenterSurveyRecord;
            List<VisitOps__Presenter_Survey__c> tempAgendaPresenterList;
            agendaPresenterWrapperList = new List<AgendaPresenterWrapper>();
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
            
        }
        
        catch (SurveyAlreadySubmittedException ex) {ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,System.Label.VisitOps.Survey_Already_Submitted));}
        catch(Exception ex) {
            system.debug('surveyRecord**'+surveyRecord);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.Label.VisitOps.Survey_Loading_Error));System.debug('Exception occured:'+ex.getMessage()+'line'+ex.getlinenumber());
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
        // newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        newString = 'https://' + fullFileURL.getHost() +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        //newString =  fullFileURL +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        
        
        
        return newString;
    }
    public string getDocumentFooterUrl()
    {
        
        list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName = 'Survey_Footer'];
        System.Url fullFileURL = URL.getOrgDomainUrl();
        //newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        newString = 'https://' + fullFileURL.getHost() +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        return newString;
    } 
    public List<SelectOption> getRadioOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
        options.add(new SelectOption('4','4'));  
        options.add(new SelectOption('5','5')); 
       
        return options; 
    }
     public List<SelectOption> getRadioOpts1(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('0','N/A'));
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
        options.add(new SelectOption('4','4'));  
        options.add(new SelectOption('5','5')); 
       
        return options; 
    } 
      public List<SelectOption> getRadioOpts2(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('','N/A'));
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
        options.add(new SelectOption('4','4'));  
        options.add(new SelectOption('5','5')); 
       
        return options; 
    } 
    public List<SelectOption> getsatRadioOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('0','0'));
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
        options.add(new SelectOption('4','4'));  
        options.add(new SelectOption('5','5')); 
        options.add(new SelectOption('','N/A'));
        return options; 
    }
    public List<SelectOption> getEngProgOptsNolabel(){
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Not At All Confident','Not At All Confident'));
        options.add(new SelectOption('Somewhat Confident','Somewhat Confident'));
        options.add(new SelectOption('Neutral','Neutral'));
        options.add(new SelectOption('Confident','Confident'));
        options.add(new SelectOption('Very Confident','Very Confident'));
                  
        return options; 
    }
    public List<SelectOption> getRadioOptions(){
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
    public List<SelectOption> getPercentRadioOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('0','0%'));
        options.add(new SelectOption('10','10%')); 
        options.add(new SelectOption('20','20%')); 
        options.add(new SelectOption('30','30%')); 
        options.add(new SelectOption('40','40%')); 
        options.add(new SelectOption('50','50%')); 
        options.add(new SelectOption('60','60%')); 
        options.add(new SelectOption('70','70%')); 
        options.add(new SelectOption('80','80%')); 
        options.add(new SelectOption('90','90%')); 
        options.add(new SelectOption('100','100%'));
        return options; 
    }
    public List<SelectOption> getRadio(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes',''));
        options.add(new SelectOption('SomeWhat','')); 
        options.add(new SelectOption('NotReally','')); 
        options.add(new SelectOption('N/A','')); 
        return options; 
    }
    public PageReference submitSurvey() {
        requiredQ1Flag = false;
        requiredQ2Flag = false;
        requiredQ3Flag = false;
        requiredQ4Flag = false;
        requiredQ5Flag = false;
        requiredQ6Flag = false;
        requiredQ7Flag = false;
        
       // recommendPost = surveyRecord.VisitOps__Likely_To_Recommend_Post__c;
       // system.debug('=:recommendPost:='+recommendPost);
        system.debug('=:surveyRecord.VisitOps__Likely_To_Recommend_Post__c:=' +surveyRecord.VisitOps__Likely_To_Recommend_Post__c);
        system.debug('=:surveyRecord.Confidence_Before_Engagement__c:=' +surveyRecord.Confidence_Before_Engagement__c);
        system.debug('=:surveyRecord.VisitOps__Satisfaction_Rating__c:=' +surveyRecord.VisitOps__Satisfaction_Rating__c);
        system.debug('=:surveyRecord.Anything_Not_Addressed_During_Engagement__c:=' +surveyRecord.Anything_Not_Addressed_During_Engagement__c);
        
        Savepoint sp = Database.setSavepoint();
        if(Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__User_Type__c.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__User_Type__c.isUpdateable()){
            surveyRecord.VisitOps__User_Type__c='Customer';
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
        if(Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__isPrint__c.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__isPrint__c.isUpdateable()){
            surveyRecord.VisitOps__isPrint__c = false;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
            return null;
        }
        isError=false;
        system.debug('surveyRecord**'+surveyRecord);
        if(surveyRecord.VisitOps__Likely_To_Recommend_Post__c==null){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Please complete How likely is it that you would recommend Dell Technologies '));
            requiredQ1Flag=true;
            system.debug('=:surveyRecord.VisitOps__Likely_To_Recommend_Post__c:=' +surveyRecord.VisitOps__Likely_To_Recommend_Post__c);
            isError=true;
        }
        /*
        if(surveyRecord.Understood_Your_Objectives_Before__c=='' || surveyRecord.Understood_Your_Objectives_Before__c==null){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Please complete Understood your Objectives'));
            requiredQ2Flag=true;
            isError=true;
        }
        if(surveyRecord.Met_Your_Objectives_During__c=='' || surveyRecord.Met_Your_Objectives_During__c==null){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Please complete Met your Objectives'));
            requiredQ3Flag=true;
            isError=true;
        } 
        if(!surveyRecord.Cloud_Native_Applications__c && !surveyRecord.Data_Analytics__c 
           && !surveyRecord.Internet_of_Things__c && !surveyRecord.Hybrid_Cloud__c && !surveyRecord.Converged_Hyper_converged_Infrastructure__c
           && !surveyRecord.Operating_Model__c && !surveyRecord.Client_Devices__c && !surveyRecord.Desktop_Virtualization__c && !surveyRecord.End_point_Security__c && !surveyRecord.PC_lifecycle_services__c && !surveyRecord.Infrastructure_Security__c
           && !surveyRecord.Threat_Identification_and_Response__c && !surveyRecord.Business_Risk_Management__c && !surveyRecord.Software_defined_Storage__c && !surveyRecord.All_Flash_Primary_Storage__c && !surveyRecord.Business_resiliency__c
           && !surveyRecord.Server_Virtualization__c && !surveyRecord.Networking__c && !surveyRecord.OEM__c && (surveyRecord.Anything_Not_Addressed_During_Engagement__c==null || surveyRecord.Anything_Not_Addressed_During_Engagement__c=='')){
               //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Please complete Key Focus Area'));
               requiredQ4Flag=true;
               isError=true;
           } 
        if(surveyRecord.Digital_Transformation_Journey__c=='' || surveyRecord.Digital_Transformation_Journey__c==null){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Please complete Digital Transformation Journey'));
            requiredQ5Flag=true;
            isError=true;
        } */
        if(surveyRecord.Confidence_Before_Engagement__c=='' || surveyRecord.Confidence_Before_Engagement__c==null ){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Please complete Confidence Before Engagement'));
            requiredQ6Flag=true;
            isError=true;
                       
            system.debug('=:surveyRecord.Confidence_Before_Engagement__c:=' +surveyRecord.Confidence_Before_Engagement__c);
        }
        if(surveyRecord.Confidence_After_Engagement__c=='' || surveyRecord.Confidence_After_Engagement__c==null){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Please complete Confidence After Engagement'));
                        
            requiredQ6Flag=true;
            isError=true;
        }
        if(surveyRecord.VisitOps__Satisfaction_Rating__c == 0 || surveyRecord.VisitOps__Satisfaction_Rating__c==null){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Please complete Confidence After Engagement'));
            requiredQ7Flag=true;
            isError=true;
            system.debug('=:surveyRecord.VisitOps__Satisfaction_Rating__c:=' +surveyRecord.VisitOps__Satisfaction_Rating__c);
        }
        
        if(isError){
            if(recommendPost != NULL){
                //surveyRecord.VisitOps__Likely_To_Recommend_Post__c = recommendPost;
                system.debug('=:recommendPost:='+recommendPost+'=:surveyRecord.VisitOps__Likely_To_Recommend_Post__c:=' +surveyRecord.VisitOps__Likely_To_Recommend_Post__c);
            }
            return null;
        }
        flag=true;  
        flag1=true; 
        try{
            List<RecordType> rtList = [select Id,DeveloperName,Name from RecordType where DeveloperName='Customer_Survey' limit 1];
            if(rtList!=null && rtList.size()>0){ 
                List<VisitOps__Survey__c> listSurvey = [select Id,VisitOps__Post_Survey_status__c from VisitOps__Survey__c where VisitOps__Visit__c=:visitId AND VisitOps__Attendee__c=:attendeeId AND VisitOps__Visit__c=:visitId limit 1] ;
                if(listSurvey!=null && listSurvey.size()>0) {
                    if(listSurvey[0].VisitOps__Post_Survey_status__c) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.Label.VisitOps.Survey_Already_Submitted));
                        return null;
                    }
                }
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
                if((Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Attendee__c.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Attendee__c.isUpdateable())){
                    surveyRecord.VisitOps__Attendee__c = attendeeId;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
                    return null;
                }
            }
            
            if(visitList!=null && visitList.size()>0){
                if((Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Visit_Owner__c.isCreateable() || Schema.SObjectType.VisitOps__Survey__c.Fields.VisitOps__Visit_Owner__c.isUpdateable())) {
                    surveyRecord.VisitOps__Visit_Owner__c = visitList[0].VisitOps__VisitOwner__c;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Permissions_Error_Message));
                    return null;
                }
            }
            
            if(existingSurveyId==null ){
                if(!Schema.SObjectType.VisitOps__Survey__c.isCreateable() ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Survey_Create_Error_Message));
                    return null;
                }
                insert surveyRecord;            
            }
            else {
                if(!Schema.SObjectType.VisitOps__Survey__c.isUpdateable() ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Survey_Update_Error_Message));
                    return null;
                }
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
                    if(!Schema.SObjectType.VisitOps__Agenda_Survey__c.isCreateable()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.Label.VisitOps.Presenter_Survey_Error_Message));
                        return null;
                    }
                    insert presenterSurveyList;
                }
                
            }
            
            if(!isError){
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.CONFIRM, System.Label.VisitOps.Survey_Success_Message));      
                showSubmitButton = false;
            }else{
                showSubmitButton = true;
            }
            return null;        
        }
        
        catch(DMLException ex){Database.rollback(sp);ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR, ex.getDmlMessage(0)));return null;}
        catch(Exception ex) {Database.rollback(sp);ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.VisitOps.Survey_Committing_Error));return null;}
        
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