/*
 * Author   : Niveda
 * Purpose  : Utility class to hold simple and reusable functionalities for validating Leads.
 *        
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 11837    16.10           18-Aug-2015     Niveda          Validate users associated in the Dell Lead Follow Up - LM2.0.
 * 1.1      CR 11925    16.10           03-Sep-2015     Ragu            Validation of "Related Contact for Channel Leads" is moved from CMAP_BeforeInsertUpdateLeadTrigger and included Channel Lead 2.0 in the validation.
 * 1.2      CR 11925    16.10           03-Sep-2015     Ragu            Validation of "Duplicate Channel Lead checking and scoring" is moved from CMAP_BeforeInsertUpdateLeadTrigger and included Channel Lead 2.0 in the validation.
 * 1.3      TFS 204661  16.10           22-Oct-2015     Nagendra        E2E regression : Update a CL 2.0 with the Status is Closed – Invalid Lead and Invalid Reason is Existing CL
 * 2.0      CR 12336    16.12           13-Nov-2015     Ragu            LM2_1_76-Enhance related account change in Direct Lead 2.0
 * 3.0      CR 13244    FY17-DCS-0703   13-Jun-2016     Jessie          Convert some validation rules to trigger (to reduce the lead limit issues)
 * 4.0      CR 13332    FY17-DCS-0801   19-Jul-2016     Jessie          Defect 2163404: E2E: Unable to create contact for Partner Account/Company from FAP in SIT3 (confirm currentUser.contact is not null before further logic)
 * 5.0      CR 13288    FY17-DCS-0801   02-Aug-2016     Azwanti         added boolean bSkipCampaignValidator where BatchUpdateLeadStatusUponEndDate will set this to TRUE to bypass the validation on Close Date.
 * 6.0      CR 13560    FY17-DCS-1101   29-Sep-2016     SuiYee          LM2-Update "Eloqua SFDC Integration User" profile to allow Leads on Inactive Account
 * 7.0      CR 14187    FY18-DCS-0602   18-Apr-2017     Ashok           LM2_Update converted leads without validation rule
 * 8.0      CR 17117    FY20-DCS-0402   6-Feb-2019      Naresh          Checking Partner account track exist in the current users track list
 * 9.0      Defect      FY20-DCS-0802   25-Jul-2019     Shue/Niveda     Defect 7041494: SDET - Wunderkind: CMAP: FY20-0802: Partner Account Is auto populating When save the Lead With Partner User
 * 10.0     CR 18290    FY20-DCS-0102   24-Oct-2019     Sonali          Logic to link Leads to Opportunities by utilizing the Deal ID fields on Lead
*/

public class LeadValidator {
public static boolean bSkipLeadValidator=false;//v5.0
  
    // v1.0 - Start
    // Validate whether Users associated in the Direct Lead 2.0 is internal users or not.
    public static final String SF_LICENSETYPE = 'Salesforce'; 
    public static void validateDirectLead2(list<Lead> lstDirectLeads2) {
        //v5.0
        if(!bSkipLeadValidator){
            set<Id> setUserIds = new set<Id>();
            for(Lead newDirectLead2 : lstDirectLeads2) {
                setUserIds.add(newDirectLead2.Inside_Sales_Rep_ICAM__c);
                setUserIds.add(newDirectLead2.ISM_Channel_ISM__c);
                setUserIds.add(newDirectLead2.Account_Executive_PDM__c);
                setUserIds.add(newDirectLead2.RSM__c);
            }
            setUserIds.remove(null);
            
            set<Id> setNonStdUserIds = new set<Id>();
            for(User usr : [select Id from User where Id in :setUserIds and License_Used__c != :SF_LICENSETYPE]) {
                setNonStdUserIds.add(usr.Id);
            }
            if(!setNonStdUserIds.isEmpty()) {
                for(Lead newDirectLead2 : lstDirectLeads2) {
                    if(setNonStdUserIds.contains(newDirectLead2.Inside_Sales_Rep_ICAM__c)) {
                        newDirectLead2.addError('ISR/ICAM user selected cannot be a Partner or Chatter user. Please select a valid user');
                    }
                    if(setNonStdUserIds.contains(newDirectLead2.ISM_Channel_ISM__c)) {
                        newDirectLead2.addError('ISM/Channel ISM user selected cannot be a Partner or Chatter user. Please select a valid user');            
                    }
                    if(setNonStdUserIds.contains(newDirectLead2.Account_Executive_PDM__c)) {
                        newDirectLead2.addError('Account Executive/PDM user selected cannot be a Partner or Chatter user. Please select a valid user');
                    }
                    if(setNonStdUserIds.contains(newDirectLead2.RSM__c)) {
                        newDirectLead2.addError('RSM user selected cannot be a Partner or Chatter user. Please select a valid user');
                    }
                }
            }
        }//v5.0
    }
    // v1.0 - End
    
    // v2.0 - Start: Commenting below method since it is implemented in validation rules
    /*
    // v1.1 - Start
    // Validate whether Related Contact associated with the Direct Lead is belongs to the Account which is selected in that Direct Lead.
    public static void validateRelatedContactForDL(list<Lead> lstDirectLeads, map<Id, Contact> mapRelatedContacts) {
        for(Lead newChannelLead : lstDirectLeads) {
            if(newChannelLead.Account__c != null && newChannelLead.Contact__c != null) {
                Contact relatedContact = mapRelatedContacts.get(newChannelLead.Contact__c);
                if(relatedContact != null && newChannelLead.Account__c != relatedContact.AccountId) {
                    newChannelLead.Contact__c.addError('Related Contact must belong to the selected Account.');
                }
            }
        }
    }
    // v1.1 - End
    */
    // v2.0 - End
    
    // v1.1 - Start
    // Validate whether Related Contact associated with the Channel Lead is belongs to the Account which is selected in that Channel Lead.
    public static void validateRelatedContactForCL(list<Lead> lstChannelLeads, map<Id, Contact> mapRelatedContacts) {
        //v5.0
        if(!bSkipLeadValidator){
            for(Lead newChannelLead : lstChannelLeads) {
                if(newChannelLead.Account__c != null && newChannelLead.Related_Contact__c != null) {
                    Contact relatedContact = mapRelatedContacts.get(newChannelLead.Related_Contact__c);
                    if(relatedContact != null && newChannelLead.Account__c != relatedContact.AccountId) {
                        newChannelLead.Related_Contact__c.addError('Related Contact must belong to the selected Account.');
                    }
                }
            }
        }//v5.0 
    }
    // v1.1 - End

    // v1.2 - Start
    // Validate whether duplicate Channel Lead is being created / it is scored.
    public static void validateDuplicateChannelLeads(list<Lead> lstChannelLeads, map<Id, Lead> mapOldLeads) {
        //v5.0
        if(!bSkipLeadValidator){
            set<Id> setCampaignIds = new set<Id>();
            set<Id> setContactIds = new set<Id>();
            set<Id> setCLIds = new set<Id>(); 
            list<Lead> lstCLToProcess = new list<Lead>();

            Boolean bIsUpdate = false;
            if(mapOldLeads != null && !mapOldLeads.isEmpty()) {
                bIsUpdate = true;
            }
            
            Id clCleansingRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
            
            for(Lead newChannelLead : lstChannelLeads) {
                Lead oldChannelLead = null;
                if(bIsUpdate) {
                    oldChannelLead = mapOldLeads.get(newChannelLead.Id);
                }
                
                if(newChannelLead.Related_Contact__c != null 
                    && (!bIsUpdate || (bIsUpdate && (oldChannelLead.Related_Contact__c != newChannelLead.Related_Contact__c || oldChannelLead.Campaign__c != newChannelLead.Campaign__c || (oldChannelLead.Ignore_Duplicate_Record__c == true && newChannelLead.Ignore_Duplicate_Record__c == false) || (oldChannelLead.Status == 'Closed - Invalid Lead' && newChannelLead.Status != 'Closed - Invalid Lead') || (oldChannelLead.Invalid_Lead_Reason__c == 'Existing CL' && newChannelLead.Invalid_Lead_Reason__c != 'Existing CL')
                    
                    )))
                ) {
                    if(bIsUpdate) {
                        setCLIds.add(newChannelLead.Id);
                    }
                    
                    setCampaignIds.add(newChannelLead.Campaign__c);
                    setContactIds.add(newChannelLead.Related_Contact__c);
                    lstCLToProcess.add(newChannelLead);
                }
                // v1.3 - Start         
                if(bIsUpdate && ( newChannelLead.Status == 'Closed - Invalid Lead' && newChannelLead.Invalid_Lead_Reason__c == 'Existing CL')) {
                    if(newChannelLead.Ready_for_Scoring__c) {
                        newChannelLead.Ready_for_Scoring__c.addError('Duplicate Closed - Invalid Lead cannot score.');
                    }                      
                }              
                // v1.3 - End
            }
            
            map<Id, set<Id>> mapCampIdConIds = new map<Id, set<Id>>();
            map<Id, list<string>> mapCampIdUniqueKeys = new map<Id, list<string>>();
            for(Lead leadIterator : [select Id, Related_Contact__c, Campaign__c from Lead where Campaign__c in :setCampaignIds and Related_Contact__c in :setContactIds and Id not in :setCLIds and (Status != 'Closed - Invalid Lead' or Invalid_Lead_Reason__c != 'Existing CL') order by Campaign__c]) {
                if(mapCampIdConIds.containsKey(leadIterator.Campaign__c)) {
                    mapCampIdConIds.get(leadIterator.Campaign__c).add(leadIterator.Related_Contact__c);
                    mapCampIdUniqueKeys.get(leadIterator.Campaign__c).add(leadIterator.Id + ';' + leadIterator.Related_Contact__c);
                }
                else {
                    mapCampIdConIds.put(leadIterator.Campaign__c, new set<Id>{leadIterator.Related_Contact__c});
                    mapCampIdUniqueKeys.put(leadIterator.Campaign__c, new string[] {leadIterator.Id + ';' + leadIterator.Related_Contact__c});
                }
            }
            
            String strErrorMessage = 'This entity is already a member of this campaign, If you want to close this as duplicate, select ‘Lead Status’ as ‘Closed - Invalid Lead’ and ‘Invalid Lead Reason’ as ‘Existing CL’ or if you want to proceed with creating this Lead, select the ‘Ignore Duplicate Record?’ checkbox and save.';
            for(Lead newChannelLead : lstCLToProcess) {
                if(mapCampIdConIds.containsKey(newChannelLead.Campaign__c)) {
                    if(mapCampIdConIds.get(newChannelLead.Campaign__c).contains(newChannelLead.Related_Contact__c)) {
                        // If Ignore Duplicate Record checkbox is checked then do not allow scoring of the the duplicate Lead
                        if(newChannelLead.Ignore_Duplicate_Record__c || (newChannelLead.Status == 'Closed - Invalid Lead' && newChannelLead.Invalid_Lead_Reason__c == 'Existing CL')) {
                            if((newChannelLead.Status == 'Closed - Invalid Lead' || newChannelLead.Invalid_Lead_Reason__c == 'Existing CL') && newChannelLead.Ready_for_Scoring__c) {
                                newChannelLead.Ready_for_Scoring__c.addError('Duplicate Closed - Invalid Lead cannot score.');
                            }
                            continue;
                        }
                        
                        // If Ignore Duplicate Record checkbox is unchecked and status not equal to Invalid Lead and existing CL, fetch duplicate Ids
                        if(!newChannelLead.Ignore_Duplicate_Record__c && (newChannelLead.Status != 'Closed - Invalid Lead' || newChannelLead.Invalid_Lead_Reason__c != 'Existing CL')) {
                            String strDuplicateIds = '';
                            for(String strUniqueKey : mapCampIdUniqueKeys.get(newChannelLead.Campaign__c)) {
                                if(strUniqueKey.contains(newChannelLead.Related_Contact__c)) {
                                    strDuplicateIds += (strDuplicateIds == '' ? strUniqueKey.split(';')[0] : ', ' + strUniqueKey.split(';')[0]);
                                }
                            }
                            
                            String strRecordError = strErrorMessage + ' The duplicate record Id is ' + strDuplicateIds;
                            if(!bIsUpdate && newChannelLead.Id == null && newChannelLead.RecordTypeId == clCleansingRTId && newChannelLead.Relationship_Lead__c != null) {
                                strRecordError = strRecordError + '. Otherwise please click cancel to abort the route to channel process and return to the relationship Lead record.';
                            }
                            newChannelLead.addError(strRecordError);
                        }
                    }
                }
            }
        }//v5.0 
    }
    // v1.2 - End
    
    // v3.0 - Start
    // Validate whether Account Owner is a Rep or Mgr
    public static void validateAccountOwner(list<Lead> lstLeads, map<Id, User> mapRelatedAccountOwners) {
        //v5.0
        if(!bSkipLeadValidator){
            Id leadAccSuggestionId = StaticFactory.getRecordTypeIdByName('Lead', 'Account Suggestion');
                
            for(Lead lead: lstLeads) {
               list<string> rolesAre = new list<String>();
                   rolesAre = system.label.Role_Starts_with.toLowercase().split(',');
                 list<string> exactrolesAre  = new list<String>();
                   exactrolesAre = system.label.Role_Equals_To.toLowercase().split(',');   
                if(lead.Account_Owner__c != null && lead.RecordTypeId == leadAccSuggestionId){
                    
                    User currentUser = mapRelatedAccountOwners.get(lead.Account_Owner__c);
                    
                   /* if(
                        !(currentUser.UserRole.Name.toLowerCase().startsWith('rep_')) 
                            &&  
                        !(currentUser.UserRole.Name.toLowerCase().startsWith('mgr_'))    
                            &&
                        !(currentUser.UserRole.Name.toLowerCase() == 'ww_exec')     
                    )*/
                     
                                        
                     // added group_id__c for QE Story#5805764                    
                     if(
                        ((!(rolesAre.contains(currentUser.UserRole.Name.toLowerCase().substring(0,4))) || currentUser.Group_Id__c != null) 
                            && 
                        !(exactrolesAre.contains(currentUser.UserRole.Name.toLowerCase())))     
                    )
                    {
                        lead.addError('Only a Rep or manager can be an account owner.');
                        continue;
                    }
                    
                    
                    
                    
                    
                    if (
                        currentUser.Badge_Number__c == null 
                            ||
                        currentUser.Title == null                    
                            ||
                        currentUser.Title.toLowerCase() == 'integration temp' 
                    ){
                        lead.addError('Account owner should have a valid title and badge number.');                
                    }
                    
                    
                }
                
            }
        }//v5.0
    }
   
    // Validate whether Postal Phone Number and Physical Phone Number are valid
    public static void validatePostalPhoneNumberNPhysicalPhoneNumber(list<Lead> lstLeads, map<Id, Country__c> mapRelatedCountries ) {
        //v5.0
        if(!bSkipLeadValidator){
            
            Id leadAccSuggestionId = StaticFactory.getRecordTypeIdByName('Lead', 'Account Suggestion');
            Id leadAccSuggestionLockedId = StaticFactory.getRecordTypeIdByName('Lead', 'Account Suggestion Locked');
                    
            for(Lead lead: lstLeads) {
                       
                if(lead.RecordTypeId == leadAccSuggestionId || lead.RecordTypeId == leadAccSuggestionLockedId){
                    
                    Country__c currentPostalCountry = mapRelatedCountries.get(lead.Postal_Country__c);
                    Country__c currentPhysicalCountry = mapRelatedCountries.get(lead.Physical_Country__c);
                    
                    if(
                        currentPostalCountry !=null && currentPostalCountry.Name.toLowerCase() == 'united states' 
                             &&  
                        lead.Postal_Phone__c !=null && !lead.Postal_Phone__c.startsWith('1-')  
                    ) {
                        lead.Postal_Phone__c.addError('Please prepend the Postal phone with ‘1-‘ in order to save the record.');
                    }
                    
               /*     if(
                        currentPhysicalCountry!=null && currentPhysicalCountry.Name.toLowerCase() == 'united states' 
                             &&  
                        lead.Physical_Phone__c!=null && !lead.Physical_Phone__c.startsWith('1-')  
                    ) {
                        lead.Physical_Phone__c.addError('Please prepend the Physical phone with 1- in order to save the record.');
                    }
                     */
                    
                }
                
            }
        
        }//v5.0
    }   
   
    // Validate to prevent users from creating Leads with Inactive Accounts
    public static void validateToPreventLeadWithInactiveAccount(list<Lead> lstLeads, map<Id, Contact> mapRelatedContacts ) {
        //v5.0
        if(!bSkipLeadValidator){
            
            for(Lead lead: lstLeads) {
                
                Contact currentContact = mapRelatedContacts.get(lead.Contact__c); 
               
                if(currentContact!=null && currentContact.Account.Calculated_Status__c == 'Inactive' && currentContact.Account.Owner.Name.toLowerCase() == 'global data admin' && !lead.isConverted){ //7.0 - added to skip the validation of converted leads
                    
                    lead.addError('You are trying to create or convert using an Inactive Account. Please select a Contact associated with an Active Account.');
                                   
                }
                
            }
        }//v5.0
    }
    
    
    /*    
    1) Only Partner Account can be selected when creating or editing Channel Lead.
    2) User selected in the Partner User field should be of type Partner User.
    3) The Partner User should belong to the Partner Account selected, if Partner Account is not blank.
    */    
    //v4.0 - start
    public static void validatePartnerAccountNPartnerUser(list<Lead> lstLeads, map<Id, User> mapRelatedUsers, map<Id, Account> mapRelatedAccounts ) {
        //System.debug('Shue in validatePartnerAccountNPartnerUser--- ');
        //System.debug('Shue lstLeads--- '+lstLeads);
        //System.debug('Shue mapRelatedUsers--- '+mapRelatedUsers);
        //System.debug('Shue mapRelatedAccounts --- '+mapRelatedAccounts);
        //v5.0
        if(!bSkipLeadValidator){
            
            Id clSubmissionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');
            Id clClensingScoringRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
            Id clAssignmentRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Assignment Complete');
            Id clConversionRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Conversion');
            Id channelLead2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');
            Id dsgPartnerRTId = StaticFactory.getRecordTypeIdByName('Lead', 'DSG Partner');
            
            set<Id> setRTIds = new set<Id>{clSubmissionRTId, clClensingScoringRTId, clAssignmentRTId, clConversionRTId, channelLead2RTId, dsgPartnerRTId };
        
            for(Lead lead: lstLeads) {
               
                Account currentAccount = mapRelatedAccounts.get(lead.Partner_Account__c);
                 
                User currentUser = mapRelatedUsers.get(lead.Partner_User__c);
                //Updated by Naresh CR 17117 
                //V 8.0 Start
                //system.debug('check currentUser' +currentUser );
                list<string> listUserContactTracks=new list<string>();
                if(currentUser!=null){
                    if(currentUser.Contact !=null){
                        if(currentUser.Contact.EligibleTracks__c!=null && currentUser.Contact.EligibleTracks__c!=''){
                        listUserContactTracks=currentUser.Contact.EligibleTracks__c.split(';');
                        }
                    }
                }
                //V 8.0 End
                // End
                if(
                    setRTIds.contains(lead.RecordTypeId)
                        &&
                    (
                        (lead.Partner_User__c!=null && lead.Partner_Account__c!=null && currentUser !=null && currentUser.Contact !=null && !listUserContactTracks.contains(currentAccount.Partner_track__c))//currentUser.Contact.AccountId <> lead.Partner_Account__c  
                            ||
                            //9.0 start
                        (lead.Partner_User__c!=null && (lead.Partner_Account__c == null || String.isBlank(lead.Partner_Account__c) )) 
                            //9.0 end
                            ||
                        (lead.Partner_User__c!=null && currentUser !=null && currentUser.UserType != 'PowerPartner')    
                            ||
                        (
                            lead.Partner_Account__c!=null 
                                && 
                            (
                                currentAccount.RecordType.Name != 'Partner Account'
                                    ||
                                (
                                    currentAccount.Type!='Partner'
                                        &&
                                    currentAccount.Type!='OEM'
                                )
                                
                            )
                            
                        )     
                    )
                          
                    
                ){
                    
                 //   lead.addError('Selected partner account or partner user is incorrect, or Partner user does not belong to the selected partner account, please contact your channel marketing team for assistance.');
                                   
                }
                
            }
        }//v5.0 
    }
    
    // v3.0 - End
    // v4.0 - End 

    //V1.0 Validate Double byte characters in company and address fields
    public static void validateDoubleByte(List<Lead> leadList, map<Id, Country__c> mapRelatedCountries) {
    
        for (Lead l: leadList) {
          
            if (l.recordTypeID == System.Label.Lead_Account_suggestion_RT_ID.normalizeSpace() || l.RecordTypeID == System.Label.Lead_Update_Acc_Sugg_RT_ID.normalizeSpace()) {
              
              Country__c currentPostalCountry = mapRelatedCountries.get(l.Postal_Country__c);
              if(currentPostalCountry!=null){
              if(System.label.Lead_Legal_Local_Addr_Applicable_Countries.contains(currentPostalCountry.Name)){
                       
                if (String.isNotBlank(l.Postal_Address_1__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Postal_Address_1__c) || String.isNotBlank(l.Mg_Address_Line_1__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Mg_Address_Line_1__c))
                    {
                    l.Mg_Address_Line_1__c.addError('MasterGroup Address 1 must be in English');
                    l.Postal_Address_1__c.addError('Postal Address 1 must be in English');
                    }
                if (String.isNotBlank(l.Postal_Address_2__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Postal_Address_2__c) || String.isNotBlank(l.Mg_Address_Line_2__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Mg_Address_Line_2__c))
                    {
                    l.Mg_Address_Line_2__c.addError('MasterGroup Address 2 must be in English');
                    l.Postal_Address_2__c.addError('Postal Address 2 must be in English');
                    }
                if (String.isNotBlank(l.Postal_City__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Postal_City__c) || String.isNotBlank(l.Mg_City__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Mg_City__c))
                    {
                    l.Mg_City__c.addError('MasterGroup City must be in English');
                    l.Postal_City__c.addError('Postal City must be in English');
                    }
                if (String.isNotBlank(l.Postal_State__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Postal_State__c) || String.isNotBlank(l.Mg_State__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Mg_State__c))
                    {
                    l.Mg_State__c.addError('MasterGroup State must be in English');
                    l.Postal_State__c.addError('Postal State must be in English');
                    }
                 if (String.isNotBlank(l.Postal_Company_Name__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Postal_Company_Name__c) || String.isNotBlank(l.Mg_Name__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Mg_Name__c))
                    {
                     l.Mg_Name__c.addError('Master Group Name must be in English');
                    l.Postal_Company_Name__c.addError('Postal Company Name must be in English');
                    }
                if (String.isNotBlank(l.Physical_Company_Name__c) && !ChinaTranslation.validateDoubleByteRegExp(l.Physical_Company_Name__c))
                    {
                    l.Physical_Company_Name__c.addError('Physical Company Name must be in English');
                    }
            }
            }
           }
           }
     
    }
    
    //v10.0 - start
    public static void validatePartnertInChannelLead(list<Lead> listLeads, set<String> setDealIds ) {
        Map<String,ID> mapDealToOppOwner= new  Map<String,ID>();
        if(!bSkipLeadValidator){
            
        for(Opportunity objOpp: [select Id, Deal_ID__c,OwnerId from Opportunity where Deal_ID__c  in :setDealIds]){
           mapDealToOppOwner.put(objOpp.Deal_ID__c, objOpp.OwnerId);
        }
            for(Lead objLead: listLeads){
                
                if(objLead.Partner_User__c != NULL &&((objLead.Deal_1_ID__c != NULL && objLead.Partner_User__c != mapDealToOppOwner.get(objLead.Deal_1_ID__c)) || 
                (objLead.Deal_2_ID__c != NULL && objLead.Partner_User__c != mapDealToOppOwner.get(objLead.Deal_2_ID__c)) || 
                (objLead.Deal_3_ID__c != NULL && objLead.Partner_User__c != mapDealToOppOwner.get(objLead.Deal_3_ID__c)) || 
                (objLead.Deal_4_ID__c != NULL && objLead.Partner_User__c != mapDealToOppOwner.get(objLead.Deal_4_ID__c)) || 
                (objLead.Deal_5_ID__c != NULL && objLead.Partner_User__c != mapDealToOppOwner.get(objLead.Deal_5_ID__c)) || 
                (objLead.Deal_6_ID__c != NULL && objLead.Partner_User__c != mapDealToOppOwner.get(objLead.Deal_6_ID__c)))){ 
                  
                objLead.addError('Please check the partner user in the channel lead and associated opportunity, they should belong to the same partner user.');
                }   
            }
                
        }
    }//v10.0 - end
}