/* 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0                  14.2        19-Nov-2012     Jiji            New Deal RT Selection.
 * 2.0      10736       16.03       22-Dec-2015     Ragu            Allow the “New Deal Reg” button to be immediately visible to Partners on the Channel Lead.
 * 3.0      16129       FY19-0802   10-July-2018    Naga        Deleted duplicated code as part of code clean up
 * 4.0      6377603     FY19-0402   30-July-2019    Sonali      Logic to populate Lead's Partner account on opportunity's Partner Account 
 * 
 */
public without sharing class CMAP_DealRTselectionController {
    
    Lead leadRecord {get; set;}
    String strselectedRecordType;    
    public Boolean bRTSelection {get; private set;}
    public Boolean bInvalidLead {get; private set;} // v2.0
    public String strLeadId;
    public String strRedirect;
    public CMAP_DealRTselectionController(ApexPages.StandardController controller) {
        try {
            bRTSelection = false;
            bInvalidLead = true; // v2.0
            strLeadId = ApexPages.currentPage().getParameters().get('leadId');
            if(!String.isBlank(strLeadId)) {
                leadRecord = [select Id, Name, Called_Customer__c, Sales_Qualified__c, Search_My_Customer__c, Search_My_Customer__r.Name, Company, Country, Website, Street, Industry, City,
                                  State, Email, FirstName, MobilePhone, PostalCode, LastName, Fax, Title, Phone,Partner_Account__c, Partner_Account__r.Name,
                                  Solution_Type__c, Account__C, Account__r.Name, Total_Expected_Dell_Revenue__c, Solution_Scope__c, Marketing_Comments__c, Engagement_Type__c,
                                  Campaign__c, Campaign__r.Name, Campaign__r.Region__c, Sales_Comments__c, Search_My_Customer_Contact__c, Search_My_Customer_Contact__r.Name 
                              from Lead where Id = :strLeadId];

                // v2.0 - Start
                if(leadRecord.Called_Customer__c == 'Yes' && leadRecord.Sales_Qualified__c == 'Qualified') {
                    bInvalidLead = false;
                }
                // v2.0 - End
            }
            System.debug('leadRecord.Partner_Account__c'+leadRecord.Partner_Account__c);
            //v3.0 Start
            strRedirect = (leadRecord.Company != null ? '&00N70000001mdPS=' + pageUtils.encodeVariable(leadRecord.Company) : '')
                          + (leadRecord.Account__c != null ? '&opp4_lkid=' + leadRecord.Account__c : '')
                          + (leadRecord.Account__r.Name != null ? '&opp4=' + pageUtils.encodeVariable(leadRecord.Account__r.Name) : '')
                          + '&CF00NA00000063bHk_lkid=' + leadRecord.Id
                          + (leadRecord.PostalCode != null ? '&00N70000001mdU8=' + leadRecord.PostalCode : '')
                          + (leadRecord.Name != null ? '&CF00NA00000063bHk=' + pageUtils.encodeVariable(leadRecord.Name) : '')
                          + (leadRecord.Name != null ? '&'+Label.Channel_Lead_Id+'=' + pageUtils.encodeVariable(leadRecord.Id) : '')
                          + (leadRecord.Engagement_Type__c != null ? '&00N7000000284s3=' + pageUtils.encodeVariable(leadRecord.Engagement_Type__c) : '')
                          + (leadRecord.Campaign__r.Region__c != null ? '&00N70000001lwVn=' + leadRecord.Campaign__r.Region__c : '')
                          + (leadRecord.Campaign__c != null ? '&opp17=' + leadRecord.Campaign__r.Name : '')
                          + (leadRecord.Campaign__c != null ? '&'+Label.Primary_Campaign_Id+'='+ leadRecord.Campaign__c : '')
                          + (leadRecord.Solution_Type__c != null ? '&00N30000001O7vL=' + pageUtils.encodeVariable(leadRecord.Solution_Type__c) : '')
                          + (leadRecord.Solution_Scope__c != null ? '&00N7000000284rZ=' + pageUtils.encodeVariable(leadRecord.Solution_Scope__c) : '')
                          + (leadRecord.Marketing_Comments__c != null ? '&00NA00000063bHa=' + pageUtils.encodeVariable(leadRecord.Marketing_Comments__c) : '')
                          + (leadRecord.Sales_Comments__c != null ? '&00NA00000063bHf=' + pageUtils.encodeVariable(leadRecord.Sales_Comments__c) : '')
                          + (leadRecord.Total_Expected_Dell_Revenue__c != null ? '&00N70000001nEfk=' + leadRecord.Total_Expected_Dell_Revenue__c : '')
                         /*//v4.0 - Start
                          + (leadRecord.Partner_Account__c != null ? '&PartnerAccount_lkid=' + pageUtils.encodeVariable(leadRecord.Partner_Account__c) : '')
                          + (leadRecord.Partner_Account__r.Name != null ? '&PartnerAccount=' + pageUtils.encodeVariable(leadRecord.Partner_Account__r.Name) : '')
                         //v4.0 - End*/
                          + '&nooverride=1&retURL=' + leadRecord.Id;
                          System.debug('leadRecord.Partner_Account__c'+leadRecord.Partner_Account__c);
                //v3.0 End
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.CMAP_Default_Error_Message));
        }
    }
    public String getSelectedRecordType() {
        return strselectedRecordType;
    }

    public void setSelectedRecordType(String strrecordType) {
        this.strselectedRecordType = strrecordType;
    }

    public list<SelectOption> getRecordTypes() {
        list<SelectOption> listRtSelectOptions = new list<SelectOption>();
        listRtSelectOptions.add(new SelectOption('Register Deal without an End Customer', System.Label.CMAP_RT_without_EndCustomer));
        listRtSelectOptions.add(new SelectOption('Register Deal with an End Customer', System.Label.CMAP_RT_with_EndCustomer));
        return listRtSelectOptions;
    }
    public PageReference redirect() {
        // v2.0 - Start
        if(bInvalidLead) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.CMAP_Invalid_Lead_for_New_Deal_Reg));
            return null;
        } 
        // v2.0 - End
        if(leadRecord.Search_My_Customer__c != null) {
            // Navigate to Register Deal With an End Customer new page if an end customer exist
            Id dealWithECusRTId = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer', 'Opportunity', true);
            String strURL = '/006/e?RecordType=' + dealWithECusRTId
                            + (leadRecord.Search_My_Customer__r.Name != null ? '&CF00NA00000063VT1=' + pageUtils.encodeVariable(leadRecord.Search_My_Customer__r.Name) : '')
                            + (leadRecord.Search_My_Customer__c != null ? '&CF00NA00000063VT1_lkid=' + leadRecord.Search_My_Customer__c : '')
                            + (leadRecord.Search_My_Customer_Contact__c != null ? '&CF00NA00000063VT6_lkid=' + leadRecord.Search_My_Customer_Contact__c : '')
                            + (leadRecord.Search_My_Customer_Contact__r.Name != null ? '&CF00NA00000063VT6=' + pageUtils.encodeVariable(leadRecord.Search_My_Customer_Contact__r.Name) : '')
                            + strRedirect;   //v3.0
               System.debug('***************Line 96'+leadRecord.Partner_Account__c);            
            // Update Selected track account on contact with lead partner account
                updateSelectedSMOnContact(leadRecord.Partner_Account__c);
                    
            PageReference pageRef = new PageReference(strURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else {
            bRTSelection = true;
            return null;
        }
    }

    public pageReference continueButton() {
        PageReference pageRef;                   
        if(strselectedRecordType == 'Register Deal with an End Customer') {
            Id dealWithECusRTId = IdLookupUtils.getRecordTypeId('Deal Registration for Existing End Customer', 'Opportunity', true);
            String strURL = '/006/e?RecordType=' + dealWithECusRTId
                            + strRedirect;    //v3.0
            pageRef = new pagereference(strURL);
            pageRef.setRedirect(true);
        }
        System.debug('leadRecord.Partner_Account__c'+leadRecord.Partner_Account__c); 
            
        if(strselectedRecordType == 'Register Deal without an End Customer') {
            Id dealRegRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
            String strURL = '/006/e?leadId=' + leadRecord.Id + '&RecordType=' + dealRegRTId
                            + (leadRecord.FirstName != null ? '&00N70000001mdQ0=' + pageUtils.encodeVariable(leadRecord.FirstName) : '')
                            + (leadRecord.LastName != null ? '&00N70000001mdRP=' + pageUtils.encodeVariable(leadRecord.LastName) : '')
                            + (leadRecord.Title != null ? '&00N70000001mdYt=' + pageUtils.encodeVariable(leadRecord.Title) : '')
                            + (leadRecord.Email != null ? '&00N70000001mdPX=' + pageUtils.encodeVariable(leadRecord.Email) : '')
                            + (leadRecord.Phone != null ? '&00N70000001mdXn=' + pageUtils.encodeVariable(leadRecord.Phone) : '')
                            + (leadRecord.MobilePhone != null ? '&00N70000001mdWh=' + pageUtils.encodeVariable(leadRecord.MobilePhone) : '')
                            + (leadRecord.Fax != null ? '&00N70000001md8N=' + pageUtils.encodeVariable(leadRecord.Fax) : '')                         
                            + (leadRecord.Street != null ? '&00N70000001mdSs=' + pageUtils.encodeVariable(leadRecord.Street) : '')
                            + (leadRecord.City != null ? '&00N70000001mdSm=' + pageUtils.encodeVariable(leadRecord.City) : '')
                            + (leadRecord.State != null ? '&00N70000001mdU2=' + pageUtils.encodeVariable(leadRecord.State) : '')
                            + (leadRecord.Country != null ? '&00N70000001mdTn=' + pageUtils.encodeVariable(leadRecord.Country) : '')
                            + (leadRecord.website != null ? '&00N7000000285Fs=' + pageUtils.encodeVariable(leadRecord.website) : '')
                            + (leadRecord.Industry != null ? '&00N70000001mdPN=' + pageUtils.encodeVariable(leadRecord.Industry) : '')
                           /*// v4.0 - Start
                            + (leadRecord.Partner_Account__c != null ? '&PartnerAccount_lkid=' + pageUtils.encodeVariable(leadRecord.Partner_Account__c) : '')
                          + (leadRecord.Partner_Account__r.Name != null ? '&PartnerAccount=' + pageUtils.encodeVariable(leadRecord.Partner_Account__r.Name) : '')
                          //v4.0 - end*/
                            + strRedirect;   //v3.0
                System.debug('***************Line 142'+leadRecord.Partner_Account__c);               
             // Update Selected track account on contact with lead partner account
                updateSelectedSMOnContact(leadRecord.Partner_Account__c);
                
            pageRef = new pagereference(strURL);
            pageRef.setRedirect(true);
        }
        System.debug('leadRecord.Partner_Account__c'+leadRecord.Partner_Account__c);
        return pageRef;
    }
    public pageReference cancelButton() {
        return PageUtils.Redirect('/' + leadRecord.Id);
    }
    
    public static void updateSelectedSMOnContact(Id partnerAccId){
    
        User loggedInUser = [select Id,Contact.Id from user where id = : UserInfo.getUserId()];
        Account acc = [select id,Account_Country__c from account where id = :partnerAccId];
        contact con = new contact(id = loggedInUser.Contact.Id);
        //con.
        con.Selected_Track_Account__c = partnerAccId;
        TriggerExecutionController.setSkipAllTriggers(true);
        update con;
         
        TriggerExecutionController.setSkipAllTriggers(false); 
        checkAndAddAccShare(partnerAccId);
        updateUserCurrency(acc.Account_Country__c);
        
    }
    
     public static void checkAndAddAccShare(Id straccId){
        Integer intaccShareCount = [select count() from AccountShare where UserOrGroupId = : userinfo.getUserId() and AccountId = :straccId];
        if (intaccShareCount == 0){
            AccountShare accShare = new AccountShare();
            accShare.AccountId = straccId;
            accShare.UserOrGroupId = userinfo.getUserId();
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.CaseAccessLevel = 'None';
            insert accShare;
        }        
    }
    
    @future
    public static void updateUserCurrency(String strCountry){
        if(strCountry != null && strCountry!= ''){
            list<Deal_Registration__mdt> listCurrencyMetadata = new list<Deal_Registration__mdt>();
            try{
                listCurrencyMetadata = [select Country__c,Currency__c from Deal_Registration__mdt where Country__c = :strCountry limit 1]; 
                if(listCurrencyMetadata.size() > 0 && listCurrencyMetadata[0].Currency__c != null){
                    user usrToUpdate = new user(id = userinfo.getUserId());
                    //usrToUpdate.;
                    usrToUpdate.CurrencyIsoCode = listCurrencyMetadata[0].Currency__c;
                    usrToUpdate.DefaultCurrencyIsoCode = listCurrencyMetadata[0].Currency__c;

                    TriggerExecutionController.setSkipAllTriggers(true);
                    update usrToUpdate;
                    TriggerExecutionController.setSkipAllTriggers(false); 
                }
            }
            catch(exception ex){
                system.debug('Exception occured in updateUserCurrency Method:' +ex.getMessage());
                
            }
        }
    }
}