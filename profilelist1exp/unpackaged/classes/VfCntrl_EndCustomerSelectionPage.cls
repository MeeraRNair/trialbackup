/***************************************************************************************************************************************************************
* 
* Name          : VfCntrl_EndCustomerSelectionPage
* Description   : controller class to support vfpage "EndCustomerSelectionPage" 
* ---------------------------------------------------------------------------------------
* Revision    Name            Date                 CR                                         Description
* 1.0       Srikanth        02.08.2016            12771                         Added logic to fetch the End customers related to loggedin User Account.
* 2.0       Meera           30-08-2016            13457                         Existing Customer List - UI enhancements
* 4.0       Srikanth        17.08.2016                                          Added logic to fetch the End customer Contacts related to Endcustomers.
* 4.0       Srikanth        06.09.2016                                          Added logic to Auto Populate End customer and End Customer COntact to Opportunity Detail page [RecordType: Deal Registartion with Existing End Customer]
* 4.0       Yeswanth        18.10.2016            13621                         Enable Partners to Deactivate End customers from deal reg  
* 5.0       Mahesh          20.06.2018            16069                         5157171:PAM - Intake # 16423 :  Display Existing End Customers\End customer contacts related to the track account
***************************************************************************************************************************************************************/

public without sharing class VfCntrl_EndCustomerSelectionPage{
    public boolean bdisplayPop {get; set;}
    public String strSelectedvalue{get; set;}
    public transient list<End_Customer__c> endCustomerList {get;set;}  // transient
    public string ErrorMessage{set;get;}
    public list<End_Customer_Contact__c> EndConList {get;set;}
    public boolean showTable {get;set;}
    public boolean showError {get;set;} 
    public boolean showContError {get;set;}
    public Id selectedAccId {get;set;}
    public Id selectedRecordId;
    public string createNewContact{get;set;}
    public boolean displayContactForm{get;set;}
    public boolean displaynewContactOption{get;set;}
    public End_Customer_Contact__c objEndCustumerContact {get;set;}     //transient  
    public string errorMsg{get;set;}
    public boolean showErroMsg{get;set;} 
    public boolean displayPopUp{get;set;}
    public boolean displayConfirmMsg{get;set;}
    public boolean displayErrorPopup{get;set;}
    public string selectedEndCustomerName {get;set;}
    public string selectedEndCustomerId{get;set;}
    // Temporary Variables to display Success msg
    public string endCustSuccessMsg{get;set;}
    ID selectedAccId1 {get;set;}
    string selectedContactName;
    public Id selectedContactId;
    string endCustomername;
    String endCustomerContactName;
    String stringToAppend = '';
    string endCustId;
    list<opportunity> oppId;
    public map<string,end_customer__c> mapOfEndCustomers {set;get;}
    public set<string> setofKeys {set;get;}
    public integer noOfRecords { get; set; }    
    public integer size { get; set; }   
    public ApexPages.StandardSetController ssc { get; set; }
    public list<wrapList> wrapAccList {get;set;}
    public list<SelectOption> paginationSizeOptions{get;set;}
    map<Id, wrapList> mapHoldingSelectedRecords{get;set;}
    public string name { get; set; }
    public string mailingState { get; set; }
    public integer pageSize{set;get;}
    public boolean Match {get;set;}
    public boolean NoMatch {get;set;}
    public boolean Showbutton {get;set;}
    public boolean SerchMatch{get;set;}
    public boolean hideCustListTable{get;set;}
    
    
    // Constructor    
    public  VfCntrl_EndCustomerSelectionPage(){
        // Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=11');content="IE=EmulateIE7
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible','IE=EmulateIE10');
        objEndCustumerContact = new End_Customer_Contact__c();
        createNewContact = 'false';
        displayContactForm = false;
        showErroMsg = false;
        displaynewContactOption = false;
        mapHoldingSelectedRecords = new Map<Id, wrapList>();
        init();
        getEndCustomers();
        strSelectedvalue = '';
        name='';
        mailingState='';
        pageSize = 10;
        //size=10;
        paginationSizeOptions = new List<SelectOption>();
        //paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
      //  getEndCustomers2();
        
        // Get Parameters from URL and append to url 
        PageReference pr = ApexPages.currentPage();                
        map<String, String> params = pr.getParameters();       
        for(String keyStr : params.keySet()){           
            if(keyStr != 'sfdc.override' && keyStr != 'save_new'){                
                if(stringToAppend != '') {
                    stringToAppend += '&';
                }
                stringToAppend += keyStr + '=' + pageUtils.encodeVariable(params.get(keyStr));
            }
        }
  }
  
public void searchContacts() {
 Match = False;
  User loggedInUser = [select id,contact.accountid,contact.Selected_Track_Account__c from user where id =:UserInfo.getUserId()];
  Id loggedinUserVar;
        
        if(loggedInUser.contact.Selected_Track_Account__c != null){
            loggedinUserVar =  loggedInUser.contact.Selected_Track_Account__c ;
        }else{
            loggedinUserVar =  loggedInUser.contact.accountid;
        }
        if(Name !='' && mailingState !=''){
        endCustomerList = [select id,name,Account_Department__c,Tax_Id__c,Mailing_street__c,Mailing_city__c,Mailing_State__c,Zip_Code__c,Mailing_country__c,DUNS_Number__c,Status__c,CreatedBy.Name from End_Customer__c where Name LIKE :('%' + name+ '%')
                    and Mailing_State__c=:mailingState AND Status__c ='Active' AND Partner_Account__c =:loggedinUserVar AND Source_System__c ='Deal Registration' order by name limit 1000 ];
                    showTable = false;
        
        
        if(endCustomerList.size()==0){
        NoMatch = True;
        SerchMatch = False; 
        Match = False;
        hideCustListTable = True;
        Showbutton = False;   
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'No records found'));     
    }
    else if(endCustomerList.size()>0){
        NoMatch = False;
        SerchMatch = True;
        Match = False;
        hideCustListTable = False;
        name='';
        mailingState='';
         if(endCustomerList.size()>10){
         Showbutton = true;
         }
         else{
         Showbutton = False;
         }
        
    } 
    
    }
      else if (Name !='' && mailingState ==''){
       Showbutton = False;
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'please enter a value for Mailing state'));
        }
        else if (Name =='' && mailingState !=''){
         Showbutton = False;
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'please enter a value for Account Name'));
        }
        else if (Name =='' && mailingState ==''){
         Showbutton = False;
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'please enter values for Account Name and Mailing state'));
        }
        
    }
      
 public void init() {
 name='';
        mailingState='';
 wrapAccList = new List<wrapList>();
 for (End_Customer__c cont : (List<End_Customer__c>)setCon.getRecords()) {
 if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(cont.id)){
 wrapAccList.add(mapHoldingSelectedRecords.get(cont.id));
 wrapAccList.sort();
 }
 else{
   wrapAccList.add(new wrapList(cont, false));
 }
 }
 }
 public ApexPages.StandardSetController setCon {
 get {
 NoMatch = False;
    Match = True; 
    Showbutton = true; 
    SerchMatch = False;
 if(setCon == null) {
 User loggedInUser = [select id,contact.accountid,contact.Selected_Track_Account__c from user where id =:UserInfo.getUserId()]; //transient
       Id loggedinUserVar;
        //*****5.0 Start*****//
        if(loggedInUser.contact.Selected_Track_Account__c != null){
            loggedinUserVar =  loggedInUser.contact.Selected_Track_Account__c ;
        }else{
            loggedinUserVar =  loggedInUser.contact.accountid;
        }
        system.debug('*****' +loggedinUserVar);
      //*****5.0 End*****//
      
      string endCustQuery = 'select id,name,Account_Department__c,Tax_Id__c,Mailing_street__c,Mailing_city__c,Mailing_State__c,Zip_Code__c,Mailing_country__c,DUNS_Number__c,Status__c,CreatedBy.Name from End_Customer__c where Status__c = ' + '\'' + 'Active' + '\' AND Partner_Account__c =:loggedinUserVar AND Source_System__c = ' + '\'' + 'Deal Registration' + '\' order by name limit 10000';
   //setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select id,name,Account_Department__c,Tax_Id__c,Mailing_street__c,Mailing_city__c,Mailing_State__c,Zip_Code__c,Mailing_country__c,DUNS_Number__c,Status__c,CreatedBy.Name from End_Customer__c where Status__c ='Active' AND Partner_Account__c =:loggedinUserVar AND Source_System__c ='Deal Registration' order by name LIMIT 10000]));
   setCon = new ApexPages.StandardSetController(Database.getQueryLocator(endCustQuery));
   string endCustCountQuery = 'select Count() from End_Customer__c where Status__c = ' + '\'' + 'Active' + '\' AND Partner_Account__c =:loggedinUserVar AND Source_System__c = ' + '\'' + 'Deal Registration' + '\' ';     
   setCon.setPageSize(10);
       try{
            Integer endCustCount = Database.countQuery(endCustCountQuery); 
          
            If( endCustCount >= 10000 ){
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Total No. of End Customers are :'+ endCustCount + '. Displaying Max Limit of 10000 End Customers'  ));

            }
            endCustomerList = database.query(endCustQuery);
        }catch(QueryException ex){
            System.debug('***Exception: '+ ex.getMessage());
        }
   
 }
   return setCon;
 }
 set;
 }
 public PageReference refreshPageSize() {
         setCon.setPageSize(pageSize);
         return null;
    }
 
 /** indicates whether there are more records after the current page set.*/
 public Boolean hasNext {
 get {
   return setCon.getHasNext();
 }
 set;
 }
 
 /** indicates whether there are more records before the current page set.*/
 public Boolean hasPrevious {
 get {
   return setCon.getHasPrevious();
 }
 set;
 }
 
 /** returns the page number of the current page set*/
 public Integer pageNumber {
 get {
   return setCon.getPageNumber();
 }
 set;
 }
 
 /** return total number of pages for page set*/
   Public Integer getTotalPages(){
     Decimal totalSize = setCon.getResultSize();
     Decimal pageSize = setCon.getPageSize();
     Decimal pages = totalSize/pageSize;
     return (Integer)pages.round(System.RoundingMode.CEILING);
 }
 
 /** returns the first page of the page set*/
 public void first() {
   
   setCon.first();
   init();
 }
 
 /** returns the last page of the page set*/
 public void last() {
   
   setCon.last();
   init();
 }
 
 /** returns the previous page of the page set*/
 public void previous() {
   
   setCon.previous();
   init();
 }
 
 /** returns the next page of the page set*/
 public void next() {
   
   setCon.next();
   init();
 }
 //Display end customers  
    public void getEndCustomers(){
         
     
        endCustomerList = new List<End_Customer__c>();   
        string endCustCountQuery = 'select Count() from End_Customer__c where Status__c = ' + '\'' + 'Active' + '\' AND Partner_Account__c =:loggedinUserVar AND Source_System__c = ' + '\'' + 'Deal Registration' + '\' ';     
        /*string endCustQuery = 'select id,name,Account_Department__c,Tax_Id__c,Mailing_street__c,Mailing_city__c,Mailing_State__c,Zip_Code__c,Mailing_country__c,DUNS_Number__c,Status__c,CreatedBy.Name from End_Customer__c where Status__c = ' + '\'' + 'Active' + '\' AND Partner_Account__c =:loggedinUserVar AND Source_System__c = ' + '\'' + 'Deal Registration' + '\' order by name limit 10000';*/
       /*try{
            Integer endCustCount = Database.countQuery(endCustCountQuery); 
          
            If( endCustCount >= 10000 ){
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Total No. of End Customers are :'+ endCustCount + '. Displaying only 10000 End Customers'  ));

            }
            endCustomerList = database.query(endCustQuery);
        }catch(QueryException ex){
            System.debug('***Exception: '+ ex.getMessage());
        }*/
    }
   
    public void fetchContacts(){
    system.debug('inside fetchContacts method calling');
        EndConList = new List<End_Customer_Contact__c>();
        showtable = True;
        displaynewContactOption = true; 
        showError = false;
        showErroMsg = false;
        displayContactForm = false;
        selectedRecordId = System.currentPagereference().getParameters().get('selectedAccId');
      
        if(selectedRecordId != Null){
            string contQuery = 'select id,Name,Last_Name__c,Title__c,Email__c,Status__c,End_Customer__c from End_Customer_Contact__c where Status__c = ' + '\'' + 'Active' + '\' AND End_Customer__c =:selectedRecordId order by createddate desc ';
            EndConList = database.query(contQuery);

            If(EndConList.size() < 1){
                showError = true;
                showtable = false;
                displaynewContactOption = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, (system.label.NoPrevUsed_Contact_Error)  ));
            }
        }
        else{
            showError = true;
            showtable = false;
            displaynewContactOption = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, (system.label.Please_select_one_End_Customer)));
            return;
        }
        
        //Selected EndCustomer Name to pass to URL
        endCustomername = [select name from End_Customer__c where id=:selectedRecordId limit 1][0].name;
        
    }
    
    public void createNewContForm(){
        objEndCustumerContact = new End_Customer_Contact__c();
        createNewContact = 'true';
        displayContactForm = true;
        showErroMsg = false;
        showContError = false;
    } 
     public Pagereference close(){
        system.debug('>>>>>>>>>>>>strSelectedvalue::'+strSelectedvalue);
        system.debug('!!!!!!!'+createNewContact );
        if(strSelectedvalue == 'No'){
            bdisplayPop = false;
            return null;
        }
        //system.debug('@@@@@@@@'+strSelectedvalue );
         
        else if (strSelectedvalue == 'Yes' && createNewContact == 'True'){
            String dup = DealReg_CustomerSelectionHelper.checkEndCustomerContactDuplicate(objEndCustumerContact.Email__c,selectedRecordId);                
                system.debug('dup'+dup);
                if( true){
                
                   objEndCustumerContact.End_Customer__c= selectedRecordId;
                    objEndCustumerContact.Status__c = 'Active';
                    insert objEndCustumerContact;                  
                    system.debug('selectedRecordId value is :'+selectedRecordId);                    
                    End_Customer__c endCust = [SELECT id FROM End_Customer__c WHERE Id =: selectedRecordId];
                    endCust.End_Customer_Selection__c = 'Existing';
                    endCust.Created_using_Partner_D_B_Search__c = 'No';
                    update endCust; 
                    system.debug('>>>>AFter UPDATE :: '+endCust);
                    
                    endCustomerContactName = objEndCustumerContact.Name;
                  //  endCustomerContactName = objEndCustumerContact.Name + objEndCustumerContact.Last_name__c;
                    selectedContactId = objEndCustumerContact.Id;
                    system.debug('****endCustomerContactName:'+endCustomerContactName);
                    showErroMsg = false;
                    
                    End_Customer__c endCust1 = [SELECT id FROM End_Customer__c WHERE Id =: selectedRecordId];
                    endCust.End_Customer_Selection__c = 'Existing';
                    update endCust1;
                   // String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&CF00NA00000063VT1= '+ pageUtils.encodeVariable(endCustomername) +'&CF00NA00000063VT1_lkid='+ selectedRecordId +'&CF00NA00000063VT6='+ pageUtils.encodeVariable(endCustomerContactName) +'&CF00NA00000063VT6_lkid='+selectedContactId+''+'&'+stringToAppend;
                    String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&00N3B000000iyik='+'Existing'+'&CF00NA00000063VT1= '+ pageUtils.encodeVariable(endCustomername) +'&CF00NA00000063VT1_lkid='+ selectedRecordId +'&CF00NA00000063VT6='+ pageUtils.encodeVariable(endCustomerContactName) +'&CF00NA00000063VT6_lkid='+selectedContactId+''+'&'+stringToAppend;
                  
                    PageReference page = new PageReference(redirectToOppDetailPage);
                    system.debug('****endCustomerContactName:'+endCustomerContactName);
                    system.debug('****selectedContactId:'+selectedContactId);
                    return page;
                } 
                else{
                system.debug('>>>>>IN ELSE 1');
                    //duplicate exists
                    errorMsg = System.Label.DealReg_ECContactDupeError +dup ;
                    showErroMsg = true;
                    displayContactForm = true;                    
                    End_Customer__c endCust = [SELECT id FROM End_Customer__c WHERE Id =: selectedRecordId];
                    endCust.End_Customer_Selection__c = 'Existing';
                    endCust.Created_using_Partner_D_B_Search__c = 'No';
                    update endCust; 
                     system.debug('>>>>AFter UPDATE IN ELSE :: '+endCust);
                    
                    return null;
                }
            
        }
        else if (strSelectedvalue == 'Yes' && createNewContact == 'False'){
           string endCustomername = [select name from End_Customer__c where id=:selectedRecordId limit 1][0].name;
            string endCustomerContactName = [Select name, Last_Name__c from End_Customer_Contact__c where id=:selectedContactId Limit 1][0].Name;
            String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&00N3B000000iyik='+'Existing'+'&CF00NA00000063VT1= '+ pageUtils.encodeVariable(endCustomername) +'&CF00NA00000063VT1_lkid='+ selectedRecordId +'&CF00NA00000063VT6='+ pageUtils.encodeVariable(endCustomerContactName) +'&CF00NA00000063VT6_lkid='+selectedContactId+''+'&'+stringToAppend;
                  
                    PageReference page = new PageReference(redirectToOppDetailPage);
                    system.debug('****endCustomerContactName##:'+endCustomerContactName);
                    system.debug('****selectedContactId:'+selectedContactId);
                    return page;
        }
        return null;
    }
    public void hideNewContForm(){
        displayContactForm = false;
        showContError = false;
        createNewContact = 'false';
        showErroMsg = false;
    }
     public List<SelectOption> getradiobuttonsItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }
    
    public pageReference saveEndCustomerDetails(){
        strSelectedvalue = '';
    
        try{
            showErroMsg = false;
            selectedContactId = System.currentPagereference().getParameters().get('selectedAccId1');
            System.debug('***COntact Id: '+ selectedContactId);
            If((selectedContactId == Null ) && createNewContact == 'false' ){
                errorMsg = system.label.DealReg_ContactButError;
                showErroMsg = true;   
                return null;
            }
            
              if(createNewContact == 'True'){
                If( objEndCustumerContact.Name == null || objEndCustumerContact.Name == ''
                   || objEndCustumerContact.Email__c == null || objEndCustumerContact.Email__c == '' 
                   || objEndCustumerContact.Last_Name__c == null || objEndCustumerContact.Last_Name__c == ''
                   || objEndCustumerContact.Phone__c ==null || objEndCustumerContact.Phone__c ==''){
                
                system.debug('>>>in iF::');      
                If(objEndCustumerContact.Name == null || objEndCustumerContact.Name == ''){
                    objEndCustumerContact.Name.addError(system.label.You_must_enter_a_value);
                }
                
                If(objEndCustumerContact.Email__c == null || objEndCustumerContact.Email__c == ''){
                    objEndCustumerContact.Email__c.addError(system.label.You_must_enter_a_value);
                }
                
                If(objEndCustumerContact.Last_Name__c == null || objEndCustumerContact.Last_Name__c == ''){
                    objEndCustumerContact.Last_Name__c.addError(system.label.You_must_enter_a_value);
                }
                       
                If(objEndCustumerContact.Phone__c == null || objEndCustumerContact.Phone__c == ''){
                    objEndCustumerContact.Phone__c.addError(system.label.You_must_enter_a_value);
                }
                
                return null;  
            
               }else{
               
              
                //check for duplicate
                String dup = DealReg_CustomerSelectionHelper.checkEndCustomerContactDuplicate(objEndCustumerContact.Email__c,selectedRecordId);
                
                if( dup == 'None'){
                system.debug('>>>>>IN IF 1');
                    String[] strloginuseremail = System.UserInfo.getUserEmail().split('@');
                    string strdomain = strloginuseremail[1].substringBefore('.'); 
                    String[] strexistingemail;  
                    if(selectedContactId == null){
                         strexistingemail = objEndCustumerContact.Email__c.split('@');
                    }else{
                         strexistingemail = [Select id,Email__c from End_Customer_Contact__c where id =:selectedContactId].Email__c.split('@');
                         //strexistingemail = 
                    }
                    string strenduserdomain = strexistingemail[1].substringBefore('.'); 
                    system.debug('>>>strenduserdomain ::'+strenduserdomain );          
                    if(strdomain == strenduserdomain ){
                        bdisplayPop = true;
                        system.debug('bdisplayPop ********'+bdisplayPop );
                       
                        return null;
                    }else if(strdomain != strenduserdomain ){
                        objEndCustumerContact.End_Customer__c=selectedRecordId;
                        objEndCustumerContact.Status__c = 'Active';
                        insert objEndCustumerContact;
                        
                        system.debug('selectedRecordId value is :'+selectedRecordId);
                        
                        End_Customer__c endCust = [SELECT id FROM End_Customer__c WHERE Id =: selectedRecordId];
                        endCust.End_Customer_Selection__c = 'Existing';
                        endCust.Created_using_Partner_D_B_Search__c = 'No';
                        update endCust; 
                        system.debug('>>>>AFter UPDATE :: '+endCust);
                        
                        endCustomerContactName = objEndCustumerContact.Name;
                      //  endCustomerContactName = objEndCustumerContact.Name + objEndCustumerContact.Last_name__c;
                        selectedContactId = objEndCustumerContact.Id;
                        system.debug('****endCustomerContactName:'+endCustomerContactName);
                        showErroMsg = false;
                    }  
                    
                } 
                else{
                system.debug('>>>>>IN ELSE 1');
                    //duplicate exists
                    errorMsg = System.Label.DealReg_ECContactDupeError +dup ;
                    showErroMsg = true;
                    displayContactForm = true;                    
                    End_Customer__c endCust = [SELECT id FROM End_Customer__c WHERE Id =: selectedRecordId];
                    endCust.End_Customer_Selection__c = 'Existing';
                    endCust.Created_using_Partner_D_B_Search__c = 'No';
                    update endCust; 
                     system.debug('>>>>AFter UPDATE IN ELSE :: '+endCust);
                    
                    return null;
                }
              }
            } 
            
            
            else{
            String[] strloginuseremail = System.UserInfo.getUserEmail().split('@');
            string strdomain = strloginuseremail[1].substringBefore('.'); 
            String[] strexistingemail;  
            if(selectedContactId == null){
                 strexistingemail = objEndCustumerContact.Email__c.split('@');
            }else{
                 strexistingemail = [Select id,Email__c from End_Customer_Contact__c where id =:selectedContactId].Email__c.split('@');
                 //strexistingemail = 
            }
            string strenduserdomain = strexistingemail[1].substringBefore('.'); 
            system.debug('>>>strenduserdomain ::'+strenduserdomain );          
            if(strdomain == strenduserdomain ){
                bdisplayPop = true;
                system.debug('bdisplayPop ********'+bdisplayPop );
               
                return null;
            }  
                //Selected EndCustomer Contact to pass to URL
                endCustomerContactName = [Select name, Last_Name__c from End_Customer_Contact__c where id=:selectedContactId Limit 1][0].Name;
               
              /* List<End_Customer_Contact__c> endcustomerLFNmae = new List<End_Customer_Contact__c>([select name,Last_name__c from End_Customer_Contact__c where id=:selectedContactId limit 1]);
               string endCustomerContactName = endcustomerLFNmae[0].name  + endcustomerLFNmae[0].Last_name__c;
                 system.debug('****endcustomerLFNmae:'+endCustomerContactName);  */
           }
            
            End_Customer__c endCust = [SELECT id FROM End_Customer__c WHERE Id =: selectedRecordId];
            endCust.End_Customer_Selection__c = 'Existing';
            update endCust;
            
             system.debug('>>>>AFter UPDATE END::'+endCust);
            String[] strloginuseremail = System.UserInfo.getUserEmail().split('@');
            string strdomain = strloginuseremail[1].substringBefore('.'); 
            String[] strexistingemail;  
            if(selectedContactId == null){
                 strexistingemail = objEndCustumerContact.Email__c.split('@');
            }else{
                 strexistingemail = [Select id,Email__c from End_Customer_Contact__c where id =:selectedContactId].Email__c.split('@');
                 //strexistingemail = 
            }
            string strenduserdomain = strexistingemail[1].substringBefore('.'); 
            system.debug('>>>strenduserdomain END ::'+strenduserdomain );          
            if(strdomain == strenduserdomain ){
                bdisplayPop = true;
                system.debug('bdisplayPop END********'+bdisplayPop );
               
                return null;
            }        
            
           // String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&CF00NA00000063VT1= '+ pageUtils.encodeVariable(endCustomername) +'&CF00NA00000063VT1_lkid='+ selectedRecordId +'&CF00NA00000063VT6='+ pageUtils.encodeVariable(endCustomerContactName) +'&CF00NA00000063VT6_lkid='+selectedContactId+''+'&'+stringToAppend;
           String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&00N3B000000iyik='+'Existing'+'&CF00NA00000063VT1= '+ pageUtils.encodeVariable(endCustomername) +'&CF00NA00000063VT1_lkid='+ selectedRecordId +'&CF00NA00000063VT6='+ pageUtils.encodeVariable(endCustomerContactName) +'&CF00NA00000063VT6_lkid='+selectedContactId+''+'&'+stringToAppend;
          
            // String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&00N3B000000iyik='+'Existing'+'&CF00NA00000063VT1= '+ pageUtils.encodeVariable(endCustomername) +'&CF00NA00000063VT1_lkid='+ selectedRecordId +'&CF00NA00000063VT6='+ pageUtils.encodeVariable(endCustomerContactName) +'&CF00NA00000063VT6_lkid='+selectedContactId+''+'&00N3B000000k2sC=1'+'&'+stringToAppend;
          
            
        //     String redirectToOppDetailPage= '/apex/OpportunityRedirectPage?&ent=Opportunity&nooverride=1&RecordType=012A0000000Vi0S&retURL=%2F006%2Fo&00N3B000000iyik='+'Existing'+'&CF00NA00000063VT1= '+ pageUtils.encodeVariable(endCustomername) +'&CF00NA00000063VT1_lkid='+ selectedRecordId +'&CF00NA00000063VT6='+ pageUtils.encodeVariable(endCustomerContactName) +'&CF00NA00000063VT6_lkid='+selectedContactId+''+(DealRegUtils.IsGcCountry() == true? '&00N3B000000k2sC=1':'') +'&'+stringToAppend;
            
            
            // Deal Reg Id: 00NA00000063VZx
            // Deal reg Exist Id: 012A0000000Vi0S
            
            
            PageReference page = new PageReference(redirectToOppDetailPage);
            
            return page;
                
            }catch(DmlException dmlEx){
                SYstem.debug('***DML Exception: '+ dmlEx.getMessage());
            }catch(Exception ex){
                SYstem.debug('***Exception: '+ ex.getMessage() + ' at line# '+ ex.getLineNumber());
            }
        return null;
                      
       } 
    
    public pageReference Cancel(){
        //return new pageReference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F006%2Fo&save_new_url=%2F006%2Fe%3FretURL%3D%252F006%252Fo');
        return new pageReference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F006%2Fo&save_new_url=%2Fapex%2FSales_motion_account_selection_vfp%3FretURL%3D%252F006%252Fo');
    }
    
    public pageReference navigateToDnBPage(){
        String URL= '/apex/SearchEndCustomerFromDnB?'+stringToAppend+'&nooverride=1';
        pagereference page = new pagereference(URL);
        page.setRedirect(TRUE);
        return page;
    }
    
 // Inactivate Method   
   public void inactivateMethod(){ 
  // system.debug('Inside the inactivateMethod');
       displayErrorPopup = false;
       displayPopUp = false;
       displayConfirmMsg = false;
       oppId = new list<opportunity>();
       system.debug('****' +selectedEndCustomerId); 
       try{
       

               selectedEndCustomerId = System.currentPagereference().getParameters().get('selectedAccId');
       //   system.debug('Inside the inactivateMethod inside try catch '+ selectedRecordId);
       
       
         if(selectedEndCustomerId==null || selectedEndCustomerId =='')
             {
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, (system.label.Please_select_one_End_Customer)));

                    system.debug('inside try catch selectedEndCustomerId value is: ' + selectedEndCustomerId);
             }
             
         else
         {
           selectedEndCustomerName = [select name from end_customer__c where id = :selectedEndCustomerId limit 1 ][0].name; 
           
         // Query to check if there is any open opportunity tied to the end customer  
            String oppQuery = 'select id,name from opportunity where Deal_Reg_Oppty__c = ' + '\'' + 'Yes' + '\'' + ' AND StageName != ' + '\'' + 'Win - 100%' + '\'' + ' AND StageName != ' + '\'' + 'Lost, Cancelled - 0%' + '\'' + ' AND Deal_Registration_Status__c != ' + '\'' + 'Rejected' + '\'' + ' AND End_Customer__c = :selectedEndCustomerId limit 1';                              
            oppId = Database.query(oppQuery);     
           
           system.debug('***' +oppId);
      
           if(oppId.size()>0) {     
              displayConfirmMsg = false;
              displayErrorPopup = true;
              displayPopUp = true;
           }
           else{
               displayPopUp = true;
               displayConfirmMsg = true;  
           }
         }  
        }catch(Exception ex){
                showErroMsg = true;
                errorMsg = ex.getMessage();
                displayConfirmMsg = false;
                displayErrorPopup = false;
                displayPopUp = false;
                SYstem.debug('***Exception: '+ ex.getMessage() + ' at line# '+ ex.getLineNumber());
    }
   
  }  
 // Method which fires when user clicks on NO on Pop up  
    public void closePopup() {        
        displayPopup = false; 
        showTable = false;
        displaynewContactOption = false;
    }  

 // Method which fires when user clicks on Yes on Pop up   
    public void delEndCust(){
     try{        
                end_customer__c endCustomer = new end_customer__c(id = selectedEndCustomerId,
                                                                  Status__c = 'Inactive');
               Update endCustomer;
               
                               
                getEndCustomers();
                displayPopup = false;
                showTable = false;
                displaynewContactOption = false;
                displayContactForm = false;
        }
    catch(Exception ex){
                displayConfirmMsg = false;
                displayErrorPopup = false;
                displayPopUp = false;
                showErroMsg = true;
                errorMsg = ex.getMessage();
                SYstem.debug('***Exception: '+ ex.getMessage() + ' at line# '+ ex.getLineNumber());
            }
    }
public class wrapList {           
//Declare variables to wrap (one will be for checkbox, another is the list record)    
public Boolean isSelected {get;set;}    
public End_Customer__c ecRecord {get;set;}        
//The above variables are decalred so that an End_Customer__c record can be binded with a checkbox variable       
//We can treat the checkbox and End_Customer__c record together and later even identify the checkbox selected for a unique record by end user     //Contructor method to bind the End_Customer__c record with checkbox whenever class is instantiated     
public wrapList(End_Customer__c endCust, Boolean isSelected) {      
isSelected = false;       
ecRecord = endCust;       
}       
}
}