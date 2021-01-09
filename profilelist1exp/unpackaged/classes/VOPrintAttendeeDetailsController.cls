public with sharing class VOPrintAttendeeDetailsController {
    public String visitId {get;set;}
    public String AttendeeId {get;set;}
    public List<VisitOps__Attendee__c> attendeesList {get;set;}
    public List<AttendeeWrapper> attendeeWrapperList {get;set;}
    public List<VisitOps__Visit__c> visitList {get;set;}
    public String Name='';
    public list<VisitOps__Presenter_Agenda_Link__c> plist = new List<VisitOps__Presenter_Agenda_Link__c>();
    public list<VisitOps__Agenda__c> alist = new List<VisitOps__Agenda__c>();
    public string newString{get;set;}
    public string contentType{get;set;}
    
    public VOPrintAttendeeDetailsController(){
        visitId = ApexPages.currentPage().getParameters().get('VisitId');
        AttendeeId = ApexPages.currentPage().getParameters().get('AttendeeId');
        attendeesList = new List<VisitOps__Attendee__c>();
        attendeeWrapperList = new List<AttendeeWrapper>();
        
        alist = [select a.Id,a.VisitOps__Visit__c from VisitOps__Agenda__c a where a.VisitOps__Visit__c=:visitId LIMIT :LIMITS.getLimitQueryRows()];
        plist = [select Id,VisitOps__Presenter_Name__c,VisitOps__Attendee__c,VisitOps__Presenter__c,VisitOps__User__c,VisitOps__Attendee__r.VisitOps__FirstName__c,VisitOps__Attendee__r.VisitOps__Contact__r.Account.name,
                 VisitOps__Attendee__r.VisitOps__User__r.companyname,VisitOps__Attendee__r.VisitOps__LastName__c,VisitOps__Attendee__r.VisitOps__User__c,VisitOps__Attendee__r.VisitOps__Contact__c,VisitOps__Attendee__r.VisitOps__Company__c,
                 VisitOps__Presenter__r.VisitOps__Company__c,VisitOps__User__r.CompanyName,VisitOps__User__r.Name
                 from VisitOps__Presenter_Agenda_Link__c where VisitOps__Status__c='Accepted' AND VisitOps__Agenda__c IN :alist LIMIT :LIMITS.getLimitQueryRows()];
     
        
        visitList = new List<VisitOps__Visit__c>();
        if(visitId != null && visitId != ''){
            attendeesList = [select id,VisitOps__FirstName__c,VisitOps__LastName__c,VisitOps__Company__c,VisitOps__Contact__c,VisitOps__User__c,VisitOps__User__r.companyname,VisitOps__Contact__r.Account.name,owner.name from VisitOps__Attendee__c where VisitOps__Visit__c = :visitId LIMIT :LIMITS.getLimitQueryRows()];
            visitList = [select id,owner.name,ownerId,VisitOps__VisitOwner__c,VisitOps__VisitOwner__r.VisitOps__Full_Name__c,VisitOps__VisitOwner__r.companyname,VisitOps__visitName__c from VisitOps__Visit__c where id= :visitId LIMIT :LIMITS.getLimitQueryRows()];
        }else if(AttendeeId != null && AttendeeId != ''){
            attendeesList = [select id,VisitOps__FirstName__c,VisitOps__LastName__c,VisitOps__Company__c,VisitOps__Contact__c,VisitOps__User__c,VisitOps__Contact__r.Account.name,owner.name,VisitOps__User__r.companyname from VisitOps__Attendee__c where id = :AttendeeId LIMIT :LIMITS.getLimitQueryRows()];
        }
        //Adding Visit Owner to Attendees List
        if(visitList.size()>0 && visitList != null){
            if(visitList[0].VisitOps__VisitOwner__r.companyname!=null && visitList[0].VisitOps__VisitOwner__r.companyname!=''){
                attendeeWrapperList.add(new AttendeeWrapper(visitList[0].VisitOps__VisitOwner__r.VisitOps__Full_Name__c,visitList[0].VisitOps__VisitOwner__r.companyname));
            }/*else{
                attendeeWrapperList.add(new AttendeeWrapper(visitList[0].VisitOwner__r.Full_Name__c,'Lenovo'));
            }*/
            contentType = 'application/vnd.msword#'+visitList[0].VisitOps__visitName__c+'-Attendee Cards.doc';
        }
        //Adding internal users,Adhoc users,Contacts to Attendees List
        for(VisitOps__Attendee__c att : attendeesList){
            if(att.VisitOps__FirstName__c != null && att.VisitOps__LastName__c != null){
                Name = att.VisitOps__FirstName__c + ' ' + att.VisitOps__LastName__c;
            }else if(att.VisitOps__FirstName__c == null && att.VisitOps__LastName__c != null){
                Name = att.VisitOps__LastName__c;
            }else if(att.VisitOps__FirstName__c != null && att.VisitOps__LastName__c == null){
                Name = att.VisitOps__FirstName__c;
            }
            attendeeWrapperList.add(new AttendeeWrapper(Name,att.VisitOps__Company__c));
            if(visitId==null){
                contentType = 'application/vnd.msword#'+Name+'-Attendee Card.doc';
            }
        }
        //Adding Presenters to Attendees List
        for(VisitOps__Presenter_Agenda_Link__c pal : plist){
            if(pal.VisitOps__Presenter__c!=null || pal.VisitOps__User__c!=null){
                if(pal.VisitOps__Presenter__r.VisitOps__Company__c != null && pal.VisitOps__Presenter__r.VisitOps__Company__c != ''){
                    attendeeWrapperList.add(new AttendeeWrapper(pal.VisitOps__Presenter_Name__c,pal.VisitOps__Presenter__r.VisitOps__Company__c));
                }else if(pal.VisitOps__User__r.CompanyName != null && pal.VisitOps__User__r.CompanyName != ''){
                    attendeeWrapperList.add(new AttendeeWrapper(pal.VisitOps__User__r.Name,pal.VisitOps__User__r.CompanyName));
                }
                /*else{
                    attendeeWrapperList.add(new AttendeeWrapper(pal.Presenter_Name__c,'Lenovo'));
                }*/
            }else if(pal.VisitOps__Attendee__c!=null){
                if(pal.VisitOps__Attendee__r.VisitOps__FirstName__c != null && pal.VisitOps__Attendee__r.VisitOps__LastName__c != null){
                    Name = pal.VisitOps__Attendee__r.VisitOps__FirstName__c + ' ' + pal.VisitOps__Attendee__r.VisitOps__LastName__c;
                }else if(pal.VisitOps__Attendee__r.VisitOps__FirstName__c == null && pal.VisitOps__Attendee__r.VisitOps__LastName__c != null){
                    Name = pal.VisitOps__Attendee__r.VisitOps__LastName__c;
                }else if(pal.VisitOps__Attendee__r.VisitOps__FirstName__c != null && pal.VisitOps__Attendee__r.VisitOps__LastName__c == null){
                    Name = pal.VisitOps__Attendee__r.VisitOps__FirstName__c;
                }
                attendeeWrapperList.add(new AttendeeWrapper(Name,pal.VisitOps__Attendee__r.VisitOps__Company__c));
            }
            
        }
    }
    
    public string getLeftCompanyLogoUrl()
    {
        
        list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName =:Label.VisitOps.Tent_Card_Left_Image_Doc_Name limit 1];
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        //newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
        if(!d.isEmpty())
        newString = System.Label.VisitOps.VisitOps_Site_Url +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        return newString;
    }
    
    public string getRightCompanyLogoUrl()
    {
        
        list<Document> d = [Select Id,LastModifiedById,DeveloperName from Document where DeveloperName =:Label.VisitOps.Tent_Card_Right_Image_Doc_Name limit 1];
        String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        //newString =fullFileURL+'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId();
        if(!d.isEmpty())
        newString = System.Label.VisitOps.VisitOps_Site_Url +'/servlet/servlet.FileDownload?file='+d[0].id+'&oid='+UserInfo.getOrganizationId()+'" alt="User-added image">';
        return newString;
    }
    // Wrapper to store Attendees 
    public class AttendeeWrapper{
        public String Name {get;set;}
        public String Company {get;set;}
        public AttendeeWrapper(String name,String Company){
            this.Name = name;
            this.Company = Company;
        }
    }
}