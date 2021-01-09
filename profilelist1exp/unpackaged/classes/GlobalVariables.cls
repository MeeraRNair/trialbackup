/*
Description: Class which contains global variables which helps in preventing trigger on Contact.
Version:4.0

History:
1.0 - 09-Sep-2008:  Creation
2.0 - 14-Nov-2009:  Commented out 2 variables related to custom campaign member follow up functionality(CR 2008)
3.0 - 18-Feb-2010:  Added boolean for bypassing partner profile integration.
4.0 - 23-Feb-2010:  Added boolean for by passing Remove User Partner Request creation in user after trigger
5.0 - 27-Apr-2010: Added to skip LOT OCEAN
6.0 - 26-Nov-2010: Added Lead RecType for CR4460
7.0 - 12-Jan-2011:  Added boolean flag to skip the whole trigger
8.0 - 08-Apr-2011: Added Lattice RecType for CR6019
9.0 - 03-Apr-2013: Added Boolean  to skip the update trigger execution not more than once.   
10.0 - 15-Aug-2013: Added Channel Opportunity rec type for CR 8577
11.0 - 7-Apr-2014: Added a boolean flag to skip Opportunitylineitem triggers
12.0 - 8-May-2014: Added 2 booleans to skip RL/AP "before update" triggers if RL/AP updated from batch job - CR9438
13.0 - 28-05-2014: Added a boolean flag to skip RL/AP before update trigger for re-assignment - CR 9535
14.0 - 22-09-2015: added boolean flag to skip CM creation from new Lead CR11955
15.0 - 22-02-2019: Added AVS_CONTACT_ADDRESS_CHANGED, to replace VFCtrl_AVSContactSuggestion.addressChanged (DX: VF Cntrl not be part of Base)
*/

public class GlobalVariables{
    /** removing custom campaign member follow up functionality
    public static Boolean BYPASS_CONTACT_TRIGGER  = false;
    public static Boolean BYPASS_CAMPAIGN_TRIGGER  = false;
    */

    public static Boolean AVS_CONTACT_ADDRESS_CHANGED = false;
        
    /* Used in : afterUpdateContactTrigger(Contact Trigger), , , */
    public static Boolean BYPASS_PARTNER_PROFILE_INTEGRATION  = false;    
    
    /* Used in : afterInactivateUser(User Trigger), , , */
    public static Boolean BYPASS_REMOVE_USER_RERQUEST_CREATION  = false; 
    
    /* Used in : accountTrigger(Account Trigger), , , */
    public static Boolean BYPASS_FUTURE_CALLS  = false;
    public static Boolean BYPASS_ACCOUNT_TRIGGER = false; 
    
    public static String CMI_RESPONSE_SUCCESSFUL =  '<InsertSegmentationDataResult>true</InsertSegmentationDataResult>';
    
    public static Boolean BYPASS_LOT_OCEAN_CALCULATION  = false; //this is only used in LOTOCEANUtils
    public static Boolean BYPASS_ALL_LOT_OCEAN_CALCULATION  = false; //this will by pass all LOT OCean calculation
    public static Boolean SKIP_OCEAN_POPUP_NOTIFICATION = false;
    public static Boolean SKIP_SOLUTION_CERT_FUNCTIONALITY = false; //this will by pass solution cert insert functionality
    
    public static Boolean SKIP_OPP_PARTNER_ADDITION = false;// this is used to bypass the Partner Account Addition func related to Opp trigger.
    /*Used in: opportunityTrigger, trgOppFYCloseDate, opptyBeforeInsertUpdateTrigger*/
    public static Boolean SKIP_ALL_OPP_TRIGGERS = false; // This is used to bypass all opportunity related Apex triggers.
    // CR7790
    public static Boolean SM_SOC_ISINSERT = false;
    
    public static Boolean SKIP_OPP_LINEITEM_TRIGGERS = False; // Used to bypass all the OpportunityLineItem triggers
    
    /* RecordTypes */
    
    //Opportunity
    public static String STANDARD_OPP_RECTYPE           = '012300000004zf2AAA';
    public static String RUNRATE_MARKETING_OPP_RECTYPE  = '012A0000000TehsIAC';
    public static String RUNRATE_OPP_RECTYPE            = '012A0000000TWOiIAO';
    public static String APOS_OPP_RETYPE                = '012A0000000UvEpIAK'; 
    public static String SMB_OPP_RECTYPE                = '012A0000000Vhy7IAC';    
    
   
    //CR8577
    //public static String CHANNEL_OPP_RECTYPE = IdLookupUtils.getRecordTypeId('Channel Opportunity', 'Opportunity', true); 
    public static String CHANNEL_OPP_RECTYPE            = '012A0000000VjtgIAC';
    
    //Lead
    public static String ACCOUNT_SUGGESTION_LEAD_RECTYPE = '012A0000000TRIUIA4';
    public static String ACCOUNT_SUGGESTION_LOCKED_LEAD_RECTYPE = '012A0000000TRIZIA4';
    public static String LEAD_QUALIFICATION_RECTYPE = '012A0000000VhxiIAC';
    public static Boolean BYPASS_createLeadFromCM = false; // CR11955 : set to True if Lead is created from Create Direct Lead button in CampaignMember page.
    
    //Account Play
    public static String LATTICE_AP_RECTYPE = '012A0000000Vhxd';
    
    //User Trigger
    public static Boolean TEST_USER_SUBSCRIPTION = false;
    
    // used in Account Trigger
    public static Boolean CERTIFICATION_TRACKER_CREATED = false;
   
    public static Boolean SKIP_AssignSalesConsole_USR_TRG_InTest = true; // This is used to bypass user trigger assignSalesConsole license
    public static boolean RL_Owner_Batch_Flag = false; // used to skip Relationship Lead before trigger that makes System auto-populate fields false
    public static boolean AP_Owner_Batch_Flag = false; // used to skip Account Play before trigger that makes System auto-populate fields false
    public static boolean Uncheck_GeoPopulated = false; // Used to uncheck Geo_populated field only when there is manual RL/AP re-assignment
      
    public static boolean override_first_run = false;  
}