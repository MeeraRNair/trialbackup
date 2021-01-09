/*
* Author   : Ragu
* Purpose  : This is the controller for the leadConvertCoreComponent.
* 
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      11609       16.07           15-Dec-2014     Ragu            Installed "Convert Lead - Custom Lead Conversion Process" app from AppExchange.
* 1.1      11609       16.07           18-Dec-2014     Ragu            Customization to attach Lead to the existing Account and Contact when converting it.
* 1.2      11609       16.07           19-Dec-2014     Ragu            Updated code to use opportunityName instead of Opportunity object.
* 1.3      TFS: 176170 16.07           23-Jun-2015     Ragu            Updated code to use Account__c along with Contact__c for auto populating Account Name field.
* 1.4      12006       16.10           30-Sep-2015     Syidah          Remove "Channel Qualified Lead" Lead Status 
* 1.5      12379       16.12           26-Nov-2015     Nagendra        LM2_1_81-Enhance lead conversion process for matching contacts in existing account
* 1.6      12449       16.12           07-Dec-2015     Nagendra        LM2_15_1-Enhance lead conversion based on user
* 1.7      TFS 220169  16.12           07-Jan-2016     Nagendra        LM2_15_1 - For service sales users, the Converted Status is "Marketing Qualified Lead" instead of "Sales Qualified Lead"
* 2.0      13053       FY17-DCS-0502   19-Apr-2016     Sui Yee         LM2_17- Status MQL can only be selected by marketing profiles in lead page and convert page
* 3.0      13232       FY17-DCS-0801   13-Jun-2016     Sui Yee         LM2_15-Existing opportunity - Lead conversion page lay out changes
* 3.1      13216       FY17-DCS-0801   14-Jun-2016     Azwanti         LM2_15-Existing opportunity - Search & Select opportunity
* 3.2      13282       FY17-DCS-0801   23-Jun-2016     Gan             Populate fields needed for lead conversion
* 3.3      13232       FY17-DCS-0801   23-Jun-2016     Gan             Book Date Changes and query only oppty that are not passed book date
* 4.0      13806       FY18-DCS-0202   23-Dec-2016     Gan             To enable creation of SubAccount
* 5.0      13991       FY18-DCS-0302   07-Feb-2016     Sajith          LM2_Optimization in lead conversion process - Contact validations
* 6.0      14137       FY18-DCS-0403   03-Apr-2017     Sajith          Fix SOQL 101 Error to remove duplicate contact validation on lead conversion with Existing contact
* 7.0      14098       FY18-DCS-0502   27-Mar-2017     Ashok           LM2_Existing Partner Opportunity 
* 8.0      14143       FY18-DCS-0602   05-Apr-2017     Sajith          LM2_15-Bypass contact validation rules in conversion for existing contact
* 8.1      14336       FY18-DCS-0602   09-May-2017     Ashok           Global TAM - Remove "Do not create opportunity" for Sales profiles and keep the option for marketing profiles
* 9.0      14559       FY18-DCS-0702   28-Jun-2017     Sajith          INC3518054: To Fix prod INC Unable to create new contact during lead conversion if existing contacts are offered
* 10.0     14566       FY18-DCS-0802   11-Jul-2017     Sajith          Existing Partner opportunity - New Grid for Partner Account
* 11.0     15180       FY19-DCS-0202   28-Dec-2017     Sajith          Updated converted statuses during lead conversion
* 12.0     Def#4749315 FY19-DCS-0301   02-Mar-2018     Sajith          Updated 'Converted to Opportunity' to 'Converted to New Opportunity' 
* 13.0     18097       FY20-DCS-1101   17-Sep-2019     Anuj            LD008 - Change Lead Conversion logic for  Marketing Profiles   
*/ 

public without sharing class leadConvertCoreComponentController extends ComponentControllerBase {
    
    // Prefix for the label of existing accounts
    private final String EXISTING = 'Attach to existing: ';
    //4.0
    private final String STRSUBACCOUNT = 'Create New SubAccount: ';    
    // Checkbox on the component indicating if there will be an email sent to the owner 
    public boolean sendOwnerEmail {get; set;}
    
    // This will hold the Opportunity for the Opportunity name on the component 
    public Opportunity opportunityID {get; set;}
    // v1.2 : Updated code to use opportunityName instead of Opportunity object.
    public String opportunityName {get; set;}
    //3.2
    public String strOpportunityId {get; private set;}
    public Integer intOpptyDaysCreated {get; private set;}
    
    // Checkbox on the component indicating if an Opportunity should be created
    public Boolean doNotCreateOppty {get; set;}
    
    // This will hold the owner of Lead
    public Contact contactID {
        get {
            if(contactId == null) {
                contactID = new Contact(OwnerId = leadConvert.ownerId);
            }
            return contactId;
        }
        set;
    }
    
    // This is set by the <apex:attribute> and is the lead to convert
    public Lead leadConvert {
        get; 
        set {
            // The first time this is set, the select list of Accounts will be populated 
            if(accounts == null) {
                System.debug('leadConvert set to ' + value);
                
                leadConvert = value;
                
                // Populate the Account dropdown based on the lead
                populateAccounts(); 
                populateContactsAndOpptyAction();               
            }
             leadConvert.Status=LeadStatusOption;
        }
    }
    
    // The list of accounts in the select list
    public list<SelectOption> accounts {get; set;}
    
    // The list of contacts in the select list
    public list<SelectOption> Contacts {get; set;}
    
    //v3.0 The list of oppty action
    public list<SelectOption> listOpptyActionOptions {get; set;}
    
    // v3.0 The list of contacts in the select list
    public string Oppty {get; set;}
    
    // The selected account in the select list of accounts
    public String selectedAccount {get; set;}
    
    // The selected contact in the select list of contacts
    public String selectedContact {get; set;}
    
    // Logged in user is sales user
    public Boolean salesLoginUser {get; set;}
    
    //v7.0
    public Boolean bShowPartnerOpptySection{get;set;}
    
    // Logged in user is channel user - v7.0
    public Boolean channelLoginUser {
        get{
            User currentUser = [SELECT id,Name,Title,ProfileId,Profile.Name from User where  Id = :UserInfo.getUserId()]; 
            string uTitle= (currentUser.Title!=null)?currentUser.Title.toUpperCase():'';
            string profileName = currentUser.Profile.Name;
            
            List<string> channelProfiles = system.label.Channel_Profiles.split(';');
            List<string> ChannelUserTitileProfiles = system.label.Allow_Channel_Profiles.split(';');
            set<String> channel_Profiles = new set<string>();
            channel_Profiles.addAll(channelProfiles);
            set<String> channel_User_Title_Profiles = new set<string>();
            channel_User_Title_Profiles.addAll(ChannelUserTitileProfiles);
            system.debug(logginglevel.INFO,'### Channel Profiles :' + channel_Profiles);
            system.debug(logginglevel.INFO,'### Current user Profile Name :' + profileName);
            system.debug(logginglevel.INFO,'### Current user title :' + uTitle);
            if(channel_Profiles.contains(profileName)){
                system.debug('-----------Channel Profile -----------------');
                channelLoginUser = TRUE;
                return channelLoginUser;
            }else if(channel_User_Title_Profiles.contains(profileName)){
                system.debug('-----------Channel USER TITLE-----------------');
                
                if(uTitle.contains('CHANNEL')){
                    channelLoginUser = TRUE;
                    return channelLoginUser;
                }
                else{
                    channelLoginUser = FALSE;
                    return channelLoginUser;
                }
            }else{
                channelLoginUser = FALSE;
            }
            
            return channelLoginUser;
        }set;
    }
    //V8.1
    public Boolean MarketingProfileUser {
        get{
            User currentUser1 = StaticFactory.getCurrentUserDetails(); 
            string pname = currentUser1.Profile.Name.toUpperCase();
            List<string> MarketingProfiles = system.label.Marketing_Profile_Access_to_donotcreateOppty.toUpperCase().split(';');
            set<String> Marketing_Profiles = new set<string>();
            Marketing_Profiles.addAll(MarketingProfiles);
            
            if(Marketing_Profiles.contains(pname)){
                MarketingProfileUser = TRUE;
                return MarketingProfileUser;
            }else MarketingProfileUser = FALSE;
            
            return MarketingProfileUser;
            
        }set;
    }
    //V8.1 End
    
    
    //v3.1
    private List<Opportunity> listOpp;
    public List<existingOppWrapper> listExistingOpp {
        get{            
            List<existingOppWrapper> listExistOppWrap = new List<existingOppWrapper>(); 
            //4.0
            if(selectedAccount!=null && selectedAccount !='NONE' && selectedAccount !='NEW' 
               && !selectedAccount.startsWith('SUB-')){      
                   for(Opportunity opp : getListOpp())
                   { 
                       Integer days = opp.CreatedDate.dateGMT().daysBetween(system.now().dateGMT());   // count the Number of Days Since Opportunity is Created  
                       //system.debug('-=============================='+opp.RecordType.Name+' '+bshowPartnerOpptySection+'----- '+channelLoginUser);
                       //v7.0
                       listExistOppWrap.add(new existingOppWrapper(opp, days));            
                   }
               }
            listExistingOpp = listExistOppWrap;
            return listExistingOpp;
        }set;
    }
    
    
    public Integer noOfRecords{get; set;}
    public Integer size{get;set;}
    public Integer numOfDaysSinceCreated{get; set;} 
    
    private static final Integer PAGE_SIZE=20;
    public integer currentPage {get; private set;}
    public integer lastPage {get; private set;}
    public Boolean bHasPreviousAndNext; 
    public Boolean bHasNext {get; private set;}
    public Boolean bHasPrevious {get; private set;}
    public Boolean bIsOppExist {get; private set;} 
    
    public integer pcurrentPage {get; private set;}
    public integer plastPage {get; private set;}
    public Boolean pHasPreviousAndNext; 
    public Boolean pHasNext {get; private set;}
    public Boolean pHasPrevious {get; private set;}
    public Boolean pIsOppExist {get; private set;} 
    //v3.1
    
    
    //v3.0
    public boolean bAllowEnterOpptyName {get; set;}
    public boolean bShowOpptySection {get; set;}
    //public boolean bShowPartnerOpptySection {get; set;}
    public boolean bIsMarketingUser {get;set;}    
    
    
    // Constructor
    public leadConvertCoreComponentController() {
        // Create a new Opportunity which will hold the Opportuniy name set by the user
        // v1.2 : Updated code to use opportunityName instead of Opportunity object.
        //opportunityId = new Opportunity();
        
        // Set the selected Account to NONE by default
        selectedAccount = 'NONE';
        // Set the selected Contact to NONE by default
        selectedContact = 'NONE';
        //Set login user is not sales user
        salesLoginUser = false;
        
        
        
        //v3.0 comment out existing oppty
        //Oppty = 'New';
        //bAllowEnterOpptyName = true;
        resetOpptyAction();
        
    }
    
    //v3.1
    public ApexPages.StandardSetController setCon{
        get{
            if(setCon == null){
                
                if(Oppty == 'Existing'){
                    //3.3
                    Date dToday = Datetime.now().dateGMT();
                    Id standartOpptyRTId = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
                    Id smbOpptyRTId = IdLookupUtils.getRecordTypeId('SMB Opportunity','Opportunity',true);
                    Id aposOpptyRTId = IdLookupUtils.getRecordTypeId('APOS','Opportunity',true);
                    Id channelOpptyRTId = IdLookupUtils.getRecordTypeId('Channel Opportunity','Opportunity',true);
                    Id smallDealOpptyRTId = IdLookupUtils.getRecordTypeId('Small Deal Marketing','Opportunity',true);
                    Id dealRegOpptyRTId = IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity',true); //v7.0
                    Id runRateOpptyRTId = IdLookupUtils.getRecordTypeId('Run Rate Opportunity','Opportunity',true); //v10.0
                    //only show existing Opportunity from the following record type:
                    //Standard Opportunity, SMB Opportunity, APOS, Channel Opportunity, Small Deal Marketing
                    string queryString = 'SELECT Id, Name, StageName, Unweighted_Rev_Formula__c, CreatedDate, CloseDate,RecordType.Name,Deal_Reg_Oppty__c,Deal_Registration_Status__c '+ 
                        'FROM Opportunity WHERE AccountId = '+ '\''+ selectedAccount + '\' ';
					String strCriteriaMktgUser = '';
					if(checkForMarketingProfiles())
					{
						strCriteriaMktgUser = 'AND (( (StageName =  \'Lost, Cancelled - 0%\' OR StageName =  \'Win - 100%\' OR StageName =  \'Order Submitted - 99%\') AND CreatedDate = LAST_N_DAYS:97 ) OR (StageName = \'Plan - 1%\' OR StageName = \'Discover - 10%\' OR StageName = \'Qualify - 30%\' OR StageName = \'Propose - 60%\' OR StageName = \'Commit - 90%\'))';
					}
					else 
					{
						strCriteriaMktgUser = 'AND StageName != \'Lost, Cancelled - 0%\' AND StageName != \'Win - 100%\' AND CloseDate >= :dToday ';
					}
                        
                    queryString = queryString +  strCriteriaMktgUser +   'AND RecordTypeId IN ( \''+ standartOpptyRTId + '\','+
                        '\''+ smbOpptyRTId + '\','+
                        '\''+ aposOpptyRTId + '\','+
                        '\''+ channelOpptyRTId + '\','+
                        '\''+ smallDealOpptyRTId + '\',' +     
                        '\''+ runRateOpptyRTId   + '\') ' +     //v10.0
                        'Order by CloseDate DESC LIMIT 10000'; //limit 10k due to governor limit on getQueryLocator
                    system.debug('ZY => queryString : ' +  queryString);
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));                    
                }
                
                if(setCon != null && setCon.getResultSize()!= 0 && setCon.getResultSize() > 0){
                    this.setCon.setPageSize(PAGE_SIZE);
                    bIsOppExist = true;                  
                    setNextPrevious();
                    setCon.last();                    
                    lastPage =  setCon.getPageNumber();                   
                    setCon.first();    
                    currentPage = setCon.getPageNumber();
                }
                else{
                    bIsOppExist = false;    
                }
            }
            return setCon;
        }set;
    }
    
    
    public List<Opportunity> getListOpp(){        
        if(listOpp==null){ 
            listOpp= new List<Opportunity>();      
            listOpp = (List<Opportunity>) setCon.getRecords();   
            //system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=>'+listOpp);   
        }        
        return listOpp;
    }
    
    
    //populate selected existing Opportunity to Opportunity
    public PageReference populateOppty(){
        String strOppId = ApexPages.currentPage().getParameters().get('selectedOppid');
        String strOppName = ApexPages.currentPage().getParameters().get('selectedOppName');
        string intOppDaysCreated = ApexPages.currentPage().getParameters().get('selectedOppDaysCreated');
        
        opportunityName = strOppName;
        //3.2
        strOpportunityId = strOppId;
        intOpptyDaysCreated = integer.valueOf(intOppDaysCreated);    
        return null;
    }
    //end
    
    //Wrapper class to store existing Opportunity record 
    public class existingOppWrapper{
        public Opportunity objOpp {get; set;}
        public Integer intDays {get; set;}
        
        //Constructor for wrapper class      
        public existingOppWrapper(Opportunity o, Integer intDay){    
            objOpp = o;
            intDays = intDay; 
        }
    }
    
    //Function get called when user click on next link in opportunity record list
    public PageReference next() {      
        if (bHasNext){
            listOpp=null;
            setCon.next();            
            currentPage = setCon.getPageNumber();
        }
        setNextPrevious();
        return null;
    }
    
    
    //Function get called when user click on previous link in opportunity record list
    public PageReference previous() {
        if (bHasPrevious){
            listOpp=null;
            setCon.previous();
            currentPage = setCon.getPageNumber();
        }
        setNextPrevious();
        return null;
    }
    
    
    //Set values for hasNext and hasPrevious booleans
    private void setNextPrevious() {
        if (setCon.getHasNext()) {
            bHasNext = true;
        }
        else {
            bHasNext = false;
        }
        if (setCon.getHasPrevious()) {
            bHasPrevious = true;
        }
        else {
            bHasPrevious = false;
        }
    } 
    
    
    public boolean getbHasPreviousAndNext(){
        return (bHasPrevious && bHasNext);
    }
    
    
    //end - v3.1    
    
    
    // Find an Account using SOSL based on the given company name
    private Account [] findCompany(String companyName) {
        // Perform the SOSL query
        list<list<SObject>> searchList = [FIND :companyName IN NAME FIELDS RETURNING Account(Id, Name, Account_Id__c, Status__c, Type) limit 200];
        list<Account> accountsFound = new list<Account>();
        
        for(list <sobject> sObjs : searchList) {
            for(sObject s : sObjs) {
                // add the account that was found to the list of found accounts
                accountsFound.add((Account) s);
            }   
        }
        
        // return the list of found accounts
        return accountsFound;
    }
    
    //V 1.5 Start
    private list<Contact> findLeadName(String LeadName,String selectedAccount)
    {
        List<contact> contactsFound = new List<contact>();
        // Perform the SOQL query
        if(selectedAccount!=null && selectedAccount !='NONE')
        {       
            contactsFound = [select id,name from Contact  where AccountId =:selectedAccount And 
                             ((Email =:leadConvert.Email And Email !=null) OR (FirstName =:leadConvert.FirstName And FirstName !=null) OR LastName =:leadConvert.LastName)];
        }       
        // return the list of found accounts
        return contactsFound;
    }
    //V 1.5 End
    
    // populate the list of Accounts in the dropdown
    private void populateAccounts() {
        if(leadConvert != null) {
            // v1.1, v1.3 - Starts : Populate Account / Account of the Related Contact as the default and make it as the only option for the Account Name drop down. 
            if(leadConvert.Account__c != null || leadConvert.Contact__c != null) {
                Id accountId = (leadConvert.Account__c != null ? leadConvert.Account__c : leadConvert.Contact__r.AccountId);
                String strAccountName = (leadConvert.Account__c != null ? leadConvert.Account__r.Name : leadConvert.Contact__r.Account.Name);
                accounts = new list<SelectOption>();
                accounts.add(new SelectOption(accountId, EXISTING + strAccountName));
                
                //Gan Fix
                selectedAccount = accountId;
                return;
            }
            // v1.1, v1.3 - Ends : Populate Account / Account of the Related Contact as the default and make it as the only option for the Account Name drop down.
            
            String company = leadConvert.Company;
            
            // Find any accounts that match the SOSL query in the findCompany() method  
            Account [] accountsFound = findCompany(company + '*');
            accounts = new list<SelectOption>();
            
            if(accountsFound != null && accountsFound.size() > 0) {
                // If there is at least 1 account found add a NONE option and a Create New Account option
                accounts.add(new SelectOption('NONE', '-None-'));
                
                accounts.add(new SelectOption('NEW', 'Create New Account: ' + company ));
                
                // For each account found, add an option to attach to the existing account
                for(Account a : accountsFound) {
                    accounts.add(new SelectOption(a.Id, EXISTING + a.Name));
                    //4.0
                    if(a.status__c == 'A' && a.account_id__c != null && a.Type == 'End User')   {
                        accounts.add(new SelectOption('SUB-' + a.Id + '#' + a.Account_Id__c, STRSUBACCOUNT + company + ' under: ' +  a.Name));
                    }
                }
            }
            else {
                // If no accounts matched then simply add a Create New Account option
                accounts.add(new SelectOption('NEW', 'Create New Account: ' + company ));
                selectedAccount = 'NEW';
                System.debug('no account matches on company ' + company);
            }
            
            // v1.1 : Commented below line so that Opportunity will not have the Account Name by default.
            // The default opportunity name will be the lead's company
            // opportunityId.Name = company + ' - ';
        }
        else {
            System.debug('leadConvert = null');
        }
    }
    
    //V 1.5 Start
    public void populateContacts() {
        if(leadConvert != null) {
            
            if(leadConvert.Contact__c != null) {
                Id contactId = leadConvert.Contact__c;
                String strContacttName =  leadConvert.Contact__r.Name;
                
                Contacts = new list<SelectOption>();
                Contacts.add(new SelectOption(contactId, EXISTING + strContacttName));
                
                selectedContact = contactId;
                
                return;
            }
            String LeadName = leadConvert.Name;           
            // Find any Contacts that match the SOSL query in the findLeadName() method 
            list<Contact> ContactsFound;
            try{
                ContactsFound = findLeadName(LeadName + '*',selectedAccount); 
            }
            catch(Exception e)
            {
                System.debug('error'+e.getmessage()); 
            }
            System.debug('error:after error');
            contactBasedOnAccount(ContactsFound,LeadName);          
        }
        else {
            System.debug('leadConvert = null');
        }
    }   
    
    private void contactBasedOnAccount(list<Contact> ContactsFound ,String LeadName){
        
        Contacts = new list<SelectOption>();
        if(ContactsFound != null && ContactsFound.size() > 0) {
            // If there is at least 1 contact found add a NONE option and a Create New Contact option
            selectedContact = 'NONE';
            Contacts.add(new SelectOption('NONE', '-None-'));               
            Contacts.add(new SelectOption('NEW', 'Create New Contact: ' + LeadName ));               
            // For each Contact found, add an option to attach to the existing Contact
            for(Contact c : ContactsFound) {
                Contacts.add(new SelectOption(c.Id, EXISTING + c.Name));
            }
        }
        else {
            // If no Contacts matched then simply add a Create New Contact option
            Contacts.add(new SelectOption('NEW', 'Create New Contact: ' + LeadName ));
            selectedContact = 'NEW';
            System.debug('no Contact matches on selected account ' + LeadName);
        }  
    }
    //V 1.5 End
    // v1.1 - Starts : This method no longer used.
    /* 
// when the selected account in the select list of accounts changes this method is called 
public PageReference accountChanged() {
// If either the NONE option or the Create New Account option is selected, the Opportuniy Name is set to the lead's company
if(selectedAccount == 'NEW' || selectedAccount == 'NONE') {
opportunityId.Name = leadConvert.Company  + ' - ';
}
else {
// Otherwise find the account's Id and Name that was selected and set the Opportuity name to that Account
Account [] arrAccounts = [SELECT Id, Name FROM Account WHERE Id = :selectedAccount];

if(arrAccounts.size() > 0) {
opportunityId.Name = arrAccounts[0].Name + ' - ';
}
}
return null;
}
*/
    // v1.1 - Ends
    
    
    // This gets called when an existing accout gets looked up via the lookup magnifying glass
    public PageReference accountLookedUp() {
        System.debug(loggingLevel.info,'!!! Account looked up --> ' + contactId.AccountId );
        
        // Find the Id and Nmae of the Account that was looked up
        // 4.0        
        Account [] arrAccounts = [SELECT Id, Name, status__c, account_id__c, type FROM Account WHERE Id = :contactId.AccountId];
        
        if(arrAccounts.size() > 0) {
            // Add the locked up account to the slect list
            accounts.add(new SelectOption(arrAccounts[0].Id, EXISTING + arrAccounts[0].Name));
            
            //4.0
            system.debug(loggingLevel.info,'ZY : status__c:' + arrAccounts[0].status__c + ', account_id__c:' + arrAccounts[0].account_id__c + ', type:' + arrAccounts[0].type );
            if(leadConvert != null && arrAccounts[0].status__c == 'A' && arrAccounts[0].account_id__c != null && arrAccounts[0].type == 'End User') {
                accounts.add(new SelectOption('SUB-' + arrAccounts[0].Id + '#' + arrAccounts[0].account_id__c, STRSUBACCOUNT + leadConvert.Company + ' under: ' +  arrAccounts[0].Name));
            } 
            
            // Set the selected account to the one that was just looked up by default
            selectedAccount = arrAccounts[0].Id;
            //Wanti
            resetOpptyAction();
            populateContactsAndOpptyAction();
            //V 1.5 Start
            list<Contact> ContactsFound;
            try{
                ContactsFound = findLeadName(leadConvert.Name,selectedAccount); 
            }
            catch(Exception e)
            {
                System.debug('Error after selecting account by lookup'+e.getmessage());
            }           
            contactBasedOnAccount(ContactsFound,leadConvert.Name);
            //V 1.5 End
            
            // v1.1 : Commented below line so that Opportunity will not have the Account Name by default.
            // Set the Opportunity name to the account's name that was looked up
            //opportunityId.Name = arrAccounts[0].Name + ' - ';
            
            System.debug('accounts --> ' + accounts);
        }
        return null;
    }
    
    
    
    // set up the Lead Status pick list
    public String LeadStatusOption {
        get {
                Set<String> SalesProfileName = new Set<String> {
                    'GBL Dell Services Rep',
                        'GBL Dell Services Rep – Non SSO',
                        'GBL Dell Services Mgr',
                        'GBL Dell Services Mgr – Non SSO',
                        'MSG Service Sales', 
                        'MSG Service Sales – Non SSO'};
                            User currentUser = StaticFactory.getCurrentUserDetails(); 
                System.debug('currentUser '+currentUser );
                String profileNameWithoutVersion = currentUser.Profile.Name.replaceFirst('[Rr]{1}[0-9.]+[ ]{1}', '');                        
                System.debug('profileNameWithoutVersion'+profileNameWithoutVersion);
                if(profileNameWithoutVersion.containsIgnorecase('Sales') || SalesProfileName.contains(profileNameWithoutVersion)){
                    salesLoginUser = true;
                    //11.0 Update converted statuses based on the opportunity selection
                    if(Oppty == 'Existing'){
                        leadConvert.Status = 'Converted to Existing Opportunity';
                    }else{
                        leadConvert.Status = 'Converted to New Opportunity';
                    }
                }
                else{
                    system.debug('Opportunity Selection 2'+oppty);
                    if(Oppty == 'Existing'){
                        leadConvert.Status = 'Converted to Existing Opportunity';
                    }else if(Oppty == 'New' || Oppty == 'SmallDeal'){
                        leadConvert.Status = 'Converted to New Opportunity';
                    }else{
                        leadConvert.Status = 'Converted without Opportunity';
                    }
                }
               return leadConvert.Status; 
            }
        set;
    }
    //v3.0 
    public PageReference opptyActionChanged() {
        system.debug('Oppty Selected: ' + Oppty);
        //Oppty = 'New';
        if (Oppty == 'Default') {
            bAllowEnterOpptyName = false;
            bShowOpptySection = false;
            bShowPartnerOpptySection=false;
        } 
        else if(Oppty == 'New' || Oppty == 'SmallDeal') {
            bAllowEnterOpptyName = true;
            bShowOpptySection = false;
            bShowPartnerOpptySection=false;
            
        }
        else if(Oppty == 'Existing') {
            bAllowEnterOpptyName = false;
            bShowOpptySection = true;
            getListOpp();
            bShowPartnerOpptySection = checkForPartnerAccount();//10.0 
            if(bShowPartnerOpptySection){
             getListPartnerOpp();
            }
        }
        
        resetOpptyInfo();
        return null;
    }
    
    //v3.0
    public void resetOpptyAction() {
        Oppty = 'New';
        bAllowEnterOpptyName = true;
        bAllowEnterOpptyName = true;
        bShowOpptySection = false;
        bShowPartnerOpptySection = false;
        
    }
    
    //v3.0
    public void populateContactsAndOpptyAction() {
        //Oppty = 'New';
        populateContacts();
        populateOpptyAction();
        system.debug('ZY => Reset the setCon' );
        clearOpptyRelatedInfo();
        resetOpptyAction(); 
    }
    
    public void clearOpptyRelatedInfo() {
        setCon = null;
        setPartnerCon=null; //10.0
        listOpp = null;
        listPartnerOpp = null;
        
        //3.2
        resetOpptyInfo();
    }
    
    //3.2
    public void resetOpptyInfo() {
        opportunityName = '';
        strOpportunityId = '';
        intOpptyDaysCreated = 0;
    }
    
    
    //v3.0
    public void populateOpptyAction() {
        listOpptyActionOptions = new List<SelectOption>();
        //v8.1
        if(MarketingProfileUser){
            listOpptyActionOptions.add(new SelectOption('Default', 'Do Not Create New Opportunity'));
        }// V8.1 End
        
        listOpptyActionOptions.add(new SelectOption('New', 'Create New Opportunity'));
        listOpptyActionOptions.add(new SelectOption('SmallDeal', 'Create New Small Deal Opportunity'));
        System.debug('ZY: selectedAccount: ' + selectedAccount);
        if(selectedAccount != null && selectedAccount != 'NEW' && selectedAccount != 'NONE'
           //4.0
           && !selectedAccount.startsWith('SUB-')) {
               listOpptyActionOptions.add(new SelectOption('Existing', 'Link To Existing Opportunity'));
           }    
        
    }   
    
    //v5.0 Contact Validation During Lead Conversion
    public PageReference validateContact() {
        system.debug(LoggingLevel.INFO, 'Saji## : Inside ValidateContact');
        List<string> listObjectNames = new List<string>(); //8.0
        listObjectNames.add('Contact'); //8.0
        String strbkpContact=selectedContact;
        selectedContact=null;
        if(strbkpContact != 'NONE' ) {
            TriggerExecutionController.setSkipAccountTriggers(true);
            list<contact> lstContacts = [select Id, Mailing_Address_Changed__c, Status__c, AccountId, Account_Active_Contact__c, Account_Inactive_Contact__c from contact where Id = :strbkpContact];
            SystemBehaviorBypasser.setSkipValidationRules(listObjectNames); //8.0
            Database.SaveResult[] conList = Database.update(lstContacts, false);
            ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjectNames); //8.0
            for (Database.SaveResult cList: conList) {
                if (!cList.isSuccess()) {
                    for(Database.Error err : clist.getErrors()) {
                        PrintError(err.getMessage());
                    }
                    if(selectedContact != 'NONE') {
                        //PrintError('Please go back to the lead or open related contact and edit any bad data prompted by system when saving');
                        PrintError(System.Label.LM2_ContactBadData); //v10.0
                        resetContactInfo();
                        system.debug(logginglevel.INFO,'###Contact Validation Completed Successfully 1');
                        return null;
                    }
                }
                else{
                    selectedContact=strbkpContact;
                }
            }
            //9.0 Code Fix for INC3518054
            if(strbkpContact=='New'){
                selectedContact=strbkpContact;
            }//9.0 End of Fix
            TriggerExecutionController.setSkipAccountTriggers(false);    
        } 
        system.debug(logginglevel.INFO,'###Contact Validation Completed Successfully 2');
        return null;
    }   
    
    public void resetContactInfo() {
        selectedContact = null;
    }
    
    // This method will put an error into the PageMessages on the page
    public void PrintError(String error) {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, error);
        ApexPages.addMessage(msg);
    }
    //*******************************************************************************************************************/
    //10.0 Setting wrapper for partner opportunities
     private List<Opportunity> listPartnerOpp;
     public List<existingOppWrapper> listExistingPartnerOpp {
        get{            
            List<existingOppWrapper> listExistOppWrap = new List<existingOppWrapper>(); 
            //4.0
            if(selectedAccount!=null && selectedAccount !='NONE' && selectedAccount !='NEW' 
               && !selectedAccount.startsWith('SUB-') && bShowPartnerOpptySection){      
                   for(Opportunity opp : getListPartnerOpp())
                   { 
                       Integer days = opp.CreatedDate.dateGMT().daysBetween(system.now().dateGMT());   // count the Number of Days Since Opportunity is Created  
                       //system.debug('-=============================='+opp.RecordType.Name+' '+bshowPartnerOpptySection+'----- '+channelLoginUser);
                       //v7.0
                       listExistOppWrap.add(new existingOppWrapper(opp, days));            
                   }
               }
            listExistingPartnerOpp = listExistOppWrap;
            return listExistingPartnerOpp;
        }set;
    }
     public List<Opportunity> getListPartnerOpp(){        
        if(listPartnerOpp==null && bShowPartnerOpptySection){ 
            listPartnerOpp= new List<Opportunity>();      
            listPartnerOpp = (List<Opportunity>) setPartnerCon.getRecords();   
           // system.debug(LoggingLevel.INFO,'-=-=-=-Partner Opportunities-=-=-=--=-=-=>'+listPartnerOpp);   
        }        
        return listPartnerOpp;
    }
    
    //10.0 Setting connection to pull partner opportunities
    public ApexPages.StandardSetController setPartnerCon{
       
        get{
            if(setPartnerCon == null){
                boolean partnerAccount = checkForPartnerAccount();
                if(Oppty == 'Existing' && channelLoginUser && partnerAccount){
                    Date dToday = Datetime.now().dateGMT();
                    Id standartOpptyRTId = IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
                    Id smbOpptyRTId = IdLookupUtils.getRecordTypeId('SMB Opportunity','Opportunity',true);
                    Id aposOpptyRTId = IdLookupUtils.getRecordTypeId('APOS','Opportunity',true);
                    Id channelOpptyRTId = IdLookupUtils.getRecordTypeId('Channel Opportunity','Opportunity',true);
                    Id smallDealOpptyRTId = IdLookupUtils.getRecordTypeId('Small Deal Marketing','Opportunity',true);
                    Id runRateOpptyRTId = IdLookupUtils.getRecordTypeId('Run Rate Opportunity','Opportunity',true); //v10.0
                    //only show existing Opportunity from the following record type:
                    //Standard Opportunity, SMB Opportunity, APOS, Channel Opportunity, Small Deal Marketing, Run Rate Opportunity
                    string queryString = 'SELECT Id, Name, StageName, Unweighted_Rev_Formula__c, CreatedDate, CloseDate,RecordType.Name,Deal_Reg_Oppty__c,Deal_Registration_Status__c '+ 
                        'FROM Opportunity WHERE PartnerAccountId = '+ '\''+ selectedAccount + '\' '+ 
                        'AND StageName != \'Lost, Cancelled - 0%\' AND StageName != \'Win - 100%\' '+
                        'AND RecordTypeId IN ( \''+ standartOpptyRTId + '\','+
                        '\''+ smbOpptyRTId + '\','+
                        '\''+ aposOpptyRTId + '\','+
                        '\''+ channelOpptyRTId + '\','+
                        '\''+ smallDealOpptyRTId + '\', ' +     
                        '\''+ runRateOpptyRTId   + '\') ' + 
                        'AND CloseDate >= :dToday '+
                        'Order by CloseDate DESC LIMIT 10000'; //limit 10k due to governor limit on getQueryLocator
                    system.debug(Logginglevel.INFO,'#### queryString => : ' +  queryString);
                    setPartnerCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));                    
                }
                
                if(setPartnerCon != null && setPartnerCon.getResultSize()!= 0 && setPartnerCon.getResultSize() > 0){
                    this.setPartnerCon.setPageSize(PAGE_SIZE);
                    pIsOppExist = true;                  
                    setPartnerNextPrevious();
                    setPartnerCon.last();                    
                    plastPage =  setPartnerCon.getPageNumber();                   
                    setPartnerCon.first();    
                    pcurrentPage = setPartnerCon.getPageNumber();
                }
                else{
                    pIsOppExist = false;    
                }
            }
            return setPartnerCon;
        }set;
    }
    //10.0 Function get called when user click on next link in Partner opportunity record list
    public PageReference nextPartnerOpp() {      
        if (pHasNext){
            listPartnerOpp=null;
            setPartnerCon.next();            
            pcurrentPage = setPartnerCon.getPageNumber();
        }
        setPartnerNextPrevious();
        return null;
    }
    
    
    //10.0 Function get called when user click on previous link in Partner opportunity record list
    public PageReference previousPartnerOpp() {
        if (pHasPrevious){
            listPartnerOpp=null;
            setPartnerCon.previous();
            pcurrentPage = setPartnerCon.getPageNumber();
        }
        setPartnerNextPrevious();
        return null;
    }
    //10.0 Set values for hasNext and hasPrevious booleans for SetPartnerCon
    private void setPartnerNextPrevious() {
        if (setPartnerCon.getHasNext()) {
            pHasNext = true;
        }
        else {
            pHasNext = false;
        }
        if (setPartnerCon.getHasPrevious()) {
            pHasPrevious = true;
        }
        else {
            pHasPrevious = false;
        }
    }
    //10.0
    public boolean getpHasPreviousAndNext(){
        return (pHasPrevious && pHasNext);
    }
    
    public boolean checkForPartnerAccount(){
        Account objAccount = [SELECT Id, Name, type FROM Account WHERE Id = :selectedAccount];
        system.debug(logginglevel.INFO,'### Selected Account =' + objAccount.Name + '  Account type = ' + objAccount.Type);
        boolean partnerAccount= (objAccount.type =='Partner')?true:false;
        boolean cPartnerChek = (PartnerAccount && channelLoginUser)?TRUE:FALSE;
        //system.debug(logginglevel.INFO,'### Is this Channel User =' + channelLoginUser);
        return cPartnerChek;
    }
    
    public boolean checkForMarketingProfiles()
    {
        bIsMarketingUser = false;
        User currentUser1 = StaticFactory.getCurrentUserDetails(); 
        string strPname = currentUser1.Profile.Name;
        List<string> listMarketingProfiles = Label.Marketing_Profiles_for_LeadConversion.split(';');
        if(listMarketingProfiles.contains(strPname))
        {
            bIsMarketingUser = true;
        }
        
        return bIsMarketingUser;
    }
}