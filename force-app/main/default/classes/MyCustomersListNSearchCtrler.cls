/*------------------------------------------------------------------------------
Project : Reusable end user data capture
History:
    1.0 : 1-Nov-2011: Hanan     : CR: 6702,6703,6719 (R13.1)
    2.0 : 3-Jan-2013:Sandhya    : CR: 7827
    3.0 : 25-Feb-2014 Meera     : CR: 8867 Defect fix to remove lead related list when leadmanagement is not enabled  

This class is used as custom controller in the following Visualforce pages:

    -AddNewCustomer : VF code to insert end customer & end customer contact 
    -EndCustomerContactPage : VF code to insert end customer contact
    -EndCustomerDetailPage : VF code to view ebd customer record & its related lists
    -ModifyEndCustomer : VF code to edit end customer record
    -MyCustomersListNSearch : VF code to view the list of end customers of a partner user
--------------------------------------------------------------------------------*/
Public Class MyCustomersListNSearchCtrler{
       
    Public Id partnerAccountId;
    Public Id RecordTypeId;
    Public Id EndCustomerId;
    Public String searchCustomer;
    List<Contact> partnerRec;
    Public End_Customer__c endCustomer=new End_Customer__c();    
    Public End_Customer__c selectedEndCstmr=new End_Customer__c();
    Public End_Customer__c endCstmr2Bmodified=new End_Customer__c();    
    Public End_Customer_Contact__c endCustomerContact=new End_Customer_Contact__c();
    Public End_Customer_Contact__c ECContactVar=new End_Customer_Contact__c();    
    Public Opportunity opportunityObj=new Opportunity();
    
    Boolean newCustomer=false;
    Boolean customerList=false;
    //Public string userOper='List';
    String country;
    Public Account partnerAcc;
    Public Country__c countryRec;
    Boolean nullValue=false;
    Boolean boolViewContact=false;
    Boolean boolModifyContact=false;    
    String apexParam;
    
    Public List<End_Customer__c> endCustomers=new List<End_Customer__c>();
    Public List<End_Customer__c> allCustomers=new List<End_Customer__c>();
    Public List<Opportunity> opportunityList;
    Public ApexPages.StandardSetController recordSetCon;
    
    public List<End_Customer_Contact__c> endCustomerContactList=new List<End_Customer_Contact__c>();  
    
    //CR 7827
    public Id customerForLeadId{get;set;}
    public Id leadId{get;set;}
    Public List<Lead> leadList{get;set;}
    public User userRec{get;set;}
    //-----------------------------------------Constructor-------------------------------------------//
    public MyCustomersListNSearchCtrler(){  
       try{ 
        userRec=[Select id,ContactId,profile_region__c,Enable_Partner_Lead_Management__c from User where id=:UserInfo.getUserId()];        
        Recordtype recordTypeObj=[Select SobjectType,Name,Id From RecordType  where SobjectType='Opportunity' and Name='Deal Registration for Existing End Customer' limit 1];
        RecordTypeId=recordTypeObj.Id;
        customerForLeadId = ApexPages.currentPage().getParameters().get('id'); // Cr 7827
        
        if(userRec!= null && userRec.ContactId != null){
            partnerRec=[Select AccountId,Account.name from Contact where id=:userRec.ContactId limit 1];
            if(partnerRec.size()>0){
                partnerAcc=new Account();               
                partnerAccountId=partnerRec[0].AccountId;
                partnerAcc=[select id,Account_Country__c,Account_Country_Code__c,Name from account where id=:partnerAccountId];
                if(partnerAcc!= null){
                    if(partnerAcc.Account_Country__c!=null){
                        countryRec=[SELECT Name,Id,Partner_Support_Queue_ID__c,Code__c,Dell_Online_Country_Code__c from Country__c where Name=:partnerAcc.Account_Country__c];
                    }else if(partnerAcc.Account_Country_Code__c!=null){
                         countryRec=[SELECT Name,Id,Partner_Support_Queue_ID__c,Code__c,Dell_Online_Country_Code__c from Country__c where Name=:partnerAcc.Account_Country_Code__c];
                    }
                           
                    endCustomer=new End_Customer__c();
                    endCustomer.Status__c='Active';
                    endCustomer.Partner_Account__c=partnerAccountId;
                    if(countryRec!=null){
                        endCustomer.Mailing_country__c=countryRec.Name;
                    }
                    
                    endCustomerContact=new End_Customer_Contact__c();  
                    endCustomerContact.Status__c='Active';  
                    ECContactVar.Status__c='Active';             
                    String QueryString = 'Select Status__c,Tax_Id__c,Name,Mailing_city__c,Account_Department__c,Mailing_country__c,Mailing_State__c,Mailing_street__c,Partner_Account__c,Zip_Code__c from End_Customer__c Where Partner_Account__c=\''+partnerAccountId+'\'  Order By Name';
                    try{
                        recordSetCon= new ApexPages.StandardSetController(Database.query(QueryString));
                        recordSetCon.setPageSize(25); 
                        endCustomers=(List<End_Customer__c>)recordSetCon.getRecords();
                        allCustomers=endCustomers;
                    }Catch(Exception e){
                        System.debug('### Exception in MyCustomersListNSearchCtrler : '+e);
                    }
               }else{
                   ApexPages.Message msg;     
                   msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: User doesnt have a partner account.');
                   ApexPages.addMessage(msg);
               }
            
        }else{
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: User doesnt have a partner contact.');
            ApexPages.addMessage(msg);
        }
        }else{
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error:Logged in user is not a partner User .');
            ApexPages.addMessage(msg);
        }
        
        }catch(Exception e){
            System.debug('### Exception in MyCustomersListNSearchCtrler : '+e);
        }
            
    }
    
    Public ApexPages.StandardSetController getRecordSetCon(){
        return recordSetCon;
    } 
    
    public void SetRecordSetCon(ApexPages.StandardSetController cntrller){
        this.recordSetCon=cntrller;
    }
    
    public List<End_Customer__c> getEndCustomers(){
        return endCustomers;
    }
    
    public  void setEndCustomers(List<End_Customer__c> ecList){
        this.endCustomers=ecList;
    } 

    //To create fixed header for page blocke table
    public List<End_Customer__c> getTableHeader(){
        List<End_Customer__c> TblHeader=new List<End_Customer__c>(); 
        return TblHeader;
    }
    
    public Account getPartnerAccount(){
        return partnerAcc; 
    }
    
    /*------------------------------------*/
            //Pagination
    /*-------------------------------------*/
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext{
        get {
            Boolean bool;
            if(recordSetCon!=null){
                bool=recordSetCon.getHasNext();
            }else{
                bool=false;
            }
            return bool;
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious{
        get {
            Boolean bool;
            if(recordSetCon!=null){
                bool=recordSetCon.getHasPrevious();
            }else{
                bool=false;
            }           
            return bool;
        }
        set;
    }
 
    // returns the page number of the current page set
    public Integer pageNumber{
        get {
            Integer intr;
            if(recordSetCon!=null){
                intr=recordSetCon.getPageNumber();
            }           
            return intr;            
        }
        set;
    }
 
    // returns the first page of records
    public void first() {
        recordSetCon.first();  
        List<End_Customer__c> nCustomerList=(List<End_Customer__c>)recordSetCon.getRecords();
        setEndCustomers(nCustomerList);
        
    }
 
    // returns the last page of records
    public void last(){
        recordSetCon.last();
       List<End_Customer__c> nCustomerList=(List<End_Customer__c>)recordSetCon.getRecords();
        setEndCustomers(nCustomerList);
    }
 
    // returns the previous page of records
    public void previous(){
        recordSetCon.previous();
       List<End_Customer__c> nCustomerList=(List<End_Customer__c>)recordSetCon.getRecords();
        setEndCustomers(nCustomerList);
    }
 
    // returns the next page of records
    public void next(){
        recordSetCon.next();
        List<End_Customer__c> nCustomerList=(List<End_Customer__c>)recordSetCon.getRecords();
        setEndCustomers(nCustomerList);
    }
 
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel(){
        recordSetCon.cancel();
    }
    
    //*----------------------------Search Customer----------------------------*//
      
    public String getSearchCustomer(){
        return searchCustomer; 
    } 
    
    public void setSearchCustomer(String myString){
        this.searchCustomer=myString;
    }
    
 
  
    Public PageReference SearchEndCustomer(){
        String search='%'+searchCustomer+'%';
        List<End_Customer__c> recList=new List<End_Customer__c>(); 
        recordSetCon= new ApexPages.StandardSetController(Database.getQueryLocator([select Status__c,Tax_Id__c,Name,Mailing_city__c,Account_Department__c,Mailing_country__c,Mailing_State__c,Mailing_street__c,Partner_Account__c,Zip_Code__c from End_Customer__c Where Partner_Account__c=:partnerAccountId and (Tax_Id__c like:search OR Name like:search OR Mailing_city__c like:search OR Account_Department__c like:search OR Mailing_country__c like:search OR Mailing_State__c like:search OR Mailing_street__c like:search OR Zip_Code__c like:search) Order by Name]));                
        recordSetCon.setPageSize(25); 
        recList=(List<End_Customer__c>)recordSetCon.getRecords(); 
        setEndCustomers(recList);
       
        return null;
    }   

    //*----------------------------------------- All link-------------------------------------------*/
    
    Public PageReference showAllCustomers(){
        recordSetCon= new ApexPages.StandardSetController(Database.getQueryLocator([select Status__c,Tax_Id__c,Name,Mailing_city__c,Account_Department__c,Mailing_country__c,Mailing_State__c,Mailing_street__c,Partner_Account__c,Zip_Code__c from End_Customer__c Where Partner_Account__c=:partnerAccountId Order by Name]));                
        recordSetCon.setPageSize(25); 
        endCustomers=(List<End_Customer__c>)recordSetCon.getRecords(); 
        setEndCustomers(endCustomers);
        return null;
    }
    
    
    //*------------------------------------------Add New Customer---------------------------------------------*//     
    
    Public PageReference CreateEndCustomer(){        
        PageReference pageRef=new PageReference('/apex/AddNewCustomer');        
        return pageRef;
    }
    
     public End_Customer__c getEndCustomer(){
        return endCustomer; 
    } 
    
    public void setEndCustomer(End_Customer__c ECrec){
        this.endCustomer=ECrec;
    }    
    
    public End_Customer_Contact__c getEndCustomerContact(){
        return endCustomerContact;
    }
    
    public  void setEndCustomerContact(End_Customer_Contact__c sobj){
        this.endCustomerContact=sobj;
    }

    
    public Boolean getNullValue(){
        return nullValue;
    }
    
    public void setNullValue(Boolean bool){
        this.nullValue=bool;
    }
    Public PageReference SaveEndCustomer(){
        PageReference pageRef;
        
        if(endCustomer.Name==null || endCustomer.Mailing_city__c==null || endCustomer.Mailing_country__c==null||endCustomer.Mailing_State__c==null||endCustomerContact.Name==null){
            nullValue=true; 
            if(endCustomer.Name==null){
                endCustomer.Name.addError('You must enter a value');    
            }
            if(endCustomer.Mailing_city__c==null){
                endCustomer.Mailing_city__c.addError('You must enter a value');    
            }
           
            if(endCustomer.Mailing_country__c==null){
                endCustomer.Mailing_country__c.addError('You must enter a value');    
            }
            if(endCustomer.Mailing_State__c==null){
                endCustomer.Mailing_State__c.addError('You must enter a value');    
            }
                        
            if(endCustomerContact.Name==null){
                endCustomerContact.Name.addError('You must enter a value');    
            }
            return null;

        }else{
        //CR 6719.
            pageRef=new PageReference('/apex/MyCustomersListNSearch');
            RecordType recType=[SELECT Name,Id,SobjectType FROM RecordType WHERE Name ='New Customer' AND SobjectType='Partner_Request__c'];
            List<End_Customer__c> recList=new List<End_Customer__c>();
            endCustomer.Partner_Account__c=partnerRec[0].AccountId;  
            try{      
                Database.insert(endCustomer);
              }catch(exception e){
            }
                    
            endCustomerContact.End_Customer__c=endCustomer.Id;       
           try{
                Database.insert(endCustomerContact);
            }catch(exception e){
            }
            
            //CR 6719
             Partner_Request__c partnerRequest=new Partner_Request__c(); 
             partnerRequest.Company__c=endCustomer.Name;
             partnerRequest.Org_Address_1__c=endCustomer.Mailing_street__c;
             partnerRequest.Org_City__c=endCustomer.Mailing_city__c;
             partnerRequest.Org_State__c=endCustomer.Mailing_State__c;
             partnerRequest.Org_Postal_Code__c=endCustomer.Zip_Code__c;
             partnerRequest.End_Customer__c=endCustomerContact.End_customer__c;
             partnerRequest.First_Name__c=endCustomerContact.Name;
             partnerRequest.Last_Name__c=endCustomerContact.Last_Name__c;
             partnerRequest.Job_Title__c=endCustomerContact.Title__c;
             partnerRequest.Email__c=endCustomerContact.Email__c;
             partnerRequest.Phone__c=endCustomerContact.Phone__c;
             partnerRequest.Mobile__c=endCustomerContact.Mobile__c;
             partnerRequest.Fax__c=endCustomerContact.Fax__c;
             partnerRequest.Status__c='New';
             partnerRequest.Account__c=endCustomer.Partner_Account__c;
             partnerRequest.recordtypeId=recType.Id;
             if(countryRec!=null){
                 partnerRequest.OwnerId=countryRec.Partner_Support_Queue_ID__c;
                 partnerRequest.Org_Country__c=countryRec.Id;
             }
            try{
                 Database.insert(partnerRequest);
             }catch(exception e){
             }      
                    
            recList.addAll(endCustomers);
            recList.add(endCustomer);        
            setEndCustomers(recList);
            allCustomers=recList;
    
            endCustomer=new End_Customer__c(); 
            endCustomer.Status__c='Active';
            if(countryRec!=null){
                endCustomer.Mailing_country__c=countryRec.Name;
            }
            endCustomer.Partner_Account__c=partnerRec[0].AccountId;
            endCustomerContact=new End_Customer_Contact__c();
            endCustomerContact.Status__c='Active';
        }
        pageRef.setRedirect(true);
        return pageRef;
    
    }
    
    Public PageReference Back2List(){
        PageReference pageRef=new PageReference('/apex/MyCustomersListNSearch');
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
   /*-------------------------------------------Sorting based on other fields in list view-----------------------------------*/
  
   public String sortDirection = 'ASC';   
   public String sortExp = 'Name';
     
   
   
   public String sortExpression {
        get {
            return sortExp;
        }
        set{
        //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp) 
            sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else {
                sortDirection = 'ASC';
                sortExp = value;
            }
        }
    }
    
    public String getSortDirection() {
        //if not column is selected     
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    } 
   
    public void setSortDirection(String value) {
        sortDirection = value;
    }
    
    public PageReference sortingOtherFields(){
        List<End_Customer__c> recList=new List<End_Customer__c>();
        string sortFullExp = sortExpression+'  '+sortDirection; 
        String QueryString = 'Select Status__c,Tax_Id__c,Name,Mailing_city__c,Account_Department__c,Mailing_country__c,Mailing_State__c,Mailing_street__c,Partner_Account__c,Zip_Code__c from End_Customer__c Where Partner_Account__c=\''+partnerAccountId+'\'  Order By  '+sortFullExp+' nulls last';
        recordSetCon= new ApexPages.StandardSetController(Database.query(QueryString));
        recList.addAll((List<End_Customer__c>)recordSetCon.getRecords());
        setEndCustomers(recList);
        
        return null;        
    }
    
    //-------------------View selected end customer details--------------------------//
    
    public End_Customer__c getSelectedEndCustomer(){
        return selectedEndCstmr; 
    } 
  
    
     public pageReference viewEndCustomerPage(){
        Id customerId=ApexPages.currentPage().getParameters().get('id');       
        selectedEndCstmr=[Select Zip_Code__c, Website__c, Total_of_End_User_Employees__c, Tax_Id__c, Status__c, Segment__c, Partner_Account__c, OpportunityID__c, Name, MayEdit, Mailing_street__c,Mailing_street2__c, Mailing_country__c, Mailing_city__c, Mailing_State__c, LastModifiedDate, LastModifiedById, IsLocked, IsDeleted, Id, End_User_Account__c, Customer_Id__c, CurrencyIsoCode,Account_Industry__c, Account_Department__c,B2BCRTEndUserID__c From End_Customer__c  Where id=:customerId];
        endCustomerContactList=[select Name,Email__c,Last_Name__c,Phone__c,Mobile__c,Status__c,Fax__c,Title__c,end_customer__c from End_Customer_Contact__c where end_customer__c=:selectedEndCstmr.Id];      
        opportunityList=[select name,Deal_ID__c,closeDate,StageName,amount,End_Customer__c from opportunity where End_Customer__c=:customerId];
        leadList = [Select Id,Name,Email,Phone,Company,Status,CreatedDate
                    from Lead where Search_My_Customer__c =: customerId and OwnerId = :UserInfo.getUserId()];//CR 7827
        return null;
    }


    
    //---------------------------------Edit end customer details-----------------------------------//
    
    public pageReference ModifyEndCustomer(){
        Id customerId;
        if(ApexPages.currentPage().getParameters().get('listPage')!=null){
            customerId=ApexPages.currentPage().getParameters().get('listPage');
            apexParam='listPage';
        }        
        if(ApexPages.currentPage().getParameters().get('DetailPage')!=null){
            customerId=ApexPages.currentPage().getParameters().get('DetailPage');
            apexParam='DetailPage';
        }
        endCstmr2Bmodified=[Select Zip_Code__c, Website__c, Total_of_End_User_Employees__c, Tax_Id__c, SystemModstamp, Status__c, Segment__c, Partner_Account__c, OpportunityID__c, Name, MayEdit, Mailing_street__c,Mailing_street2__c, Mailing_country__c, Mailing_city__c, Mailing_State__c, LastModifiedDate, LastModifiedById, IsLocked, IsDeleted, Id, End_User_Account__c, Customer_Id__c, CurrencyIsoCode,Account_Industry__c, Account_Department__c, B2BCRTEndUserID__c From End_Customer__c  Where id=:customerId];
        
        return null;   
        
    } 
    
    public End_Customer__c getEndCustomerVar(){
        return endCstmr2Bmodified;
    } 
    
    public void setEndCustomerVar(End_Customer__c ecVar){
        this.endCstmr2Bmodified=ecVar;
    } 
    
    public pageReference saveEndCustomerVar(){        
        PageReference pageRef;
        Database.update(endCstmr2Bmodified);
        if(apexParam=='listPage'){            
             pageRef=new PageReference('/apex/MyCustomersListNSearch');
        }
        
        if(apexParam=='DetailPage'){            
             pageRef=new PageReference('/apex/EndCustomerDetailPage?id='+endCstmr2Bmodified.id);
        }       
        pageRef.setRedirect(true);
        return pageRef;                  
    }
    
    //---------------------view,edit,create,clone end customer contact---------------------------------//
    
    public List<End_Customer_Contact__c> getEndCustomerContactList(){
        return endCustomerContactList;
    }
    
    public pagereference doAction(){
        String mode=ApexPages.currentPage().getParameters().get('mode');
        EndCustomerId=ApexPages.currentPage().getParameters().get('ECCID');
        selectedEndCstmr=[Select Zip_Code__c, Website__c, Total_of_End_User_Employees__c, Tax_Id__c, Status__c, Segment__c, Partner_Account__c, OpportunityID__c, Name, MayEdit, Mailing_street__c, Mailing_country__c, Mailing_city__c, Mailing_State__c, LastModifiedDate, LastModifiedById, IsLocked, IsDeleted, Id, End_User_Account__c, Customer_Id__c, CurrencyIsoCode,Account_Industry__c, Account_Department__c From End_Customer__c  Where id=:EndCustomerId];
        
        if(mode=='view'){
            Id contactId=ApexPages.currentPage().getParameters().get('Id');
            ECContactVar=[select Name,Email__c,Last_Name__c,Phone__c,Mobile__c,Status__c,Fax__c,Title__c,end_customer__c,end_customer__r.name from 
            End_Customer_Contact__c where Id=:contactId];               
            boolViewContact=true;
            boolModifyContact=false;
        }else if(mode=='Create'){
            boolViewContact=false;
            boolModifyContact=true;
            apexParam='ContactCreate';
            ECContactVar=new End_Customer_Contact__c();
            ECContactVar.end_customer__c=selectedEndCstmr.Id;
            ECContactVar.Status__c='Active'; 
        }else if(mode=='Edit'){
            Id contactId=ApexPages.currentPage().getParameters().get('contactID2');
            ECContactVar=[select Name,Email__c,Last_Name__c,Phone__c,Mobile__c,Status__c,Fax__c,Title__c,end_customer__c,end_customer__r.name from
            End_Customer_Contact__c where Id=:contactId];
            boolViewContact=false;
            boolModifyContact=true;
            apexParam='ContactEdit';
        }else if(mode=='Clone'){
            boolViewContact=false;
            boolModifyContact=true;
            apexParam='ContactClone';
        }
        
        return null;
    }
    
    public Boolean getBoolViewContact(){
        return boolViewContact; 
    }
    
    public void setBoolViewContact(Boolean bool){
        this.boolViewContact=bool;
    }
    
    public Boolean getBoolModifyContact(){
        return boolModifyContact; 
    }
    
    public void setBoolModifyContact(Boolean bool){
        this.boolModifyContact=bool;
    }
    
    public End_Customer_Contact__c getECContactVar(){
        return ECContactVar; 
    }
    
    public void setECContactVar(End_Customer_Contact__c contact){
        this.ECContactVar=contact;
    }
    
    public pageReference ModifyEndCustomerContact(){
        PageReference pageRef=new PageReference('/apex/EndCustomerDetailPage?id='+EndCustomerId);
        Database.SaveResult MySaveResult;
        if(apexParam=='ContactEdit'){
            try{
                MySaveResult=Database.update(ECContactVar);
            }Catch(Exception e){
                ApexPages.Message msg;     
                msg = new ApexPages.Message(ApexPages.severity.FATAL,MySaveResult.getErrors()+'');
                ApexPages.addMessage(msg); 
                pageRef=null;
            }
          
        }
        
        if(apexParam=='ContactClone' || apexParam=='ContactCreate'){
            End_Customer_Contact__c contact=new End_Customer_Contact__c();
            contact.Name=ECContactVar.Name;
            contact.Email__c=ECContactVar.Email__c;
            contact.Last_Name__c=ECContactVar.Last_Name__c;
            contact.Phone__c=ECContactVar.Phone__c;
            contact.Mobile__c=ECContactVar.Mobile__c;
            contact.Status__c=ECContactVar.Status__c;
            contact.Fax__c=ECContactVar.Fax__c;
            contact.Title__c=ECContactVar.Title__c;
            contact.end_customer__c=selectedEndCstmr.Id;
            try{                
                MySaveResult=Database.Insert(contact);  
                if(MySaveResult.isSuccess()==true){
                        ECContactVar=contact;    
                 }
                
             }Catch(DMLException e) {
                 ApexPages.Message msg;     
                 msg = new ApexPages.Message(ApexPages.severity.FATAL,e.getDMLMessage(0)+'');
                 ApexPages.addMessage(msg); 
                 pageRef=null; 
             }             
            
        }
        try{
        //selectedEndCstmr=new End_customer__c();
        selectedEndCstmr=[Select Zip_Code__c, Website__c, Total_of_End_User_Employees__c, Tax_Id__c, Status__c, Segment__c, Partner_Account__c, OpportunityID__c, Name, MayEdit, Mailing_street__c, Mailing_country__c, Mailing_city__c, Mailing_State__c, LastModifiedDate, LastModifiedById, IsLocked, IsDeleted, Id, End_User_Account__c, Customer_Id__c, CurrencyIsoCode,Account_Industry__c, Account_Department__c From End_Customer__c  Where id=:ECContactVar.End_customer__c];
        endCustomerContactList=new List<End_Customer_Contact__c>();
        endCustomerContactList=[select Name,Email__c,Last_Name__c,Phone__c,Mobile__c,Status__c,Fax__c,Title__c,end_customer__c from End_Customer_Contact__c where end_customer__c=:selectedEndCstmr.Id];
        }Catch(Exception e){
                System.debug(e);        
        }
       pageRef.setRedirect(true);
       return pageRef;
    }
    
    public Opportunity getOpportunity(){
        return opportunityObj;
    }
    
    public void setOpportunity(Opportunity oppVar){
        this.opportunityObj=oppVar;
    }
    
    public List<Opportunity> getOpportunityList(){
        return opportunityList;
    }
    
   
    public pagereference helperFn(){
       return null;
    }
    
    public Id getRecordTypeId(){      
        return RecordTypeId;       
    }
        
    public String getBaseURL(){
        String baseURL=URL.getSalesforceBaseUrl().toExternalForm();        
        return baseURL; 
    } 
    //CR 7827 - Start
    public pageReference openLeadAction(){
        leadId =  ApexPages.currentPage().getParameters().get('leadId');
        return null;
    }//CR 7827 - End
}