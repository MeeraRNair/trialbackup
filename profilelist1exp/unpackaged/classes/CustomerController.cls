/***********************************************************************************************************************
* Name          : CustomerController
* Description   : Add Customer Attendees
* ---------------------------------------------------------
* Revision  Name        Date            Description
* 1.0       Sandhya     16.06.2011      CR 6382 -Change the subject line and email template for EBC/DSC Presenter invite.
* 2.0       Manikandan  05.09.2011      Governor Limit.
* 3.0       Rahul M     10.07.2018      Code Reduce!
*************************************************************************************************************************/

//public with sharing class CustomerController {        //Governor Limit
global with sharing class CustomerController implements al.ObjectPaginatorListener {
     
    public String CERecord;
    public List<SelectOption> options = new List<SelectOption>();
    public Boolean contactPresent = False;
    public Boolean externalContactPresent = False;
    public Boolean errorfornoaccountteam= False;
    public List<Attendees__c> extContactList= new List<Attendees__c>();
    public List<Attendees__c> contactList = new List<Attendees__c>();
    public String accountName;   
    public String URL;
    Id rtList=IdLookupUtils.getRecordTypeId('Customer','Attendees__c',true); 
    /*CR 6372*/
    public String customerAttendee {get; set;}
    public List<Id> AcctTeamIds = new List<Id>{};
    public Boolean searcherrorfornoaccountteam = False;
    public Boolean searchListSizeNotZero = False;
    
    /***** Governor Limit *****/
    public List<ContactWrapper> contactWrappers {get;set;}
    private String query;  

    
    /******************* Governor Limit ********************/    
    //Set Controller
    public ApexPages.StandardSetController setController;
        
    //SObject Paginator
    public al.ObjectPaginator paginator {get;private set;} 
    public Integer PAGE_SIZE;
    
    public Integer getPAGE_SIZE(){
        return PAGE_SIZE;
    }
    
    public void setPAGE_SIZE(Integer value){
        PAGE_SIZE = value;
        paginator.setPageSize(PAGE_SIZE);
    }

    /* ************************
     * Constructor & Set Controller Methods
     * *************************/
     
    public CustomerController(ApexPages.StandardSetController stdSetController) {
        init();
    }
    
    public CustomerController() {
        init();
        CERecord=ApexPages.currentPage().getParameters().get('CEId');
        Attendees__c contactattendeeList = new Attendees__c();    
        contactattendeeList.Customer_Engagement__c=CERecord;
        contactattendeeList.RecordTypeId= rtList;
        extContactList.add(contactattendeeList);        
    }

    public void setaccountName(String accountName){   
        this.accountName=accountName;    
    }
   
    public String getaccountName(){ 
        return accountName;
    }
    
    public List<SelectOption> getaccountNames() {
        try{
            options.clear(); 
            List<Id> attendingAcctIds = new List<Id>{};
            for (Attending_Accounts__c account : [select Account__c,Name,Customer_Engagement__c from Attending_Accounts__c where Customer_Engagement__c=:CERecord]){
                attendingAcctIds.add(account.Account__c);
            } 
            for(Account accName:[select Name from Account where Id IN :attendingAcctIds]){
                  options.add(new SelectOption(accName.Name, accName.Name));
            }
        }
        catch(Exception e){
            PageUtils.addError('Exception Occured while listing the Attending Account');
        }
        return options;
    }
     
    public Boolean getcontactPresent() {
        return contactPresent;
    }
     
    public Boolean getexternalContactPresent() {
        return externalContactPresent;
    }
 
    public Boolean geterrorfornoaccountteam() {
        return errorfornoaccountteam;
    }
        
    private void init() { 
        PAGE_SIZE = 100;
        paginator = new al.ObjectPaginator(PAGE_SIZE,this);
    }
        
    /* ************************
     *Set Controller
     * *************************/
     
    public ApexPages.StandardSetController getSetController(){
        if(setController == null){
            
            for(Attendees__c atnd :  [select Customer_Attendee__c from Attendees__c where Customer_Engagement__c=:CERecord]){
                 AcctTeamIds.add(atnd.Customer_Attendee__c);
            }
            string query  = 'select AccountId, Title,Id, Name from Contact where Account.Name=:accountName and Id NOT IN :AcctTeamIds Order By Name';

            if(query == null){
                al.PageUtils.addError('Blank query, please try again.');
            }else{                
                try{   
                    setController = new ApexPages.StandardSetController(Database.query(query));
                }catch(Exception exp){
                    al.PageUtils.addError('Exception with query: ' + exp.getMessage());                 
                }
            }                                                   
        }
        return setController;
    }
    
    /* ************************
     * Paginator Methods
     * *************************/
     
    global void handlePageChange(List<Object> newPage){
                
        if(contactWrappers == null) {
            contactWrappers = new List<ContactWrapper>();
        }

        //Clear the current page
        contactWrappers.clear();
                
        //Create the new page
        if(newPage != null) {
            for(Object o : newPage) {
                ContactWrapper tw = (ContactWrapper)o;
                contactWrappers.add(tw);
            }
        }
    }

    /* ************************
     * Action Methods
     * *************************/
    
    List<ContactWrapper> allWrappers;
    
    public PageReference Next() {

        contactWrappers = null;
        
        if(contactWrappers == null) {                

            for(Attendees__c atnd :  [select Customer_Attendee__c from Attendees__c where Customer_Engagement__c=:CERecord]){
                AcctTeamIds.add(atnd.Customer_Attendee__c);
            }
            string query  = 'select AccountId, Title,Id, Name from Contact where Account.Name=:accountName and Id NOT IN :AcctTeamIds Order By Name';

            if(query == null) {
                al.PageUtils.addError('Blank query, please try again.');
                return null;
            } else {
                List<SObject> allRecords;                
                try {                                                                                 
                    allRecords = Database.query(query);                                       
                } catch (Exception exp) {
                    al.PageUtils.addError('Exception with query: ' + exp.getMessage()); 
                    return null;                
                }

                if(paginator == null) {
                    paginator = new al.ObjectPaginator(PAGE_SIZE,this);
                }

                paginator.setPageSize(PAGE_SIZE);

                allWrappers = new List<ContactWrapper>(); 
                Contact con = new Contact();
                                 
                for(SObject t : allRecords) {
                    allWrappers.add(new ContactWrapper((Contact)t));
                }

                paginator.setRecords(allWrappers);
                
                if(allWrappers.size() >0){
                    errorfornoaccountteam=FALSE;
                    contactPresent = TRUE; 
                    externalContactPresent = False; 
                    searchListSizeNotZero = true; 
                    searcherrorfornoaccountteam=FALSE;
                 }
                 else{
                    errorfornoaccountteam=TRUE;
                    contactPresent = False; 
                    externalContactPresent = False;
                    searchListSizeNotZero = false;
                    searcherrorfornoaccountteam=FALSE;               
                 }
            }
        }
        return NULL;        
    }

    public String getPageCounter() {
        if(setController != null) {
            if(setController.getResultSize() > 0 && setController.getPageSize() > 0) {                                
                Double pageCount = setController.getResultSize() / setController.getPageSize();
                pageCount = Math.ceil(pageCount);
                return pageCount.intValue().format();
            }else{
                return '1';
            }
            }else{
                return '1';
            }
                return '1';
    }

    public class ContactWrapper {
        public Contact con {get;set;}
        public Boolean selected {get;set;}
        public ContactWrapper(Contact t) {
            con = t;
            selected = false;
        }
    }

    /*CR 6372 : Search function for Customer and Account Team Attendees : Start*/
    public PageReference Search() {
 
        contactWrappers =null;
        
        if(contactWrappers == null) {
            for(Attendees__c atnd :  [select Customer_Attendee__c from Attendees__c where Customer_Engagement__c=:CERecord]){
                 AcctTeamIds.add(atnd.Customer_Attendee__c);
            }                
            string query  = 'select AccountId, Title,Id, Name from Contact where Account.Name=:accountName and Id NOT IN :AcctTeamIds';
                    query  = query + ' and ' + 'Name like ' + '\'%' + customerAttendee+ '%\'Order By Name' ;
           
            if(query == null) {
                al.PageUtils.addError('Blank query, please try again.');
                return null;
            } else {
                List<SObject> allRecords;                
                try {                                                                                 
                    allRecords = Database.query(query);                                       
                } catch (Exception exp) {
                     PageUtils.addError('Exception Occured while retrieving attendee list');
                    return null;                
                }

                if(paginator == null) {
                    paginator = new al.ObjectPaginator(PAGE_SIZE,this);
                }

                paginator.setPageSize(PAGE_SIZE);

                allWrappers = new List<ContactWrapper>(); 
                Contact con = new Contact();                 
                
                for(SObject t : allRecords) {
                    allWrappers.add(new ContactWrapper((Contact)t));
                }

                paginator.setRecords(allWrappers);
                
                if(allWrappers.size() >0){
                    searcherrorfornoaccountteam=FALSE;
                    contactPresent = TRUE; 
                    externalContactPresent = False; 
                    searchListSizeNotZero = true;
                }
                else{
                    searcherrorfornoaccountteam=TRUE;
                    contactPresent = true; 
                    externalContactPresent = False;
                    searchListSizeNotZero = false;              
                }
            }
        }
        return null;
    }    

    public Boolean getsearcherrorfornoaccountteam() {
        return searcherrorfornoaccountteam;
    }
    
    public Boolean getsearchListSizeNotZero() {
        return searchListSizeNotZero;
    }    

    public List<Attendees__c> getattendee(){
        contactPresent=TRUE;
        return extContactList;  
    }
    
    public void setattendee(List<Attendees__c> extContactList){
        extContactList= extContactList ;
    }    
    
    public PageReference addNew(){
        Attendees__c contactattendeeList = new Attendees__c();    
        contactattendeeList.Customer_Engagement__c=CERecord;
        extContactList.add(contactattendeeList);
        return NULL;
    }
 
    public PageReference addnewContact(){
        externalContactPresent = TRUE;
        return Null;
    }    

    public PageReference Save(){
        try{

            for (ContactWrapper team : allWrappers ){
                if (team.selected == TRUE) {
                  Attendees__c saveList = new Attendees__c(Customer_Attendee__c=team.con.Id,Role__c=team.con.Title,Customer_Engagement__c=CERecord,
                                           Attendee_Name__c =team.con.Name, RecordTypeId= rtList,Account_Name__c=accountName );
                  contactList.add(SaveList);
                }
            }
            for(Attendees__c extAtt:extContactList){
                extAtt.Account_Name__c=accountName;
            }
            if(extContactList.size()>0 && externalContactPresent==TRUE){
                insert extContactList;
            }
            if(contactList.size()>0){
                insert contactList;
            }
        }
        catch(Exception e){
            PageUtils.addError('Exception Occured while saving the attendees');
            //return NULL;
        }
        return PageUtils.redirect('/'+CERecord);
    }
    
    public PageReference Cancel() {
        return PageUtils.redirect('/'+CERecord);
    }

}