/* ============================================================
 * This Controller Created for creating New NPS Task Manully
 * CR 9028 - Version 0.1 Developed by Rakesh Muppiri on 22-01-2014
 * ============================================================
 */
public class CreateTaskManually_Cntrl {
    public CreateTaskManually_Cntrl(ApexPages.StandardController controller) {
        NSSLookup = new NSS_Category_Ranges__c();
        allowTask = true;
        t= new Task();
        i = Id.ValueOf(ApexPages.currentPage().getParameters().get('Caseid'));
        c = [SELECT Id, Queue_Name__c ,Country__c, Segment__c, Sub_Segment__c, subject FROM Case WHERE ID =: i LIMIT 1 ];
        if(c.Queue_Name__c == 'Unknown'){
            allowTask = false;
        }
        RecordType NPSTaskRecordType = [SELECT ID, Name from RecordType WHERE Name =:'NPS Task' LIMIT 1];
        t.WHATID = c.Id;
        t.ActivityDate = (date.newinstance(System.now().year(), System.now().month(), System.now().day()))+14;
        t.RecordTypeId = NPSTaskRecordType.Id;
        t.IsReminderSet = true;
        t.ReminderDateTime = System.now().addDays(7);
        t.subject = c.subject;
    }


    public Id getC() {
        return c.Id;
    }

    public Case c = new Case();
    public Boolean allowTask{set;get;}
     public CreateTaskManually_Cntrl() {     
        NSSLookup = new NSS_Category_Ranges__c();
        allowTask = true;
        t= new Task();
        i = Id.ValueOf(ApexPages.currentPage().getParameters().get('Caseid'));
        c = [SELECT Id, Queue_Name__c ,Country__c, Segment__c, Sub_Segment__c, subject FROM Case WHERE ID =: i LIMIT 1 ];
        if(c.Queue_Name__c == 'Unknown'){
            allowTask = false;
        }
        RecordType NPSTaskRecordType = [SELECT ID, Name from RecordType WHERE Name =:'NPS Task' LIMIT 1];
        t.WHATID = c.Id;
        t.ActivityDate = (date.newinstance(System.now().year(), System.now().month(), System.now().day()))+14;
        t.RecordTypeId = NPSTaskRecordType.Id;
        t.IsReminderSet = true;
        t.ReminderDateTime = System.now().addDays(7);
        t.subject = c.subject;
    }
    public NSS_Category_Ranges__c NSSLookup{set;get;}
    public Task t{set;get;}
    public Id i{set;get;}
   
   //Save method
    public PageReference Save() {
        Boolean P = CheckCategory();
        if(P == true)
            return null;
            system.debug('tttt:'+NSSlookup.NSS_Category__c);
        NSS_Category__c NSSCategory = [SELECT Name from NSS_Category__c WHERE Id =: NSSlookup.NSS_Category__c LIMIT 1];
        if([SELECT Count() from NSS_Category_Ranges__c WHERE NSS_Category__r.Name =: NSSCategory.Name] > 0)
            NSSLookup = [SELECT NSS_Category__r.Name from NSS_Category_Ranges__c WHERE NSS_Category__r.Name =: NSSCategory.Name LIMIT 1];
        List<Root_Cause_Table__c> RootCauseTable = [SELECT Primary_Root_Cause__c,Secondary_Root_Cause__c FROM Root_Cause_Table__c WHERE NSS_Category__r.Name =:NSSlookup.NSS_Category__r.Name];
        String primaryField ='';
        String SecondaryField ='';
        for(Root_Cause_Table__c r : RootCauseTable ){
            primaryField = primaryField+';'+r.Primary_Root_Cause__c;
            SecondaryField = SecondaryField+';'+r.Secondary_Root_Cause__c;
        }
        if(c.Country__c != 'Unknown' && c.Segment__c != 'Unknown'){
        system.debug('IIII');
            try{
                system.debug('IInside try');
                Cross_Functional_Matrix__c CFMX = [SELECT Owner__c,OwnerId,Functional_Call_to_Action__c  from Cross_Functional_Matrix__c  WHERE NSS_Category__r.Name =: NSSLookup.NSS_Category__r.Name AND country__c =:c.Country__c AND Segment__c=:c.Segment__c AND (Sub_Segment__c=:c.Sub_Segment__c OR Sub_Segment__c =: null) LIMIT 1];
                t.NSS_Category__c = NSSLookup.NSS_Category__r.Name;
                t.OwnerId = CFMX.OwnerId;
                t.Description = CFMX.Functional_Call_to_Action__c;
                t.Primary_Root_Causes__c= primaryField ;
                t.Secondary_Root_Causes__c = SecondaryField;
                insert t;
                system.debug('sssssl');
                return (new PageReference('/'+t.id));
            }Catch(Exception e){
                t.addError('Task cannot be created as Cross-functional matrix record not present');
                return null;
            }
        }
        else
            return null;
        
    }
    public Pagereference CheckTask() {
        Boolean check = CheckCategory();    
            return null;
    }
  
    public PageReference Cancel(){
        return (new PageReference('/'+i));
    }
    
    //Check Category method to find if there is already Task created for Selected NSS Category or not
    public Boolean CheckCategory(){
        NSS_Category__c NSS = [SELECT Name from NSS_Category__c WHERE ID =: NSSLookup.NSS_Category__c];
        String CategoryName = NSS.Name ;
        Integer i = [SELECT count() from Task WHERE NSS_Category__c =: CategoryName  AND WHATID =: i ];
        system.debug('Ccount :'+i);
        if(i>0){
            NSSLookup.NSS_Category__c.addError('Case is Already having '+CategoryName+' Task');
            return true;
        }
        return false;
    }
     public PageReference RedirectUrl(){
        Id id = ApexPages.currentPage().getParameters().get('CaseId');
        String inline = ApexPages.currentPage().getParameters().get('inline');
        if (inline != null) {
            system.debug('SSSSc');
            PageReference editPage = new PageReference(Page.CreateTaskManually.getUrl());
            editPage.setRedirect(true); 
            editPage.getParameters().put('CaseId', id);
            editPage.getParameters().remove('inline');
            system.debug('..../'+editPage);
        return editPage;
        }
        return null;
    }
}