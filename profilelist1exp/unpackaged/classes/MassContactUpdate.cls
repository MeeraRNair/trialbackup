/* 
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
2.0         CR 13173    FY17-DCS-0801   12-Jul-2016     Fenny           To excempt user (profiles) from contact exclusion list checking
3.0         CR 14436    FY18-DCS-0702   07-June-2017    Yamini          To remove 'INTERNAL - Crisis Mgmt' from Status Pick list LOV 
4.0         CR 15099    FY18-DCS-0102   08-Nov-2017     Sazleen         Renaming existing Channel Sales profile as Channel Lead Operations
5.0         CR 15568    FY19-DCS-0502   20-Mar-2018     Sakshi          Reduce Code
*/
public class MassContactUpdate{
    
    private ApexPages.StandardSetController standardController;
    private System_Behavior_Bypasser__c vrBypass = System_Behavior_Bypasser__c.getInstance(UserInfo.getProfileId()); // 2.0
    
    public Integer totalPages { get; set; }
    public boolean HasPermissionToView {get; set;}
    public boolean ShowBackButton {get; set;}
    public List<Contact> arryContact{get;set;}
    public List<Contact> arryContact1 {get;set;}
    public boolean showHide {get;set;}
    public boolean showPagination {get;set;}
    public boolean showReadOnly {get;set;}
    public boolean ckStatus {get;set;}
    public boolean noError {get; set;}    
    public boolean changePopup {get;set;} 
    public boolean pageFirst {get;set;}
    public boolean gblError {get;set;} 
    public list<Contact> lstContact;
    public Map<Id,Contact> mapVerifyOldCases;
    Contact[] lstContact1;
    public Map<Id,Contact> mapVerifyOldCases1;    
    public Map<ID,Boolean> mapAccess{get;set;}
    public map<string, Contact_Exclusion__c> mapEmail = new map<string, Contact_Exclusion__c>();
    public map<string, Contact_Exclusion__c> mapPhone = new map<string, Contact_Exclusion__c>();
    public map<string, Contact_Exclusion__c> mapMobile = new map<string, Contact_Exclusion__c>();
    public map<string, Contact_Exclusion__c> mapfName = new map<string, Contact_Exclusion__c>();
    public map<string, Contact_Exclusion__c> maplName = new map<string, Contact_Exclusion__c>();
    public boolean fNameExclusion{get; set;}    
    
    public MassContactUpdate(ApexPages.StandardSetController standardController){ 
        mapVerifyOldCases = new Map<Id,Contact>();
        mapVerifyOldCases1 = new Map<Id,Contact>();
        Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        showReadOnly = false;
        ckStatus = false;
        pageFirst = true;
        if(profileName.contains('Read Only'))
            showReadOnly = true;
        
        if(profileName.contains('Sales') || profileName.contains('KACE ASR') || profileName.contains('Services Rep') || profileName.contains('Services Mgr') || profileName.contains('MSG Service') || profileName.contains('ModelN') || profileName.contains('GBL PRM') || profileName.contains('GBL Data/User/Report Admin') || profileName.contains('Portal User') || profileName.contains('Data Load') || profileName.contains('PSM') || profileName.contains('Satmetrix-SFDC') || profileName.contains('GBL Admin Marketing User - Non SSO') || profileName.contains('Integration') || profileName.contains('GBL Marketing/Data Admin Profile'))
            ckStatus = true;
        
        try{            
            if(profileName.contains('System Administrator') || profileName.contains('IT ') || profileName.contains('Marketing User') || profileName.contains('GBL Lead Assignment Users') || profileName.contains('GBL Channel Marketing') || profileName.contains('GBL EMEA Sales') || profileName.contains('GBL Sales') || profileName.contains('JPN Sales') || profileName.contains('GBL KACE') || profileName.contains('GBL Channel Lead Operations') || profileName.contains('GBL Marketing') || profileName.contains('GBL Dell Services') || profileName.contains('MSG Service')){
                HasPermissionToView = true;
                ShowBackButton = false;
                showPagination = false;
                    
                Decimal dtotalPages;
                Integer iRecordsPerPage = 25;
                List<Contact> hasChanges = standardController.getRecords();
                noError = false;
                changePopup = true;
                    
                this.standardController = standardController;
                standardController.setPageSize(iRecordsPerPage);
                arryContact = new List<Contact>();
                arryContact = standardController.getRecords();
                    
                lstContact = standardController.getRecords().deepClone(true, true, true);
                //Iterate over the list and collect it in map
                for(Contact con:lstContact)
                    mapVerifyOldCases.put(con.Id,con);
                
                //Code Modified by shivam
                mapAccess = new Map<ID,Boolean>();         
                for(UserRecordAccess con:[SELECT HasEditAccess,MaxAccessLevel,RecordId FROM UserRecordAccess Where UserId=:userInfo.getUserId() and RecordId IN:mapVerifyOldCases.keyset() limit 25]){
                    mapAccess.put(con.RecordId, con.HasEditAccess);
                } 
                //Code Ends Here  
                // For Contact Exclusion
                list<Contact_Exclusion__c> ce = new list<Contact_Exclusion__c>();
                ce = [SELECT Id, Email__c, First_Name__c, Last_Name__c, Phone__c FROM Contact_Exclusion__c Where Active__c = true]; 
                // Contact Exclusion: Email and Contact Exclusion: Phone and Contact Exclusion: FName and Contact Exclusion: LName
                for (Contact_Exclusion__c cel : ce){
                   mapEmail.put(cel.Email__c, cel);
                   mapPhone.put(cel.Phone__c, cel);
                   mapfName.put(cel.First_Name__c, cel);
                   maplName.put(cel.Last_Name__c, cel);
                }
                            
                showHide = false;
                dtotalPages = (standardController.getResultSize() / standardController.getPageSize());
                dtotalPages = Math.floor(dtotalPages) + ((Math.mod(standardController.getResultSize(), iRecordsPerPage)>0) ? 1 : 0);
                totalPages = Integer.valueOf(dtotalPages);
                    
                if(standardController.getResultSize() > iRecordsPerPage)
                    showPagination = true;                         
            }
            else{
                HasPermissionToView = false;
                ShowBackButton = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You don\'t have permission to access this functionality.'));
            }
      
            if(standardController.getResultSize() == 0 && HasPermissionToView == true){
                HasPermissionToView = false;
                ShowBackButton = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No records to display.'));                
            }
        }
        catch (Exception e){
            system.debug(e);
        }            
    }
        
    public void saveAndReturn(){
        try{
            boolean ckEmailPhone, ckStatusCheck, emailExclusion, phoneExclusion, mobileExclusion, lNameExclusion, AcNameMandatory, DecisionMakingNull = false;
            fNameExclusion = changePopup = gblError = false;
            pageFirst = true;

            lstContact1 = standardController.getRecords().deepClone(true, true, true);
            for(Contact con:lstContact1)
                mapVerifyOldCases1.put(con.Id,con);
                
            for(UserRecordAccess con:[SELECT HasEditAccess,MaxAccessLevel,RecordId FROM UserRecordAccess Where UserId=:userInfo.getUserId() and RecordId IN:mapVerifyOldCases1.keyset() limit 25]){
              if(!mapAccess.containsKey(con.RecordId))
                 mapAccess.put(con.RecordId ,con.HasEditAccess);
            }

            arryContact1 = new List<Contact>();
            arryContact1 = standardController.getRecords();           
                        
            if(arryContact1 != null){
                for(Contact con : arryContact1){
                        if(con.Email == null && con.Phone == null && con.MobilePhone == null && mapAccess.get(con.Id) == true){
                            ckEmailPhone = true;
                            con.email.addError('In order to save a contact you need to enter data into one of the following fields: Phone, Email, Fax or Mobile.');
                            addmsg(true, 'In order to save a contact you need to enter data into one of the following fields: Phone, Email, Fax or Mobile.');
                        }
                        
                        if(mapVerifyOldCases1.get(con.Id).Status__c == 'Customer' && con.Status__c != 'Customer' && ckStatus == false){
                            ckStatusCheck = true;
                            con.Status__c.addError('Only Sales users can create or update contact records when Status is set to \'Customer\'.');
                            addmsg(true, 'Only Sales users can create or update contact records when Status is set to \'Customer\'.');
                        }                      

                        // 2.0: To excempt users (profiles) from Contact Exclusion check
                        if(!vrBypass.Bypass_Contact_VRs__c){
                        
                            if(con.FirstName != null && (mapfName.containsKey(con.FirstName) || mapfName.containsKey(con.FirstName.toLowerCase()) || mapfName.containsKey(con.FirstName.toUpperCase())) && mapAccess.get(con.Id) == true){
                                fNameExclusion = true;
                                con.FirstName.addError('Invalid First Name. First Name entered is listed in the exclusion list.');
                                addmsg(true, 'Invalid First Name. First Name entered is listed in the exclusion list.');
                            }
        
                            if(con.LastName != null && (maplName.containsKey(con.LastName) || maplName.containsKey(con.LastName.toLowerCase()) || maplName.containsKey(con.LastName.toUpperCase())) && mapAccess.get(con.Id) == true){
                                lNameExclusion = true;
                                con.LastName.addError('Invalid Last Name. Last Name entered is listed in the exclusion list.');
                                addmsg(true, 'Invalid Last Name. Last Name entered is listed in the exclusion list.');
                            }
                                               
                            if (con.Email != null && (mapEmail.containsKey(con.Email) || mapEmail.containsKey(con.Email.toLowerCase()) || mapEmail.containsKey(con.Email.toUpperCase())) && mapAccess.get(con.Id) == true){
                                emailExclusion = true;
                                con.email.addError('Invalid Email. Email entered is listed in the exclusion list.');
                                addmsg(true, 'Invalid Email. Email entered is listed in the exclusion list.');
                            }
    
                            if (con.Phone != null && (mapPhone.containsKey(con.Phone) || mapPhone.containsKey(con.Phone.toLowerCase()) || mapPhone.containsKey(con.Phone.toUpperCase())) && mapAccess.get(con.Id) == true){
                                phoneExclusion = true;
                                con.phone.addError('Invalid Phone Number. The Number entered is listed in the exclusion list.');
                                addmsg(true,'Invalid Phone Number. The Number entered is listed in the exclusion list.');
                            }
        
                            if (con.MobilePhone != null && (mapPhone.containsKey(con.MobilePhone) || mapPhone.containsKey(con.MobilePhone.toLowerCase()) || mapPhone.containsKey(con.MobilePhone.toUpperCase())) && mapAccess.get(con.Id) == true){
                                mobileExclusion = true;
                                con.MobilePhone.addError('Invalid Mobile Number. The Number entered is listed in the exclusion list.');
                                addmsg(true,'Invalid Mobile Number. The Number entered is listed in the exclusion list.');
                            }
                        }
    
                        if (con.Decision_Making_Role__c == null && mapAccess.get(con.Id) == true){
                            DecisionMakingNull = true;
                            con.Decision_Making_Role__c.addError('You must enter a value');
                            addmsg(true,'You must enter a value');
                        }                        

                        if (con.Account.Name == null && mapAccess.get(con.Id) == true){
                            AcNameMandatory = true;
                            con.Account.Name.addError('Account Name is mandatory to create contact records');
                            addmsg(true,'Account Name is mandatory to create contact records');
                        }                        
                }
            }
            
            if(ckEmailPhone == true || ckStatusCheck == true || fNameExclusion == true || lNameExclusion == true || emailExclusion == true || phoneExclusion == true || mobileExclusion == true || DecisionMakingNull == true || AcNameMandatory == true)
                gblError = true;
            if(gblError == false){
                standardController.save();            
                standardController.setPageNumber(standardController.getPageNumber());
                    
                List<Apexpages.Message> msgs = ApexPages.getMessages();                
                for(Apexpages.Message msg:msgs){
                    if ((!(msg.getDetail().contains('Phone Number'))) && (!(msg.getDetail().contains('Only Sales users'))) && (!(msg.getDetail().contains('Invalid Email'))) && (!(msg.getDetail().contains('exclusion list'))) && (!(msg.getDetail().contains('You must enter a value'))) && (!(msg.getDetail().contains('You do not have the level of access necessary'))) && (!(msg.getDetail().contains('one of the following fields')))){
                        noError = true;
                    }
                }              
                        
                if((noError == true || msgs.size() == 0)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'All modified records on this page have been updated successfully.  To return to your previous View, click Cancel, or to continue with Mass Updates, choose another page of records.'));
                }                
                changePopup = true;
                gblError = false;
            }
        }
        catch(Exception e){
            system.debug('Save Error: ' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, + e.getMessage()));
        }
    }
    
    public void saveAndReturnSuccessMsg(){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Records updated successfully.'));
    }
    
    public void NextPage() {
        try{
            pageFirst = true;       
            standardController.next();
            collectContactId(); 
            showHide = false;       
        }
        catch(Exception e){
            system.debug(e);
        }
    }    
    
    public void SaveAndNextPage() { 
        try{
            pageFirst = true;  
            integer PageNum;
            PageNum = standardController.getPageNumber();
            saveAndReturn();
            if(changePopup == true){
                standardController.setPageNumber(PageNum);
                pageFirst = false;
                standardController.next();
            }              
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }    
    
    public void CancelAndNextPage() {
        try{
            pageFirst = true;
            standardController.cancel();
            standardController.next();
            collectContactId();        
        }
        catch(Exception e){
            system.debug(e);
        }
    }
    
    public void PreviousPage() {
        try{
            pageFirst = true;        
            standardController.previous();
            collectContactId();
            showHide = false;
        }
        catch(Exception e){
            system.debug(e);
        }
    }    
    
    public void SaveAndPreviousPage() {
        try{
            pageFirst = true; 
            integer PageNum;
            PageNum = standardController.getPageNumber();     
            saveAndReturn();
            if(changePopup == true){
                standardController.setPageNumber(PageNum);
                pageFirst = false; 
                standardController.previous();               
            }              
            
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }    
    
    public void CancelAndPreviousPage() {
        try{
            pageFirst = true;
            standardController.cancel();
            standardController.previous();  
            collectContactId();         
        }
        catch(Exception e){
            system.debug(e);
        }
    }
  
    public void FirstPage() {
        try{
            pageFirst = true;        
            standardController.first();
            collectContactId();
            showHide = false;        
        }
        catch(Exception e){
            system.debug(e);
        }
    }    
    
    public void SaveAndLastPage() {        
        try{
            pageFirst = true;
            integer PageNum;
            PageNum = getTotalPages();    
            saveAndReturn();
            if(changePopup == true){
                standardController.setPageNumber(PageNum);
                pageFirst = false;
                standardController.last();              
            }                
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }    
    
    public void CancelAndLastPage() {
        try{
            pageFirst = true;
            standardController.cancel();
            standardController.last(); 
            collectContactId();         
        }
        catch(Exception e){
            system.debug(e);
        }
    }
    
    public void LastPage(){  
        try{
            standardController.last();
            pageFirst = true;   
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }    
    
    public void SaveAndFirstPage() {
        try{
            pageFirst = true;    
            integer PageNum;
            PageNum = standardController.getPageNumber();  
            saveAndReturn();
            if(changePopup == true){
                standardController.setPageNumber(1);
                pageFirst = false;                
            }                
            collectContactId();   
        }
        catch(Exception e){
            system.debug(e);
        }
    }    
    
    public void CancelAndFirstPage() {
        try{
            pageFirst = true;
            standardController.cancel();
            standardController.first(); 
            collectContactId();        
        }
        catch(Exception e){
            system.debug(e);
        }
    }

    public Integer PageNumber1 {
        get {
            if(getPageNumber() <= 2) {
                return 1;
            }
            else if(getPageNumber() == getTotalPages()) {
                return getPageNumber() - 2;
            }
            else {
                return getPageNumber() - 1;
            }            
        }
        set;        
    }

    public Integer PageNumber2 {
        get {        
            if(getPageNumber() == 1) {
                return 2;
            }
            else if(getPageNumber() == getTotalPages() && getTotalPages() != 2) {
                return getTotalPages() - 1;
            }
            else {
                return getPageNumber();
            }            
        }
        set;
    }

    public Integer PageNumber3 {
        get {        
            if(getPageNumber() == 1) {
                return 3;
            }
            else if(getPageNumber() == getTotalPages()) {
                return getTotalPages();
            }
            else {
                return getPageNumber() + 1;
            }            
        }
        set;
    }
    

    public void Page1() {
        try{
            standardController.setPageNumber(PageNumber1);
        }
        catch(Exception e){
            system.debug(e);
        }
    }

    public void SaveAndPage1() {
        try{                    
            pageFirst = true;        
            saveAndReturn();
            if(changePopup == true){
                Page1();
                pageFirst = false;                
            }
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }

    public void CancelAndPage1() {
        try{
            standardController.cancel();
            Page1();
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }

    public void Page2() {
        try{
            standardController.setPageNumber(PageNumber2);
        }
        catch(Exception e){
            system.debug(e);
        }
    }

    public void SaveAndPage2() {
        try{
            pageFirst = true;
            saveAndReturn();
            if(changePopup == true){
                Page2();
                pageFirst = false;                
            }
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }

    public void CancelAndPage2() {
        try{
            standardController.cancel();
            Page2();
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }

    public void Page3() {
        try{
            standardController.setPageNumber(PageNumber3);
        }
        catch(Exception e){
            system.debug(e);
        }   
    }

    public void SaveAndPage3() {
        try{
            pageFirst = true;
            saveAndReturn();
            if(changePopup == true){
                Page3();
                pageFirst = false;                
            }
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }

    public void CancelAndPage3() {
        try{
            standardController.cancel();
            Page3();
            collectContactId();
        }
        catch(Exception e){
            system.debug(e);
        }
    }

    public PageReference GoBack() {
        standardController.cancel();
        PageReference newPage;
        newPage = new PageReference('/003?fcf=' + standardController.getFilterId().substring(0, 15));
        return newPage.setRedirect(true);
    }    
    
    public PageReference DiscardAndStay() {
        PageReference homePg = new PageReference('/apex/MassContactUpdate?fcf=' + standardController.getFilterId().substring(0, 15));
        return homePg;
    }

    public List<SelectOption> getListStatus() {     
        List<SelectOption> listStatus = new List<SelectOption>();
        listStatus.add(new SelectOption('Customer', 'Customer'));
        listStatus.add(new SelectOption('Prospect', 'Prospect'));
        listStatus.add(new SelectOption('Marketing Suspect', 'Marketing Suspect'));
        listStatus.add(new SelectOption('Invalid - Bad Email', 'Invalid - Bad Email'));
        listStatus.add(new SelectOption('Invalid - Bad Phone', 'Invalid - Bad Phone'));
        listStatus.add(new SelectOption('Invalid - No Longer w/ Company', 'Invalid - No Longer w/ Company'));
        listStatus.add(new SelectOption('Invalid - Unmarketable', 'Invalid - Unmarketable'));
        return listStatus;
    }  

    Public Integer getTotalPages(){ 
        Decimal totalSize = this.standardController.getResultSize();
        Decimal pageSize = this.standardController.getPageSize(); 
        Decimal pages = totalSize/pageSize; 
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }      

    public Integer getPageNumber(){ 
        return this.standardController.getPageNumber();
    }

    public Integer getPageSize(){ 
        return this.standardController.getPageSize(); 
    }

    public Integer getTotalRecords(){ 
        return this.standardController.getResultSize(); 
    }

    public Integer getStartPageRecords(){
        integer StartPageRecords;
        StartPageRecords = (this.standardController.getPageNumber() * this.standardController.getPageSize()) + 1;
        if(this.standardController.getPageNumber() == 1){
            StartPageRecords = 1;
        }
        else{
            StartPageRecords = ((this.standardController.getPageNumber() * this.standardController.getPageSize()) - (this.standardController.getPageSize())) + 1;
        }                            
        return StartPageRecords; 
    }

    public Integer getEndPageRecords(){
        integer EndPageRecords;
        EndPageRecords = this.standardController.getPageNumber() * this.standardController.getPageSize();  
        if(this.standardController.getResultSize() < EndPageRecords){
            EndPageRecords = this.standardController.getResultSize();
        }     
        return EndPageRecords; 
    }
    
    private void collectContactId(){
        Set<Id> setId = new Set<Id>();
        List<Contact> lstTemp = standardController.getRecords();
        for(Contact con:lstTemp)
            setId.add(con.Id);
            
        for(UserRecordAccess con:[SELECT HasEditAccess,MaxAccessLevel,RecordId FROM UserRecordAccess Where UserId=:userInfo.getUserId() and RecordId IN:setId limit 25]){
          if(!mapAccess.containsKey(con.RecordId))
             mapAccess.put(con.RecordId ,con.HasEditAccess);
        }
    }
    
    private void addmsg(Boolean isgblError, String strMsg){
        gblError = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strMsg)); 
    }
}