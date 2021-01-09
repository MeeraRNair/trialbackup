/*
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR 15931    FY19-DCE-0602   18-May-2018     Abhinav         Created utility method and moved email logic under AccountUtils class
 * 
 */
public class PartnerRegistrationDomainDuplicateCheck {
    private static final string COUNTRY_CODE_DOMAIN_INVALID = 'Provided country code and domain cannot be null or empty.';
    private static final string ACCOUNT_ID_INVALID = 'Provided account id cannot be null or empty.';
    private static final string PARTNER_INFO_EMPTY = 'Registering partner information cannot be null.';
    private static final string PARTNER_ADMIN_EMPTY = 'Partner admin list cannot be null or empty.';
    private static final string EMAIL_TEMPLATE_NOTFOUND = 'Email template for specific language not found.';
    private static final string DEFAULT_EMAIL_LANGUAGE_CODE = 'en_US';
    private static final string EMAIL_TEMPLATE_NAME_PREFIX = 'PRM_Admin_Notice_';
    
    // Check whether the provided domain is/isn't in the DomainExclusionList and is active
    // Return TRUE if the domain is in the exclusion list, else FALSE
    public static Boolean isDomainExcluded(String strdomain){
        Boolean bisExcluded = false;
        
        try{
            if ((strdomain != null) && (strdomain.trim().length() > 0)){
                Integer intrecordCount = [SELECT Count() FROM Partner_Domain_Exclusion_List__c WHERE Domain_Name__c = :strdomain AND Is_Active__c = true];
                bisExcluded = (intrecordCount > 0);
            }else{
                throw new dellUtil.DellException(COUNTRY_CODE_DOMAIN_INVALID);
            }
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerRegistrationDomainDuplicateCheck | Method: isDomainExcluded]');        
            throw ex;
        }
        
        return bisExcluded;
    }
    
    // Check whether there is existing partner account found for the provided country and domain
    // Return NULL if NONE or MORE THAN ONE partner account found
    // Return partner account if ONLY ONE partner account found
    public static Account getSinglePartnerAccount(String strcountryCode, String strdomain,String strpartnerTrack, String strsecondaryPartnerTypes){
        Account account = null;
        if(strpartnerTrack == 'CSP (Cloud Service Provider)'){
           strpartnerTrack =  'Cloud Service Provider';
          }else if(strpartnerTrack == 'Solution Provider (Reseller)'){
                 strpartnerTrack = 'Solution Provider';
          }else if(strpartnerTrack == 'OEM (Original Equipment Manufacturer)') {
                 strpartnerTrack = 'OEM';
          } 
        try{
        List<Account> listAcc = new list<Account>();
        List <Id> listAccIds=new List <Id> ();
        List<User> listUser = new List<User>();   
                                                
            
            if ((strcountryCode != null) && (strcountryCode.trim().length() > 0) && (strdomain != null) && (strdomain.trim().length() > 0)){
               if(System.Label.PartnerRegistrationDomainDuplicateCheck_oldLogic == 'True'){
                               listAcc = [SELECT a.Id, a.Name, a.Partner_Primary_Customer__c FROM Account a
                                        WHERE a.IsPartner = TRUE AND a.IsDeleted = FALSE AND a.Account_Country_Code__c = :strcountryCode 
                                        AND a.Id in (SELECT AccountId FROM User WHERE IsActive = TRUE 
                                            AND Contact.IsDeleted = FALSE AND AccountId != null AND Partner_Domain_Name__c = :strdomain)];
               }
               else{                   
                   listUser = [SELECT AccountId,contact.EligibleTracks__c FROM User WHERE IsActive = TRUE AND Contact.IsDeleted = FALSE AND AccountId != null 
                            															  AND Partner_Domain_Name__c = :strdomain];
                   if(listUser.size() > 0){
                       for(User usr : listUser){
                           listAccIds.add(usr.AccountId);
                       }
                       
                   }
                   System.debug('listAccIds'+listAccIds.size());
                   
                   if(listAccIds.size() >0){
                       listAcc = [SELECT a.Id, a.Name, a.Partner_Primary_Customer__c,Master_Group_Id__c FROM Account a
                                        WHERE a.IsPartner = TRUE AND a.IsDeleted = FALSE AND a.Account_Country_Code__c = :strcountryCode 
                                        AND a.Master_Group_Id__c in: listAccIds 
                                        AND (a.Partner_Track__r.Partner_Track__c = :strpartnerTrack)
                                        AND (a.Partner_Track__r.Track_id__r.Partner_Program_Track__c  =: strsecondaryPartnerTypes)];
                   }     
               }
               
                system.debug('****Duplicate Found :' +listAcc );
                If ((listAcc != null) && (listAcc.size() >= 1)) {
                    account = listAcc[0];
                }
            }else{
                throw new dellUtil.DellException(COUNTRY_CODE_DOMAIN_INVALID);
            }
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerRegistrationDomainDuplicateCheck | Method: getSinglePartnerAccount]');     
            throw ex;
        }
        
        return account;
    }
    
    // Return a list of User sObjects based on the provided straccountId
    public static List<User> getPartnerAdmin(string straccountId, string strdomain){
        List<User> listAdmin = null;
        
        try{
            if ((straccountId != null) && (straccountId.trim().length() > 0) && (strdomain != null) && (strdomain.trim().length() > 0)) {
                listAdmin = [SELECT Id, Name, Email, LanguageLocaleKey FROM User WHERE AccountId = :straccountId AND Enable_Partner_Admin__c = TRUE AND IsActive = TRUE AND Partner_Domain_Name__c = :strdomain];
            }else{
                throw new dellUtil.DellException(ACCOUNT_ID_INVALID);
            }
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerRegistrationDomainDuplicateCheck | Method: GetPartnerAdmin]');     
            throw ex;
        }
        
        return listAdmin;
    }
    
    // Send email to nofity partner admin about new partner registration.
    // Following fields have to be available from the User object in listAdmins list: Id, Name, Email, LanguageLocaleKey
    // Return TRUE is there is any failure in sending email.
    public static Boolean sendEmailToPartnerAdmin(partnerInfo info, List<User> listAdmins){
        Boolean bhasError = false;
        
        try{
            if ((info != null) && (listAdmins != null) && (listAdmins.size() > 0)){
                string stremailTemplateNamePrefix = (((info.EmailTemplateNamePrefix == null) || (info.EmailTemplateNamePrefix.trim().length() == 0)) 
                    ? EMAIL_TEMPLATE_NAME_PREFIX : info.EmailTemplateNamePrefix);
                string strdefaultEmailLanguageCode = (((info.DefaultEmailLanguageCode == null) || (info.DefaultEmailLanguageCode.trim().length() == 0)) 
                    ? DEFAULT_EMAIL_LANGUAGE_CODE : info.DefaultEmailLanguageCode);

                //V1.0 BOF
                //Moved email logic to one utility method under AccountUtils class
                bhasError = AccountUtils.SendEmailToPartnerAdminUtils('PartnerRegistrationDomainDuplicateCheck', stremailTemplateNamePrefix, strdefaultEmailLanguageCode, new List<Id>(), listAdmins, info);
            }else if (info == null){
                bhasError = true;
                throw new dellUtil.DellException(PARTNER_INFO_EMPTY);
            }else{
                bhasError = true;
                throw new dellUtil.DellException(PARTNER_ADMIN_EMPTY);
            }
        }catch(Exception ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: PartnerRegistrationDomainDuplicateCheck | Method: SendEmailToPartnerAdmin]');
            bhasError = true;
            throw ex;
        }
        
        return bhasError;
    }

    // Object that hold registering partner's information that to be populated in email that being sent to partner admin
    public class partnerInfo{
        public string Firstname { get; set; }
        public string Lastname { get; set; }
        public string PhoneNumber { get; set; }
        public string MobilePhone { get; set; }
        public string Email { get; set; }
        public string RegisteringCountry { get; set; }
        public string Comment { get; set; }
        public string DefaultEmailLanguageCode { get; set; }
        public string EmailTemplateNamePrefix { get; set; }
        public string partnerTrack { get; set; }
    }
}