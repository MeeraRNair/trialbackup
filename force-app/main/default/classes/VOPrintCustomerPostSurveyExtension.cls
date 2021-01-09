public with sharing class VOPrintCustomerPostSurveyExtension {
    
    
    public string visitId {get;set;}
    private List<visitops__Visit__c> visitList {get;set;}
    public visitops__Visit__c visitRecord {get;set;}
    public visitops__Survey__c surveyRecord {get;set;}
    public String coordinatorName {get;set;}
    public boolean flag{get;set;}
    public boolean flag1{get;set;}
    public string newString{get;set;}
    public List<AgendaPresenterWrapper> agendaPresenterWrapperList {get;set;}
    public String arrivalDate{get;set;}
    
    //print page
    public String selectedAgree{get;set;}
    public String selectedImpact{get;set;}
    public String selectedDecision{get;set;}
    
    public boolean showPresentersGrid{get;set;}
	public string strSelectedLang {get;set;}
    
    public VOPrintCustomerPostSurveyExtension(ApexPages.StandardController controller) {
        try {
            flag=false; 
            flag1=false;
            visitId = ApexPages.currentPage().getParameters().get('visitId');
			strSelectedLang = ApexPages.currentPage().getParameters().get('lang');
            //if(visitId!=null && visitId!='') visitId = String.escapeSingleQuotes(visitId);
            //else throw new ErrorOccuredException();
            
            //attendeeId =ApexPages.currentPage().getParameters().get('attendeeId');
            // if(attendeeId!=null && attendeeId!='') attendeeId = String.escapeSingleQuotes(attendeeId);
            // else throw new ErrorOccuredException();
            showPresentersGrid = true;
            visitList = [select Id,Name,visitops__VisitName__c,visitops__ArrivalDateTime__c,visitops__DepartureDateTime__c,visitops__ArrivalDateTimeLocationTZ__c,visitops__DepartureDateTimeLocationTZ__c,visitops__Location__c,visitops__VisitType__c,visitops__Location__r.Name,visitops__VisitManager__c,visitops__VisitCoordinator__c,visitops__VisitCoordinator__r.Name,Owner.Name,visitops__VisitOwner__c,visitops__VisitOwner__r.Name from visitops__Visit__c where Id=:visitid];
            if(visitList!=null && visitList.size()>0) {
                Map<String,String> monthNamesMap = new Map<String,String>{'01'=>'January','02'=>'February','03'=>'March','04'=>'April',
                    '05'=>'May','06'=>'June','07'=>'July','08'=>'August',
                    '09'=>'September','10'=>'October','11'=>'November','12'=>'December'};
                        visitRecord = visitList[0];
                coordinatorName = visitList[0].visitops__VisitCoordinator__r.Name;
                List<String> arrivalDateList = visitRecord.visitops__ArrivalDateTimeLocationTZ__c.split('-'); //yyyy-mm-dd hh:mm:ss
                if(!arrivalDateList.isEmpty()){
                    arrivalDate = monthNamesMap.get(arrivalDateList[1])+ ' '+ arrivalDateList[2].split(' ')[0] + ', '+ arrivalDateList[0]; //Month_Name Date, Year
                }
                List<visitops__LocationTypeLink__c> loctyp = [select id,visitops__Hide_Presenters_on_Survey__c from visitops__LocationTypeLink__c where visitops__Location__c=:visitRecord.visitops__Location__c AND visitops__VisitType__c=:visitRecord.visitops__VisitType__c];
                if(!loctyp.isEmpty() && loctyp[0].visitops__Hide_Presenters_on_Survey__c){
                    showPresentersGrid = false;
                }
            }
            else {throw new ErrorOccuredException();}
            
            
            surveyRecord = new visitops__Survey__c();
            //showSubmitButton = true;    
            
            //List<visitops__Agenda__c> agendaList = [select Id,visitops__Agenda_Title__c,Name,(select Id,visitops__Presenter_Name__c from visitops__Presenter_Agenda_Links__r where visitops__Status__c='Accepted') from visitops__Agenda__c where visitops__Visit__c= :visitId];
            //Exclude Agendas of Type 'Instructions' from post surveys
            List<visitops__Agenda__c> agendaList = [select Id,visitops__Agenda_Title__c,Name,(select Id,visitops__Presenter_Name__c from visitops__Presenter_Agenda_Links__r where visitops__Status__c='Accepted'  and visitops__attendee__c=null) from visitops__Agenda__c where visitops__Visit__c= :visitId AND visitops__Show_on_Customer_Survey__c = true order by visitops__Start_Time__c,visitops__Agenda_Title__c];
            
            AgendaPresenterWrapper agendaPresenterWrapperRecord;
            visitops__Agenda_Survey__c agendaSurveyRecord;
            visitops__Presenter_Survey__c tempPresenterSurveyRecord;
            List<visitops__Presenter_Survey__c> tempAgendaPresenterList;
            agendaPresenterWrapperList = new List<AgendaPresenterWrapper>();
            for(visitops__Agenda__c each : agendaList){
                agendaSurveyRecord = new visitops__Agenda_Survey__c(visitops__Agenda__r=each,visitops__Agenda__c=each.Id);
                tempAgendaPresenterList = null;
                if(each.visitops__Presenter_Agenda_Links__r!=null && each.visitops__Presenter_Agenda_Links__r.size()>0) {
                    tempagendaPresenterList = new List<visitops__Presenter_Survey__c>();
                    for(visitops__Presenter_Agenda_Link__c eachPresenterLink : each.visitops__Presenter_Agenda_Links__r) {
                        tempPresenterSurveyRecord = new visitops__Presenter_Survey__c(visitops__Presenter_Agenda_Link__r=eachPresenterLink,visitops__Presenter_Agenda_Link__c=eachPresenterLink.Id);
                        tempagendaPresenterList.add(tempPresenterSurveyRecord);
                    }
                }
                agendaPresenterWrapperRecord = new AgendaPresenterWrapper(agendaSurveyRecord,tempAgendaPresenterList);
                agendaPresenterWrapperList.add(agendaPresenterWrapperRecord);
            }
            
        }
        catch(Exception ex) {ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error occured while loading the Survey'));System.debug('Exception occured:'+ex.getMessage());}
    }
    public string getDocumentLogoUrl()
    { 
        list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName = 'Survey_Logo'];
        System.Url fullFileURL = URL.getOrgDomainUrl();
        //newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        newString = 'https://' + fullFileURL.getHost() +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        return newString;
    }
    /*public string getDocumentFooterUrl()
{

list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName = 'Survey_Footer'];
String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
//newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
newString = System.Label.VisitOps_Site_Url +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
return newString;
} */
    public List<SelectOption> getRadioOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('N/A','N/A'));
        
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
        options.add(new SelectOption('4','4'));  
        options.add(new SelectOption('5','5')); 
        
        return options; 
    }
    public List<SelectOption> getRadioOpts1(){
        List<SelectOption> options = new List<SelectOption>();        
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
        options.add(new SelectOption('4','4'));  
        options.add(new SelectOption('5','5')); 
        
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
    
    public List<SelectOption> getEngProgOptsNolabel(){
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Not At All Confident','Not At All Confident'));
        options.add(new SelectOption('Somewhat Confident','Somewhat Confident'));
        options.add(new SelectOption('Neutral','Neutral'));
        options.add(new SelectOption('Confident','Confident'));
        options.add(new SelectOption('Very Confident','Very Confident'));
        
        return options; 
    }
    //For print page
    public list<selectOption> getMyCheckboxes(){
        
        List<SelectOption> myOptions = new List<SelectOption>();
        
        Schema.DescribeFieldResult agreementPicklist= Schema.sObjectType.visitops__Survey__c.fields.visitops__Accomplishment__c;
        Schema.PicklistEntry[] values = agreementPicklist.getPickListValues();
        System.debug('#####'+values);   
        for(Schema.PicklistEntry val : values){
            myOptions.add(new selectOption(String.valueOf(val.getValue()), val.getLabel()));
        }
        
        return myOptions;
    }
    
    public list<selectOption> getObjectiveCheckboxes(){
        
        List<SelectOption> myOptions = new List<SelectOption>();
        
        Schema.DescribeFieldResult agreementPicklist= Schema.sObjectType.visitops__Survey__c.fields.Understood_Your_Objectives_Before__c;
        Schema.PicklistEntry[] values = agreementPicklist.getPickListValues();
        System.debug('#####'+values);   
        for(Schema.PicklistEntry val : values){
            myOptions.add(new selectOption(String.valueOf(val.getValue()), val.getLabel()));
        }
        
        return myOptions;
    }
    
    public list<selectOption> getobjectiveduringCheckboxes(){
        
        List<SelectOption> myOptions = new List<SelectOption>();
        
        Schema.DescribeFieldResult agreementPicklist= Schema.sObjectType.visitops__Survey__c.fields.Met_Your_Objectives_During__c;
        Schema.PicklistEntry[] values = agreementPicklist.getPickListValues();
        System.debug('#####'+values);   
        for(Schema.PicklistEntry val : values){
            myOptions.add(new selectOption(String.valueOf(val.getValue()), val.getLabel()));
        }
        
        return myOptions;
    }
    
    public list<selectOption> getDigitalCheckboxes(){
        
        List<SelectOption> myOptions = new List<SelectOption>();
        
        Schema.DescribeFieldResult agreementPicklist= Schema.sObjectType.visitops__Survey__c.fields.Digital_Transformation_Journey__c;
        Schema.PicklistEntry[] values = agreementPicklist.getPickListValues();
        System.debug('#####'+values);   
        for(Schema.PicklistEntry val : values){
            myOptions.add(new selectOption(String.valueOf(val.getValue()), val.getLabel()));
        }
        
        return myOptions;
    }
    public list<selectOption> getConfidenceCheckboxes(){
        
        List<SelectOption> myOptions = new List<SelectOption>();
        
        Schema.DescribeFieldResult agreementPicklist= Schema.sObjectType.visitops__Survey__c.fields.Confidence_Before_Engagement__c;
        Schema.PicklistEntry[] values = agreementPicklist.getPickListValues();
        System.debug('#####'+values);   
        for(Schema.PicklistEntry val : values){
            myOptions.add(new selectOption(String.valueOf(val.getValue()), val.getLabel()));
        }
        
        return myOptions;
    }
    public list<selectOption> getConfidenceAfterCheckboxes(){
        
        List<SelectOption> myOptions = new List<SelectOption>();
        
        Schema.DescribeFieldResult agreementPicklist= Schema.sObjectType.visitops__Survey__c.fields.Confidence_After_Engagement__c;
        Schema.PicklistEntry[] values = agreementPicklist.getPickListValues();
        System.debug('#####'+values);   
        for(Schema.PicklistEntry val : values){
            myOptions.add(new selectOption(String.valueOf(val.getValue()), val.getLabel()));
        }
        
        return myOptions;
    }
    
    //wrapper class for agendas
    
    public class AgendaPresenterWrapper{
        
        public visitops__Agenda_Survey__c agendaSurvey {get;set;}
        public List<visitops__Presenter_Survey__c> presenterSurveyList {get;set;}
        
        public AgendaPresenterWrapper(visitops__Agenda_Survey__c agendaSurvey, List<visitops__Presenter_Survey__c> presenterSurveyList){
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