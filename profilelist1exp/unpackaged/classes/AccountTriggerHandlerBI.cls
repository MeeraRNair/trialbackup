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
 * 13.0     CR 17545    FY20-0702       23-May-2019     Fenny           Code refactoring: execution configuratble by Trigger_Handler__mdt
 *                                                                      Above histories, and below method calls are copied from AccountTriggerHanlder
 * 14.0		CR 18303	FY20-0102		26-Nov-2019		Fenny			To make AccountRecordSelect accessible by other features
*/
public class AccountTriggerHandlerBI implements BeforeInsert {
    
   public void handleBeforeInsert(List<sObject> listNew){
        system.debug('Entered Account handleBeforeInsert');
        system.debug(listNew);
        
         if(!AccountTriggerHandler.accRecordSelector.setProdRepEmails.isEmpty()) {
            // Validate Product Representative Email 
            AccountValidator.validateProdRepEmail(AccountTriggerHandler.accRecordSelector.lstAccountsForEmailValidation, AccountTriggerHandler.accRecordSelector.setProdRepEmails);
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
        AccountFieldPopulator.syncIncentivesEnabled(Trigger.new, null, AccountTriggerHandler.handler);
        
        /*v12.0 //v4.0 - To auto populate the Account field "Industry Hidden"
        AccountFieldPopulator.populateCRMTFields(Trigger.new, null);*/
    }

}