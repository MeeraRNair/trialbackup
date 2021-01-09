/*
 * Author   : Ragu
 * Purpose  : Gives abstract view of all the business logics / functionality implemented on Account.
 * 
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 10751    16.03           03-Dec-2014     Ragu            Created for implementing "Centralized by Org" trigger architecture - Best practices
 * 2.0      CR 12369    16.12           16-Dec-2015     Ragu            Defect 216660 - LM2_1_104-Add RAD account field into Direct Lead 2.0 page
 * 3.0      CR 12487    16.12           17-Dec-2015     Dipin Raju      FAP Dell Competency Email to Partner Admins
 * 4.0      CR 12507    16.12           06-Jan-2016     Krishnamoorthi  Auto populate the Account field "Industry Hidden"
 * 5.0      CR 12695    DCS0401         18-Mar-2016     Devika          Commented the code calling the FAP method.
 * 6.0      CR 13041    SAR14022        12-Apr-2016     Sui Yee         Commented the code updating RAD_Code__c at lead record when account RAD code is updated.
 * 7.0      CR 13136    0602            10-May-2016     Sui Yee         Bypass all the future call if it is batch upload
 * 8.0      CR 13220                    09-June-2016    Swathi          Controlling protect or optimize flag fields enabled either one on account record
 * 9.0      CR 13627    FY17-DCS-0103   18-Oct-2016     Gan             to activate account in affinity for account that meets the criteria.
 * 10.0     CR 14781    FY18-DCS-1001   14-Aug-2017     Ashok           LM2_MDM_5-Retire Update Account Web Service
 * 11.0     CR 14884    FY18-DCS-1001   06-Sep-2017     Naga            Commented line number 175 to 178 to stop triggering email when competencies updated.
 * 12.0     CR 15690    FY19-DCE-0602   27-Apr-2018     Emily           Field Trip clean up for Account (Part 2)
 * 13.0     CR 17545    FY20-0702       24-May-2019     Fenny           AccountTriggerHandler obsolete
 * 14.0		CR 18303	FY20-0102		26-Nov-2019		Fenny			To make AccountRecordSelect accessible by other features
*/

public class AccountTriggerHandler extends TriggerHandler {

    public static AccountRecordSelector accRecordSelector;
    public static AccountTriggerHandler handler;
         
    public override void getRecordSelector() {
        handler = this;
        accRecordSelector = new AccountRecordSelector(Trigger.new, Trigger.oldMap, this);
    }
   /* 
    public override void onBeforeInsert() {
        if(!accRecordSelector.setProdRepEmails.isEmpty()) {
            // Validate Product Representative Email 
            AccountValidator.validateProdRepEmail(accRecordSelector.lstAccountsForEmailValidation, accRecordSelector.setProdRepEmails);
        }
        
        // Validate whether incentives are enabled for the specified country or not.
        AccountValidator.validateCountryForIncentives(Trigger.new);
        
        // Check for Credit Card informations stored in Description field
        AccountValidator.checkCreditCardInfoInDescription(Trigger.new, null);
        
        // Populate account fields on before insert
        AccountFieldPopulator.populateFieldsOnBeforeInsert(Trigger.new);
        
        // Populate account fields on before insert and update
        AccountFieldPopulator.populateFieldsOnBeforeInsertUpdate(Trigger.new);
        
        // Copy enabled for incentive from Lead to Account on Account insertion
        AccountFieldPopulator.syncIncentivesEnabled(Trigger.new, null, this);
        
        //v12.0 //v4.0 - To auto populate the Account field "Industry Hidden"
        //AccountFieldPopulator.populateCRMTFields(Trigger.new, null);
    }
    
    public override void onBeforeUpdate() {
    
           AccountUtilities.UpdateFields(trigger.new);
        if(!accRecordSelector.setProdRepEmails.isEmpty()) {
            // Validate Product Representative Email 
            AccountValidator.validateProdRepEmail(accRecordSelector.lstAccountsForEmailValidation, accRecordSelector.setProdRepEmails);
        }
    
        
        
        
        // Validate whether incentives are enabled for the specified country or not
        AccountValidator.validateCountryForIncentives(Trigger.new);
        
        // Check for Credit Card informations stored in Description field
        AccountValidator.checkCreditCardInfoInDescription(Trigger.new, (map<Id, Account>)Trigger.oldMap);
        
        // Update LOB flag to false when recordtype is changed from End User to Partner.
        AccountFieldPopulator.populateParticipatingInLOBProgram(Trigger.new, (map<Id, Account>)Trigger.oldMap);
        
        // Populate account fields on before insert and update
        AccountFieldPopulator.populateFieldsOnBeforeInsertUpdate(Trigger.new);
        
        // Copy enabled for incentive from Lead to Account / Account to Lead on Account update
        AccountFieldPopulator.syncIncentivesEnabled(Trigger.new, (map<Id, Account>)Trigger.oldMap, this);
        
        // Populate Boomi - CMI integration related fields
        AccountFieldPopulator.populateBoomiCMIRelatedFields(Trigger.new, (map<Id, Account>)Trigger.oldMap);
        
        // Validate Inconsistency_in_Lead_Management_data__c and populate it for Partner Accounts
        AccountUtilities.checkInconsistencyInLMData((map<Id, Account>)Trigger.newMap, (map<Id, Account>)Trigger.oldMap);
        
        //v12.0 //CR 12461 - CRMT field "Customer Reference Relationship Owner" population in Account
        //AccountFieldPopulator.populateCRMTFields(Trigger.new, (map<Id, Account>)Trigger.oldMap);
        
        //CR 13220  -   Controlling protect or optimize flag fields enabled either one on account record
        AccountFieldPopulator.populateProtectOptimizeFlagFieldsOnBeforeUpdate(Trigger.new,(map<Id, Account>)Trigger.oldMap);
    }
    
    public override void onAfterInsert() {
        if(!accRecordSelector.mapAccountsForCertificationTracker.isEmpty()) {
            // Create Certification_Tracker__c whenever Partner Account of Type 'Partner' is created.
            AccountCertificationTracker.createCertificationTrackers(accRecordSelector.mapAccountsForCertificationTracker.keySet());
        }
        //v7.0 Bypass future call if it is batch upload
        if(!System.isBatch() && !accRecordSelector.mapAccountsForIntegration.isEmpty() && !GlobalVariables.BYPASS_FUTURE_CALLS) {
            // Synchronize to CMI whenever Partner Account is Created / Updated (16-Dec-2009: Raymond => CR2150) => @future call
            AccountIntegrationUtilities.integratePartnerAccounts(accRecordSelector.mapAccountsForIntegration);
        }
        //v7.0 Bypass future call if it is batch upload
        if(!System.isBatch() && !accRecordSelector.mapAccIdSalesChannelId.isEmpty()) {
            // Associate a Sales Channel Group record to Account if Sales_Channel_ID__c is not null
            AccountUtilities.associateAccount_SalesChannelGroupHelper(accRecordSelector.mapAccIdSalesChannelId);
        }
    }
    
    public override void onAfterUpdate() {
         
       //AccountUtilities.sendEmailOnFieldChange(trigger.oldMap,trigger.New);
       List<Account> lstAcc =  (List<Account>) trigger.New;
       Map<Id,Account> oldMap = (Map<Id,Account>) trigger.oldMap;

       boolean bflag = false;
       system.debug('######  lstAcc' + lstAcc );
       for(Account objAcc: lstAcc){
       if(bflag == false && (oldMap.get(objAcc.id).LOBi_Preferred_Partner_of_Record__c != objAcc.LOBi_Preferred_Partner_of_Record__c ||
          oldMap.get(objAcc.id).LOBi_Preferred_Partner_of_Record_Network__c != objAcc.LOBi_Preferred_Partner_of_Record_Network__c || 
            oldMap.get(objAcc.id).LOBi_Preferred_Partner_of_Record_Storage__c != objAcc.LOBi_Preferred_Partner_of_Record_Storage__c ||
            oldMap.get(objAcc.id).LOBi_Preferred_Partner_of_Record_Server__c != objAcc.LOBi_Preferred_Partner_of_Record_Server__c)){
               bflag = true; 
            }
       }
              system.debug('######  bflag ' + bflag );

         if(bflag)
            AccountUtilities.sendEmailOnFieldChange(trigger.oldMap,trigger.New);

        //
        //Changes for US 194867
        //if(!accRecordSelector.setLOBAccountIds.isEmpty()) {
            // Delete all related Account_Branch__c & LOB_Registration__c records if Participating_in_LOB_Program__c on Account is set to false.
        //    AccountBranchUtils.deleteAllAccBrAndLOBs(accRecordSelector.setLOBAccountIds);
        //}
        //
        if(!accRecordSelector.setInactivePartnerAccountIds.isEmpty()) {
            // Deactivate all related End Customer records when Partner Account status is set to Inactive.
            PartnerEndUserDataCaptureUtils.deActivateCustomers(accRecordSelector.setInactivePartnerAccountIds);
        }
        
        if(!accRecordSelector.setAccountIdsToDisableIncentives.isEmpty()) {
            // Disable Is_Enabled_for_Incentives__c checkbox in all related Contact records whenever Is_Enabled_for_Incentives__c on Account is set to false.
            AccountUtilities.disableIncentivesInRelatedContacts(accRecordSelector.setAccountIdsToDisableIncentives);
        }
        
        if(!accRecordSelector.mapCountryUpdatedAccounts.isEmpty()) {
            // Populate Email__c on LOB_Registration__c object based on the Account_Country__c selected in the Account.
            AccountUtilities.updateLOBRegistrationEmails(accRecordSelector.mapCountryUpdatedAccounts);
        }
        
        if(!accRecordSelector.mapAccountsForCertificationProcess.isEmpty()) {
            // Update related Certification_Tracker__c details of an Account whenever Partner_Relationship__c is changed across Registered, Preferred, Premier.
            AccountCertificationTracker.updateCertificationTrackerDetails(accRecordSelector.mapAccountsForCertificationProcess, (map<Id, Account>)Trigger.newMap, (map<Id, Account>)Trigger.oldMap);
            
            // Send email to partner admin users whenever Partner_Relationship__c on an Account is changed to Preferred / Premier.
            AccountEmailUtilities.sendEmailToPartnerAdminUsers(accRecordSelector.mapAccountsForCertificationProcess, (map<Id, Account>)Trigger.newMap, (map<Id, Account>)Trigger.oldMap);
        }
        
        if(!accRecordSelector.mapAccountsForCertificationTracker.isEmpty()) {
            // Create Certification_Tracker__c whenever Partner Account of Type 'Partner' is updated and it already has Certification_Tracker__c
            AccountCertificationTracker.checkAndCreateCertificationTrackers(accRecordSelector.mapAccountsForCertificationTracker.keySet());
        }
        
        //v7.0 Bypass future call if it is batch upload
          if(!System.isBatch() && !accRecordSelector.mapAccountsForIntegration.isEmpty() && !GlobalVariables.BYPASS_FUTURE_CALLS) {
            // Synchronize to CMI whenever Partner Account is Created / Updated (16-Dec-2009: Raymond => CR2150) => @future call
            AccountIntegrationUtilities.integratePartnerAccounts(accRecordSelector.mapAccountsForIntegration);
        }
        
         //v7.0 Bypass future call if it is batch upload
        if(!System.isBatch() && !accRecordSelector.mapAccIdSalesChannelId.isEmpty()) {
            // Associate a Sales Channel Group record to Account if Sales_Channel_ID__c is updated
            AccountUtilities.associateAccount_SalesChannelGroupHelper(accRecordSelector.mapAccIdSalesChannelId);
        }
        
        if(!accRecordSelector.setPrimaryContactUpdatedAccIds.isEmpty()) {
            // Allow for Data Loading on Primary Contact
            AccountUtilities.contactUpdateHelper(accRecordSelector.setPrimaryContactUpdatedConIds, accRecordSelector.setPrimaryContactUpdatedAccIds);
        }
        
        if(!accRecordSelector.setInactiveAccountIds.isEmpty()) {
            // Delete AccountTeamMembers for Inactive Accounts.
            AccountUtilities.deleteAccountTeamMembersHelper(accRecordSelector.setInactiveAccountIds);
        }
        
        // v5.0 
        //if(!accRecordSelector.setAccountIdsForPartnerFinder.isEmpty()) {
        //    // Send email to Partner Admin for Partner Finder (16-May-2012: Murphy => CR7109)
        //   //AccountUtils.SendEmailToPartnerAdmin(Utility.getList(accRecordSelector.setAccountIdsForPartnerFinder));
        //}
        //
        
//v3.0: Start
//        if(!accRecordSelector.setAccountIdsForCompetencyEmail.isEmpty()) {
//            // Send email to Partner Admin when there is a change in Dell Competency
//            AccountUtils.SendCompetencyEmailToPartnerAdmin(Utility.getList(accRecordSelector.setAccountIdsForCompetencyEmail));
//        } 
//        
//v3.0: End
        
        // Create Account Work Item and Account Share on Owner Change. 
        AccountUtilities.handleAccountOwnerChange((map<Id, Account>)Trigger.newMap, (map<Id, Account>)Trigger.oldMap);
        
        // Update Partner Requests whenever Legacy_ID__c is updated in the Account.
        AccountUtilities.updateAccountPartnerRequestsHelper((map<Id, Account>)Trigger.newMap, (map<Id, Account>)Trigger.oldMap);
        
        
        //Subramanyam m {Team Astra FY19 0502 release}
        // Updating the oppty and user fields when an  account name is changed
        UpdateAccountName.update_accountNames((map<Id, Account>)Trigger.newMap, (map<Id, Account>)Trigger.oldMap);
        
        // v2.0 - Populate RAD_Code__c field in Lead
        // v6.0 - Commented the code updating RAD_Code__c at lead record when account RAD code is updated - SAR 14022
        //AccountChildUpdater.updateLeadRecords((map<Id, Account>)Trigger.newMap, (map<Id, Account>)Trigger.oldMap);
    
        //9.0
        //10.0 - Retire update account webservice
        //
        //if(!System.isBatch() && !System.isFuture() && !accRecordSelector.setAccountIdsStatusU.isEmpty() && !TriggerExecutionController.skipActivateAccount()) {
          
        //      // Associate a Sales Channel Group record to Account if Sales_Channel_ID__c is not null
        //    system.debug('ZY: Calling new method');
        //    AccountSuggestionIntegrationCIL.activateAccountInAffinityGivenAccId(accRecordSelector.setAccountIdsStatusU);
        //    //set this for 2 times it is being called from field update
        //    TriggerExecutionController.setSkipActivateAccount(true);
        //}
        //
    }
    */
    

}