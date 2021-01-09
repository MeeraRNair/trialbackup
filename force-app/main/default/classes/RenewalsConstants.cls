/*****************************************************************************
*CreatedBy : Shubham Bhatt
*
* Purpose: To accomodate the values related to Renewal process referring from custom setting (this class is only for variables not for adding methods or any logic)
*
*Date : 19Nov2019
*******************************************************************************/
public without sharing class RenewalsConstants {
    Public Static Id aposRecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().Get('APOS').getRecordTypeId();
    Public Static String strsourceSystemEMCCore = RenewalsLabels__c.getInstance('sourceSystem_EMC_Core')!=null? RenewalsLabels__c.getInstance('sourceSystem_EMC_Core').labelValue__c:'';
    Public Static String strsourceSystemRenewalsEBIA = RenewalsLabels__c.getInstance('sourceSystem_Renewals_EBIA')!=null? RenewalsLabels__c.getInstance('sourceSystem_Renewals_EBIA').labelValue__c:'';
    Public Static String strteamMemberRole = RenewalsLabels__c.getInstance('teamMemberRole')!=null? RenewalsLabels__c.getInstance('teamMemberRole').labelValue__c:'';
    Public Static String strtypeEMCRenewalsDirect = RenewalsLabels__c.getInstance('type_EMC_Renewals_Direct')!=null? RenewalsLabels__c.getInstance('type_EMC_Renewals_Direct').labelValue__c:'';
    Public Static String strtypeEMCRenewalsInDirect = RenewalsLabels__c.getInstance('type_EMC_Renewals_In_Direct')!=null? RenewalsLabels__c.getInstance('type_EMC_Renewals_In_Direct').labelValue__c:'';
    Public Static String strRenewalWaitingSync= RenewalsLabels__c.getInstance('RenewalWaitingSync')!=null? RenewalsLabels__c.getInstance('RenewalWaitingSync').labelValue__c:'';
    
    
}