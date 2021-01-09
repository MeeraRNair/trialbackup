/*
 * Author   : Men Mee
 * Purpose  : Utility class to hold simple and reusable functionalities for validating Users. 
 *        
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR12402     17.02       01-12-2015      Men Mee            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */

public class UserValidator {

    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CRQ 0869    15.03
    2.0         CR12402     17.02       01-12-2015      Men Mee          This logic is separated from  beforeUserModification trigger and rewritten as part of trigger redesign.
    */
    public static void validateForLeadManagementEnabledForOEM(Map<Id,User> mapNewUsers, Map<Id,User> mapOldUsers,  Set<id> LMchangedids) {
       
        if(LMchangedids.size()>0){
            PartnerCountry pc = new PartnerCountry();
            Map<String,Country__c>  countryMap = pc.returnCountryCodeMap();
                
            for(User u : [SELECT contact.accountid,contact.account.Partner_Relationship__c, contact.account.account_country_code__c,contact.account.Sales_channel__r.name FROM User where id IN :LMchangedids]){
                //For OEM users check if it satisfies condition for lead management else throw error
                if(u.contact.account.Sales_channel__c != null&& u.contact.account.Sales_channel__r.name.contains('OEM') && (countryMap.get(u.contact.account.account_country_code__c).Lead_Management_Enabled_for_OEM__c != 'Yes' ||
                        !((countryMap.get(u.contact.account.account_country_code__c) != null && countryMap.get(u.contact.account.account_country_code__c).Partner_Relationship_for_OEM__c.contains('All')) ||(u.contact.account.Partner_Relationship__c != null && countryMap.get(u.contact.account.account_country_code__c).Partner_Relationship_for_OEM__c.contains(u.contact.account.Partner_Relationship__c)) ))){
                    mapNewUsers.get(u.id).addError('You cannot enable lead management since this record does not meet the conditions (Country: Lead management Enabled for OEM ='+countryMap.get(u.contact.account.account_country_code__c).Lead_Management_Enabled_for_OEM__c+' and Partner Relationship for OEM = '+countryMap.get(u.contact.account.account_country_code__c).Partner_Relationship_for_OEM__c+') to enable Lead Management.');
                }
                
                //For non OEM users check if it satisfies condition for lead management else throw error
                if((u.contact.account.Sales_channel__c !=null && !u.contact.account.Sales_channel__r.name.contains('OEM')||u.contact.account.Sales_channel__c == null) && ((countryMap.get(u.contact.account.account_country_code__c)!= null && countryMap.get(u.contact.account.account_country_code__c).Lead_Management_Enabled__c != 'Yes') ||
                        !((countryMap.get(u.contact.account.account_country_code__c) != null && countryMap.get(u.contact.account.account_country_code__c).Partner_Relationship__c.contains('All')) ||(u.contact.account.Partner_Relationship__c != null && countryMap.get(u.contact.account.account_country_code__c) != null && countryMap.get(u.contact.account.account_country_code__c).Partner_Relationship__c.contains(u.contact.account.Partner_Relationship__c) )))){
                    mapNewUsers.get(u.id).addError('You cannot enable lead management since this record does not meet the conditions (Country: Lead management Enabled ='+countryMap.get(u.contact.account.account_country_code__c).Lead_Management_Enabled__c+' and Partner Relationship = '+countryMap.get(u.contact.account.account_country_code__c).Partner_Relationship__c+') to enable Lead Management.');
                }                    
            }
        }
    }
}