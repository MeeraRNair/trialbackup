/*
REVISION HISTORY
================
Version     Author        Date            Release#    CR#     Description
-------     ------        ----            --------    ---     -----------
1.0                                                           Initial draft
2.0      Krishnamoorthi  07-Dec-2012        14.2      7678    R14.2 Maintenance - PRM - Website auto-populated from Partner Request to Account
3.0      Bikram Dutta    21-8-2014          15.10  
4.0      Anu             10-Dec-2015        CSM0104    12431
*/
public with sharing class PartnerRegistrationLinkToAcctCtrlrExt {
 
    public string searchString {get; set;}
    public Integer getAccountSearchResultsCount(){ return results.size(); }
    public List<Account> getAccountSearchResults() {return results;}
    private List<Account> results = new List<Account>();
    public Account selectedAccount {get; set;}
    public Boolean getIsAccountSelected(){ return selectedAccount != null; }
    public Partner_Request__c registration {get;set;}
    public static final String REQUESTED_FEATURE_PARTNER_FINDER = 'Partner Finder';
    public string recTypeId;
    RecordType recType;
    public Boolean ConfirmEUAcc=false;
    public Boolean ConfirmAccount=false;
    public boolean newCsmr=false;
    Public boolean nonNewCsmr=false;

    public PartnerRegistrationLinkToAcctCtrlrExt(ApexPages.StandardController c){
        registration = (Partner_Request__c) c.getRecord();
        recType=[SELECT Name,Id,SobjectType FROM RecordType WHERE Name ='New Customer' AND SobjectType='Partner_Request__c'];
        List<Partner_Request__c> recordList = 
            [select id, (select id,status from leads__r), account__c, company__c, name, 
                Currently_Selling_Dell__c, Dell_Revenue_Percent__c, Hardware_Revenue_Percent__c, 
                Other_Customers__c, Percent_Sales_Force__c, Percent_Technical_Professionals__c, 
                Preferred_Dell_Distribution_Partner__c, Primary_Channel_Model__c, Primary_Customer__c, 
                Product_Focus__c, Reseller_Tax_ID__c, Service_Revenue_Percent__c, Software_Revenue_Percent__c, 
                States_Provinces_doing_business__c,recordtypeId,End_Customer__c,End_Customer__r.name,recordtype.name, Website__c  //Rev2.0 added Website field
            from Partner_Request__c 
            where id = :registration.id limit 1];
            
        
        if(registration.recordtypeId==recType.Id){
            ConfirmEUAcc=true; 
            newCsmr=true;   
        }
        if(registration.recordtypeId!=recType.Id){
            ConfirmAccount=true;
            nonNewCsmr=true;
        }    
        if(recordList.isEmpty()){ 
            PageUtils.addError('Record not found.');
            return;
        }
        registration = recordList.get(0);
    }
    

    public PageReference doPageLoad(){
        PageReference result = null;
        if(registration != null && StringUtils.isNotBlank(registration.company__c)){
            searchString = registration.company__c;
            result = doSearch();    
        }
        return result;   
    }
    
    //SOSL Version
    public PageReference doSearch(){
        results.clear();
        String wildcardedSearchString = searchString;
        
        if(wildcardedSearchString != null){
            wildcardedSearchString = wildcardedSearchString.endsWith('*') ? wildcardedSearchString : wildcardedSearchString + '*';
            wildcardedSearchString = wildcardedSearchString.startsWith('*') ? wildcardedSearchString : '*' + wildcardedSearchString ;
        }

        try{
            List<List<SObject>> searchList; 
            if(recType.Id!=registration.recordTypeId){
                searchList = [FIND :wildcardedSearchString IN ALL FIELDS RETURNING Account (
                id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Owner.Name,Owner.Id,
                ShippingPostalCode,ShippingCountry,recordTypeId,recordType.name)];
                results = ((List<Account>)searchList[0]);
            }
            if(recType.Id==registration.recordTypeId){
                searchList = [FIND :wildcardedSearchString IN ALL FIELDS RETURNING Account (
                id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,Owner.Name,Owner.Id,
                ShippingPostalCode,ShippingCountry,billingStreet,billingCity,billingState,billingPostalCode,billingCountry,
                Account_ID__c,Segment_Desc__c,Segment_Business_Unit_Name__c,recordTypeId,recordType.name
                where IsPartner=false AND RecordTypeId!=: System.Label.RecType_Partner_Account)];
                results = ((List<Account>)searchList[0]);
            }
            
        }catch(QueryException e){//x
            PageUtils.addError('Too many Account records match the specified search criteria. Please refine your search criteria and try again');//x
            return null;//x
        }catch(Exception e1){//x
            ApexPages.addMessages(e1);//x
            return null;//x
        }        

        if (results.size() == 0){
            PageUtils.addError('The specified search criteria did not match any existing Account records. Please try again');
        }
        return null;
    }

    public PageReference doSelectAccount(){
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        String accountId2 = ApexPages.currentPage().getParameters().get('accountId2');
        List<Account> records;
        if(StringUtils.isBlank(accountId) && registration.recordtypeId!=recType.Id){
            return null;
        }
        if(StringUtils.isBlank(accountId2) && registration.recordtypeId==recType.Id){
            return null;
        }
         
        if(recType.Id!=registration.recordTypeId){
            records = [select id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,
                Currently_Selling_Dell__c, Dell_Revenue_Percent__c, Hardware_Revenue_Percent__c, Other_Customers__c, 
                Percent_Sales_Force__c, Percent_Technical_Professionals__c, Preferred_Dell_Distribution_Partner__c, 
                Primary_Channel_Model__c, Partner_Primary_Customer__c, Product_Focus__c, Reseller_Tax_ID__c, 
                Service_Revenue_Percent__c, Software_Revenue_Percent__c, States_Provinces_doing_business__c, Website  //Rev2.0 added Website field
            from Account 
            where id = :accountId];
            
            
        } else if(recType.Id==registration.recordTypeId){
            records = [select id,IsPartner,name,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,
                Currently_Selling_Dell__c, Dell_Revenue_Percent__c, Hardware_Revenue_Percent__c, Other_Customers__c, 
                Percent_Sales_Force__c, Percent_Technical_Professionals__c, Preferred_Dell_Distribution_Partner__c, 
                Primary_Channel_Model__c, Partner_Primary_Customer__c, Product_Focus__c, Reseller_Tax_ID__c, 
                Service_Revenue_Percent__c, Software_Revenue_Percent__c, States_Provinces_doing_business__c, Website  //Rev2.0 added Website field
            from Account 
            where id = :accountId2];
            
        }    
        if(records.isEmpty()){
            selectedAccount = null;
        } else {
            selectedAccount = records.get(0);
            if(selectedAccount.IsPartner){
                PageUtils.addError('The Account you selected (' + selectedAccount.name 
                    + ') is already enabled as a Partner and cannot be linked to the Partner Registration.  Please choose a different Account.');//x
                selectedAccount = null;//x
            }
        }    
        return null;        
    }
    
    public PageReference doConfirmAccount(){
        if(selectedAccount == null){
            return null;
        }
        Savepoint sp = null;
        try{
            sp = Database.setSavepoint();
            registration.Account__c = selectedAccount.id;
            registration.Link_to_Account_Record_Is_Complete_Flag__c = true;
            update registration;
            
            if(registration.Leads__r != null && registration.Leads__r.size() > 0){
                Lead lead = registration.Leads__r;//x
                lead.status = 'Converted';//x
                update lead;//x
            }
            
            selectedAccount.Partner_Registration__c = registration.id;
            selectedAccount.IsPartner = true;
            selectedAccount.Currently_Selling_Dell__c = registration.Currently_Selling_Dell__c;
            selectedAccount.Dell_Revenue_Percent__c = registration.Dell_Revenue_Percent__c;
            selectedAccount.Hardware_Revenue_Percent__c = registration.Hardware_Revenue_Percent__c;
            selectedAccount.Other_Customers__c = registration.Other_Customers__c;
            selectedAccount.Percent_Sales_Force__c = registration.Percent_Sales_Force__c;
            selectedAccount.Percent_Technical_Professionals__c = registration.Percent_Technical_Professionals__c;
            selectedAccount.Preferred_Dell_Distribution_Partner__c = registration.Preferred_Dell_Distribution_Partner__c;
            selectedAccount.Primary_Channel_Model__c = registration.Primary_Channel_Model__c;
            selectedAccount.Primary_Routes_to_Market__c = registration.Primary_Routes_to_Market__c;
            selectedAccount.Partner_Primary_Customer__c = registration.Primary_Customer__c;
            selectedAccount.Product_Focus__c = registration.Product_Focus__c;
            selectedAccount.Reseller_Tax_ID__c = registration.Reseller_Tax_ID__c;
            selectedAccount.Service_Revenue_Percent__c = registration.Service_Revenue_Percent__c;
            selectedAccount.Software_Revenue_Percent__c = registration.Software_Revenue_Percent__c;
            selectedAccount.States_Provinces_doing_business__c = registration.States_Provinces_doing_business__c;
             
            //Rev2.0 added Website field
            if(selectedAccount.Website == null){
                selectedAccount.Website = registration.Website__c;
            }
                        
            update selectedAccount;
          
          /*  
           //R15.10 EUDC
            system.debug('---RT ID--- if ----'+selectedAccount.RecordtypeID);
            system.debug('---RT ID--- if ----'+selectedAccount.IsPartner );
            system.debug('---RT ID--- if ----'+selectedAccount.Type );

           if(selectedAccount.RecordTypeID == '012A0000000TR6Y' && selectedAccount.IsPartner == true || selectedAccount.Type == 'Partner' || selectedAccount.Type == 'OEM'){
            system.debug('---RT ID--- inside if ----'+selectedAccount.RecordtypeID);
            selectedAccount.Partner_Flag_for_Channel_DB__c = true;
           }
            
           update selectedAccount; */
            
        }catch(Exception e){
            Database.rollback(sp);//x
            ApexPages.addMessages(e);//x
            return null;//x
        }
        return PageUtils.redirect('/' + registration.id);
    }

    public PageReference doCancel(){
        return PageUtils.redirect('/' + registration.id);
    }
    
         
    public PageReference doConfirmEndUserAccount(){
        if(selectedAccount == null){
            return null;
        }
        Savepoint sp = null;
        try{
            sp = Database.setSavepoint();
            //registration.Account__c = selectedAccount.id;
            registration.Link_to_Account_Record_Is_Complete_Flag__c = true;
            registration.Status__c='Complete';
            update registration;
            
            List<End_Customer__c> endCstmr=[select id,End_User_Account__c,EU_Affinity_ID__c from End_Customer__c where id=:registration.End_Customer__c]; 
            //R15.10
            System.debug('-----------------endCstmr[0].EU_Affinity_ID__c '+endCstmr[0].EU_Affinity_ID__c );
            if(endCstmr[0].EU_Affinity_ID__c != '' && endCstmr[0].EU_Affinity_ID__c != null){ //v4.0
                   List<Account> endAcc =[select id, Name,Account_ID__c from Account where Account_ID__c =: endCstmr[0].EU_Affinity_ID__c limit 1];
                   endCstmr[0].End_User_Account__c=endAcc[0].Id;
            }
             System.debug('-----------------endCstmr[0].End_User_Account__c '+endCstmr[0].End_User_Account__c );
            if(endCstmr[0].End_User_Account__c == NULL){
               // endCstmr[0].End_User_Account__c = registration.Company__c;
                endCstmr[0].End_User_Account__c = selectedAccount.id;
             }   
            System.debug('-----------------endCstmr[0] '+endCstmr[0] );
            update endCstmr[0];
        }catch(Exception e){
            Database.rollback(sp);//x
            ApexPages.addMessages(e);//x
            return null;//x
        }
        return PageUtils.redirect('/' + registration.id);
    }
    
 
        
    public boolean getConfirmEUAcc(){
        return ConfirmEUAcc; 
    }
    
    public boolean getConfirmAccount(){
        return ConfirmAccount;
    }
 }