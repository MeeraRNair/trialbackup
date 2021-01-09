/*
* Author   : Ashok
* Purpose  : This is the controller to delete Account Chatter feed on lead Conversion.
* 
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0      14117      FY18 DCS-0502   29-Feb-2017     Ashok           LM2_Account chatter feed deletion after lead conversion
*/

public class DeleteAccountFeedFutureClass {

 @future
 public static void DeleteFeed(List<ID> recordIds)
  { 
       list<AccountFeed> listAccountFeedsToDelete = new list<AccountFeed>(); 
        FOR(AccountFeed objFeed : [SELECT Id,Type,ParentId,(SELECT Id,FieldName FROM FeedTrackedChanges) 
                                       FROM AccountFeed WHERE Type = 'TrackedChange' and ParentId in: recordIds]){
                                       system.debug('ObjFeed....'+ObjFeed); 
                                       FOR(FeedTrackedChange objChange : objFeed.FeedTrackedChanges){
                                           system.debug('objChange...'+objChange);
                                           IF(objChange.FieldName == 'accountCreatedFromLead' || objChange.FieldName == 'accountUpdatedByLead'){
                                                System.debug('Accound Feeds To Delete is ' + listAccountFeedsToDelete);
                                                listAccountFeedsToDelete.add(objFeed);
                                                System.debug('Accound Feeds To Delete is ' + listAccountFeedsToDelete);
                                           }

                                       }

                                   }
        System.debug('Accound Feeds To Delete is ' + listAccountFeedsToDelete);
        System.debug('Accound Feeds To Delete size is ' + listAccountFeedsToDelete.size());

        DELETE listAccountFeedsToDelete;

         System.debug('Accound Feeds To Delete is ' + listAccountFeedsToDelete); 
}

public static void invokeDelAccountFeed(List<Lead> leadToDel){
    Set<String> convertedLeads = new Set<String>();
    List<AccountFeed> listAccountFeedsToDelete = new List<AccountFeed>();
    List<Id> convertedAccountList = new List<Id>();

    FOR(Lead l : leadToDel){
        IF(l.IsConverted == TRUE){
            convertedLeads.add(l.Id);
            system.debug('convertedLead'+l.Id);
            convertedAccountList.add(l.convertedAccountId);
            system.debug('convertedAccountId'+l.convertedAccountId);
        }
    }

    system.debug('Converted Leads size is ' + convertedLeads.size());

    system.debug('convertedAccountList'+convertedAccountList);

    IF(convertedLeads.size() > 0){
        DeleteFeed(convertedAccountList);
    }
}
}