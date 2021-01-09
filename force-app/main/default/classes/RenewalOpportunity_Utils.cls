/*****************************************************************************
*CreatedBy : Shubham Bhatt
*
* Purpose: To accomodate the values of frequently calling fields while comparing: related to APOS Opportunity
*
*Date : 13thAug2019
*******************************************************************************/
Public without sharing Class RenewalOpportunity_Utils {
    Public Static Id aposRecordTypeId =  RenewalsConstants.aposRecordTypeId;
    Public Static String strsourceSystemEMCCore =   RenewalsConstants.strsourceSystemEMCCore;
    Public Static String strsourceSystemRenewalsEBIA = RenewalsConstants.strsourceSystemRenewalsEBIA;
    Public Static String strteamMemberRole =  RenewalsConstants.strteamMemberRole;
    Public Static String strtypeEMCRenewalsDirect =  RenewalsConstants.strtypeEMCRenewalsDirect;
    Public Static String strtypeEMCRenewalsInDirect =  RenewalsConstants.strtypeEMCRenewalsInDirect;
    Public Static String strRenewalWaitingSync= RenewalsConstants.strRenewalWaitingSync;
    
    Public static list<opportunity> checkIfRenewalsOppty(list<sobject> listSobj){ 
        list<opportunity> listOpty = New list<opportunity> ();
        
        For (opportunity opp : (List<opportunity>)listSobj){
            If ((opp.recordtypeid == RenewalOpportunity_Utils.aposRecordTypeId) && (opp.Source_System__c == RenewalOpportunity_Utils.strsourceSystemEMCCore || opp.Source_System__c == RenewalOpportunity_Utils.strsourceSystemRenewalsEBIA ||opp.type == RenewalOpportunity_Utils.strtypeEMCRenewalsDirect || opp.type == RenewalOpportunity_Utils.strtypeEMCRenewalsInDirect)){
                listOpty.add(opp);
            }
        }  
        return listOpty;
    }
}