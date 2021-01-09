public with sharing class VOAgendaPrintViewExtensionController {
    
    private String visitId {get;set;}
    private List<VisitOps__Agenda__c> agendaItemsList {get;set;}
    public VisitOps__Visit__c visitRecord {get;set;}
    private Map<Date,List<AgendaRecordFormat>> agendaDateMap = new Map<Date,List<AgendaRecordFormat>>();
    public List<AgendaWrapper> awList {get;set;}
    public String view {get;set;}
    public String fileType {get;set;}
    public String renderPDF {get;set;}
    public String contentType {get;set;}
    public string newString{get;set;}
    public list<string> AttendeesWithoutComapnyList {get; set;}
    public Map<String, List<String>> AttendeeContactMap {get; set;}
    public Map<String, String> AttendeeContactMap1 {get; set;}
    public Map<String, List<String>> AttendeeUserMap {get; set;}
    public Map<String, List<String>> AttendeeAdHocUserMap {get; set;}
    public Map<String, List<String>> OtherAttendeesMap {get; set;}
    
    public Boolean isAttendeeContactMapNotEmpty {get{return AttendeeContactMap.size()>0;}}
    public Boolean isAttendeeUserMapNotEmpty {get{return AttendeeUserMap.size()>0;}}
    public Boolean isAttendeeAdHocUserMapNotEmpty {get{return AttendeeAdHocUserMap.size()>0;}}
    public Boolean isOtherAttendeesMapNotEmpty {get{return OtherAttendeesMap.size()>0;}}
            
    //public AgendaPrintViewExtension.AgendaPrintViewExtension(ApexPages.StandardController controller) {
    public VOAgendaPrintViewExtensionController() {
        try{
            visitId = ApexPages.currentPage().getParameters().get('visitId');
            view = ApexPages.currentPage().getParameters().get('viewType');
            fileType = ApexPages.currentPage().getParameters().get('selectedTypeofFile');
            System.debug('visitId---'+visitId);
            if(visitId!=null && visitId!='') {
                visitRecord = [select Id,Name,VisitOps__VisitName__c,VisitOps__Room__r.Name,VisitOps__ArrivalDateTime__c,VisitOps__ArrivalDateTimeLocationTZ__c,VisitOps__DressCode__c from VisitOps__Visit__c where Id=:visitId]; 
                if(view!=null && view!='' && view=='Customer'){
                    agendaItemsList = [select  Id,Name,VisitOps__Agenda_Title__c,VisitOps__Place__r.Name,VisitOps__Room__r.Name,VisitOps__Start_Time__c,VisitOps__StartTimeLocationTZ__c,VisitOps__Catering_Menu_Item__r.VisitOps__MenuItem__c,VisitOps__Details__c,VisitOps__Catering_Menu_Item__r.VisitOps__MenuType__c,VisitOps__Objectives__c,VisitOps__Show_on_Customer_Agenda__c,VisitOps__Agenda_Subtopics__c,VisitOps__Rooms_Booked__c, (select Id,VisitOps__Presenter_Name__c,VisitOps__Title__c,VisitOps__Presenter_name_formula__c,VisitOps__Title_formula__c from VisitOps__Presenter_Agenda_Links__r where VisitOps__Status__c='Accepted') from VisitOps__Agenda__c where VisitOps__Visit__c=:visitId and VisitOps__IsParked__c=false and VisitOps__Show_on_Customer_Agenda__c = true order by VisitOps__Start_Time__c];
                }else if(view!=null && view!='' && view=='VisitTeam'){
                    List<String> statusToShow = new List<String>{'Accepted','Invited','Tentative','New Time Proposed'};
                    agendaItemsList = [select  Id,Name,VisitOps__Agenda_Title__c,VisitOps__Place__r.Name,VisitOps__Room__r.Name,VisitOps__Start_Time__c,VisitOps__StartTimeLocationTZ__c,VisitOps__Catering_Menu_Item__r.VisitOps__MenuItem__c,VisitOps__Details__c,VisitOps__Catering_Menu_Item__r.VisitOps__MenuType__c,VisitOps__Objectives__c,VisitOps__Show_on_Customer_Agenda__c,VisitOps__Agenda_Subtopics__c,VisitOps__Rooms_Booked__c, (select Id,VisitOps__Presenter_Name__c,VisitOps__Title__c,VisitOps__Presenter_name_formula__c,VisitOps__Title_formula__c,VisitOps__Status__c from VisitOps__Presenter_Agenda_Links__r where VisitOps__Status__c IN :statusToShow order by VisitOps__Status__c) from VisitOps__Agenda__c where VisitOps__Visit__c=:visitId and VisitOps__IsParked__c=false order by VisitOps__Start_Time__c];
                }else{
                    agendaItemsList = [select  Id,Name,VisitOps__Agenda_Title__c,VisitOps__Place__r.Name,VisitOps__Room__r.Name,VisitOps__Start_Time__c,VisitOps__StartTimeLocationTZ__c,VisitOps__Catering_Menu_Item__r.VisitOps__MenuItem__c,VisitOps__Details__c,VisitOps__Catering_Menu_Item__r.VisitOps__MenuType__c,VisitOps__Objectives__c,VisitOps__Show_on_Customer_Agenda__c,VisitOps__Agenda_Subtopics__c,VisitOps__Rooms_Booked__c, (select Id,VisitOps__Presenter_Name__c,VisitOps__Title__c,VisitOps__Presenter_name_formula__c,VisitOps__Title_formula__c from VisitOps__Presenter_Agenda_Links__r where VisitOps__Status__c='Accepted') from VisitOps__Agenda__c where VisitOps__Visit__c=:visitId and VisitOps__IsParked__c=false and VisitOps__Topic_CategoryId__c!='Visit Team Only' order by VisitOps__Start_Time__c];
                }
            }
            String arrivDateLocation=String.isNotBlank(visitRecord.VisitOps__ArrivalDateTimeLocationTZ__c)?visitRecord.VisitOps__ArrivalDateTimeLocationTZ__c.split(' ')[0]:''; 
            String nameofFileGenerated=visitRecord.VisitOps__VisitName__c+'_'+visitRecord.Name+'_'+arrivDateLocation;
            if(fileType!=null && fileType!='') {
                if(fileType=='PDF'){
                    renderPDF='PDF';
                    contentType='';
                    String pdfFileName='attachment; filename="'+nameofFileGenerated+'.pdf"';
                    Apexpages.currentPage().getHeaders().put('content-disposition', pdfFileName);
                }
                else if(fileType=='Word'){
                    renderPDF='';
                    contentType='application/vnd.msword#"'+nameofFileGenerated+'.doc"';
                    //contentType='application/application/vnd.openxmlformats-officedocument.wordprocessingml.document#'+nameofFileGenerated+'.docx';
                }
            }
    
            System.debug('agendaItemsList:'+agendaItemsList);
            AgendaRecordFormat agendaWrapperRecord;
            for(VisitOps__Agenda__c each : agendaItemsList) {
                System.debug('Start Time:'+each.VisitOps__Start_Time__c.date());
                //Timezone Changes
                //Date agendaDate = each.Start_Time__c.date();
                Date agendaDate = DateTime.valueOf(each.VisitOps__StartTimeLocationTZ__c).date();
                
                List<AgendaRecordFormat> tempAgendaList = agendaDateMap.get(agendaDate);
                if(tempAgendaList==null) {
                    tempAgendaList = new List<AgendaRecordFormat>();
                }
                agendaWrapperRecord = new AgendaRecordFormat();
                
                //Timezone Changes
                //agendaWrapperRecord.startTime = each.Start_Time__c.format('hh:mm a');
                agendaWrapperRecord.startTime = DateTime.valueOf(each.VisitOps__StartTimeLocationTZ__c).format('h:mm a');
                
                agendaWrapperRecord.agendaRecord = each;
                tempAgendaList.add(agendaWrapperRecord);
                agendaDateMap.put(agendaDate,tempAgendaList);
            }
            AgendaWrapper aw;
            awList = new List<AgendaWrapper>();
            list<Date> AgendaDates = new list<Date>(agendaDateMap.keySet());
            AgendaDates.sort();
            for(Date each : AgendaDates) {
                aw = new AgendaWrapper();
                aw.agendaDate = each;
                aw.agendaItemsList = agendaDateMap.get(each);
                awList.add(aw);
            }
            AccountAttendeeMap();
        }catch(Exception ex){
            system.debug('Exception inside construcor--'+ex.getMessage());
            ApexPages.addMessages(ex);
        }   
    }
    
    
    public string getDocumentLogoUrl()
    { 
        list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName = 'Survey_Logo'];
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        //newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        if(!d.isEmpty())
        newString = System.Label.VisitOps.VisitOps_Site_Url +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        return newString;
    }
    
    public class AgendaWrapper {
        public Date agendaDate {get;set;}
        public List<AgendaRecordFormat> agendaItemsList{get;set;}
    }
    
    /*public class PresenterWrapper {
        public String presenterName {get;set;}
    }*/

    public class AgendaRecordFormat {
        public VisitOps__Agenda__c agendaRecord {get;set;}
        public String startTime {get;set;}
    }
    
    public void AccountAttendeeMap(){
       // Map<String, List<String>> AccAttendeeMap = new Map<String, List<String>>();
        AttendeesWithoutComapnyList = new list<string>();
        AttendeeContactMap = new Map<String, List<String>>();
        AttendeeContactMap1 = new Map<String, String>();
        AttendeeUserMap= new Map<String, List<String>>();
        AttendeeAdHocUserMap= new Map<String, List<String>>();
        OtherAttendeesMap = new Map<String, List<String>>();
        string compwebsite;
        
        List<VisitOps__Attendee__c> attendeesList = new list<VisitOps__Attendee__c>();
        attendeesList = [select VisitOps__Attendee_Name__c,VisitOps__Attendee_Types__c, VisitOps__Company__c, VisitOps__title__c, VisitOps__Contact__c, VisitOps__Contact__r.name, VisitOps__Contact__r.account.name,VisitOps__Contact__r.account.website, VisitOps__contact__r.title, VisitOps__user__c from VisitOps__Attendee__c where VisitOps__Visit__c =:visitID ];
        VisitOps__Visit__c visitOwnerrelatedInfo= [Select Requestor_Name__c,Requestor_Company__c,VisitOps__VisitOwner__r.Name,VisitOps__VisitOwner__r.Title,VisitOps__VisitOwner__r.CompanyName,VisitOps__Owner_Portal__c,VisitOps__Portal_Visit__c,Child_Visit__c from VisitOps__Visit__c where id=:visitID];
        if(attendeesList.size()>0){
            for(VisitOps__Attendee__c a: attendeesList){
              //  if(a.VisitOps__contact__c!=null){  
                    
                system.debug('a.VisitOps__Attendee_Types__c : '+a.VisitOps__Attendee_Types__c);
                 if((a.VisitOps__Attendee_Types__c).equalsIgnoreCase('Customer')|| (a.VisitOps__Attendee_Types__c).equalsIgnoreCase('Partner')){  //PREPARE MAP FOR CONTACT ATTENDEES

                    //PREPARE MAP FOR CONTACT ATTENDEES
                    /*String MapValue= a.VisitOps__Contact__r.name ;
                    if(a.VisitOps__contact__r.title != null){
                        MapValue = MapValue + ', '+ a.VisitOps__contact__r.title;
                    }*/
                    String MapValue= a.VisitOps__Attendee_Name__c ;
                    if(a.VisitOps__title__c != null){
                        MapValue = MapValue + ', '+ a.VisitOps__title__c;
                    }
                    if(AttendeeContactMap.containsKey(a.VisitOps__Company__c)){
                        List<string> tempAttendeesList = new list<string>(AttendeeContactMap.get(a.VisitOps__Company__c));
                        tempAttendeesList.add(MapValue);
                        AttendeeContactMap.put(a.VisitOps__Company__c,tempAttendeesList);
                         if(a.VisitOps__Contact__r.account.website!=null){
                           compwebsite =a.VisitOps__Contact__r.account.website;
                           
                             if(compwebsite.startsWith('www')) {    
                                compwebsite='http://'+compwebsite;                    
                             }
                             AttendeeContactMap1.put(a.VisitOps__Company__c,compwebsite);
                         }
                         else{
                            AttendeeContactMap1.put(a.VisitOps__Company__c,'NoLink');
                         }
                    }else{
                        List<string> tempAttendeesList = new list<string>();
                        tempAttendeesList.add(MapValue);
                        AttendeeContactMap.put(a.VisitOps__Company__c,tempAttendeesList);
                        if(a.VisitOps__Contact__r.account.website!=null){
                            compwebsite =a.VisitOps__Contact__r.account.website;
                             if(compwebsite.startsWith('www')) { 
                                compwebsite='http://'+compwebsite;   
                             }
                             AttendeeContactMap1.put(a.VisitOps__Company__c,compwebsite);
                        }
                        else{
                             AttendeeContactMap1.put(a.VisitOps__Company__c,'NoLink');
                        }
                    }
                }else if(a.VisitOps__user__c !=null){  //PREPARE MAP FOR USER-ATTENDEES & OTHER-ATTENDEES
                    /*String MapValue= a.VisitOps__user__r.name ;
                    if(a.VisitOps__user__r.title != null){
                        MapValue = MapValue + ', '+ a.VisitOps__user__r.title;
                    }*/
                    String MapValue= a.VisitOps__Attendee_Name__c ;
                    if(a.VisitOps__Title__c != null){
                        MapValue = MapValue + ', '+ a.VisitOps__Title__c;
                    }
                    /*if(string.IsBlank(a.VisitOps__user__r.CompanyName)){*/
                    if(string.IsBlank(a.VisitOps__Company__c)){
                        AttendeesWithoutComapnyList.add(MapValue);
                        //OtherAttendeesMap.put('Other Attendees', MapValue);
                    }
                    else{
                        /*if(AttendeeUserMap.containsKey(a.VisitOps__user__r.CompanyName)){*/
                        if(AttendeeUserMap.containsKey(a.VisitOps__Company__c)){
                            List<string> tempAttendeesList = new list<string>(AttendeeUserMap.get(a.VisitOps__Company__c));
                            tempAttendeesList.add(MapValue);
                            AttendeeUserMap.put(a.VisitOps__Company__c,tempAttendeesList);
                        }else{
                            List<string> tempAttendeesList = new list<string>();
                            tempAttendeesList.add(MapValue);
                            /*AttendeeUserMap.put(a.VisitOps__user__r.CompanyName,tempAttendeesList);*/
                            AttendeeUserMap.put(a.VisitOps__Company__c,tempAttendeesList);
                        }
                    }    
                
                }else if(a.VisitOps__Attendee_Name__c!=null){ //PREPARE MAP FOR AD-HOC ATTENDEES & OTHER-ATTENDEES
                    String MapValue= a.VisitOps__Attendee_Name__c ;
                    if(a.VisitOps__title__c != null){
                        MapValue = MapValue + ', '+ a.VisitOps__title__c ;
                    }
                    if(string.IsBlank(a.VisitOps__Company__c)){
                        AttendeesWithoutComapnyList.add(MapValue);
                        //OtherAttendeesMap.put('Other Attendees', MapValue);
                    }
                    else{
                        if(AttendeeAdHocUserMap.containsKey(a.VisitOps__Company__c)){
                            List<string> tempAttendeesList = new list<string>(AttendeeAdHocUserMap.get(a.VisitOps__Company__c));
                            tempAttendeesList.add(MapValue);
                            AttendeeAdHocUserMap.put(a.VisitOps__Company__c,tempAttendeesList);
                        }else{
                            List<string> tempAttendeesList = new list<string>();
                            tempAttendeesList.add(MapValue);
                            AttendeeAdHocUserMap.put(a.VisitOps__Company__c,tempAttendeesList);
                        }
                    }                    
                }
            
            }//End ForLoop to prepare Maps for contacts, users, ad-hoc attendees, Other-Attendees
            if(!AttendeesWithoutComapnyList.isEmpty()){
                OtherAttendeesMap.put('Other Attendees', AttendeesWithoutComapnyList);
            }
            //Add Visit Owner to Company Users map
            String ownerInfo='';
            /*if(visitOwnerrelatedInfo.VisitOps__Portal_Visit__c){
                if(visitOwnerrelatedInfo.VisitOps__Owner_Portal__c!=null && visitOwnerrelatedInfo.VisitOps__Owner_Portal__c!=null){
                    ownerInfo = visitOwnerrelatedInfo.VisitOps__Owner_Portal__c;
                }
            }else{
                if(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Name!=null&&visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Name!=''){
                    ownerInfo=visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Name;
                }
                if(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Title!=null&&visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Title!=''){
                    ownerInfo+=' , '+visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Title;
                }
            }
            if(AttendeeUserMap.containsKey(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.CompanyName)){
                AttendeeUserMap.get(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.CompanyName).add(ownerInfo);
            }else{
                AttendeeUserMap.put(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.CompanyName, new List<String>{ownerInfo});
            }*/
            if(visitOwnerrelatedInfo.VisitOps__Portal_Visit__c || visitOwnerrelatedInfo.Child_Visit__c){
                //if(visitOwnerrelatedInfo.VisitOps__Owner_Portal__c!=null && visitOwnerrelatedInfo.VisitOps__Owner_Portal__c!=null){
                   // ownerInfo = visitOwnerrelatedInfo.Requestor_Name__c;
                //}
                /*if(AttendeeUserMap.containsKey(visitOwnerrelatedInfo.Requestor_Company__c)){
                    AttendeeUserMap.get(visitOwnerrelatedInfo.Requestor_Company__c).add(ownerInfo);
                }else{
                    AttendeeUserMap.put(visitOwnerrelatedInfo.Requestor_Company__c, new List<String>{ownerInfo});
                }*/
            }else{
                if(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Name!=null&&visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Name!=''){
                    ownerInfo=visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Name;
                }
                if(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Title!=null&&visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Title!=''){
                    ownerInfo+=' , '+visitOwnerrelatedInfo.VisitOps__VisitOwner__r.Title;
                }
            if(AttendeeUserMap.containsKey(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.CompanyName)){
                AttendeeUserMap.get(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.CompanyName).add(ownerInfo);
            }else{
                AttendeeUserMap.put(visitOwnerrelatedInfo.VisitOps__VisitOwner__r.CompanyName, new List<String>{ownerInfo});
            }
            }
            
            //check if Adhoc attendees have same company name as that of the contacts or employees and segregate accordingly
            Map<String,List<String>> tempAttendeeAdHocUserMap = new Map<String,List<String>>();
            for(String s:AttendeeAdHocUserMap.keySet()){
                if(AttendeeUserMap.containsKey(s)){
                    AttendeeUserMap.get(s).addAll(AttendeeAdHocUserMap.get(s));
                }else if(AttendeeContactMap.containsKey(s)){
                    AttendeeContactMap.get(s).addAll(AttendeeAdHocUserMap.get(s));
                }else{
                    tempAttendeeAdHocUserMap.put(s,AttendeeAdHocUserMap.get(s));
                }
            }
            AttendeeAdHocUserMap = tempAttendeeAdHocUserMap;     
            
        }//EndIF
        
    }//End getAccountAttendeeMap
    
}//End Class