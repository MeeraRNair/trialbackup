/***************************************************************************************************************************************************************
* 
* Name          : Vfcntrl_Distributor_Switch_Form
* Description   : controller class to support vfpage "Distributor Switch Form" 
* ---------------------------------------------------------------------------------------
* Revision  Name            Date                 CR                                         Description
* 1.0       Yeswanth      12.05.2017            14328                            Created Distributor Switch Request Form for Resellers
* 2.0       JVSantosh     15.05.2017            14329                            Save Distributor Switch Request on the Distributor Relationship
* 3.0       JVSantosh     09.06.2017            14473                            Created Distributor Setup RequestForm  Form for Resellers
* 4.0       Mahesh        02.01.2019                                             updated code to use Selected Salesmotion account details instead of master grouping account
***************************************************************************************************************************************************************/

public without sharing class Vfcntrl_Distributor_Switch_Form {
    // Variables declaration
    public Disti_Relationship__c distiRelationShip = new Disti_Relationship__c();
    public string searchString {get;set;}
    public list < Account > accList {get;set;}
    public boolean showTable {get;set;}
    public boolean showForm {get;set;}
    public boolean showSubmittedSection {get;set;}
    public boolean TnCaccept {get;set;}
    public boolean hideSubmitButton{get;set;}
    public boolean showError{get;set;}
    Public boolean DistributorSetupRequestForm{get;set;}
    public string SearchBy {get;set;}
    public List<Disti_Relationship__c> distiRecord {get;set;}
    public user loggedInUser{get;set;}
    Id selectedRecordId;
    public string loggedInUserCountry {get ; set ;}
    public string selectedname {get ; set;}
    public string selectednamesecond {get ; set;}
    public boolean hidesavebutton {get ; set ;}
    public boolean has2Distis {get ; set ;}
    public boolean Openfirstsearch  {get ; set ;}
    public boolean opensecondsearch {get ; set ;}
    public boolean changedisti1 {get ; set ;}
    public boolean changedisti2 {get ; set ;}
    id firstdistiid;
    id seconddistiid;
    public string type {get ; set;}
    id trackAccId;
    set<id> masterGrouppingIds;
    
    public Disti_Relationship__c getdistiRelationShip() {
        return distiRelationShip;
    }
    // Below Method executes OnPageLoad                
    public void onPageLoad() {
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');      
        try{
            DistributorSetupRequestForm = false;
            distiRecord = new List<Disti_Relationship__c>();
            showForm = true;  
            showSubmittedSection = false;
            hidesavebutton = false;
            has2Distis = false;
            Openfirstsearch = false;
            opensecondsearch = false; 
            type = ApexPages.currentPage().getParameters().get('type');   
            loggedInUser = [select Id,name,contact.accountid,contact.Selected_Track_Account__c,contact.Selected_Track_Account__r.account_country__c,contact.account_country__c from user where id = : UserInfo.getUserId()];
            //*****4.0 Start*****//
            if(loggedInUser.contact.Selected_Track_Account__c != null){
                trackAccId = loggedInUser.contact.Selected_Track_Account__c;
                loggedInUserCountry = loggedInUser.contact.Selected_Track_Account__r.account_country__c.Tolowercase();
            }else{
                trackAccId = loggedInUser.Contact.accountid;
                loggedInUserCountry = loggedInUser.contact.account_country__c.Tolowercase();
            }
            //*****4.0 End*****//
            distiRecord = [select id,Disti_Account__c,Disti_Account_Name__c,Requested_Distributor__r.name,Requested_Distributor_Date__c,Requested_Distributor_By__c,Requested_Distributor_Status__c,Secondary_Storage_Preferred_Distributor__c,Secondary_Storage_Preferred_Distributor__r.Name, Requested_Secondary_Distributor__c,Requested_Secondary_Distributor__r.name,
                           Requested_Secondary_Distributor_By__c, Requested_Secondary_Distributor_Date__c, Requested_Secondary_Distributor_Status__c, Secondary_Distributor_Request_Reason__c, Existing_Secondary_Distributor_Informed__c from Disti_Relationship__c where Reseller_Account__c = :trackAccId limit 1];
            if(type == 'firstdisti'){
                changedisti1 = true;
                changedisti2 = false;
                if(loggedInUser != null  && distiRecord.size() > 0 && distiRecord[0].Disti_Account__c != null) {
                    if(distiRecord[0].Requested_Distributor__c != null && (distiRecord[0].Requested_Distributor_Status__c == 'Submitted' || distiRecord[0].Requested_Distributor_Status__c == 'In Progress')){
                        showSubmittedSection = true;
                        showForm = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Deal_Reg_Distributor_Switch_Submitted_Msg));      
                    }             
                }else{
                    showError = true;
                    showSubmittedSection = false;
                    showForm = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Deal_Reg_Distributor_Switch_No_Disti_Record));      
                }
            }
            else if (type == 'seconddisti'){
                changedisti1 = false;
                changedisti2 = true;
                if(loggedInUser != null  && distiRecord.size() > 0 && distiRecord[0].Secondary_Storage_Preferred_Distributor__c != null) {
                    if(distiRecord[0].Requested_Secondary_Distributor__c != null && (distiRecord[0].Requested_Secondary_Distributor_Status__c == 'Submitted' || distiRecord[0].Requested_Secondary_Distributor_Status__c == 'In Progress')){
                        showSubmittedSection = true;
                        showForm = false;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Deal_Reg_Distributor_Switch_Submitted_Msg));      
                    }             
                }else{
                    showError = true;
                    showSubmittedSection = false;
                    showForm = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Deal_Reg_Distributor_Switch_No_Disti_Record));      
                }      
            }
        }catch (Exception ex) {
            system.debug('----catch 1---' + ex.getMessage());
        }       
    }
    
    // Below Method executes OnnewPageLoad of DistributorSetupRequestForm
    public void onnewPageLoad() {
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        
        try{
            DistributorSetupRequestForm = false;
            changedisti1 = false;
            changedisti2 = false;
            distiRecord = new List<Disti_Relationship__c>();
            showForm = true;  
            showSubmittedSection = false;  
            hidesavebutton = true;  
            type = null;
            loggedInUser = [select Id,name,contact.accountid,contact.account_country__c,contact.Selected_Track_Account__c,contact.Selected_Track_Account__r.account_country__c from user where id = : UserInfo.getUserId()];
            //*****4.0 Start*****//
            if(loggedInUser.contact.Selected_Track_Account__c != null){
                trackAccId = loggedInUser.contact.Selected_Track_Account__c;
                loggedInUserCountry = loggedInUser.contact.Selected_Track_Account__r.account_country__c.Tolowercase();
            }else{
                trackAccId = loggedInUser.Contact.accountid;
                loggedInUserCountry = loggedInUser.contact.account_country__c.Tolowercase();
            }
            //*****4.0 End*****//
            has2Distis = ((Label.DealReg_GcCountries).Containsignorecase(loggedInUserCountry) || Label.DealReg_GcCountries == 'ALLCOUNTRIES') ? true : false;
            Opensecondsearch = false; 
            openfirstsearch = false;
            
            distiRecord = [select id,Disti_Account__c,Disti_Account_Name__c,Requested_Distributor__r.name,Requested_Distributor_Date__c,Requested_Distributor_By__c,Requested_Distributor_Status__c from Disti_Relationship__c where Reseller_Account__c = :trackAccId limit 1];
            
            if(distiRecord.size() > 0 && (distiRecord[0].Requested_Distributor__c != null && (distiRecord[0].Requested_Distributor_Status__c == 'Submitted' || distiRecord[0].Requested_Distributor_Status__c == 'In Progress'))){
                showSubmittedSection = true;
                showForm = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.Deal_Reg_Distributor_Setup_Req_Msg));      
            }
            else{
                showSubmittedSection = false;
                showForm = true;
            }
            DistributorSetupRequestForm = true;
        }catch (Exception ex) {
            system.debug('----catch 1---' + ex.getMessage());
        }       
    }
    // Search Functionality
    public void fetchResults() {
        try {
            hideSubmitButton = true;
            List<string> listdistributorPartnerTypes = system.label.Distibutor_Partner_Types.split(',');
            accList = new List < Account > ();
            If(string.isNotBlank(searchString) && TnCaccept && ((string.isNotBlank(distiRelationShip.Distributor_Request_Reason__c) && string.isNotBlank(distiRelationShip.Existing_Distributor_Informed__c)) || DistributorSetupRequestForm )){
                If(searchString.length() > 2) {
                    String modifiedsearchString = searchString.replace('\\', '\\\\');
                    if (modifiedsearchString.contains('\'')) {
                        modifiedsearchString = modifiedsearchString.replaceAll('[\\\\\']', '\\\\\'');
                    }
                    boolean invalidInput = false;
                    
                    List < Account > accQueryList = new List < Account > ();
                    accList = new List < Account > ();
                    String recid = '012A0000000TR6Y';
                    String searchquery = 'Select id,name,Billingcity,Account_ID__c,Billingstate,Billingcountry,NameLocal,Account_Country__c, Calculated_Status__c,Partner_Registration__c from account where Sales_Motion_Deal_Registration__c = True and RecordTypeId = :recid';
                    
                    // Search by Account Name
                    if (SearchBy == 'Name') {
                    system.debug('>>>>>>>loggedInUserCountry'+loggedInUserCountry);
                     //   searchquery += '  And Account_Country__c = :loggedInUserCountry And (name LIKE' + '\'%' + modifiedsearchString + '%\'' + ' OR NameLocal LIKE ' + '\'%' + modifiedsearchString + '%\' ) AND (Partner_Type__c = ' + '\'' + 'Commercial Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'OEM Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Distributor (GCC)' + '\') AND Partner_Relationship__c LIKE ' + '\'%' + 'Storage' + '%\' ';
                        searchquery += '  And Account_Country__c = :loggedInUserCountry And (name LIKE' + '\'%' + modifiedsearchString + '%\'' + ' OR NameLocal LIKE ' + '\'%' + modifiedsearchString + '%\' ) AND (Partner_Type__c IN: listdistributorPartnerTypes) AND Partner_Relationship__c LIKE ' + '\'%' + 'Storage' + '%\' ';
                        accQueryList = Database.query(searchquery);
                        If(accQueryList.size() > 0) {
                            for (Account acc: accQueryList) {
                                If(acc.Calculated_Status__c == 'Active' && acc.Partner_Registration__c <> null) {
                                    accList.add(acc);
                                }
                            }
                        }
                    }
                    
                    // Search by Affinity ID
                    else if (SearchBy == 'Affinity') {
                        boolean alphaStringCheck = pattern.matches('[0-9]+', modifiedsearchString);
                        if (alphaStringCheck == false) {
                            showtable = false;
                            invalidInput = true;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Affinity_Error_Message));
                        } else {
                      //      searchquery += ' AND Partner_Registration__c <> null AND Calculated_Status__c = ' + '\'' + 'Active' + '\' AND Account_ID__c = : modifiedsearchString AND (Partner_Type__c = ' + '\'' + 'Commercial Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'OEM Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Distributor (GCC)' + '\') order by name';
                                searchquery += ' AND Partner_Registration__c <> null AND Calculated_Status__c = ' + '\'' + 'Active' + '\' AND Account_ID__c = : modifiedsearchString AND (Partner_Type__c IN: listdistributorPartnerTypes) order by name';
                           
                            accList = Database.query(searchquery);
                        }      
                    }
                    
                    //**** Search by Email  
                    else if (SearchBy == 'Email') {
                        If(!modifiedsearchString.startsWithIgnoreCase('.com') && !modifiedsearchString.startsWithIgnoreCase('.net') && !modifiedsearchString.startsWithIgnoreCase('.co')) {
                            masterGrouppingIds = new set<id>();
                            masterGrouppingIds = DistiVisibilityHelperClass.getMasterGroupAccnts(modifiedsearchString); 
                        //    String searchEmail = 'select id,name,Account_ID__c, Billingcity,Purchasing_Model__c, Billingstate, Billingcountry, NameLocal, Account_Country__c ,Master_Group_Id__c,Calculated_Status__c,Partner_Registration__c from Account where Sales_Motion_Deal_Registration__c = True and RecordTypeId = :recid AND Partner_Registration__c <> null and Calculated_Status__c = ' + '\'' + 'Active' + '\'  and Master_Group_Id__c in :masterGrouppingIds AND (Partner_Type__c = ' + '\'' + 'Commercial Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Federal Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'OEM Distributor' + '\'' + ' or Partner_Type__c = ' + '\'' + 'Distributor (GCC)' + '\') AND Partner_Relationship__c LIKE ' + '\'%' + 'Storage' + '%\' order by name limit 1000';
                              String searchEmail = 'select id,name,Account_ID__c, Billingcity,Purchasing_Model__c, Billingstate, Billingcountry, NameLocal, Account_Country__c ,Master_Group_Id__c,Calculated_Status__c,Partner_Registration__c from Account where Sales_Motion_Deal_Registration__c = True and RecordTypeId = :recid AND Partner_Registration__c <> null and Calculated_Status__c = ' + '\'' + 'Active' + '\'  and Master_Group_Id__c in :masterGrouppingIds AND (Partner_Type__c IN: listdistributorPartnerTypes) AND Partner_Relationship__c LIKE ' + '\'%' + 'Storage' + '%\' order by name limit 1000';
                           
                            list < Account > accountList = new list < Account > ();
                            accList = Database.query(searchEmail);
                          /*  Set < Id > accIds = new Set < Id > ();
                            if (accountList.size() > 0) {
                                for (Account acc: accountList) {
                                    If(acc.Calculated_Status__c == 'Active') {
                                        accIds.add(acc.Master_Group_Id__c);
                                    }
                                }
                            }
                            String searchEmailMainQuery = 'select Email,contact.selected_track_account__c,contact.Master_Group_Id__c,ContactId from user where contact.Account.Master_Group_Id__c IN: accIds AND (Email LIKE ' + '\'%' + modifiedsearchString + '%\') AND IsActive = true AND Enable_Partner_Deal_Registration__c = true';
                            
                            List < User > users = new List < User > ();
                            users = Database.query(searchEmailMainQuery);
                            set < Id > accountIds = new set < Id > ();
                            for (User u: users) {
                                accountIds.add(u.contact.Account.Master_Group_Id__c);
                            }
                            accList = [Select Id, name, Account_ID__c, Billingcity,Purchasing_Model__c, Billingstate, Billingcountry, NameLocal, Account_Country__c from Account where Master_Group_Id__c IN: accountIds]; */
                        } else {
                            invalidInput = true;
                            showtable = false;
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Email_Domain_Error));
                        }
                    }
                    
                    //handle 1000 records VF error
                    if (accList.size() == 1000) {
                        showTable = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.DealReg_searchLimit));
                    } else if (accList.size() == 0 && invalidInput == false) {
                        showTable = false;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.no_records_found));
                    } else if (invalidInput == true) {
                        showTable = false;
                    } else {
                        showTable = true;
                    }
                } else {
                    showTable = false;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Keyword_search));
                }
            } else {
                showTable = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Deal_Reg_Distributor_Switch_Mandatory_Fields));
            }
        } catch (Exception ex) {
            system.debug('----catch 2---' + ex.getMessage());
        }
    }
    
    // Enable/Disable submit button based on record selection
    public void enableDisableButton(){
        selectedRecordId = System.currentPagereference().getParameters().get('selectedAccId');
        Account ac;
        if(selectedRecordId != null){ 
            ac = [select id,name from Account Where id =: selectedRecordId ];
            if(firstdistiid == null || changedisti1 || changedisti2){
                selectedname = ac.Name;
                firstdistiid = ac.id;
            }
            if(has2Distis){
                hidesavebutton = false;
            }else{
                hideSubmitButton = false;
            }   
            if(has2Distis && Opensecondsearch){             
                seconddistiid = ac.id;
                selectednamesecond = ac.Name;
            }
        }
    }
    
    ////Seconday Distributor for GC change
    public void savefirstacc(){
        Opensecondsearch = true;
        hidesavebutton = true;
        showTable = false;
        Searchby = '';
        if(!Openfirstsearch || !Opensecondsearch)
            Searchstring='';
    }
    public void savesecondacc(){
        Openfirstsearch = true;
        hidesavebutton = true;
        showTable = false;
        Searchby = '';      
        if(!Openfirstsearch || !Opensecondsearch)
            Searchstring='';
    }
    //------------------------------------------For changing Disti----------
    public void changefirstdisti()
    {
        Opensecondsearch = false; 
        openfirstsearch=true;
        firstdistiid=null;
        searchBy ='';
        searchstring='';
        if(seconddistiid == null)     
        {     
            Opensecondsearch = false;      
            openfirstsearch = false;       
        }
    }
    public void changeseconddisti()
    {
        opensecondsearch=true;
        openfirstsearch=false;
        //   seconddistiid = null;
        searchBy ='';
        searchstring='';
    }
    //--------------------------------------END------------------------
    // Below Method executes when user clikcs on submit button
    public pagereference submitFunction(){
        try{
            If(string.isNotBlank(searchString) && TnCaccept && string.isNotBlank(distiRelationShip.Distributor_Request_Reason__c) && string.isNotBlank(distiRelationShip.Existing_Distributor_Informed__c) && changedisti1){
                distiRecord[0].Requested_Distributor__c = firstdistiid ;
                distiRecord[0].Requested_Distributor_By__c = loggedInUser.name;
                distiRecord[0].Existing_Distributor_Informed__c = distiRelationShip.Existing_Distributor_Informed__c;
                distiRecord[0].Distributor_Request_Reason__c = distiRelationShip.Distributor_Request_Reason__c;
                distiRecord[0].Requested_Distributor_Date__c = system.now(); 
                distiRecord[0].Requested_Distributor_Status__c = 'Submitted';
                
                list<Database.SaveResult> srList= Database.Update(distiRecord);
                for (Database.SaveResult sr : srList) {  
                    if(sr.isSuccess()){                 
                        PageReference pageRef = new PageReference('/home/home.jsp');
                        pageRef.setRedirect(true);
                        return pageRef;               
                    }else{      
                        for(Database.Error err : sr.getErrors()) {                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Disti Relationship fields that affected this error: ' + err.getFields());
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,err.getMessage() )); 
                        }
                    }
                }
            }else if(string.isNotBlank(searchString) && TnCaccept && string.isNotBlank(distiRelationShip.Distributor_Request_Reason__c) && string.isNotBlank(distiRelationShip.Existing_Distributor_Informed__c) && changedisti2){
                distiRecord[0].Requested_Secondary_Distributor__c = firstdistiid ;
                distiRecord[0].Requested_Secondary_Distributor_By__c = loggedInUser.name;
                distiRecord[0].Existing_Secondary_Distributor_Informed__c = distiRelationShip.Existing_Distributor_Informed__c;
                distiRecord[0].Secondary_Distributor_Request_Reason__c = distiRelationShip.Distributor_Request_Reason__c;
                distiRecord[0].Requested_Secondary_Distributor_Date__c = system.now(); 
                distiRecord[0].Requested_Secondary_Distributor_Status__c = 'Submitted';
                
                list<Database.SaveResult> srList= Database.Update(distiRecord);
                for (Database.SaveResult sr : srList) {  
                    if(sr.isSuccess()){                 
                        PageReference pageRef = new PageReference('/home/home.jsp');
                        pageRef.setRedirect(true);
                        return pageRef;               
                    }else{      
                        for(Database.Error err : sr.getErrors()) {                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Disti Relationship fields that affected this error: ' + err.getFields());
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,err.getMessage() )); 
                        }
                    }
                }
            }else If(string.isNotBlank(searchString) && TnCaccept && DistributorSetupRequestForm){      
                //      distiRecord = [select id,Disti_Account__c,Disti_Account_Name__c,Requested_Distributor__r.name,Requested_Distributor_Date__c,Requested_Distributor_By__c,Requested_Distributor_Status__c from Disti_Relationship__c where Reseller_Account__c = :loggedInUser.Contact.accountid limit 1];
                if(distiRecord.size() > 0)
                {
                    distiRecord[0].Requested_Distributor__c = firstdistiid;
                    distiRecord[0].Requested_Distributor_Status__c = 'Submitted';
                    distiRecord[0].Requested_Distributor_Date__c = system.now(); 
                    distiRecord[0].Requested_Distributor_By__c = loggedInUser.name;
                    //Seconday Distributor for GC 
                    if(has2Distis)
                    {
                        distiRecord[0].Requested_Secondary_Distributor__c = seconddistiid  ;
                        distiRecord[0].Requested_Secondary_Distributor_By__c = loggedInUser.name;
                        distiRecord[0].Requested_Secondary_Distributor_Date__c = system.now(); 
                        distiRecord[0].Requested_Secondary_Distributor_Status__c = 'Submitted';                                      
                    }           
                    
                    list<Database.SaveResult> srList= Database.Update(distiRecord);
                    for (Database.SaveResult sr : srList) {  
                        if(sr.isSuccess()){ 
                            sendnotification(distiRecord[0]);
                            Id oppId ;
                            if (ApexPages.currentPage().getParameters().containsKey('Id'))
                                oppId = ApexPages.currentPage().getParameters().get('Id');
                            
                            PageReference pageRef = new PageReference('javascript:window.close();');
                            pageRef.setRedirect(true);
                            
                            return pageRef;
                            //      return new PageReference('javascript:window.close();');                   
                        }else{      
                            for(Database.Error err : sr.getErrors()) {                   
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Disti Relationship fields that affected this error: ' + err.getFields());
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,err.getMessage() )); 
                            }
                        }
                    }
                }else{
                    //insert distiRecord;
                    List<Disti_Relationship__c> newListdisti = new list<Disti_Relationship__c>();
                    Disti_Relationship__c newdisti = new Disti_Relationship__c();
                    //*****4.0 Start*****//
                    if(loggedInUser.contact.Selected_Track_Account__c != null){
                        newdisti.Reseller_Account__c = loggedInUser.contact.Selected_Track_Account__c;                    
                    }else{
                        newdisti.Reseller_Account__c = loggedInUser.contact.accountid;
                    }
                    //*****4.0 End*****//
                    newdisti.Requested_Distributor__c = firstdistiid;
                    newdisti.Requested_Distributor_Status__c = 'Submitted';
                    newdisti.Requested_Distributor_By__c = loggedInUser.name;
                    newdisti.Requested_Distributor_Date__c = system.now();
                    
                    //Seconday Distributor for GC 
                    if(has2Distis)
                    {
                        newdisti.Requested_Secondary_Distributor__c = seconddistiid  ;
                        newdisti.Requested_Secondary_Distributor_By__c = loggedInUser.name;
                        newdisti.Requested_Secondary_Distributor_Date__c = system.now(); 
                        newdisti.Requested_Secondary_Distributor_Status__c = 'Submitted';                                      
                    }
                    newListdisti.add(newdisti);
                    
                    list<Database.SaveResult> srList= Database.insert(newListdisti);
                    for (Database.SaveResult sr : srList) {  
                        if(sr.isSuccess()){ 
                            sendnotification(newListdisti[0]);
                            /*PageReference pageRef = new PageReference('/home/home.jsp');
pageRef.setRedirect(true);
return pageRef;   */
                            Id oppId ;
                            if (ApexPages.currentPage().getParameters().containsKey('Id'))
                                oppId = ApexPages.currentPage().getParameters().get('Id');
                            
                            PageReference pageRef = new PageReference('javascript:window.close();');      
                            pageRef.setRedirect(true);
                            return pageRef;   
                            // return new PageReference('javascript:window.close();');         
                        }else{      
                            for(Database.Error err : sr.getErrors()) {                   
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Disti Relationship fields that affected this error: ' + err.getFields());
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,err.getMessage() )); 
                            }
                        }
                    }     
                }
            }else{
                showTable = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Deal_Reg_Distributor_Switch_Mandatory_Fields));      
            }
        } catch (Exception ex) {
            system.debug('----catch 3---' + ex.getMessage());
        }
        return null;
    }
    
    // Below method executes when user clicks on submit or cancel button which navigates them to home page
    public pagereference cancel(){
        // redirect user to deal registration when clicks on ok button from submit request form.
        if(DistributorSetupRequestForm){
            Id oppId ;
            if (ApexPages.currentPage().getParameters().containsKey('Id'))
                oppId = ApexPages.currentPage().getParameters().get('Id');
            
            PageReference pageRef = new PageReference('/' + oppId);      
            pageRef.setRedirect(true);
            return pageRef;  
        }
        else{
            //redirect user to home page when clicked ok on switch request form.
            PageReference pageRef = new PageReference('/home/home.jsp');
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    
    //Mail sending to onboarding team 
    public void sendnotification(Disti_Relationship__c disti ){
        //if(!Test.isRunningTest())
        try{
            List <Contact> con =  [select id from contact limit 1];
            Id oppId ;
            if (ApexPages.currentPage().getParameters().containsKey('Id'))
                oppId = ApexPages.currentPage().getParameters().get('Id');
            
            List<Opportunity> opp = [select id,Partner_Account_Country_Code__c from Opportunity where Id =: oppId limit 1];
            
            if(opp != null && opp.size() > 0 && opp[0].Partner_Account_Country_Code__c != null)   
            {            
                
                List<Country__c> cun =  [SELECT Region__c FROM Country__c WHERE (Dell_Online_Country_Code__c =: opp[0].Partner_Account_Country_Code__c)];
                
                List <String> toAddresses = new List <String>();
                List < String > Onboardingteam = new List < String >();
                if(cun[0].Region__c == 'EMEA' || cun[0].Region__c == 'EC-EMEA'){
                    Onboardingteam = new List < String > (system.label.Dealreg_EMEA_Partner_onboarding.split(','));
                }
                if(cun[0].Region__c == 'APJ'){
                    Onboardingteam = new List < String > (system.label.Dealreg_APJ_Partner_onboarding.split(','));
                }
                if(cun[0].Region__c == 'LATAM'){
                    Onboardingteam = new List < String > (system.label.Dealreg_LATAM_Partner_onboarding.split(','));
                }
                if(cun[0].Region__c == 'NA'){
                    Onboardingteam = new List < String > (system.label.Dealreg_NA_Partner_onboarding.split(','));
                }
                List<Messaging.SingleEmailMessage> mails = new List <Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Emailtemplate templateid = [select id from Emailtemplate Where name =: 'DealReg Email Notification to Onboarding team'];
                mail.setTemplateid(templateid.id);
                mail.setWhatId(disti.id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setTargetObjectid(con[0].id);
                mail.setSaveAsActivity(false);
                
                for(string st: Onboardingteam ){
                    toAddresses.add(st); 
                }
                mail.setToAddresses(toAddresses);
                mails.add(mail);
                if (!mails.isEmpty()){
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(mails);
                }
            } 
        }catch(exception ex){
            system.debug('----catch 4---' + ex.getMessage());
        }
    }
}