/*
REVISION HISTORY
================
Version     Author        Date            Release#    CR#     Description
-------     ------        ----            --------    ---     -----------
1.0                                                           Initial draft
2.0      Krishnamoorthi  07-Dec-2012        14.2      7678    R14.2 Maintenance - PRM - Website auto-populated from Partner Request to Account
3.0      Shahiruni       02-May-2013                  8248    Limit and remove unused fields from the query to decrease the data size.
*/

public class PartnerRegistrationDupSearchCtrlExt {

    public String searchString {get; set;}
    public String searchBy {get; set;}
    public Integer accountCount;
    public String  accountCountStr {get;set;}
 
    public Integer getAccountSearchResultsCount(){ if(accountSearchResults==null){ return 0; } else { return accountCount; } }
    
    public List<Account> accountSearchResults {get;set;}
    public Boolean getIsAccountSelected(){ return request.Duplicate_Account__c != null; }
    
    public Integer getRegistrationSearchResultsCount(){ if(registrationSearchResults==null){ return 0; } else { return registrationSearchResults.size(); } }
    public List<Partner_Request__c> registrationSearchResults {get;set;}
    public Boolean getIsRegistrationSelected(){ return request.Duplicate_Registration__c != null; }
    
    public string manualAccountValid{get;set;}
    
    public Boolean getIsManualAccountSelected(){ return !StringUtils.isBlank(manualAccountValid) ; }

    public String selectionName {get;set;}
    public  String confirmlinkaccountId{get;set;}
    public  String confirmlinkaccountPRId{get;set;} 
    
    public SObjectPaginator acctPaginator {get;set;}
    public List<Account> accounts {get;set;}
    
    public SObjectPaginator prPaginator {get;set;}
    public List<Partner_Request__c> pr_accounts {get;set;}
    
    public Partner_Request__c request {get;set;}
    
      

    public PartnerRegistrationDupSearchCtrlExt(ApexPages.StandardController c){
        request = (Partner_Request__c) c.getRecord();
        if(request == null || request.id == null){
            PageUtils.addError('You have reached this screen in error.');
            return;
        }
        
        request = 
            [select id, email__c, account__c, company__c, name,RecordType.Name, Org_Phone__c, Duplicate_Account__c, Duplicate_Registration__c
            from Partner_Request__c 
            where id = :request.id limit 1];
        request.Duplicate_Account__c = null;
        request.Duplicate_Registration__c = null;
        
    }
    

    public PageReference doPageLoad(){
        if(request == null || request.id == null){
            return null;
        }
        searchString = request.company__c;
        if(searchString != null){
            searchString = searchString.endsWith('%') ? searchString : searchString + '%';
            searchString = searchString.startsWith('%') ? searchString : '%' + searchString ;
        }
        //searchString += ' or ';
        //searchString += request.Email__c;
        return doSearch();  
    }
           
    public List<SelectOption> getSearchByList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('CompanyName', 'Company Name'));
        options.add(new SelectOption('Email', 'Email'));
        options.add(new SelectOption('AccountID', 'Account ID'));
        options.add(new SelectOption('Domain', 'Domain'));
        options.add(new SelectOption('Phone', 'Phone'));
        options.add(new SelectOption('Address', 'Address'));
        options.add(new SelectOption('Duns', 'Duns'));
        options.add(new SelectOption('Tax ID', 'Tax ID'));
        return options;
    }
    
    //every search will refresh the Paginator object 
    public PageReference doSearch(){
        request.Check_For_Duplicates_Is_Complete_Flag__c = true;
        
        try{
            update request;
        }catch(Exception e){
            ApexPages.addMessages(e);   
        }
        accountSearchResults = null;
        registrationSearchResults = null;
        System.debug('searchString = [' + searchString + ']');
        try{
            /*
            List<List<SObject>> searchList = [
                FIND :searchString IN ALL FIELDS RETURNING 
                Account (
                    id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,
                    ShippingPostalCode,ShippingCountry,Owner.Name,Owner.Id,recordtype.name, Partner_registration__r.name, Partner_registration__r.id
                    ORDER BY name
                )
                ,Partner_Request__c(
                    id,name,Company__c,email__c,first_name__c, last_name__c, status__c, createddate, Account__r.Id, Account__r.Name
                    WHERE id != :request.id and recordtype.name = 'New Partner'
                )
                ];
                
                
            accountSearchResults = ((List<Account>)searchList[0]);
            registrationSearchResults = ((List<Partner_Request__c>)searchList[1]);
            */
            
            //CR : 16551 & CR : 16552
            // Changes to the PR Processing Duplicate check  - Filter Criteria change 
             if (searchBy == 'Email') {
                 accountSearchResults =  [SELECT id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Website,Phone,Reseller_Tax_ID__c,D_U_N_S__c,Billing_Address_CN__c,
                                                ShippingPostalCode,ShippingCountry,Owner.Name,Owner.Id,recordtype.name, Partner_registration__r.name, Partner_registration__r.id
                                         FROM   Account 
                                         WHERE  id IN (SELECT AccountId FROM Contact WHERE Email = :searchString) and Partner_registration__r.id != :request.Id 
                                         and Master_Group_Id__c != null and Partner_Track__c != null
                                         ORDER  BY name limit 1000];
                                     
              registrationSearchResults = [SELECT id,name,Company__c,email__c,first_name__c, last_name__c, status__c,Org_Phone__c, Reseller_Tax_ID__c, Website__c, Org_Address_1__c,Org_Address_2__c ,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Country__c,Org_Country__r.Name,ISDUNSUpdated__c, createddate, Account__r.Id, Account__r.Name
                                         FROM   Partner_Request__c
                                         WHERE email__c = :searchString and recordtype.name = 'New Partner' and id != :request.Id
                                         ORDER BY email__c limit 1000]; 
            }
            else if (searchBy == 'AccountID') {
                 accountSearchResults =  [SELECT id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Website,Phone,Reseller_Tax_ID__c,D_U_N_S__c,Billing_Address_CN__c,
                                                ShippingPostalCode,ShippingCountry,Owner.Name,Owner.Id,recordtype.name, Partner_registration__r.name, Partner_registration__r.id
                                         FROM   Account 
                                         WHERE  Account_ID__c = :searchString and Partner_registration__r.id != :request.Id   
                                         and Master_Group_Id__c != null and Partner_Track__c != null
                                         ORDER  BY name limit 1000];
                                     
              registrationSearchResults = [SELECT id,name,Company__c,email__c,first_name__c, last_name__c, status__c,Org_Phone__c, Reseller_Tax_ID__c, Website__c, Org_Address_1__c,Org_Address_2__c ,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Country__c,Org_Country__r.Name,ISDUNSUpdated__c, createddate, Account__r.Id, Account__r.Name
                                         FROM   Partner_Request__c 
                                         WHERE Account__r.Account_ID__c = :searchString and recordtype.name = 'New Partner' and id != :request.Id
                                         ORDER BY Company__c limit 1000]; 
            }
            else if (searchBy == 'Phone') {
            accountSearchResults =  [SELECT id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Website,Phone,Reseller_Tax_ID__c,D_U_N_S__c,Billing_Address_CN__c,
                                                ShippingPostalCode,ShippingCountry,Owner.Name,Owner.Id,recordtype.name, Partner_registration__r.name, Partner_registration__r.id
                                         FROM   Account 
                                         WHERE  Phone = :searchString and Partner_registration__r.id != :request.Id and recordtype.name = 'Partner Account'
                                         and Master_Group_Id__c != null and Partner_Track__c != null
                                         ORDER  BY name limit 1000];
                                         
                 registrationSearchResults = [SELECT id,name,Company__c,email__c,first_name__c, last_name__c, status__c, Org_Phone__c, Reseller_Tax_ID__c, Website__c, Org_Address_1__c,Org_Address_2__c ,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Country__c,Org_Country__r.Name,ISDUNSUpdated__c, createddate, Account__r.Id, Account__r.Name
                                         FROM   Partner_Request__c 
                                         WHERE Org_Phone__c = :searchString and recordtype.name = 'New Partner' and id != :request.Id
                                        ORDER BY Company__c limit 1000]; 
            } 
             else if (searchBy == 'Tax ID') {
            //String TaxSearch = '%'+searchString+'%';
             String strappendSearch = searchString;
                   strappendSearch = strappendSearch.endsWith('%') ? strappendSearch : strappendSearch + '%';
                   strappendSearch = strappendSearch.startsWith('%') ? strappendSearch : '%' + strappendSearch;
                   
            accountSearchResults =  [SELECT id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Website,Phone,Reseller_Tax_ID__c,D_U_N_S__c,Billing_Address_CN__c,
                                                ShippingPostalCode,ShippingCountry,Owner.Name,Owner.Id,recordtype.name, Partner_registration__r.name, Partner_registration__r.id
                                         FROM   Account 
                                         WHERE  Reseller_Tax_ID__c Like :searchString  and Partner_registration__r.id != :request.Id and recordtype.name = 'Partner Account'
                                         and Master_Group_Id__c != null and Partner_Track__c != null
                                         ORDER  BY name limit 1000];
                                         
                 registrationSearchResults = [SELECT id,name,Company__c,email__c,first_name__c, last_name__c, status__c, Org_Phone__c, Reseller_Tax_ID__c, Website__c, Org_Address_1__c,Org_Address_2__c ,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Country__c,Org_Country__r.Name,ISDUNSUpdated__c, createddate, Account__r.Id, Account__r.Name
                                         FROM   Partner_Request__c 
                                         WHERE Reseller_Tax_ID__c Like :searchString and recordtype.name = 'New Partner' and id != :request.Id
                                        ORDER BY Company__c limit 1000]; 
            } 
            else if (searchBy == 'Domain') {
            // String DomainSearch = '%'+searchString+'%';
             String strappendSearch = searchString;
                   strappendSearch = strappendSearch.endsWith('%') ? strappendSearch : strappendSearch + '%';
                   strappendSearch = strappendSearch.startsWith('%') ? strappendSearch : '%' + strappendSearch;
            
            accountSearchResults =  [SELECT id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Website,Phone,Reseller_Tax_ID__c,D_U_N_S__c,Billing_Address_CN__c,
                                                ShippingPostalCode,ShippingCountry,Owner.Name,Owner.Id,recordtype.name,Partner_registration__r.name, Partner_registration__r.id
                                         FROM   Account 
                                         WHERE  Website Like :searchString and Partner_registration__r.id != :request.Id and recordtype.name = 'Partner Account'
                                         and Master_Group_Id__c != null and Partner_Track__c != null
                                         ORDER  BY name limit 1000]; 
                                         
                 registrationSearchResults = [SELECT id,name,Company__c,email__c,first_name__c, last_name__c, status__c, Org_Phone__c, Reseller_Tax_ID__c, Website__c, Org_Address_1__c,Org_Address_2__c ,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Country__c,Org_Country__r.Name,ISDUNSUpdated__c, createddate, Account__r.Id, Account__r.Name
                                         FROM   Partner_Request__c 
                                         WHERE Website__c Like :searchString and recordtype.name = 'New Partner' and id != :request.Id
                                        ORDER BY Company__c limit 1000]; 
            } 
            else if (searchBy == 'Address') {
            string[] partnersearch= searchString.split(',');
            if(partnersearch.size() > 1){
                for(integer i=0;i<partnersearch.size();i++){
                    partnersearch[i] ='%'+partnersearch[i]+'%';
                }
        }else{
            partnersearch[0]='%'+searchString+'%'; 
        } 
            accountSearchResults =  [SELECT id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Website,Phone,Reseller_Tax_ID__c,D_U_N_S__c,Billing_Address_CN__c,
                                                ShippingPostalCode,ShippingCountry,Owner.Name,Owner.Id,recordtype.name, Partner_registration__r.name, Partner_registration__r.id
                                         FROM   Account 
                                         WHERE  Billing_Address_CN__c LIKE :partnersearch and Partner_registration__r.id != :request.Id and recordtype.name = 'Partner Account'
                                         and Master_Group_Id__c != null and Partner_Track__c != null    
                                         ORDER  BY name limit 1000];
                 registrationSearchResults = [SELECT id,name,Company__c,email__c,first_name__c, last_name__c, status__c, Org_Phone__c, Reseller_Tax_ID__c, Website__c, Org_Address_1__c,Org_Address_2__c ,
                              Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Country__c,Org_Country__r.Name,ISDUNSUpdated__c, createddate, Account__r.Id, Account__r.Name
                                         FROM   Partner_Request__c 
                                         WHERE (Org_Address_1__c LIKE :partnersearch OR Org_Address_2__c LIKE :partnersearch OR Org_Address_3__c LIKE :partnersearch OR Org_City__c LIKE :partnersearch OR Org_State__c 
                                         LIKE :partnersearch OR Org_Postal_Code__c LIKE :partnersearch OR Org_Country__r.Name LIKE :partnersearch) and recordtype.name = 'New Partner' and id != :request.Id
                                        ORDER BY Company__c limit 1000]; 
                       System.debug('registrationSearchResults >>'+registrationSearchResults );
            }
              else if (searchBy == 'Duns') {
             
             String strdunsSearch = searchString;
            accountSearchResults =  [SELECT id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Website,Phone,Reseller_Tax_ID__c,D_U_N_S__c,Billing_Address_CN__c,
                                                ShippingPostalCode,ShippingCountry,Owner.Name,Owner.Id,recordtype.name, Partner_registration__r.name, Partner_registration__r.id
                                         FROM   Account 
                                         WHERE  D_U_N_S__c Like :strdunsSearch  and Partner_registration__r.id != :request.Id and recordtype.name = 'Partner Account'
                                         and Master_Group_Id__c != null and Partner_Track__c != null
                                         ORDER  BY name limit 1000]; 
                                         
                 registrationSearchResults = [SELECT id,name,Company__c,email__c,first_name__c, last_name__c, status__c, Org_Phone__c, Reseller_Tax_ID__c, Website__c, Org_Address_1__c,Org_Address_2__c ,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Country__c,Org_Country__r.Name,ISDUNSUpdated__c, createddate, Account__r.Id, Account__r.Name
                                         FROM   Partner_Request__c 
                                         WHERE ISDUNSUpdated__c Like :strdunsSearch and recordtype.name = 'New Partner' and id != :request.Id
                                        ORDER BY Company__c limit 1000]; 
            } 
            else {
            
            String appendSearchString = searchString;
                   appendSearchString = appendSearchString.endsWith('%') ? appendSearchString : appendSearchString + '%';
                   appendSearchString = appendSearchString.startsWith('%') ? appendSearchString : '%' + appendSearchString ;
            
            
            System.debug('appendSearchString>>'+appendSearchString);
            
            // 3.0 start 
            /*
            accountSearchResults =      [SELECT id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,
                                                ShippingPostalCode,ShippingCountry,Owner.Name,Owner.Id,recordtype.name, Partner_registration__r.name, Partner_registration__r.id
                                         FROM   Account 
                                         WHERE  name like :appendSearchString and Partner_registration__r.id != :request.Id    
                                         ORDER  BY name limit 1000];
            */
            accountSearchResults =      [SELECT id,IsPartner,name,Owner.Name, Owner.Id,recordtype.name,Website,Phone,Reseller_Tax_ID__c,D_U_N_S__c,Billing_Address_CN__c, Partner_registration__r.name, Partner_registration__r.id
                                         FROM   Account 
                                         WHERE  name like :appendSearchString and Partner_registration__r.id != :request.Id and recordtype.name = 'Partner Account' 
                                         and Master_Group_Id__c != null and Partner_Track__c != null
                                         ORDER  BY name limit 1000];
            // 3.0 end 
                                                                             
            
            registrationSearchResults = [SELECT id,name,Company__c,email__c,first_name__c, last_name__c, status__c, Org_Phone__c, Reseller_Tax_ID__c, Website__c, Org_Address_1__c,Org_Address_2__c ,Org_Address_3__c,Org_City__c,Org_State__c,Org_Postal_Code__c,Org_Country__c,Org_Country__r.Name,ISDUNSUpdated__c, createddate, Account__r.Id, Account__r.Name
                                         FROM   Partner_Request__c 
                                         WHERE company__c like :appendSearchString and recordtype.name = 'New Partner' and id != :request.Id
                                         ORDER BY company__c limit 1000];
                                         
            accountCount = [SELECT count() FROM Account WHERE name like :appendSearchString limit 1001];
            accountCountStr = String.valueOf(accountCount);
                                
            System.debug('accountCount>>'+accountCount);
            
            }
            
            System.debug('size of accountSearchResults>>'+accountSearchResults.size());
            System.debug('size of registrationSearchResults>>'+registrationSearchResults.size());
            
            PartnerRegistrationDupSearchPageCtrlExt PaginatorCtrl = new PartnerRegistrationDupSearchPageCtrlExt();         
            
            acctPaginator = PaginatorCtrl.getAccountPaginator(accountSearchResults);
            accounts = PaginatorCtrl.accounts;
            
            prPaginator = PaginatorCtrl.getPartnerPaginator(registrationSearchResults);
            pr_accounts = PaginatorCtrl.partnerReqs;
            
        }catch(QueryException e){
            PageUtils.addError('Too many records match the specified search criteria. Please refine your search criteria and try again');
            return null;
        }catch(Exception e1){
            ApexPages.addMessages(e1);
            return null;
        }        

        if (accountSearchResults.size() == 0 && registrationSearchResults.size() == 0){
            PageUtils.addError('The specified search criteria did not match any existing records.');
        }
        return null;
    }

    public PageReference doSelectAccount(){
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        System.debug('account id >> ' +accountId);
        if(StringUtils.isBlank(accountId)){
            request.Duplicate_Account__c = null;
            request.Duplicate_Registration__c = null;
            return null;
        }
        List<Account> records = [select id,name,Partner_Registration__c from Account where id = :accountId];
        if(records.isEmpty()){
            request.Duplicate_Account__c = null;
            request.Duplicate_Registration__c = null;
            return null;
        }    
        request.Duplicate_Account__c = records.get(0).id;
        request.Duplicate_Registration__c = records.get(0).Partner_Registration__c;
        selectionName = records.get(0).name;
        return null;        
    }
    
    public PageReference doSelectRegistration(){
        String registrationId = ApexPages.currentPage().getParameters().get('registrationId');
        if(StringUtils.isBlank(registrationId)){
            request.Duplicate_Account__c = null;
            request.Duplicate_Registration__c = null;
            return null;
        }
        List<Partner_Request__c> records = [
            select id,name,Account__r.id,Account__r.name 
            from Partner_Request__c where id = :registrationId];
        if(records.isEmpty()){
            request.Duplicate_Account__c = null;
            request.Duplicate_Registration__c = null;
            return null;
        }    
        if(records.get(0).Account__r == null){
            request.Duplicate_Account__c = null;
            request.Duplicate_Registration__c = records.get(0).id;
            selectionName = records.get(0).name;
        } else {
            request.Duplicate_Account__c = records.get(0).Account__r.id;
            request.Duplicate_Registration__c = records.get(0).id;
            selectionName = records.get(0).Account__r.name;
        }
        return null;        
    }
    
  
    
    //Invoke when 'Link To' button clicked and ensure it meet the criterias(isLinked Account & isValid partner request)
    public PageReference doSelectManualLink(){
        String manualAccountID = PageUtils.get('linkaccountId');
        String linkaccountPRId = PageUtils.get('linkaccountPRId');        
        
              
        System.debug('manualAccountID >> ' +manualAccountID);
        System.debug('linkaccountPRId >>' + linkaccountPRId);
        try{                
                if(isLinkedAccount(manualAccountID) && isPartnerRequestValid(linkaccountPRId)){
                    manualAccountValid      = 'validLinkAccount';   
                    confirmlinkaccountId    =  manualAccountID;
                    confirmlinkaccountPRId  = linkaccountPRId;
                    System.debug('Show linked account valid');                
                }else{
                    if(!isLinkedAccount(manualAccountID)){PageUtils.addError('Linking account is not valid, manual account linkage is not successful');}
                    else{
                    if(!isPartnerRequestValid(linkaccountPRId)){PageUtils.addError('PR is not approved, manual account linkage is not successful');}
                    }
                }
        }catch(QueryException e){
                PageUtils.addError('Manual account linkage is not successful');
                return null;
        }catch(Exception e1){
                ApexPages.addMessages(e1);
                return null;
        }       
                   
        return null;        
    
    }
    
    public Boolean isLinkedAccount(String accountId){
        Boolean isLinkedAccountFlag = false;
        Account selectAccount = [SELECT id, name, Partner_Registration__c,Recordtype.Name  FROM Account where id = :accountId ];
        
        if(selectAccount.Recordtype.Name=='Partner Account' && selectAccount.Partner_Registration__c==null && selectAccount!=null){
            isLinkedAccountFlag = true;
            selectionName = selectAccount.name;
            System.debug('selectionName >>>'+selectionName );
        }
        System.debug('isLinkedAccountFlag >>' +isLinkedAccountFlag);
        return isLinkedAccountFlag;
    }
    
    public Boolean isPartnerRequestValid(String pr_accountId){
        Boolean isValidLinkedAccountFlag = false;
        //CR3480 :Need to enable Accounts to be linked to "Approved" and "Lead Draft" status PR
        List<Partner_Request__c> retAccountCount = [SELECT id from Partner_Request__c WHERE status__c in ('Approved') AND name = :pr_accountId limit 1];
        
        if(!retAccountCount.isEmpty()){
            isValidLinkedAccountFlag = true;
        }
        System.debug('isValidLinkedAccountFlag >>' +isValidLinkedAccountFlag);
        return isValidLinkedAccountFlag;
    }
    
    public List<Partner_Request__C> getPartnerRequestRecord(String pr_accountId){
        List<Partner_Request__c> prObj = null;
        
        //CR 3263 :- Modified query for including PRs of record type 'Existing Partner'
        //Rev2.0 added Website field
        if(!StringUtils.isBlank(pr_accountId)){
            prObj = new List<Partner_Request__c>() ;
            prObj = 
            [SELECT    
                    id,
                    Currently_Selling_Dell__c,
                    Dell_Revenue_Percent__c,
                    Hardware_Revenue_Percent__c,
                    Other_Customers__c,
                    Percent_Sales_Force__c,
                    Percent_Technical_Professionals__c,
                    Preferred_Dell_Distribution_Partner__c,
                    Primary_Channel_Model__c,
                    Primary_Routes_to_Market__c,
                    Primary_Customer__c,
                    Product_Focus__c,
                    Reseller_Tax_ID__c,
                    Service_Revenue_Percent__c,
                    Software_Revenue_Percent__c,
                    States_Provinces_doing_business__c,
                    Account__c,
                    RecordType.Name,
                    Website__c,Service_Type__c,
                    Service_Capability__c,Mode_Of_Service__c,Hardware_warranty_Break_fix_support__c,Software_Technical_Support__c,Installation_Deployment_Services__c,
                    Installation_Deployment_Services_Market__c,Custom_Configuration_Imaging__c,Data_Migration__c,Asset_recovery_resale_recycling__c,
                    Consulting__c,Consulting_Market__c,Education_Training__c,Managed_Deployment__c,Custom_enterprise_data_center_services__c,Dell_Service_Tools_Used__c 
                FROM Partner_Request__c 
                WHERE name = :pr_accountId
                AND ( RecordType.Name ='New Partner' OR RecordType.Name ='Existing Partner')
                LIMIT 1];
        }
        
        
        
        
        
        return prObj;
    }
    
    public List<Account> getAccountRecord(String accountId){
        List<Account> acct = null;
           
            if(!StringUtils.isBlank(accountId)){
                acct = new List<Account>();   
                                     
                acct = 
                 [SELECT
                        Id,
                        Partner_Track__r.Partner_Grouping_ID__c,
                        Partner_Track__r.PPA_UCID__c,
                        Master_Group_Id__r.Partner_Master_Grouping_id__c,
                        Master_Group_Id__c,
                        Partner_Track__c,
                        Partner_Registration__c,
                        IsPartner,
                        Currently_Selling_Dell__c,
                        Dell_Revenue_Percent__c,
                        Hardware_Revenue_Percent__c,
                        Other_Customers__c,          
                        Percent_Sales_Force__c,
                        Percent_Technical_Professionals__c,     
                        Preferred_Dell_Distribution_Partner__c,   
                        Primary_Channel_Model__c,                 
                        Primary_Routes_to_Market__c,              
                        Partner_Primary_Customer__c,              
                        Product_Focus__c,                         
                        Reseller_Tax_ID__c,                       
                        Service_Revenue_Percent__c,               
                        Software_Revenue_Percent__c,              
                        States_Provinces_doing_business__c,
                        Website,Service_Type__c,
                    Service_Capability__c,Mode_Of_Service__c,Hardware_warranty_Break_fix_support__c,Software_Technical_Support__c,Installation_Deployment_Services__c,
                    Installation_Deployment_Services_Market__c,Custom_Configuration_Imaging__c,Data_Migration__c,Asset_recovery_resale_recycling__c,
                    Consulting__c,Consulting_Market__c,Education_Training__c,Managed_Deployment__c,Custom_enterprise_data_center_services__c,Dell_Service_Tools_Used__c,
                    Partner_Origin__c    //Rev2.0 added Website field
                    FROM Account
                    WHERE Id=:accountId
                    LIMIT 1];
            }
            
            
        return acct;
    }
    
    //update Account based on criteria of PR
    public void updateLinkedAccount(Account linkedAccount, Partner_Request__c selectedPR){
         try{
                    linkedAccount.Partner_Registration__c = selectedPR.id;
                    linkedAccount.IsPartner = true;
                    linkedAccount.Currently_Selling_Dell__c = selectedPR.Currently_Selling_Dell__c;
                    linkedAccount.Dell_Revenue_Percent__c = selectedPR.Dell_Revenue_Percent__c;
                    linkedAccount.Hardware_Revenue_Percent__c = selectedPR.Hardware_Revenue_Percent__c;
                    linkedAccount.Other_Customers__c = selectedPR.Other_Customers__c;
                    linkedAccount.Percent_Sales_Force__c = selectedPR.Percent_Sales_Force__c;
                    linkedAccount.Percent_Technical_Professionals__c = selectedPR.Percent_Technical_Professionals__c;
                    linkedAccount.Preferred_Dell_Distribution_Partner__c = selectedPR.Preferred_Dell_Distribution_Partner__c;
                    linkedAccount.Primary_Channel_Model__c = selectedPR.Primary_Channel_Model__c;
                    linkedAccount.Primary_Routes_to_Market__c = selectedPR.Primary_Routes_to_Market__c;
                    linkedAccount.Partner_Primary_Customer__c = selectedPR.Primary_Customer__c;
                    linkedAccount.Product_Focus__c = selectedPR.Product_Focus__c;
                    linkedAccount.Reseller_Tax_ID__c = selectedPR.Reseller_Tax_ID__c;
                    linkedAccount.Service_Revenue_Percent__c = selectedPR.Service_Revenue_Percent__c;
                    linkedAccount.Software_Revenue_Percent__c = selectedPR.Software_Revenue_Percent__c;
                    linkedAccount.States_Provinces_doing_business__c = selectedPR.States_Provinces_doing_business__c;
                    //Rev2.0 added Website field
                    if(linkedAccount.Website == null){
                        linkedAccount.Website = selectedPR.Website__c;
                    }
                    
                    linkedAccount.Service_Type__c=selectedPR.Service_Type__c;
                    linkedAccount.Service_Capability__c=selectedPR.Service_Capability__c;
                    linkedAccount.Mode_Of_Service__c=selectedPR.Mode_Of_Service__c;
                    linkedAccount.Hardware_warranty_Break_fix_support__c=selectedPR.Hardware_warranty_Break_fix_support__c;
                    linkedAccount.Software_Technical_Support__c=selectedPR.Software_Technical_Support__c;
                    linkedAccount.Installation_Deployment_Services__c=selectedPR.Installation_Deployment_Services__c;
                    linkedAccount.Installation_Deployment_Services_Market__c=selectedPR.Installation_Deployment_Services_Market__c;
                    linkedAccount.Custom_Configuration_Imaging__c=selectedPR.Custom_Configuration_Imaging__c;
                    linkedAccount.Data_Migration__c=selectedPR.Data_Migration__c;
                    linkedAccount.Asset_recovery_resale_recycling__c=selectedPR.Asset_recovery_resale_recycling__c;
                    linkedAccount.Consulting__c=selectedPR.Consulting__c;
                    linkedAccount.Consulting_Market__c=selectedPR.Consulting_Market__c;
                    linkedAccount.Education_Training__c=selectedPR.Education_Training__c;
                    linkedAccount.Managed_Deployment__c=selectedPR.Managed_Deployment__c;
                    linkedAccount.Custom_enterprise_data_center_services__c=selectedPR.Custom_enterprise_data_center_services__c;
                    linkedAccount.Dell_Service_Tools_Used__c=selectedPR.Dell_Service_Tools_Used__c;
                    linkedAccount.Partner_Origin__c='Self-Nominated';  
                    
                    System.debug('###Partner_Registration__c>>'+selectedPR.id);
                    System.debug('###Currently_Selling_Dell__c>>'+selectedPR.Currently_Selling_Dell__c);
                    System.debug('###selectedPR.Dell_Revenue_Percent__c>>'+selectedPR.Dell_Revenue_Percent__c);
                    System.debug('selectedPR.Hardware_Revenue_Percent__c>>'+selectedPR.Hardware_Revenue_Percent__c);
                    System.debug('selectedPR.Other_Customers__c>>'+selectedPR.Other_Customers__c);
                    System.debug('selectedPR.Percent_Sales_Force__c>>'+selectedPR.Percent_Sales_Force__c);
                    System.debug('selectedPR.Percent_Technical_Professionals__c>>'+selectedPR.Percent_Technical_Professionals__c);
                    System.debug('selectedPR.Preferred_Dell_Distribution_Partner__c>>'+selectedPR.Preferred_Dell_Distribution_Partner__c);
                    System.debug('selectedPR.Primary_Channel_Model__c>>'+selectedPR.Primary_Channel_Model__c);
                    System.debug('selectedPR.Primary_Routes_to_Market__c>>'+selectedPR.Primary_Routes_to_Market__c);
                    System.debug(' selectedPR.Primary_Customer__c>>'+ selectedPR.Primary_Customer__c);
                    System.debug('selectedPR.Product_Focus__c>>'+selectedPR.Product_Focus__c);
                    System.debug('selectedPR.Reseller_Tax_ID__c>>'+selectedPR.Reseller_Tax_ID__c);
                    System.debug('selectedPR.Service_Revenue_Percent__c>>'+selectedPR.Service_Revenue_Percent__c);
                    System.debug('selectedPR.Software_Revenue_Percent__c>>'+selectedPR.Software_Revenue_Percent__c);
                    System.debug('selectedPR.States_Provinces_doing_business__c>>'+selectedPR.States_Provinces_doing_business__c);
                    System.debug('selectedPR.Website__c>>'+selectedPR.Website__c); 
                    
                    
                    update linkedAccount;
                    System.debug('complete update in updateLinkedAccount...............');
         }catch(QueryException e){
                PageUtils.addError('Linking account is not valid, manual account linkage is not successful');
                
         }catch(Exception e1){
                ApexPages.addMessages(e1);
                
        }    
    }
    
    //update PR on Status, link_to_account flag, recordTypeID and linked account
    public void updateSelectedPR(Account linkedAccount, Partner_Request__c selectedPR){
         try{
             
             if(linkedAccount.Partner_Track__r.Partner_Grouping_ID__c != null && linkedAccount.Partner_Track__r.PPA_UCID__c !=null
                                       && linkedAccount.Master_Group_Id__r.Partner_Master_Grouping_id__c != null ){
                      system.debug('****AllSteps Complete');                     
                      selectedPR.Status__c = 'Account Suggestion Submitted'  ;   //'In Review';
                      selectedPR.Send_Account_Suggestion_Is_Complete_Flag__c = True;
                      selectedPR.Profile_UCID_as_Partner_Is_Complete_Flag__c = True;
                      selectedPR.Update_Profile_Is_Complete_Flag__c = True;
                      selectedPR.MUP_Profile_Creation__c = True;
                      selectedPR.EMC_Attributes_Flag__c = True;
                  }
                    /*
                      if(linkedAccount.Master_Group_Id__r.Partner_Master_Grouping_id__c != null){
                      selectedLead.Partner_Master_Grouping_id__c  = linkedAccount.Master_Group_Id__r.Partner_Master_Grouping_id__c;
                      }    
                      if(linkedAccount.Partner_Track__r.Partner_Grouping_ID__c != null){
                      selectedLead.Partner_Grouping_id__c = linkedAccount.Partner_Track__r.Partner_Grouping_ID__c;
                      }
                      if(linkedAccount.Partner_Track__r.PPA_UCID__c != null){
                      selectedLead.PPA_UCID__c =linkedAccount.Partner_Track__r.PPA_UCID__c;
                      } */
                      
                    selectedPR.Link_To_Account_Flag__c = True;
                    selectedPR.RecordTypeId = IdLookupUtils.getRecordTypeId('Existing Partner', 'Partner_request__c', true);
                    System.debug('####RecordtypeID >>>' +selectedPR.RecordTypeId);
                     selectedPR.account__c =  linkedAccount.id;  //Link to defec
                    
                    update selectedPR;
                    System.debug('complete update in updateSelectedPR...............');
             
         }catch(QueryException e){
                PageUtils.addError('Linking account is not valid, manual account linkage is not successful');
                
         }catch(Exception e1){
                ApexPages.addMessages(e1);
                
        }    
    }
    
  
    
    public PageReference doConfirm(){
       request.Status__c = PartnerConstants.REG_STATUS_DUPLICATE;
        try{
            update request;
        }catch( Exception e ){
            ApexPages.addMessages(e);   
        }
        return PageUtils.redirect('/' + request.id);
    }
    
    
    
    
    //When confirm button clicked under 'Link To' Account, 
     public PageReference doLinkAccountConfirm(){
        
        List<Account>            acctRec = getAccountRecord(confirmlinkaccountId);
        List<Partner_Request__C> prRec   = getPartnerRequestRecord(confirmlinkaccountPRId);        
 
        try{
            if(prRec!=null && acctRec!=null){               
              
                updateLinkedAccount(acctRec.get(0), prRec.get(0));
                updateSelectedPR(acctRec.get(0), prRec.get(0));               
                System.debug('successfully............');
                return PageUtils.redirect('/' + request.id);
            }
            
        }catch( Exception e ){
            ApexPages.addMessages(e);   
        }
       

        return null;
    }



    public PageReference doCancel(){
        return PageUtils.redirect('/' + request.id);
    }
}