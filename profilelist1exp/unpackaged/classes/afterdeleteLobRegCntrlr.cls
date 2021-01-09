/*
Description : A class to capture all deleted LOB Registration records and updating the Partner Hub Records Deleted object

History:
Version   Date            Modified By       Description     
--------------------------------------------------------------------------------------
1.0       08-Sept-2015    Nisha C O         A class to capture all deleted LOB Registration records and updating the Partner Hub Records Deleted object
*/

public class afterdeleteLobRegCntrlr{
    public list<lob_registration__c> deletedLOBRegList = new list<lob_registration__c>();
    public list<Partner_Hub_Record_Deleted__c> partnerHubDeletedToUpdate = new list<Partner_Hub_Record_Deleted__c>();
    
    public void insertPartnerHubRecDeleted(list<lob_registration__c> oldLobRegList){
        
        for(Lob_Registration__c lobrec: oldLobRegList){
        
            Partner_Hub_Record_Deleted__c PartnerHubRecord = new Partner_Hub_Record_Deleted__c();
            PartnerHubRecord.Key_Identifier__c = lobrec.Name;
            PartnerHubRecord.Record_GUID__c = lobrec.Id;
            PartnerHubRecord.Type__c = 'LOB Registration';
            partnerHubDeletedToUpdate.add(PartnerHubRecord);
        }
        
        If (partnerHubDeletedToUpdate.Size() > 0){
            insert partnerHubDeletedToUpdate;
            system.debug('--------------------------------- partner del list' + partnerHubDeletedToUpdate);
        }
    }
}