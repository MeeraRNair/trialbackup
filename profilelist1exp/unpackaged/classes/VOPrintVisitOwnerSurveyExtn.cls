public class VOPrintVisitOwnerSurveyExtn {
    
    public string visitId {get;set;}
    private String existingSurveyId {get;set;}
    public Boolean showSubmitButton {get;set;}
    private List<VisitOps__Visit__c> visitList{get;set;}
    public VisitOps__Visit__c visitRecord {get;set;}
    public VisitOps__Survey__c surveyRecord {get;set;}
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
    public String visitOpsRecommendationStrategyBuffer{get;set;}
    public String strSelectedLang{get;set;}

    public VOPrintVisitOwnerSurveyExtn(ApexPages.StandardController controller) {
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
            visitOpsRecommendationStrategyBuffer= null;
            agendaPresenterWrapperList = new List<AgendaPresenterWrapper>();
            visitId = ApexPages.currentPage().getParameters().get('visitId');
            strSelectedLang = ApexPages.currentPage().getParameters().get('lang');
            if(visitId!=null && visitId!='') 
            {
                visitId = String.escapeSingleQuotes(visitId);
            }
            else 
            {
                throw new ErrorOccuredException();
            }

            visitList = [select Id,Name,VisitOps__VisitName__c,VisitOps__ArrivalDateTime__c,VisitOps__DepartureDateTime__c,VisitOps__ArrivalDateTimeLocationTZ__c,VisitOps__DepartureDateTimeLocationTZ__c,
                         VisitOps__Location__c,VisitOps__Location__r.Name,VisitOps__VisitManager__c,VisitOps__VisitCoordinator__c,VisitOps__VisitCoordinator__r.Name,
                         Owner.Name,VisitOps__VisitOwner__r.Name,VisitOps__VisitOwner__c, Child_Visit__c from VisitOps__Visit__c where Id=:visitid];
            if(visitList!=null && visitList.size()>0) {
                visitRecord = visitList[0];
                coordinatorName = visitList[0].VisitOps__VisitCoordinator__r.Name;
                system.debug(visitList[0].VisitOps__VisitOwner__r.Name);
                visitOwnerName = visitList[0].VisitOps__VisitOwner__r.Name;               
            }
            else 
            {
                throw new ErrorOccuredException();
            }
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
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.Label.VisitOps.Survey_Loading_Error));
            System.debug('Exception occured:'+ex.getMessage());
        }
    }
    public string getDocumentLogoUrl()
    {
        list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName = 'Survey_Logo'];
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        //newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
        newString = System.Label.VisitOps.VisitOps_Site_Url +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
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
    
    //wrapper class for agendas
    
    public class AgendaPresenterWrapper{
        public VisitOps__Agenda_Survey__c agendaSurvey {get;set;}
        public List<VisitOps__Presenter_Survey__c> listPresenterSurvey {get;set;}
        
        public AgendaPresenterWrapper(VisitOps__Agenda_Survey__c agendaSurvey, List<VisitOps__Presenter_Survey__c> listPresenterSurvey ){
            this.agendaSurvey = agendaSurvey;
            this.listPresenterSurvey = listPresenterSurvey;
        }
    }
    
    // Define Exception classes
    public class ErrorOccuredException extends Exception {
        
    }
    public class SurveyAlreadySubmittedException extends Exception {
        
    }
    
    /*//Temporary Fix for Agenda Survey Insert
    public void createAgendaSurveys(){
        VOPrintVisitOwnerSurveyExtn.createAgendaSurveys(visitId);
    }
    @future
    public static void createAgendaSurveys(Id visitId){
        List<VisitOps__Agenda__c> agendaList = [select Id,VisitOps__Agenda_Title__c,VisitOps__Topic__r.VisitOps__TopicCategory__c,Name,(select Id,VisitOps__Presenter_Name__c from VisitOps__Presenter_Agenda_Links__r where VisitOps__Status__c='Accepted' and visitOps__attendee__c=null) from VisitOps__Agenda__c where VisitOps__Visit__c= :visitId AND VisitOps__Topic__r.VisitOps__TopicCategory__c!='Instructions'];
        List<VisitOps__Agenda_Survey__c> listagendaSurvey = new List<VisitOps__Agenda_Survey__c>();
        
        for(VisitOps__Survey__c survey : [Select id,(Select id, VisitOps__Survey__c, VisitOps__Agenda__c from VisitOps__Agenda_Survey__r) from VisitOps__Survey__c where VisitOps__Visit__c = :visitId AND RecordType.Name = 'Visit Owner Survey']){
            List<Id> listExistingAgendas = new List<Id>();
            if(survey.VisitOps__Agenda_Survey__r==null){  
            }
            else if(survey.VisitOps__Agenda_Survey__r.size()!=agendaList.size()){
                for(VisitOps__Agenda_Survey__c agendaSurvey : survey.VisitOps__Agenda_Survey__r){
                    listExistingAgendas.add(agendaSurvey.VisitOps__Agenda__c);
                }
            }
            else{
                continue;
            }
            for(VisitOps__Agenda__c agenda : agendaList){
                if(listExistingAgendas.isEmpty() || !listExistingAgendas.contains(agenda.id)){
                    listagendaSurvey.add(new VisitOps__Agenda_Survey__c(VisitOps__Agenda__c=agenda.id,VisitOps__Survey__c=survey.id));
                }
            }
        }
        System.debug(listagendaSurvey);
        insert listagendaSurvey;
        //Temporary fix end
    }*/
}