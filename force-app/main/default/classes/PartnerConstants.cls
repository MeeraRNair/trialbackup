/* 

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     17-SEP-2014     Jessie Tan     Modified for CR10476 to convert hardcoded Partner Portal URL to Custom Label
*/

public class PartnerConstants {

    //===================================
    // PARTNER REQUEST STATUSES
    //=================================== 
    public static final String REG_STATUS_DRAFT         = 'New';
     public static final String REG_STATUS_OWNED         = 'Owned';
    public static final String REG_STATUS_INCOMPLETE    = 'Incomplete';
    public static final String REG_STATUS_APPROVED      = 'Approved';
    public static final String REG_STATUS_REJECTED      = 'Rejected';
    public static final String REG_STATUS_RESUBMITTED   = 'Re-submitted';
    public static final String REG_STATUS_INREVIEW      = 'In Review';
    public static final String REG_STATUS_DUPLICATE     = 'Duplicate';
    public static final String REG_STATUS_COMPLETE     = 'Complete';
    public static final String REG_STATUS_INCOMPLETEANDEXPIRED           = 'Incomplete & Expired';
    public static final String REG_STATUS_LEADDRAFT               = 'Lead Draft';
    public static final String REG_STATUS_ACCOUNT_SUGGESTION_SUBMITTED       = 'Account Suggestion Submitted';
    public static final String REG_STATUS_ACCOUNT_SUGGESTION_COMPLETED       = 'Account Suggestion Completed';
    public static final String REG_STATUS_ACCOUNT_SUGGESTION_REJECTED       = 'Account Suggestion Rejected';
    public static final String REG_STATUS_ACCOUNT_SUGGESTION_CREATED       = 'Account Suggestion Created';
    public static final String REG_STATUS_ACCOUNT_SUGGESTION_PROCESS_ERRORED   = 'Account Suggestion Process Errored';
    //START R14.2
    public static final String REG_STATUS_ABORTED_BY_PARTNER         = 'Aborted By Partner';
    //END R14.2
    
    //===================================
    // RECORD TYPES
    //===================================
    public static final String REQUEST_RECORD_TYPE_NEW_PARTNER      = 'New Partner';
    public static final String REQUEST_RECORD_TYPE_UPDATE_PARTNER   = 'Update Partner';
    public static final String REQUEST_RECORD_TYPE_NEW_USER         = 'New User';
    public static final String REQUEST_RECORD_TYPE_REMOVE_USER      = 'Remove User';
    public static final String REQUEST_RECORD_TYPE_UPDATE_USER      = 'Update User';
    public static final String REQUEST_RECORD_TYPE_EXIST_PARTNER   = 'Existing Partner';
    public static final String REQUEST_RECORD_TYPE_NEW_PARTNER_ADMIN = 'New Partner Admin';
    //START R14.2
    public static final String REQUEST_RECORD_TYPE_ABORTED_BY_PARTNER = 'Aborted Partner';
    public static Boolean IS_INCENTIVE_REVERTED = false;
    //END R14.2

    //===================================
    // CONFIG VARIABLE
    //===================================
    public static String SSO_LINK_MY_ACCT_URL {get{
        // [Fenny 08 Jan 2013]: Defect 55324: Changed from HTTP to HTTPS (MyAccount will make HTTPS call compulsory)
      /*return 
         'https://'
         + (Environment.isProduction() ? 'sso' : 'www-test') 
         + '.dell.com/SSOTools/LinkToMyAccount.aspx';*/
        //rev 1.0 - start
        return 
         (Environment.isProduction() ? System.Label.PartnerPortal_Prod_Server_URL: System.Label.PartnerPortal_Sandbox_Server_URL)
         + 'SSOTools/LinkToMyAccount.aspx';
         //rev 1.0 - end 
          
    }}
    

}