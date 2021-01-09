/*
 * Purpose  : Controller to handle: Accunt and User modification from partner Portal
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      
 * 2.0                  14.2                            Meera           Removing Partner Request status update after success CMI Synch
 * 3.0      8156        14.5                            Vikas Gandhi    New Fields have added in MyCompany Page and two FieldSet named CountryFS and AccountFS have used to reduce long SOQL queries
 * 4.0                  16.03           30-Mar-2015     Ragu            Defect 158106 - Refactored the code to avoid view state error.
 * 5.0      16007       FY19-DCS-0802   12-June-2018    Michael          Decommisioned Provisioned_in_Netexam_on__c as Part of Story# 4988554

 */ 
 
public without sharing class PartnerSelfServiceMyCompanyCtrlExt extends DellStandardController {

    public Account company {get; set;}
    public Partner_Request__c request {get; set;}
    public Country__c country {get; set;}
    // Below code commented by virkam kamboj on 05/10/2012 for CR7631
    //public list<User> partnerUsers {get;set;}
    
    // Raymond 20100224 - Added for CR2420
    public Partner_Request__c inactivationRequest;
    
    public Boolean editMode {get; set;}
    public Boolean dmlError = false;
    public Boolean vendorError = false;
    
    public Boolean errorNotEnabledAsPartnerAdmin {get; set;}
    public transient list<User> partnerAdminsForAccount {get; set;}
    public User confirmInactivateUser {get; set;}
    public String manualPrimaryRouteToMarket {get; set;}
    public String manualPrimaryCustomer {get; set;}

    // [Krishna 7-May-2010] Added for CR2570
    public transient map<String, String> updateSuggestionParams;
    public transient Boolean needSuggestion;
    
    // Below variables added by vikram kamboj on 05/10/2012 for CR7631
    public Integer noOfRecords {get; set;}
    public Integer size {get; set;}
    public Integer PageSize {get; set;}
    private String sortDirection = 'ASC';
    private String sortExp = 'Name';
    private String sortFullExp = 'Name';
    
    public String bestDescribeAPIName {get; set;}
    public String bestOrgDescribeAPIName {get; set;}
    public String top3VendorOtherValue {get; set;}
    public String Orginaltop3VendorVal {get; set;}
    public Boolean showaddBtn {get; set;}
    
    public static final String HTTP_PARAMETER_USERID = 'userId';
    
    // [Men Mee 29.06.2010] Added for CR2750
    public static final String HTTP_PARAMETER_USERCHANGED = 'userChanged';

    public PartnerSelfServiceMyCompanyCtrlExt(ApexPages.StandardController controller) {
        super();
        
        System.assert(controller.getRecord() instanceof Partner_Request__c, 'Invalid type returned by ApexPages.StandardController.getRecord()');
        PageSize = 20;
        
        // Below code commented by virkam kamboj on 05/10/2012 for CR7631
        //partnerUsers=new list<User>();
        
        this.request = initialize((Partner_Request__c) controller.getRecord());
    }
    
    private Partner_Request__c initialize(Partner_Request__c request) {
        editMode = false;
        
        User loggedInUser = getCurrentUserDetails(UserInfo.getUserId());
        
        if(loggedInUser.UserRole == null 
            || StringUtils.isBlank(loggedInUser.UserRole.Name)
            || loggedInUser.Contact == null
            || loggedInUser.Contact.Id == null
            || loggedInUser.Contact.AccountId == null) {
            // Basically this is a standard user license user
            PageUtils.addError('Navigation error.  Screen is for Partners only.');
            return request;
        }
        
        // Make sure the user is a partner admin
        if(!loggedInUser.Enable_Partner_Admin__c) {
            setErrorNotEnabledAsPartnerAdmin(loggedInUser.Contact.AccountId);
            return request;
        }
        
        populateRequest(request, loggedInUser.Contact.AccountId);    
        
        // Below code commented by virkam kamboj on 05/10/2012 for CR7631
        /*
        partnerUsers = [select Title, Name, LastName, Id, FirstName, Email, Contact.Title, 
                            Contact.Email, Contact.Name, Contact.FirstName, Contact.LastName, ContactId, UserRole.Name 
                        from User where ContactId in :company.Contacts and ContactId != null and IsActive = true];
        */
        
        // CR2750 - Start
        if(StringUtils.equalsIgnoreCase(PageUtils.param(HTTP_PARAMETER_USERCHANGED), 'true')) {
            PageUtils.addInfo(Label.The_changes_have_been_successfully_updated);
        }
        // CR2750 - End
        
        return request;
    }
    
    private void populateRequest(Partner_Request__c request, Id accountId) {
        showaddBtn = false;
        
        // Set Record Type
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER, 'Partner_Request__c', true);
        System.assert(request.RecordTypeId != null, 'Record type \'' + PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER + '\' not found.');
        
        // Get Account
        // Added by Vikas CR8156: Below long SOQL query has been replaced using FieldSet i.e. AccountFS
        // v4.0 - Below line is moved from global to local context
        list<Schema.FieldSetMember> accountFieldSet = SObjectType.Account.FieldSets.AccountFS.getFields();
        // v4.0 - Contacts removed from below SOQL
        //list<Account> accountList = Database.query(returnFieldSetMembers(accountFieldSet) +', (Select Id, Name, LastName, FirstName, Email, Title From Contacts) from Account where id = :accountId');
        list<Account> lstAccounts = Database.query(returnFieldSetMembers(accountFieldSet) + ' from Account where Id = :accountId');
        /* 
        list<Account> lstAccounts = 
            [select name,Website,Does_Business_As__c,Preferred_Language__c,Number_of_years_in_business__c,Form_of_Organization__c, 
                Shipping_Suburb__c, ShippingStreet, ShippingState, Account_ID__c, 
                ShippingPostalCode, ShippingCountry, ShippingCity, Phone, Partner_Type__c, 
                Partner_Tier__c, Partner_Relationship__c, Partner_Finder_Opt_In__c, Partner_Finder_Dell_Opt_in__c,
                ACCOUNT_COUNTRY_CODE__C, Currently_Selling_Dell__c,Dell_Revenue_Percent__c,Hardware_Revenue_Percent__c,
                Other_Customers__c,Percent_Sales_Force__c,Percent_Technical_Professionals__c,Preferred_Dell_Distribution_Partner__c,
                Primary_Channel_Model__c,Partner_Primary_Customer__c,Product_Focus__c,Reseller_Tax_ID__c,
                Service_Revenue_Percent__c,Software_Revenue_Percent__c,States_Provinces_doing_business__c,Partner_Finder_Contact_Email__c,
                Primary_Routes_to_Market__c,NumberOfEmployees, (Select Id, Name, LastName, FirstName, Email, Title From Contacts)   
             from Account where id = :accountId];
        */
        System.assert(!lstAccounts.isEmpty(), 'Account(id=\'' + accountId + '\') not found');
        
        company = lstAccounts.get(0);
        
        if(company != null) {
            System.debug('Radio button API Name (Before): ' + bestDescribeAPIName);
            for(String strName : getAPINames()) {
                if(company.get(strName) == true) {
                    bestDescribeAPIName = strName;
                    break;
                }
            }
            System.debug('Radio button API Name (After): ' + bestDescribeAPIName);
        }
        bestOrgDescribeAPIName = bestDescribeAPIName;
        
        // Populate request from Account data
        request.Status__c = PartnerConstants.REG_STATUS_DRAFT;
        request.Account__c = company.Id;
        request.Company__c = company.Name;
        request.Website__c = company.Website;
        request.Does_Business_As__c = company.Does_Business_As__c;
        request.Preferred_Language__c = company.Preferred_Language__c;
        request.Number_of_years_in_business__c = company.Number_of_years_in_business__c;
        request.Form_of_Organization__c = company.Form_of_Organization__c;
        String[] addressTokens = StringUtils.split(company.ShippingStreet, '\n');
        if(addressTokens == null) { 
            addressTokens = new String[]{}; 
        }
        request.Org_Address_1__c = addressTokens.size() > 0 ? StringUtils.trim(addressTokens[0]) : '';
        request.Org_Address_2__c = addressTokens.size() > 1 ? StringUtils.trim(addressTokens[1]) : '';
        request.Org_Address_3__c = addressTokens.size() > 2 ? StringUtils.trim(addressTokens[2]) : '';
        request.Org_State__c = company.ShippingState;
        request.Org_Postal_Code__c = company.ShippingPostalCode;
        request.Org_City__c = company.ShippingCity;
        request.Org_Phone__c = company.Phone; 
        request.Partner_Finder_Opt_In__c = company.Partner_Finder_Opt_In__c;
        request.Partner_Finder_Contact_Me_Email__c = company.Partner_Finder_Contact_Email__c;
        request.Currently_Selling_Dell__c = company.Currently_Selling_Dell__c;
        request.Dell_Revenue_Percent__c = company.Dell_Revenue_Percent__c;
        request.Hardware_Revenue_Percent__c = company.Hardware_Revenue_Percent__c;
        request.Other_Customers__c = company.Other_Customers__c;
        request.Percent_Sales_Force__c = company.Percent_Sales_Force__c;
        request.Percent_Technical_Professionals__c = company.Percent_Technical_Professionals__c;
        request.Preferred_Dell_Distribution_Partner__c = company.Preferred_Dell_Distribution_Partner__c;
        request.Primary_Channel_Model__c = company.Primary_Channel_Model__c;
        request.Primary_Customer__c = company.Partner_Primary_Customer__c; 
        request.Product_Focus__c = company.Product_Focus__c;
        request.Reseller_Tax_ID__c = company.Reseller_Tax_ID__c;
        request.Service_Revenue_Percent__c = company.Service_Revenue_Percent__c;
        request.Software_Revenue_Percent__c = company.Software_Revenue_Percent__c;
        request.States_Provinces_doing_business__c = company.States_Provinces_doing_business__c;
        request.NumberOfEmployees__c = company.NumberOfEmployees;
        request.Primary_Routes_to_Market__c = company.Primary_Routes_to_Market__c;
        // To add Primary Contact Field for change it
        request.Primary_Contact__c = company.Primary_Contact__c;
        
        if(StringUtils.startsWithIgnoreCase(request.Primary_Routes_to_Market__c, 'Other')) {
            String[] split = StringUtils.split(request.Primary_Routes_to_Market__c, ':', 2);
            manualPrimaryRouteToMarket = split != null && split.size() == 2 ? StringUtils.trim(split[1]) : '';
            request.Primary_Routes_to_Market__c = 'Other';
        }
        if(StringUtils.startsWithIgnoreCase(request.Primary_Customer__c, 'Other')) {
            String[] split = StringUtils.split(request.Primary_Customer__c, ':', 2);
            manualPrimaryCustomer = split != null && split.size() == 2 ? StringUtils.trim(split[1]) : '';
            request.Primary_Customer__c = 'Other';
        }
        
        // Added by Vikas CR8156: R14.5 Below new Account fields need to be set in Partner Request
        request.Join_Dell_PartnerDirect_Program__c = company.Join_Dell_PartnerDirect_Program__c; 
        request.Number_of_Branches_Subsidiaries__c = company.Number_of_Branches_Subsidiaries__c;
        request.Principle_Name__c = company.Principle_Name1__c;
        request.Principle_Title__c = company.Principle_Title1__c;      
        request.Secondary_Customer__c = company.Secondary_Customer_Segment__c;
        request.Primary_Vertical_Market_Segment__c = company.Primary_Vertical_Market_Segment__c;
        request.Secondary_Vertical_Market_Segment__c = company.Secondary_Vertical_Market_Segment__c;
        request.Top_3_Vendors__c = company.Top_3_Vendors__c;
        request.Organization_Industry_Certificate__c = company.Organization_Industry_Certificate__c;
        request.Size_of_Customer_Base__c = company.Size_of_Customer_Base__c;
        Orginaltop3VendorVal = request.Top_3_Vendors__c;
        /*
        request.Managed_Service_Provider__c = company.Managed_Service_Provider__c;
        request.Hardware_Reseller__c = company.Hardware_Reseller__c;
        request.Solution_Oriented_Reseller__c = company.Solution_Oriented_Reseller__c;
        request.Boutique_Firm__c = company.Boutique_Firm__c;        
        request.Large_Enterprise__c = company.Large_Enterprise__c;
        request.Traditional_Reseller__c = company.Traditional_Reseller__c;
        request.Value_Added_Reseller__c = company.Value_Added_Reseller__c;
        request.Retailer__c = company.Retailer__c;
        request.Telco__c = company.Telco__c;
        request.eTailer__c = company.eTailer__c;        
        request.Other__c = company.Other__c;
        request.ISV__c = company.ISV__c;
        request.System_Integrator__c = company.System_Integrator__c;
        request.OEM__c = company.OEM__c;
        request.Software_Reseller__c = company.Software_Reseller__c;
        request.Referral_Partner__c = company.Referral_Partner__c;
        request.Distributor__c = company.Distributor__c;
        request.Technology_Partner__c = company.Technology_Partner__c;
        */
        
        // 16.03 PP II Changes
        request.Service_Type__c = company.Service_Type__c;
        request.Service_Capability__c = company.Service_Capability__c;
        request.Mode_Of_Service__c = company.Mode_Of_Service__c;
        request.Hardware_warranty_Break_fix_support__c = company.Hardware_warranty_Break_fix_support__c;
        request.Software_Technical_Support__c = company.Software_Technical_Support__c;
        request.Installation_Deployment_Services__c = company.Installation_Deployment_Services__c;
        request.Installation_Deployment_Services_Market__c = company.Installation_Deployment_Services_Market__c;
        request.Custom_Configuration_Imaging__c = company.Custom_Configuration_Imaging__c;
        request.Data_Migration__c = company.Data_Migration__c;
        request.Asset_recovery_resale_recycling__c = company.Asset_recovery_resale_recycling__c;
        request.Consulting__c = company.Consulting__c;
        request.Consulting_Market__c = company.Consulting_Market__c;
        request.Education_Training__c = company.Education_Training__c;
        request.Managed_Deployment__c = company.Managed_Deployment__c;
        request.Custom_enterprise_data_center_services__c = company.Custom_enterprise_data_center_services__c;
        request.Dell_Service_Tools_Used__c = company.Dell_Service_Tools_Used__c;
        
        try {
            String accCountryCode = company.Account_Country_Code__c;
            // Added by Vikas CR8156: Below long SOQL query has been replaced using FieldSet i.e. CountryFS
            // v4.0 - Below line is moved from global to local context
            list<Schema.FieldSetMember> countryFieldSet = SObjectType.Country__c.FieldSets.CountryFS.getFields();
            country = Database.query(returnFieldSetMembers(countryFieldSet) + ' from Country__c where Code__c = :accCountryCode limit 1');
            /*
            country = [select id, code__c,dial_code__c,Partner_Support_Queue_ID__c,Partner_Support_Email__c, Show_Total_Employees__c,Show_States_Provinces_doing_bus__c,Show_Software_Revenue_Percent__c,
                            Show_Service_Revenue_Percent__c,Show_Reseller_Tax_ID__c,Show_Product_Focus__c, Show_Primary_Customer__c,Show_Primary_Channel_Model__c,Show_Preferred_Dell_Distr_Partner__c,
                            Show_Percent_Technical_Prof__c,Show_Percent_Sales_Force__c,Show_Other_Customers__c, Show_Org_Annual_Revenue__c,Show_Hardware_Revenue_Percent__c,Show_Dell_Revenue_Percent__c,
                            Show_Currently_Selling_Dell__c,Show_Primary_Routes_to_Market__c, Require_Primary_Routes_to_Market__c, Require_Total_Employees__c,Require_States_Provinces_doing_bus__c,
                            Require_Software_Revenue_Percent__c,Require_Service_Revenue_Percent__c,Require_Reseller_Tax_ID__c, Require_Product_Focus__c,Require_Primary_Customer__c,
                            Require_Primary_Channel_Model__c,Require_Preferred_Dell_Distr_Partner__c,Require_Percent_Technical_Prof__c, Require_Percent_Sales_Force__c,Require_Other_Customers__c,Require_Org_Annual_Revenue__c,
                            Require_Hardware_Revenue_Percent__c,Require_Dell_Revenue_Percent__c,Require_Currently_Selling_Dell__c, Training_Enabled__c, Partner_Finder_Enabled__c, Deal_Registration_Enabled__c  
                       from Country__c where Code__c = :company.Account_Country_Code__c limit 1]; 
            */
            request.Org_Country__c = country.Id;
            request.OwnerId = country.Partner_Support_Queue_ID__c;
        }
        catch(QueryException e) {}
    }
    
    private void setErrorNotEnabledAsPartnerAdmin(String accountId) {
        this.errorNotEnabledAsPartnerAdmin = true;
        partnerAdminsForAccount = [select Contact.Title, Contact.Email, Contact.FirstName, Contact.LastName, ContactId from User where Contact.AccountId = :accountId and Enable_Partner_Admin__c = true];
    }
    
    private String[] getAPINames() {
        return new String[]{'Managed_Service_Provider__c', 'Hardware_Reseller__c', 'Solution_Oriented_Reseller__c', 'Boutique_Firm__c', 'Large_Enterprise__c',
                            'Traditional_Reseller__c', 'Value_Added_Reseller__c', 'Retailer__c', 'Telco__c', 'eTailer__c', 'Other__c', 'ISV__c', 
                            'System_Integrator__c', 'OEM__c', 'Software_Reseller__c', 'Referral_Partner__c', 'Distributor__c', 'Technology_Partner__c'};
    }
    
    public Boolean getErrorOccurred() {
        return PageUtils.getMessagesAtLevel(ApexPages.Severity.ERROR, true).size() > 0;
    }
    
    private User getCurrentUserDetails(String userId) {
        final list<User> lstUsers = [select Id, Enable_Partner_Admin__c, Contact.Email_Opt_In__c, Contact.Title, Contact.Email, Contact.MobilePhone, Contact.Fax, Contact.Phone, 
                                        Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, Contact.MailingCity, Contact.MailingStreet, 
                                        Contact.Salutation, Contact.FirstName, Contact.LastName, ContactId, Contact.AccountId, Contact.Account.Id, Contact.Account.Name, 
                                        Contact.Account.Account_Country_Code__c, UserRole.Name
                                    from User where Id = :userId];
        System.assert(!lstUsers.isEmpty(), 'User(id=\'' + userId + '\') not found');
        return lstUsers.get(0);
    }
    
    public PageReference doEdit() {
        editMode = true;
        return null;
    }
    
    public PageReference doCancel() {
        if(dmlError || vendorError) { // To reinitialize the request.
            System.debug('KP: ReInitialize the request');
            this.request = initialize(request);
        }
        request.Top_3_Vendors__c = Orginaltop3VendorVal;
        editMode = false;
        return null;
    }
    
    public PageReference toggleAddDiv() {
        showaddBtn = true;
        return null;
    }
    
    public PageReference addOtherValue() {
        if(top3VendorOtherValue != null && top3VendorOtherValue != '') {
            if(request.Top_3_Vendors__c != null && request.Top_3_Vendors__c != '') {
                request.Top_3_Vendors__c=request.Top_3_Vendors__c+';'+top3VendorOtherValue;
            }
            else {
                request.Top_3_Vendors__c = top3VendorOtherValue;
            }
        }
        top3VendorOtherValue = '';
        showaddBtn = false;
        return null;
    }
    
    private class ItemsChangedHolder {
        public Boolean companyChanged {get; set;}
        public Boolean registrationChanged {get; set;}
        public ItemsChangedHolder() { 
            companyChanged = false; 
            registrationChanged = false; 
        }
    }
        
    public PageReference doSave() {
        // First validation check for top 3 vendor
        vendorError = false;
        if(request.Top_3_Vendors__c != null && request.Top_3_Vendors__c != '') {
            if(String.valueOf(request.Top_3_Vendors__c).split(';').size() > 3) {
                vendorError = true;
                PageUtils.addError(Label.Top_3_Vendors + ': ' + Label.Top_3_Vendor_Error_Message);  
                return null;
            }
        }
        
        // Aded for CR2570
        String messageType = 'nochange';
       
        // Aman: CRQ 0719 16 May,2013
        // Added for new functionality on MyCompany Page for Radio Button and Multi Picklist
        if(bestDescribeAPIName != null && bestDescribeAPIName != '') {
            for(String strName : getAPINames()) {
                if(bestDescribeAPIName == strName) {
                    request.put(strName, true);
                }
                else {
                    request.put(strName, false);
                }
            }
        }
         
        if(updateSuggestionParams == null) {
            updateSuggestionParams = new map<String, String>();
        }
        updateSuggestionParams.clear();
        needSuggestion = false;
                
        ItemsChangedHolder itemsChangedHolder = populateChangeFlags(request, company);
        dmlError = false;
        Savepoint sp = Database.setSavepoint(); 
        try {
            if(itemsChangedHolder.registrationChanged) {
                if(request.Id == null) {
                    insert request; 
                } 
                else { 
                    update request; 
                } 
            }
            if(itemsChangedHolder.companyChanged) {
                update company; 
            } 
        }
        catch(Exception e) {
            dmlError = true; 
            Database.rollback(sp); 
            ApexPages.addMessages(e); 
            return null;
        }
        
        // If any integarted field was changed, sends an update suggestion
        if(needSuggestion) {
            updateSuggestionParams.put('partyId', company.Account_ID__c);            
            updateSuggestionParams.put('legacyId', 'SFDC_'+ request.Id);
            updateSuggestionParams.put('orgGroupCountryCode', company.Account_Country_Code__c);
            // CR3482
            updateSuggestionParams.put('physicalCountryCode', company.ShippingCountry);            
            
            // @future call
            System.debug('####KP: Future method is invoked');         
            AccountSuggestion.sendSelfServiceAccountUpdateSuggestion(request.Id, updateSuggestionParams);
            messageType = 'changed';
            
            return PageUtils.redirect('/apex/PartnerSelfServiceUpdateMessage?type=' + messageType);       
            
        }
        
        System.debug('####KP: registrationChanged:' + itemsChangedHolder.registrationChanged + ', companyChanged:' + itemsChangedHolder.companyChanged);
        
        // Updated as per CR 2570
        //if(itemsChangedHolder.registrationChanged || itemsChangedHolder.companyChanged) {
        if(itemsChangedHolder.companyChanged) {
            PageUtils.addInfo(Label.The_changes_have_been_successfully_updated);//your changes would have reflected immediately.
        } 
        else {
            PageUtils.addInfo(Label.No_changes_were_made);
        }
        this.request = initialize(request);
        return null;
    }
    
    private ItemsChangedHolder populateChangeFlags(Partner_Request__c req, Account acct) {
        ItemsChangedHolder returnValue = new ItemsChangedHolder();
        
        // Fields which must be reviewed
        map<String,String> changes = new map<String,String>();
        if(req.Company__c != acct.name) { 
            changes.put('Company Name', req.Company__c); 
            req.Company_CF__c = true;
            needSuggestion = true;
        }
        updateSuggestionParams.put('orgGroupName', req.Company__c);
        if(req.Does_Business_As__c != acct.Does_Business_As__c) {    
            //changes.put('Doing Business As', req.Does_Business_As__c);
            req.Does_Business_As_CF__c = true;
            acct.Does_Business_As__c = req.Does_Business_As__c; 
            returnValue.companyChanged = true;  
        }
        String[] addressTokens = StringUtils.split(acct.ShippingStreet, '\n');
        if(addressTokens == null) { 
            addressTokens = new String[]{}; 
        }
        if((addressTokens.size() <= 0 ? '' : StringUtils.trim(addressTokens[0])) != (req.Org_Address_1__c == null ? '' : req.Org_Address_1__c)) { 
            changes.put('Organization Address Line 1', req.Org_Address_1__c); 
            req.Org_Address_1_CF__c = true;
            needSuggestion = true;
        }
        updateSuggestionParams.put('physicalStreetAddr1', req.Org_Address_1__c);
        if((addressTokens.size() <= 1 ? '' : StringUtils.trim(addressTokens[1])) != (req.Org_Address_2__c == null ? '' : req.Org_Address_2__c)) { 
            changes.put('Organization Address Line 2', req.Org_Address_2__c); 
            req.Org_Address_2_CF__c = true;
            needSuggestion = true;
        }
        if((addressTokens.size() <= 2 ? '' : StringUtils.trim(addressTokens[2])) != (req.Org_Address_3__c == null ? '' : req.Org_Address_3__c)) { 
            changes.put('Organization Address Line 3', req.Org_Address_3__c); 
            req.Org_Address_3_CF__c = true;
            needSuggestion = true;
        }
        // Combined address fields comma seperated           
        String physicalStreetAddr2 = StringUtils.defaultString(req.Org_Address_2__c) + ((req.Org_Address_3__c == null)?'':(', ' + req.Org_Address_3__c));           
        updateSuggestionParams.put('physicalStreetAddr2', physicalStreetAddr2);  
        if(req.Org_State__c != acct.ShippingState ) { 
            changes.put('Organization State', req.Org_State__c); 
            req.Org_State_CF__c = true;
            needSuggestion = true;
        }
        updateSuggestionParams.put('physicalState',  req.Org_State__c);
        if(req.Org_Postal_Code__c != acct.ShippingPostalCode ) { 
            changes.put('Organization Postal Code', 
            req.Org_Postal_Code__c); 
            req.Org_Postal_Code_CF__c = true;
            needSuggestion = true;
        }
        updateSuggestionParams.put('physicalPostalCode',  req.Org_Postal_Code__c);
        if(req.Org_City__c != acct.ShippingCity ) { 
            changes.put('Organization City', req.Org_City__c); 
            req.Org_City_CF__c = true;
            needSuggestion = true;
        }
        updateSuggestionParams.put('physicalCity',  req.Org_City__c);
        if(req.Org_Phone__c != acct.Phone  ) { 
            //changes.put('Organization Phone', req.Org_Phone__c); 
            req.Org_Phone_CF__c = true;
            acct.Phone = req.Org_Phone__c;
            returnValue.companyChanged = true; 
        } 
        if(req.NumberOfEmployees__c != acct.NumberOfEmployees) { 
            changes.put('Employees', ''+req.NumberOfEmployees__c); 
            req.NumberOfEmployees_CF__c = true;
            needSuggestion = true;
        }
        updateSuggestionParams.put('employeesize', StringUtils.remove('' + req.NumberOfEmployees__c, 'null'));
        if(!changes.isEmpty()) {
            returnValue.registrationChanged = true;

            req.Description__c = 'Changes:  ';
            Boolean isFirst = true;
            for(String key : changes.keySet()) {
                if(isFirst) {
                    isFirst = false;
                } 
                else {
                    req.Description__c += '; ';
                }
                req.Description__c += '' + key + ' = \'' + changes.get(key) + '\'';
            }
        }
        // Fields which can applied to Account immediately
        if(req.Primary_Routes_to_Market__c != acct.Primary_Routes_to_Market__c) { 
            if('other'.equalsIgnoreCase(req.Primary_Routes_to_Market__c)) {
                acct.Primary_Routes_to_Market__c = req.Primary_Routes_to_Market__c + ': ' + StringUtils.defaultIfEmpty(manualPrimaryRouteToMarket, '');
            } 
            else {
                acct.Primary_Routes_to_Market__c = req.Primary_Routes_to_Market__c; 
            }
            returnValue.companyChanged = true; 
        }
        if(req.Primary_Customer__c != acct.Partner_Primary_Customer__c) { 
            if('other'.equalsIgnoreCase(req.Primary_Customer__c)) {
                acct.Partner_Primary_Customer__c = req.Primary_Customer__c + ': ' + StringUtils.defaultIfEmpty(manualPrimaryCustomer, '');
            } else {
                acct.Partner_Primary_Customer__c = req.Primary_Customer__c; 
            }
            returnValue.companyChanged = true; 
        }
        if(req.NumberOfEmployees__c != acct.NumberOfEmployees) { acct.NumberOfEmployees = req.NumberOfEmployees__c == null ? 0 : req.NumberOfEmployees__c.intValue(); returnValue.companyChanged = true; }
        if(req.Currently_Selling_Dell__c != acct.Currently_Selling_Dell__c) { acct.Currently_Selling_Dell__c = req.Currently_Selling_Dell__c; returnValue.companyChanged = true; }
        if(req.Dell_Revenue_Percent__c != acct.Dell_Revenue_Percent__c) { acct.Dell_Revenue_Percent__c = req.Dell_Revenue_Percent__c; returnValue.companyChanged = true; }
        if(req.Hardware_Revenue_Percent__c != acct.Hardware_Revenue_Percent__c) { acct.Hardware_Revenue_Percent__c = req.Hardware_Revenue_Percent__c; returnValue.companyChanged = true; }
        if(req.Other_Customers__c != acct.Other_Customers__c) { acct.Other_Customers__c = req.Other_Customers__c; returnValue.companyChanged = true; }
        if(req.Percent_Sales_Force__c != acct.Percent_Sales_Force__c) { acct.Percent_Sales_Force__c = req.Percent_Sales_Force__c; returnValue.companyChanged = true; }
        if(req.Percent_Technical_Professionals__c != acct.Percent_Technical_Professionals__c) { acct.Percent_Technical_Professionals__c = req.Percent_Technical_Professionals__c; returnValue.companyChanged = true; }
        if(req.Preferred_Dell_Distribution_Partner__c != acct.Preferred_Dell_Distribution_Partner__c) { acct.Preferred_Dell_Distribution_Partner__c = req.Preferred_Dell_Distribution_Partner__c; returnValue.companyChanged = true; }
        if(req.Primary_Channel_Model__c != acct.Primary_Channel_Model__c) { acct.Primary_Channel_Model__c = req.Primary_Channel_Model__c; returnValue.companyChanged = true; }
        if(req.Product_Focus__c != acct.Product_Focus__c) { acct.Product_Focus__c = req.Product_Focus__c; returnValue.companyChanged = true; }
        if(req.Reseller_Tax_ID__c != acct.Reseller_Tax_ID__c) { acct.Reseller_Tax_ID__c = req.Reseller_Tax_ID__c; returnValue.companyChanged = true; }
        if(req.Service_Revenue_Percent__c != acct.Service_Revenue_Percent__c) { acct.Service_Revenue_Percent__c = req.Service_Revenue_Percent__c; returnValue.companyChanged = true; }
        if(req.Software_Revenue_Percent__c != acct.Software_Revenue_Percent__c) { acct.Software_Revenue_Percent__c = req.Software_Revenue_Percent__c; returnValue.companyChanged = true; }
        
        if(req.Partner_Finder_Opt_In__c != acct.Partner_Finder_Opt_In__c) { acct.Partner_Finder_Opt_In__c = req.Partner_Finder_Opt_In__c; returnValue.companyChanged = true; }
        if(req.Partner_Finder_Contact_Me_Email__c != acct.Partner_Finder_Contact_Email__c) { acct.Partner_Finder_Contact_Email__c = req.Partner_Finder_Contact_Me_Email__c; returnValue.companyChanged = true;}
        if(req.Website__c != acct.Website ) { acct.Website = req.Website__c; returnValue.companyChanged = true; }
        if(req.Preferred_Language__c != acct.Preferred_Language__c ) { acct.Preferred_Language__c = req.Preferred_Language__c; returnValue.companyChanged = true; }
        if(req.Number_of_years_in_business__c != acct.Number_of_years_in_business__c ) { acct.Number_of_years_in_business__c = req.Number_of_years_in_business__c; returnValue.companyChanged = true; }
        if(req.Form_of_Organization__c != acct.Form_of_Organization__c ) { acct.Form_of_Organization__c = req.Form_of_Organization__c; returnValue.companyChanged = true; }
        
        //Added by Vikas CR8156: R14.5 Below new Account fields need to be set in Account if there is any change done by partner admin user in MyCompany Page
        if(req.Join_Dell_PartnerDirect_Program__c != acct.Join_Dell_PartnerDirect_Program__c ) { acct.Join_Dell_PartnerDirect_Program__c = req.Join_Dell_PartnerDirect_Program__c; returnValue.companyChanged = true; }         
        if(req.Number_of_Branches_Subsidiaries__c != acct.Number_of_Branches_Subsidiaries__c ) { acct.Number_of_Branches_Subsidiaries__c = req.Number_of_Branches_Subsidiaries__c; returnValue.companyChanged = true; }
        if(req.Principle_Name__c != acct.Principle_Name1__c ) { acct.Principle_Name1__c = req.Principle_Name__c; returnValue.companyChanged = true; }
        if(req.Principle_Title__c != acct.Principle_Title1__c ) { acct.Principle_Title1__c = req.Principle_Title__c; returnValue.companyChanged = true; }
        if(req.Secondary_Customer__c != acct.Secondary_Customer_Segment__c ) { acct.Secondary_Customer_Segment__c = req.Secondary_Customer__c; returnValue.companyChanged = true; }
        if(req.Primary_Vertical_Market_Segment__c != acct.Primary_Vertical_Market_Segment__c ) { acct.Primary_Vertical_Market_Segment__c = req.Primary_Vertical_Market_Segment__c; returnValue.companyChanged = true; }
        if(req.Secondary_Vertical_Market_Segment__c != acct.Secondary_Vertical_Market_Segment__c ) { acct.Secondary_Vertical_Market_Segment__c = req.Secondary_Vertical_Market_Segment__c; returnValue.companyChanged = true; }
        if(req.Top_3_Vendors__c != acct.Top_3_Vendors__c ) { acct.Top_3_Vendors__c = req.Top_3_Vendors__c; returnValue.companyChanged = true; }
        if(req.Organization_Industry_Certificate__c != acct.Organization_Industry_Certificate__c ) { acct.Organization_Industry_Certificate__c = req.Organization_Industry_Certificate__c; returnValue.companyChanged = true; }
        if(req.Size_of_Customer_Base__c != acct.Size_of_Customer_Base__c ) { acct.Size_of_Customer_Base__c = req.Size_of_Customer_Base__c; returnValue.companyChanged = true; }
        if(req.Managed_Service_Provider__c != acct.Managed_Service_Provider__c ) { acct.Managed_Service_Provider__c = req.Managed_Service_Provider__c; returnValue.companyChanged = true; }
        if(req.Hardware_Reseller__c != acct.Hardware_Reseller__c ) { acct.Hardware_Reseller__c = req.Hardware_Reseller__c; returnValue.companyChanged = true; }
        if(req.Solution_Oriented_Reseller__c != acct.Solution_Oriented_Reseller__c ) { acct.Solution_Oriented_Reseller__c = req.Solution_Oriented_Reseller__c; returnValue.companyChanged = true; }
        if(req.Boutique_Firm__c != acct.Boutique_Firm__c ) { acct.Boutique_Firm__c = req.Boutique_Firm__c; returnValue.companyChanged = true; }
        if(req.Large_Enterprise__c != acct.Large_Enterprise__c ) { acct.Large_Enterprise__c = req.Large_Enterprise__c; returnValue.companyChanged = true; }
        if(req.Traditional_Reseller__c != acct.Traditional_Reseller__c ) { acct.Traditional_Reseller__c = req.Traditional_Reseller__c; returnValue.companyChanged = true; }
        if(req.Value_Added_Reseller__c != acct.Value_Added_Reseller__c ) { acct.Value_Added_Reseller__c = req.Value_Added_Reseller__c; returnValue.companyChanged = true; }
        if(req.Retailer__c != acct.Retailer__c ) { acct.Retailer__c = req.Retailer__c; returnValue.companyChanged = true; }
        if(req.Telco__c != acct.Telco__c ) { acct.Telco__c = req.Telco__c; returnValue.companyChanged = true; }
        if(req.eTailer__c != acct.eTailer__c ) { acct.eTailer__c = req.eTailer__c; returnValue.companyChanged = true; }
        if(req.Other__c != acct.Other__c ) { acct.Other__c = req.Other__c; returnValue.companyChanged = true; }
        if(req.ISV__c != acct.ISV__c ) { acct.ISV__c = req.ISV__c; returnValue.companyChanged = true; }
        if(req.System_Integrator__c != acct.System_Integrator__c ) { acct.System_Integrator__c = req.System_Integrator__c; returnValue.companyChanged = true; }
        if(req.OEM__c != acct.OEM__c ) { acct.OEM__c = req.OEM__c; returnValue.companyChanged = true; }
        if(req.Software_Reseller__c != acct.Software_Reseller__c ) { acct.Software_Reseller__c = req.Software_Reseller__c; returnValue.companyChanged = true; }
        if(req.Referral_Partner__c != acct.Referral_Partner__c ) { acct.Referral_Partner__c = req.Referral_Partner__c; returnValue.companyChanged = true; }
        if(req.Distributor__c != acct.Distributor__c ) { acct.Distributor__c = req.Distributor__c; returnValue.companyChanged = true; }
        if(req.Technology_Partner__c != acct.Technology_Partner__c ) { acct.Technology_Partner__c = req.Technology_Partner__c; returnValue.companyChanged = true; }
        
        // Added by mohd for 16.03 PP  Software_Technical_Support__c, Mode_Of_Service__c
        if(req.Service_Type__c != acct.Service_Type__c ){ acct.Service_Type__c = req.Service_Type__c; returnValue.companyChanged = true; }
        if(req.Service_Capability__c != acct.Service_Capability__c ){ acct.Service_Capability__c = req.Service_Capability__c; returnValue.companyChanged = true; }
        if(req.Software_Technical_Support__c!= acct.Software_Technical_Support__c ){ acct.Software_Technical_Support__c = req.Software_Technical_Support__c; returnValue.companyChanged = true; }
        if(req.Mode_Of_Service__c != acct.Mode_Of_Service__c ){ acct.Mode_Of_Service__c = req.Mode_Of_Service__c; returnValue.companyChanged = true; }
        if(req.Hardware_warranty_Break_fix_support__c != acct.Hardware_warranty_Break_fix_support__c ){ acct.Hardware_warranty_Break_fix_support__c = req.Hardware_warranty_Break_fix_support__c; returnValue.companyChanged = true; }
        if(req.Installation_Deployment_Services__c!= acct.Installation_Deployment_Services__c ){ acct.Installation_Deployment_Services__c = req.Installation_Deployment_Services__c; returnValue.companyChanged = true; }
        if(req.Installation_Deployment_Services_Market__c != acct.Installation_Deployment_Services_Market__c ){ acct.Installation_Deployment_Services_Market__c = req.Installation_Deployment_Services_Market__c; returnValue.companyChanged = true; }
        if(req.Custom_Configuration_Imaging__c != acct.Custom_Configuration_Imaging__c ){ acct.Custom_Configuration_Imaging__c = req.Custom_Configuration_Imaging__c; returnValue.companyChanged = true; }
        if(req.Data_Migration__c != acct.Data_Migration__c ){ acct.Data_Migration__c = req.Data_Migration__c; returnValue.companyChanged = true; }
        if(req.Asset_recovery_resale_recycling__c != acct.Asset_recovery_resale_recycling__c ){ acct.Asset_recovery_resale_recycling__c = req.Asset_recovery_resale_recycling__c; returnValue.companyChanged = true; }
        if(req.Consulting__c != acct.Consulting__c ){ acct.Consulting__c = req.Consulting__c; returnValue.companyChanged = true; }
        if(req.Consulting_Market__c != acct.Consulting_Market__c ){ acct.Consulting_Market__c = req.Consulting_Market__c; returnValue.companyChanged = true; }
        if(req.Education_Training__c!= acct.Education_Training__c ){ acct.Education_Training__c = req.Education_Training__c; returnValue.companyChanged = true; }
        if(req.Managed_Deployment__c != acct.Managed_Deployment__c ){ acct.Managed_Deployment__c = req.Managed_Deployment__c; returnValue.companyChanged = true; }
        if(req.Custom_enterprise_data_center_services__c != acct.Custom_enterprise_data_center_services__c ){ acct.Custom_enterprise_data_center_services__c = req.Custom_enterprise_data_center_services__c; returnValue.companyChanged = true; }
        if(req.Dell_Service_Tools_Used__c != acct.Dell_Service_Tools_Used__c ){ acct.Dell_Service_Tools_Used__c = req.Dell_Service_Tools_Used__c; returnValue.companyChanged = true; }
        
        if(!returnValue.companyChanged) {
            System.debug('## Checking the States_Provinces_doing_business__c value change');
            Boolean noChange = ListUtils.containsSameElements(StringUtils.defaultString(req.States_Provinces_doing_business__c).split(';', -1), StringUtils.defaultString(acct.States_Provinces_doing_business__c).split(';', -1));
            if(!noChange) {         
                returnValue.companyChanged = true;                                                              
            }
            System.debug('PR:' + req.States_Provinces_doing_business__c + ' Ac:' + acct.States_Provinces_doing_business__c + '::' + noChange);
            // Just ensures the account has latest value.
            acct.States_Provinces_doing_business__c = req.States_Provinces_doing_business__c;           
        }
        
        return returnValue;
    }   
    
    public PageReference doReload() {
        return null;
    }

    public PageReference doNewUser() {
        map<String, String> params = new map<String, String>();
        params.put('retURL', Page.PartnerSelfServiceMyCompany.getUrl());
        params.put('cancelURL', Page.PartnerSelfServiceMyCompany.getUrl());
        params.put('newFlag', 'true');
        return standardRedirect(Page.PartnerSelfServiceMyProfile, params);
        //return PageUtils.redirect(Page.PartnerSelfServiceMyProfile.getUrl() + '?' + getReturnAndCancelURLs() + '&newFlag=true');
    }
    
    public PageReference doEditUser() {
        map<String, String> params = new map<String, String>();
        params.put('retURL', Page.PartnerSelfServiceMyCompany.getUrl());
        params.put('cancelURL', Page.PartnerSelfServiceMyCompany.getUrl());
        params.put('userId', PageUtils.param(HTTP_PARAMETER_USERID));
        return standardRedirect(Page.PartnerSelfServiceMyProfile, params);
        //return PageUtils.redirect(Page.PartnerSelfServiceMyProfile.getUrl() + '?' + getReturnAndCancelURLs() + '&userId=' + PageUtils.param(HTTP_PARAMETER_USERID));
    }
    
    public PageReference doInactivateUser() {
        String userId = PageUtils.param(HTTP_PARAMETER_USERID);
        list<User> lstUsers = [select Id, Name, IsActive, ContactId, Contact.AccountId, Contact.Account.Account_Country_Code__c from User where Id = :userId];
        if(!lstUsers.isEmpty()) {
            confirmInactivateUser = lstUsers.get(0);
        }
        return null;
    }
    public PageReference exportAsExcel() {
        return new PageReference('/apex/generateActiveInactiveContact');
        
    }
    
    // Raymond 20100224 - Added for CR2420. This is now the "second" step to inactivate a user.
    // After the user clicks the OK button to confirm inactivation, the method createInactivateUserPartnerRequest()
    // will create a PR and assign to inactivationRequest. Refer to Page for more info.
    public PageReference doConfirmInactivateUser() {
        try{
            // Raymond 20100224 - Added for CR2420. Set to true so that afterInactivatedUser.trigger will not create PR
            GlobalVariables.BYPASS_REMOVE_USER_RERQUEST_CREATION = true; 
            
            // Raymond 20100224 - Added for CR2420. Set to true so that contact trigger will not sync to CMI
            GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = true;
                                 
            confirmInactivateUser.IsActive = false;   
            update confirmInactivateUser;
            
            // Raymond 20100224 - Added for CR2420.Synchronize to CMI
            if(inactivationRequest != null) {
                synchronizeToCMI(confirmInactivateUser.Id, inactivationRequest.Id);
            }
              
        }
        catch(Exception e) { 
            ApexPages.addMessages(e);
        }
        
        confirmInactivateUser = null;
        return null;
    }
    
    public PageReference doCancelInactivateUser() {
        confirmInactivateUser = null;
        return null;
    }
    
    /*
    private String getReturnAndCancelURLs() {
        return 'retURL=' + Page.PartnerSelfServiceMyCompany.getUrl() + '&cancelURL=' + Page.PartnerSelfServiceMyCompany.getUrl();
    }
    */  
    
    // Raymond 20100224 - Added for CR2420. OK Button from Confirm Inactivation page will call this method first
    public PageReference createInactivateUserPartnerRequest() {
        try {
            final Id REMOVE_USER_RECORD_TYPE = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_REMOVE_USER, 'Partner_Request__c', true);
                           
            list<Country__c> queueIdList = [SELECT Code__c, Partner_Support_Queue_ID__c FROM Country__c WHERE Code__c = :confirmInactivateUser.Contact.Account.Account_Country_Code__c];
                    
            Partner_Request__c request = new Partner_Request__c();
            request.Account__c = confirmInactivateUser.Contact.AccountId;
            request.Contact__c = confirmInactivateUser.ContactId;
            request.RecordTypeId = REMOVE_USER_RECORD_TYPE;
            request.Status__c = PartnerConstants.REG_STATUS_DRAFT;
            if(queueIdList.size() > 0) {
                request.OwnerId = queueIdList[0].Partner_Support_Queue_ID__c; 
            }
            insert request;

            System.debug('##requestid:' + request.Id);
            inactivationRequest = request;
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
        }  
        return null;
    }
    
    // Added by Vikas
    private String returnFieldSetMembers(list<Schema.FieldSetMember> fieldSetMembersList)
    {
        String query = 'select Id, ';
        for(Schema.FieldSetMember f : fieldSetMembersList) {
            query += f.getFieldPath() + ', ';
        }
        return query.subString(0, query.lastIndexOf(','));
    }
        
    // Raymond 20100224 - Added for CR2420. This method will synchronize to CMI and update PR with status
    @future(callout=true)
    public static void synchronizeToCMI(String userId, String requestId) {
        String errorMsg = '';
        
        User targetUser = [SELECT Id, ContactId, IsActive, Contact.Partner_My_Account_GUID__c FROM User WHERE Id = :userId];
        
        Partner_Request__c request = [SELECT Id, Status__c, Description__c FROM Partner_Request__c WHERE Id = :requestId];     
        
        if(targetUser != null && targetUser.isActive) {
            return;
        }
           
        try {
            //Partner_Request__c inactivateRequest = createInactivateUserPartnerRequest(confirmInactivateUser); 
            //request = [SELECT Id, Status__c, Description__c FROM Partner_Request__c WHERE Id = :requestId];

            String response = PartnerProfileIntegration.integratePartnerDataWithResponse(targetUser.contactId);
            // [Krishna 10-May-2010]Updated to handle Nullpointer exception
            response = StringUtils.defaultString(response);
            if(response.contains(GlobalVariables.CMI_RESPONSE_SUCCESSFUL)) {
                // 14.2 SSO Update
                //request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;
            }
            else {
                request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;             
                errorMsg = 'Integration with CMI falied. Please contact your System Administrator.';
            }
        }
        catch(Exception e) {
            request.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
            errorMsg = 'Integration with CMI falied.';         
        }
        
        try {
            if(errorMsg != '' && request.status__c == PartnerConstants.REG_STATUS_INCOMPLETE) {
                if(request.Description__c == '') {
                    request.Description__c = errorMsg;
                }
                else {
                    request.Description__c += '\n' + errorMsg;  
                }               
            }
            
            update request;
        }
        catch(Exception e) {
            System.debug('##Caught APEX exception ' + e.getMessage());
            emailUtils.sendSupportEmail('PartnerSelfServiceAutoUpdateUserError: while updating Partner Request ' + request.Id + ': ' + e.getMessage(), dellConfig.errorEmail);   
        }
    }
    
    
    /*
     * Pagination Related Methods for Contacts
     */
    // Changes Made by Virkam Kamboj on 05/10/2012 for CR7631
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                size = PageSize;
                // v4.0 - Used Contact.AccountId in below SOQL instead of specifying all Contact Ids
                /*
                String idVals;
                // Added by aman sharma (if condition)
                if(company != null) {
                    if(company.contacts != null) {
                        idVals = createString(company.Contacts);
                    }
                }
                */
                if(company != null) {
                    String queryString = 'select Title, Name, LastName, Id, FirstName, Email, LastModifiedDate, CreatedDate, Contact.Title, Contact.Email, Contact.Name, Contact.FirstName, Contact.LastName, Contact.Primary_Contact__c, ContactId, UserRole.Name from User where ContactId != null and Contact.AccountId = \'' + company.Id + '\' and IsActive = true order by ' + sortFullExp + ' limit 10000';
                    //String queryString = 'select Title, Name, LastName, Id, FirstName, Email, LastModifiedDate, CreatedDate, Contact.Title, Contact.Email, Contact.Name, Contact.FirstName, Contact.LastName, Contact.Primary_Contact__c, ContactId, UserRole.Name from User where ContactId in (' + idVals + ') and ContactId != null and IsActive = true order by ' + sortFullExp + ' limit 10000';
                    //String queryString = 'select Title, Name, LastName, Id, FirstName, Email, Contact.Title, Contact.Email, Contact.Name, Contact.FirstName, Contact.LastName, ContactId,UserRole.Name from User order by '+sortFullExp+' Limit 10000 ';
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    setCon.setPageSize(size);
                    noOfRecords = setCon.getResultSize();
                }
                else {
                    setCon = new ApexPages.StandardSetController(new list<User>());
                }
            }
            return setCon;
        }
        set;
    }
    // v4.0 - createString() method no longer used
    /*
    private String createString(list<Contact> lstContacts) {
        String strIds = '';
        // Convert to IN clause for SOQL
        for(Contact contactIterator : lstContacts) {
            strIds = strIds + ',\'' + contactIterator.id + '\'';
        }
        strIds = strIds.subString(1);
        return strIds;
    }
    */
    public list<User> getUsers() {
        list<User> lstUsers = new list<User>();
        for(User userIterator : (list<User>)setCon.getRecords()) {
            lstUsers.add(userIterator);
        }
        return lstUsers;
    }
    public list<SelectOption> getItems() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('20', '20'));
        options.add(new SelectOption('50', '50'));
        options.add(new SelectOption('100', '100'));
        options.add(new SelectOption('200', '200'));

        return options;
    }
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    public void next() {
        setCon.next();
    }
    public void previous() {
        setCon.previous();
    }
    public void first() {
        setCon.save(); 
        setCon.first();
    }
    public void last() {
        setCon.save(); 
        setCon.last();
    }
    public pageReference changeSize() {
        setCon = null;               
        getUsers();
        setCon.setPageNumber(1);
        return null;
    }
    
    
    /*
     * Logics for Sorting
     */
    public String sortExpression {
        get {
            return sortExp;
        }
        set {
            // If the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp) {
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            }
            else {
                sortDirection = 'ASC';
            }
            sortExp = value;
        }
    }
    public String getSortDirection() {
        // If not column is selected
        if(sortExpression == null || sortExpression == '') {
            return 'ASC';
        }
        else {
            return sortDirection;
        }
    }
    public void setSortDirection(String value) {  
        sortDirection = value;
    }
    public PageReference ViewData() {
        // Build the full sort expression
        sortFullExp = sortExpression  + ' ' + sortDirection;
        // Query the database based on the sort expression
        setCon = null;
        getUsers();
        return null;
    }
    
}