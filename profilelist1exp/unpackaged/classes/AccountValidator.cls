/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities for validating Accounts. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR10751     16.03       19-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */

public class AccountValidator {
	
	/* 
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0			CR9839		15.10									    	CMAP Phase 2.2 - Contact Exclusion Email validation for Account records
    2.0         CR10751     16.03           19-Dec-2014     Ragu            This logic is separated from beforeInsertUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    3.0         CR 13173    FY17-DCS-0801   13-Jul-2016     Fenny           To excempt user (profiles) from contact exclusion list checking
    */
    public static void validateProdRepEmail(list<Account> lstAccounts, set<String> setProdRepEmails) {
        System_Behavior_Bypasser__c vrBypass = System_Behavior_Bypasser__c.getInstance(UserInfo.getProfileId()); // 3.0
        if(!vrBypass.Bypass_Contact_VRs__c){ // 3.0
            set<String> setExclusionEmails = new set<String>();
            for(Contact_Exclusion__c contactExclusion : [select Id, Email__c, Active__c from Contact_Exclusion__c where Email__c in :setProdRepEmails and Active__c = true]) {
                setExclusionEmails.add(contactExclusion.Email__c);
            }
    
            for(Account accIterator : lstAccounts) {
                if(setExclusionEmails.contains(accIterator.PRD_Rep_Email__c)) {    
                    accIterator.PRD_Rep_Email__c.addError('Invalid Email. Email entered is listed in the exclusion list');
                }
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.1                		14.2                		Fenny			set value to Is_Country_Enabled__c based on the Account Country Inc_Vendor_Name__c
	1.2                		14.2                        Ariff		   	Check Country Enabled for Incentives before enabling Account Enable for Incentives. Overwriting 2.1 version
    2.0         CR10751     16.03       19-Dec-2014     Ragu            This logic is separated from beforeInsertUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void validateCountryForIncentives(list<Account> lstAccounts) {
    	PartnerCountry partCountry = new PartnerCountry();
        map<String, Country__c> mapCountries = partCountry.returnCountryCodeMap();
        
        Id partnerAccountRTId = (Id)System.Label.RecType_Partner_Account;
        set<String> setVendorNames = new set<String> {'Partner Direct Rewards Center', 'Partner Advantage', 'Dell Achievers'};
        for(Account accountIterator : lstAccounts) {
            if(accountIterator.Type == 'Partner' && accountIterator.RecordTypeId == partnerAccountRTId && accountIterator.Is_Enabled_for_Incentives__c) {
                boolean isCountryEnabled = false;
                if(accountIterator.Account_Country_Code__c != null) {
                    Country__c country = mapCountries.get(StringUtils.upperCase((accountIterator.Account_Country_Code__c).trim()));
                    if(country != null && setVendorNames.contains(country.Inc_Vendor_Name__c)) {
                        isCountryEnabled = true;
                    }
                }
      			
                if(isCountryEnabled == false) {
                    accountIterator.Is_Enabled_for_Incentives__c.addError('Country is not enabled for Incentives. Enable the Country first to approve Account to participate in Incentives program'); 
                }
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         10582     	16.03       07-Jan-2015     Devika          Check for credit card information in description field.
    2.0         10751     	16.03       05-Feb-2015     Ragu            This logic is separated from beforeInsertUpdateAccountTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void checkCreditCardInfoInDescription(list<Account> lstAccounts, map<Id, Account> mapOldAccounts) {
    	String strErrorMessage = 'Suspected financial information detected. Storing confidential information in SFDC is non-compliant to Dell policy.';
    	for(Account newAccount : lstAccounts) {
    		if(mapOldAccounts == null) {
    			if(newAccount.Description != null) {                
                    if(CreditCardUtils.getCreditCardValid(newAccount.Description)) {
                        newAccount.Description.addError(strErrorMessage);
                    }
                }
    		}
    		else if(mapOldAccounts.containsKey(newAccount.Id)) {
    			Account oldAccount = mapOldAccounts.get(newAccount.Id);
                if(newAccount.Description != null && newAccount.Description != oldAccount.Description) {
                    if(CreditCardUtils.getCreditCardValid(newAccount.Description)) {
                        newAccount.Description.addError(strErrorMessage);               
                    }
                }
    		}
    	}
    }

}