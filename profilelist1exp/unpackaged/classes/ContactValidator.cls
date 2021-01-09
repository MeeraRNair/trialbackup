/*
 * Author   : Ragu
 * Purpose  : Utility class to hold simple and reusable functionalities for validating Contacts. 
 *        
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 10751    16.03           30-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR 13173    FY17-DCS-0801   12-Jul-2016     Fenny           To add a static "vrBypas" class variable for use in static methods
 * -------- ---------   ----------  -----------     ------------    -----------------------------------------------------------------------------------
 * Please DO NOT add revision history in the class level, instead add it in the corresponding methods. 
 */

public class ContactValidator {
    
    private static System_Behavior_Bypasser__c vrBypass = System_Behavior_Bypasser__c.getInstance(UserInfo.getProfileId()); // 2.0

    /* 
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR 8196                     13-May-2013     RP              Validate the email is in the required Dell Format.
    2.0         CR 10761    16.03           15-Dec-2014     Anwar           To Exclude PMC user from Contact Validations.
    2.1         CR 10751    16.03           02-Feb-2014     Ragu            This logic is separated from contactTrigger trigger and rewritten as part of trigger redesign.
    3.0         CR 13173    FY17-DCS-0801   11-Jul-2016     Fenny           To excempt user (profiles) from email format validation
    */  
    public static void validatePartnerAccountEmails(list<Contact> lstContacts, map<Id, Account> mapRelatedAccounts) {
        
        // v2.0 - PMC Profile Id condition check added
        Id pmcProfileId = '00eA0000000hVOFIA2';
        if((UserInfo.getProfileId() != pmcProfileId) && (!vrBypass.Bypass_Contact_VRs__c)) { // 3.0: Additional condition to check whether vrBypass to skip email format validation
            for(Contact newContact : lstContacts) {
                Account relatedAccount = mapRelatedAccounts.get(newContact.AccountId);
                
                if(relatedAccount != null && (relatedAccount.RecordTypeId == '012A0000000TR6Y' || relatedAccount.Type == 'Partner')) {
                    String newEmail = newContact.Email;
                    if(!String.isBlank(newEmail)) {
                        Pattern patternInstance = Pattern.compile('^([a-zA-Z0-9_\\-\\.\\\']+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,20}|[0-9]{1,3})(\\]?)');
                        Matcher matcherInstance = patternInstance.matcher(newEmail);
                        
                        if(!matcherInstance.matches()) {
                            newContact.Email.addError('Invalid Email');
                        }
                    }
                }
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    2.0         CR 8093                     24-Sep-2013     Kokila          To ignore case sensitivity for Phone field
    3.0         CR 9040     15.03           33-Dec-2013     TK              Exclude bad first and last names
    3.1         CR 9040     15.03           34-Dec-2013     TK              Add rest of email and phone fields for contact exclusion validation
    3.2         CR 9040     15.03           21-Feb-2014     TK              CRQ 0908 Remove email validation for Legacy_Invalid_Email__c & add phone validation for Fax
    3.3         CR 9040     15.03           03-Mar-2014     TK              CRQ 0919 Change error message
    4.0         CR 9566     15.10           28-May-2014     Manju           To validate Phone and Other Phone fields
    5.0         CR 10761    16.03           15-Dec-2014     Anwar           To Exclude PMC user from Contact Validations.
    5.1         CR 10751    16.03           30-Dec-2014     Ragu            This logic is separated from contactTrigger trigger and rewritten as part of trigger redesign.
    6.0         CR 13173    FY17-DCS-0801   11-Jul-2016     Fenny           To excempt user (profiles) from contact exclusion list checking
    */
    public static void validateExclusions(list<Contact> lstContacts) {
        // v5.0 - PMC Profile Id condition check added
        Id pmcProfileId = '00eA0000000hVOFIA2';
        if((UserInfo.getProfileId() != pmcProfileId) && (!vrBypass.Bypass_Contact_VRs__c)) { // 6.0: Additional condition to check whether vrBypass to skip contact exclusion check
            map<String, Contact_Exclusion__c> mapEmailExclusions = new map<String, Contact_Exclusion__c>();
            map<String, Contact_Exclusion__c> mapPhoneExclusions = new map<String, Contact_Exclusion__c>();
            
            // v3.0 - Start
            map<String, Contact_Exclusion__c> mapBadFirstNames = new map<String, Contact_Exclusion__c>();
            map<String, Contact_Exclusion__c> mapBadLastNames = new map<String, Contact_Exclusion__c>();
            // v3.0 - End
            
            for(Contact_Exclusion__c contactExclusion : [select Id, Email__c, Phone__c, First_Name__c, Last_Name__c from Contact_Exclusion__c where Active__c = true]) {
                mapEmailExclusions.put(contactExclusion.Email__c, contactExclusion);
                // v2.0 - Added toLowerCase() to ignore case sensitivity
                if(contactExclusion.Phone__c != null) {
                    mapPhoneExclusions.put(contactExclusion.Phone__c.toLowerCase(), contactExclusion);
                }
                
                // v3.0 - Start
                if(contactExclusion.First_Name__c != null) {
                    mapBadFirstNames.put(contactExclusion.First_Name__c.toLowerCase(), contactExclusion); 
                }
                if(contactExclusion.Last_Name__c != null) {
                    mapBadLastNames.put(contactExclusion.Last_Name__c.toLowerCase(), contactExclusion);
                }
                // v3.0 - End
            }
    
            for(Contact newContact : lstContacts) {
                if(newContact.Email != null) {
                    if(mapEmailExclusions.get(newContact.Email) != null) {
                        newContact.Email.addError('Invalid Email. Email entered is listed in the exclusion list');
                    }
                }
                if(newContact.Phone != null) {
                    // v2.0 - Added toLowerCase() to ignore case sensitivity
                    if(mapPhoneExclusions.get(newContact.Phone.toLowerCase()) != null) {
                        newContact.Phone.addError('Invalid Number. The Number entered is listed in the exclusion list');
                    }
                    
                    // v4.0 - Start
                    Pattern phoneFormat = Pattern.Compile('(^\\(?(\\d{3})\\)?[- ]?(\\d{3})[- ]?(\\d{4})$)');   
                    Pattern numberFormat = Pattern.Compile('[0-9]{10}'); 
                    Matcher phoneMatch = numberFormat.matcher(newContact.Phone);
                    Matcher format_of_number = phoneFormat.matcher(newContact.Phone);  
                    if(!phoneMatch.Matches() && newContact.Phone.length() != 10) {
                        if(!format_of_number.Matches()) {
                            newContact.Phone = newContact.Phone.replaceAll('\\s+', '');
                        }
                    }
                    // v4.0 - End
                }
                
                // v3.1 - Start
                if(newContact.Assistant_Email__c != null) {
                    if(mapEmailExclusions.get(newContact.Assistant_Email__c) != null) {
                        newContact.Assistant_Email__c.addError('Invalid Email. Email entered is listed in the exclusion list');
                    }
                }
                if(newContact.Alternate_Email__c != null) {
                    if(mapEmailExclusions.get(newContact.Alternate_Email__c) != null) {
                        newContact.Alternate_Email__c.addError('Invalid Email. Email entered is listed in the exclusion list');
                    }
                }
                
                // v3.2 - Start
                // Remove Legacy_Invalid_Email__c
                /*
                if(newContact.Legacy_Invalid_Email__c != null) {
                    if(mapEmailExclusions.get(newContact.Legacy_Invalid_Email__c) != null) {
                        newContact.Legacy_Invalid_Email__c.addError('Invalid Email. Email entered is listed in the exclusion list');
                    }
                }
                */
                
                // Add phone validation for Fax
                if(newContact.Fax != null) {
                    if(mapPhoneExclusions.get(newContact.Fax.toLowerCase()) != null) {
                        newContact.Fax.addError('Invalid Number. The Number entered is listed in the exclusion list');
                    }
                }
                // v3.2 - End
                
                if(newContact.AssistantPhone != null) {
                    if(mapPhoneExclusions.get(newContact.AssistantPhone.toLowerCase()) != null) {
                        newContact.AssistantPhone.addError('Invalid Number. The Number entered is listed in the exclusion list');
                    }
                }
                if(newContact.HomePhone != null) {
                    if(mapPhoneExclusions.get(newContact.HomePhone.toLowerCase()) != null) {
                        newContact.HomePhone.addError('Invalid Number. The Number entered is listed in the exclusion list');
                    }
                }
                if(newContact.MobilePhone != null) {
                    if(mapPhoneExclusions.get(newContact.MobilePhone.toLowerCase()) != null) {
                        newContact.MobilePhone.addError('Invalid Number. The Number entered is listed in the exclusion list');
                    }
                }
                if(newContact.OtherPhone != null) {
                    if(mapPhoneExclusions.get(newContact.OtherPhone.toLowerCase()) != null) {
                        newContact.OtherPhone.addError('Invalid Number. The Number entered is listed in the exclusion list');
                    }
                    
                    // v4.0 - Start
                    Pattern phoneFormat = Pattern.Compile('(^\\(?(\\d{3})\\)?[- ]?(\\d{3})[- ]?(\\d{4})$)');
                    Pattern numberFormat = Pattern.Compile('[0-9]{10}');
                    Matcher phoneMatch = numberFormat.matcher(newContact.OtherPhone);
                    Matcher format_of_number = phoneFormat.matcher(newContact.OtherPhone);
                    if(!phoneMatch.Matches() && newContact.OtherPhone.length() != 10) {
                        if(!format_of_number.Matches()) {
                            newContact.OtherPhone = newContact.OtherPhone.replaceAll('\\s+', '');
                        }
                    }
                    // v4.0 - End
                }
                // v3.1 - End
                
                // v3.0 - Start
                if(newContact.FirstName != null) {
                    if(mapBadFirstNames.get(newContact.FirstName.toLowerCase()) != null) {
                        newContact.FirstName.addError('Invalid First Name. First Name entered is listed in the exclusion list.');
                    }
                }
                if(newContact.LastName != null) {
                    if(mapBadLastNames.get(newContact.LastName.toLowerCase()) != null) {
                        newContact.LastName.addError('Invalid Last Name. Last Name entered is listed in the exclusion list.');
                    }
                }
                // v3.0 - End
            }
        }
    }
    
    /* 
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0         CR 10582    16.03       08-Jan-2015     Devika          Check for credit card information in Recommend Comment field.
    1.1         CR 10751    16.03       02-Feb-2014     Ragu            This logic is separated from contactTrigger trigger and rewritten as part of trigger redesign.
    */
    public static void validateRecommendComment(list<Contact> lstNewContacts, map<Id, Contact> mapOldContacts) {
        final String ERROR_MESSAGE = 'Suspected financial information detected. Storing confidential information in SFDC is non-compliant to Dell policy.';
        for(Contact newContact : lstNewContacts) {
            if(newContact.Recommend_Comment__c != null) {
                if(mapOldContacts == null || (newContact.Recommend_Comment__c != mapOldContacts.get(newContact.Id).Recommend_Comment__c)) {
                    if(CreditCardUtils.getCreditCardValid(newContact.Recommend_Comment__c)) {
                        newContact.Recommend_Comment__c.addError(ERROR_MESSAGE);
                    }
                }
            }
        }  
    }

}