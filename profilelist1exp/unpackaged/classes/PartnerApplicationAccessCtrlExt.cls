/***********************************************************
* Name          : PartnerApplicationAccessCtrlExt 
* Description   : Controller class for PartnerApplicationAccess Page to display a list of partner application
* ---------------------------------------------------------
* Revision      Name            Date            Release No    CR Number         Description
* 1.0           MenMee          04.12.2009                                      CR 2093 Partner Application Access    
* 2.0           Ray             01-01-2010                                      Modified for CR2186.
* 3.0           MenMee          05.01.2010                                     Only display Deal Registration and NetExam if setting is ON at Country object
* 4.0           MenMee          20.01.2010                                      API name changed
* 5.0           Raymond         02.02.2010                                      Fix for defect #55487. If My Account GUID is blanked, Id tag will go missing in request body/
*                                                                               Solution is to synchronize first before setting My Account GUID to blank.
* 6.0           Carmen          09.11.2010                                      CR2764: Modified doSave()
* 7.0           Krishnamoorthi  01.06.2012                                      R13.7 CR 6642 – Modified netExamAccess logic to capture the changes correctly in Contact History
* 8.0           Ariff Bahar     24.11.2012                                      R14.2 SSO Project
* 9.0           Sandhya         02.02.2013                                      R14.2 CR7824 Defect #55058
* 10.0          Meera           07.01.2013                                      R14.2 SSO - Disable Partner User - Added incentive field also
* 11.0          Bikram          14.01.2013                                      R14.2 SSO - Removed field Is Country Enabled for Incentives
* 12.0          Fenny           10.01.2013                                      CR7944 - "Partner_Opportunity_Access" permission set
* 13.0          Meghana         18.04.2013                                      Fix for Defect 64824- NE: No API access error not allowing users to save changes
* 14.0          Sandhya         22.04.2013                                      Defect fix 65618
* 15.0          Meera           23.10.2013                                      R15.3 CMAP Changes
* 16.0          Ragu            23-12-2014                                      16.03: CR10733 - Lead Management partner users should automatically be enabled for Training
* 17.1          Michael         07-06-2018      FY19-DCS-0802  CR 16007         Removed Provisioned_in_Netexam_on__c as Part of Story# 4988554 
* 17.2          Pallavi         07-06-2018      FY19-DCS-0802  CR16000          Decommissioned NET Exam logic as part of story#4988531
* 17.3          Varsha          05-02-2019      FY20-0402                       Updating contact with eligibletracks
* 17.4          Varsha          22-02-2019      FY20-0402                       Removed isalowedLeadMAnagement
* 18.0          Vasavi.M        16-04-2019      FY20-DCS-0802  CR 17388         Added create Quote & Create Order access for OSC
************************************************************/

public class PartnerApplicationAccessCtrlExt {

    public Contact contactRecord;  
    private Id accId;   
    private list<String> messages;
            
    public User userRecord {get; set;}
    public Account accRecord {get; set;}    
    public boolean isConstructorExceptionTest = false;
    public boolean dealregprevious;
    public boolean leadmgmntprevious;
    
    public boolean isDisabledUser {get; set;}

    public boolean isTrainingEnabled {get; set;} // Rev 3.0 
    public boolean isDealRegEnabled {get; set;} // Rev 3.0
    
    public String errorMessage {get; set;}
    public boolean visibleIncentive {get;set;}
    //public Boolean isalowedLeadMAnagement{get;set;}
    
    public list<Partner_Track__c> listMgPartnerTrack;
    
    public PartnerApplicationAccessCtrlExt(ApexPages.StandardController stdController) {
        contactRecord = (Contact)stdController.getRecord();
        list<Contact> lstContacts = [SELECT Id FROM Contact WHERE Id =:contactRecord.Id LIMIT 1];
                                            
        if(lstContacts.isEmpty()) {
            errorMessage = 'Could not find a valid Contact record';
            return;
        }
        
        // CR2186
        isDisabledUser = false;
        errorMessage = null;        
        //isalowedLeadMAnagement = false;
        
        
        
        // If a user cannot be found via contactId, this condition will be use
        // assuming user created during partner provisioning will always have My Account GUID as part of the username
        String accountGuidCondition = '_%' + contactRecord.Partner_My_Account_GUID__c + '@partner.dell.com%';
        
        try {
            // Try to retrieve a user record that is tied to the contact
            // Meera:CMAP 15.3 Added Enable_Partner_Lead_Management__c
            list<User> lstUsers = [SELECT UserName, Enable_Partner_Admin__c, Enable_Partner_Deal_Registration__c, IsActive, Enable_as_Partner_Group_Administrator__c, Enable_As_Partner_Lead_Super_User__c,Enable_Partner_Lead_Management__c, OSC_Create_Order__c, OSC_Create_Quote__c, OSC_Specialty_Product_Create_Order__c, OSC_Specialty_Product_Create_Quote__c
                                   FROM User WHERE ContactId = :contactRecord.Id]; 
            
            // If no user is retrieved from the above query, try to query by comparing username and my account guid
            if(lstUsers.size() <= 0) {
                isDisabledUser = true; 
                // Meera:CMAP 15.3 Added Enable_Partner_Lead_Management__c
                lstUsers = [SELECT UserName, Enable_Partner_Admin__c, Enable_Partner_Deal_Registration__c,Enable_as_Partner_Group_Administrator__c, Enable_As_Partner_Lead_Super_User__c,Enable_Partner_Lead_Management__c, OSC_Create_Order__c, OSC_Create_Quote__c, OSC_Specialty_Product_Create_Order__c, OSC_Specialty_Product_Create_Quote__c
                            FROM User WHERE UserName LIKE :accountGuidCondition ORDER BY CreatedDate DESC LIMIT 1]; // Rev 9.0 CR 7824 - Modified query to include Enable_As_Partner_Lead_Super_User__c
            }
            else {
                userRecord = lstUsers[0];
             
                // Display error on page if user is inactive
                if(!userRecord.isActive) {
                    errorMessage = 'Application access data cannot be edited for inactive users';
                    return;
                }
            }
           
            // If a user is found by comparing my account guid, this is a disabled user
            if(lstUsers.size() > 0) {
                 userRecord = lstUsers[0];   
                 dealregprevious =  userRecord.Enable_Partner_Deal_Registration__c;
                 leadmgmntprevious = userRecord.Enable_Partner_Lead_Management__c;
            }
            else {
                throw new dellUtil.DellException('Failed to retrieve user record for this contact (\''+ accountGuidCondition.replace('%','') + '\'). If this contact has been disabled, the username may be different from My Account GUID.');
            }
                    
            accId = [SELECT accountId FROM Contact WHERE Id = :contactRecord.Id][0].accountId;
            
            // Modified by Bahar, Ariff to query is Is_Enabled_for_Incentives__c    
            // Meera:15.3 CMAP Changes                   
            accRecord = [SELECT Is_Rebate_Partner__c, Account_Country_Code__c,Is_Enabled_for_Incentives__c,Vendor_Update_Datetime__c,Sales_Channel__r.Name,Partner_Relationship__c 
                       FROM Account
                       WHERE Id = :accId][0]; // 14.0 Modified query to include Vendor_Update_Datetime__c
            
            PartnerCountry pc = new PartnerCountry();
            Map<string, Country__c> countryMap = pc.returnCountryCodeMap();
            if(String.isNotBlank(accRecord.Account_Country_Code__c)){
                Country__c country = countryMap.get(StringUtils.uppercase((accRecord.Account_Country_Code__c).trim()));
            
            // 8.0 - Start
            if(country!=null) { 
                String vendorName = country.Inc_Vendor_Name__c;
                if((vendorName == 'Partner Direct Rewards Center') || (vendorName == 'Partner Advantage') ||  (vendorName == 'Dell Achievers')) {   
                    if(accRecord.Is_Enabled_for_Incentives__c  && (accRecord.Vendor_Update_Datetime__c!=NULL)) {//Ver 14.0
                        visibleIncentive =true;
                    }
                    else {
                        visibleIncentive =false;
                    }
                }
                else {
                    visibleIncentive =false;
                }
            }
            else {
                visibleIncentive =false;
            }
            // End        
            
            // Rev 3.0     
           
            isDealRegEnabled = false;
                  
            list<Country__c> countryList = new list<Country__c>();
            // Meera:15.3 CMAP added lead management related fields
            countryList = [SELECT Training_Enabled__c, Deal_Registration_Enabled__c,Lead_Management_Enabled__c,Lead_Management_Enabled_for_OEM__c,Partner_Relationship__c,
                           Partner_Relationship_for_OEM__c
                            FROM Country__c
                            WHERE Code__c = :accRecord.Account_Country_Code__c];
            if(countryList.size() > 0) {
               
                if(countryList[0].Deal_Registration_Enabled__c == 'Yes') isDealRegEnabled = true;
            }                
            // Rev 3.0-end
            // Meera:15.3 CMAP Addition- Check whether this user can be permitted for lead management for OEM Accounts
            // Commented by Varsha as part of PAM   
            /*             
            if(accRecord.Sales_Channel__r != null &&(accRecord.Sales_Channel__r.Name).contains('OEM') && countryList[0].Lead_Management_Enabled_for_OEM__c == 'Yes' && 
                accRecord.Partner_Relationship__c != null &&(countryList[0].Partner_Relationship_for_OEM__c.contains(accRecord.Partner_Relationship__c) || countryList[0].Partner_Relationship_for_OEM__c.contains('All'))) {
                    isalowedLeadMAnagement = true;
            }
            // For other Accounts           
            else if(countryList[0].Lead_Management_Enabled__c == 'Yes' && accRecord.Partner_Relationship__c != null &&
                (countryList[0].Partner_Relationship__c.contains(accRecord.Partner_Relationship__c) || countryList[0].Partner_Relationship__c.contains('All'))) {
                    isalowedLeadMAnagement = true;
            }*/
            }
            else{
                errorMessage = 'Account country code is not available, cannot manage application access.';
            }
            //System.debug('##isalowedLeadMAnagement:'+isalowedLeadMAnagement);                                   
        }
        catch (Exception e) {
            system.debug('## Caught APEX exception: '+e.getMessage());
            errorMessage = 'A problem has occured: ' + e.getMessage();
        }
    }
    
    public PageReference doSave() {                     
        try {            
            System.debug('## Updating record ##');   
            System.debug('userRecord:'+userRecord.Enable_Partner_Lead_Management__c);
            if(userRecord.Enable_Partner_Deal_Registration__c == false) {
                userRecord.Enable_Partner_Lead_Management__c = false;
                userRecord.Enable_As_Partner_Lead_Super_User__c = false;
            } 
            if(userRecord.Enable_Partner_Lead_Management__c == false) {
                userRecord.Enable_As_Partner_Lead_Super_User__c = false;
            }
            //Added by Varsha
            if(userRecord.Enable_as_Partner_Group_Administrator__c == true){
                userRecord.Enable_Partner_Admin__c = true;
            }
            
            //V18.0 Start
            if(userRecord.OSC_Create_Quote__c == false){
                userRecord.OSC_Create_Order__c = false;
            }
            if(userRecord.OSC_Specialty_Product_Create_Quote__c == false){
                userRecord.OSC_Specialty_Product_Create_Order__c = false;
            }
            //V18.0 End
            
            update userRecord;
            //#5748109: Added by Varsha
            if(userRecord.Enable_as_Partner_Group_Administrator__c == true){
                String strEligibleTracks = '';
                listMgPartnerTrack = [SELECT id, Master_Group_Id__c FROM Partner_Track__c WHERE Master_Group_Id__c =: accId];
                if(listMgPartnerTrack.size()>0){
                    for(partner_track__c pt: listMgPartnerTrack) {
                        if(String.isNotBlank(strEligibleTracks)){
                            strEligibleTracks +=';'+pt.id; 
                        }
                        else{
                            strEligibleTracks += pt.id;  
                        }
                    }
                    System.debug('strEligibleTracks ::'+strEligibleTracks );
                    //strEligibleTracks.removeEnd(';');
                    contactRecord.EligibleTracks__c = strEligibleTracks;
                    contactRecord.Preferred_Track__c = listMgPartnerTrack[0].id;
                    contactRecord.Selected_Track__c = listMgPartnerTrack[0].id;
                }
            }//Varsha's Code End
          
            update contactRecord;        
           
        } 
        catch (DmlException e) {
            //system.debug('## Caught APEX exception: '+e.getMessage());
            //throw e;
            errorMessage = 'A problem has occured: '+e.getMessage();
        }       
        //return new PageReference('/'+contactRecord.Id); // Fenny [10 Jan 2013]: CR7944 - Commented, because need to invoke doPermissionSetAssignment()  
        return null;
    }
    
    public pagereference showorHideLeadDetails() {
        System.debug('Enable_Partner_Deal_Registration__c:'+userRecord.Enable_Partner_Deal_Registration__c);
        System.debug('Enable_Partner_Lead_Management__c:'+userRecord.Enable_Partner_Lead_Management__c);
        System.debug('userRecord.Enable_As_Partner_Lead_Super_User__c:'+userRecord.Enable_As_Partner_Lead_Super_User__c);
        //System.debug('##isalowedLeadMAnagement:'+isalowedLeadMAnagement);
       
        /*if(userRecord.Enable_Partner_Deal_Registration__c == false) {
            userRecord.Enable_Partner_Lead_Management__c = false;
        }
        if(userRecord.Enable_Partner_Lead_Management__c == false) {
            userRecord.Enable_As_Partner_Lead_Super_User__c = false;
        }*/
        if(dealregprevious == false || userRecord.Enable_Partner_Deal_Registration__c == false) {
            userRecord.Enable_Partner_Lead_Management__c = false;
            userRecord.Enable_As_Partner_Lead_Super_User__c = false;
        }
        if(leadmgmntprevious == false ||userRecord.Enable_Partner_Lead_Management__c == false ) {
            userRecord.Enable_As_Partner_Lead_Super_User__c = false;
        }
        System.debug('Enable_Partner_Deal_Registration__c2:'+userRecord.Enable_Partner_Deal_Registration__c);
        System.debug('Enable_Partner_Lead_Management__c2:'+userRecord.Enable_Partner_Lead_Management__c);
        System.debug('userRecord.Enable_As_Partner_Lead_Super_User__c2:'+userRecord.Enable_As_Partner_Lead_Super_User__c);
        //System.debug('##isalowedLeadMAnagement2:'+isalowedLeadMAnagement);
        dealregprevious = userRecord.Enable_Partner_Deal_Registration__c;
        leadmgmntprevious = userRecord.Enable_Partner_Lead_Management__c;
        return null;
    }
    
    
    
    // Fenny [10 Jan 2013]: CR7944
    public PageReference doPermissionSetAssignment() {
        try {
            // v16.0 - Start
           /* if(!validateTrainingEnabled()) {
                return null;
            }*/
            // v16.0 - End
            
            list<PermissionSet> permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Partner_Opportunity_Access'];
            if((permSet != null) && (permSet.size() > 0)) {
                if(userRecord.Enable_Partner_Deal_Registration__c) {
                    list<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userRecord.Id and PermissionSetId = :permSet[0].Id];
                    if((assignments == null) || (assignments.size() == 0)) {
                        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId = userRecord.Id, PermissionSetId = permSet[0].Id);
                        insert assignment;
                    }
                }
                else {
                    list<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userRecord.Id and PermissionSetId = :permSet[0].Id];
                    delete assignments;
                }
            }
            else {
                string err = 'A problem has occured: Permission set \'Partner_Opportunity_Access\' not found. User ID = ' + userRecord.Id;
                list<string> recipients = new list<string>{'SFDC-ApexDev@dell.com'};
                emailUtils.sendTextEmail(recipients, 'Permission set \'Partner_Opportunity_Access\' not found', err);
            }
        }
        catch(Exception ex) {
            errorMessage = 'A problem has occured: '+ex.getMessage();
            return null;
        }   
        // Rev 13.0
       /* if(NetExamerrorMessage != '') { // If error from NetExam logic... do not redirect to Contact page
            errorMessage = NetExamerrorMessage;
            return null;
        }
        else {
            return new PageReference('/'+contactRecord.Id);
        }*/
        return new PageReference('/'+contactRecord.Id);
    }
    
    public PageReference doBack() {     
        return new PageReference('/'+contactRecord.Id);     
    }
    
    public list<SelectOption> YesOrNo {
        get {
            YesOrNo = new list<SelectOption> ();
            YesOrNo.add(new SelectOption ('true', 'Yes'));
            YesOrNo.add(new SelectOption ('false', 'No'));
            return YesOrNo;
        } 
        set;                
    }
    
       
    
    // CR2186 - added to remove all application access and update Partner My Account GUID to null. Will also synchronize to CMI.
    public PageReference disablePartnerUser() {
        userRecord.Enable_Partner_Admin__c = false;
        userRecord.Enable_Partner_Deal_Registration__c = false;
        userRecord.Enable_Partner_Lead_Management__c = false; // CMAP15.3
        userRecord.Enable_As_Partner_Lead_Super_User__c =  false; // Rev 9.0 CR 7824
        
        //V18.0 Start
        userRecord.OSC_Create_Order__c = false;
        userRecord.OSC_Create_Quote__c = false;
        userRecord.OSC_Specialty_Product_Create_Order__c = false; // CMAP15.3
        userRecord.OSC_Specialty_Product_Create_Quote__c =  false; 
        //v18.0 End
        
        contactRecord.Campaign_Builder__c = false; // Rev 4.0
        contactRecord.Premier_Partner__c = false;
        contactRecord.Transactional_store__c = false; // Rev 4.0
        contactRecord.Warranty_Parts_Info__c = false; // Rev 4.0
        contactRecord.Is_Rebate_User__c = false;
        // Added as part of 14.2 SSO
        contactRecord.Is_Enabled_for_Incentives__c = false;
        contactRecord.Vendor_Update_Datetime__c = null;
        //Added by Michael
        userRecord.Enable_as_Partner_Group_Administrator__c = false;
        contactRecord.Allow_Partner_Central_User__c = false;
        contactRecord.Allow_Program_Tracker__c = false;
        contactRecord.Enable_SPL_view_with_Disti_pricing__c = false;
        contactRecord.SPL_view_with_partner_recommeded_pricing__c = false;
        contactRecord.Enable_SPL_View_with_All_country_Price__c = false;
        contactRecord.Allow_RFP_and_Proposal_Express_Tool__c = false;
        contactRecord.Is_MDF_User__c = false;
        //Michael's code end
        
        PageReference returnPage = doSave();

        return null;
    }
   
    // Raymond 20100202: Added. This method will be call from button to synchronize
    public PageReference syncToPartnerProfileDB() {
        try {
            String responseText = PartnerProfileIntegration.integratePartnerDataWithResponse(contactRecord.Id, userRecord.Id);
            if(responseText != null && responseText.contains('<InsertSegmentationDataResult>true</InsertSegmentationDataResult>')) {
                contactRecord.Partner_My_Account_GUID__c = null;
                update contactRecord;       
            }
            else {
                //list<String> errorList = PartnerProfileIntegration.parseCMIResponse(responseText, 'Reason', XMLTag.CHARACTERS);
                throw new dellUtil.DellException('Failed to update CMI. Please raise a trouble ticket.');
                //throw new dellUtil.DellException(StringUtils.joinStringsinList(errorList, '. '));
            }
            return new PageReference('/'+contactRecord.Id);
        }
        catch (Exception e) {
            system.debug('## Caught APEX exception: '+e.getMessage());
            errorMessage = 'A problem has occured: ' + e.getMessage();
            return null;
        }                   
    }

    // CR2186 - This is created specially to be called from testmethods. Partner_My_Account_GUID__c is null
    // when we use the normal way of calling the method, which causes the test to fail
    public void disablePartnerUserFromTest(Id userId, Id contactId) {
        // Rev 4.0
        contactRecord = [SELECT Id,Campaign_Builder__c,Premier_Partner__c,
                                Transactional_Store__c,Warranty_parts_Info__c,
                                Is_Rebate_User__c, Partner_My_Account_GUID__c                           
                         FROM Contact WHERE Id=:contactId];
                         
        //V18.0 added OSC_Create_Order__c, OSC_Create_Quote__c, OSC_Specialty_Product_Create_Order__c, OSC_Specialty_Product_Create_Quote__c
        userRecord = [SELECT Id,username,Enable_Partner_Admin__c,Enable_Partner_Deal_Registration__c ,Enable_as_Partner_Group_Administrator__c, Enable_As_Partner_Lead_Super_User__c,Enable_Partner_Lead_Management__c,OSC_Create_Order__c, OSC_Create_Quote__c, OSC_Specialty_Product_Create_Order__c, OSC_Specialty_Product_Create_Quote__c FROM User WHERE Id=:userId];
    
        disablePartnerUser();       
    }
    
    public void checkIsUserDisabled() {
        if(isDisabledUser && errorMessage == null) {
            disablePartnerUser();
        }
    }
}