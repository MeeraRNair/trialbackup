/*
* Author   : Harsha
* Purpose  : Business logics / functionalities implemented on Territory Plan to share record.
* 
* Revision CR Number   	Release No      Date            Modified By     Description
* -------- ---------   	----------      -----------     ------------    -----------
* 1.0      CR15172    	FY18-DCS-0102   27-Nov-2017     Harsha          Created for sharing Territory Plan to assigned new manager
*/

public class TP_Sharing {
    //list<id> successTPShareIds;
    
    public static void shareWithNewManager(list<Territory_Plan__c> listTP, map<id, Territory_Plan__c> mapOldTP){
        list<id> successTPShareIds = shareWithNewManager(listTP);
        deleteOldManagerSharing(successTPShareIds, mapOldTP);
    }
    
    public static list<id> shareWithNewManager(list<Territory_Plan__c> listTP){
        List<Territory_Plan__Share> tpShrs  = new List<Territory_Plan__Share>();
       list<id> successTPShareIds = new list<id>();
        if(listTP != null){
            for(Territory_Plan__c tp : listTP){
                Territory_Plan__Share mngrShr = new Territory_Plan__Share();
                mngrShr.ParentId = tp.Id;
                mngrShr.UserOrGroupId = tp.Manager_Approver__c;
                mngrShr.AccessLevel = 'edit';
                mngrShr.RowCause = Schema.Territory_Plan__Share.RowCause.manual;
                tpShrs.add(mngrShr);
            }
            //system.debug('tpShrs : '+tpShrs);
            Database.SaveResult[] lsr = Database.insert(tpShrs,false);
            system.debug('results : '+lsr);
            
            Integer i=0;
            // Process the save results
            
            for(Database.SaveResult sr : lsr){
                if(sr.isSuccess()){
                    successTPShareIds.add(sr.getId());
                }               
                else{
                    // Get the first save result error
                    Database.Error err = sr.getErrors()[0];
                    
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                         &&  err.getMessage().contains('AccessLevel'))){
                             // Throw an error when the error is not related to trivial access level.
                             trigger.newMap.get(tpShrs[i].ParentId).
                                 addError(
                                     'Unable to grant sharing access due to following exception: '
                                     + err.getMessage());
                         }
                }
                i++;
            }  
            //system.debug('successTPShareIds '+successTPShareIds);
        }
        return successTPShareIds;
    }
    
    public static void deleteOldManagerSharing(list<id> successTPShareIds, map<id, Territory_plan__c> mapOldTP){
    	system.debug('------deleteOldManagerSharing------');
        list<id> tpSuccessId = new list<Id>();
        set<id> oldManagerIdset = new set<Id>();
        for(Territory_plan__share tp_shareNew : [Select id, parentID from territory_plan__share where id in:successTPShareIds]){
            tpsuccessId.add(tp_shareNew.parentID);
            Territory_plan__c tpOld = mapOldTP.get(tp_shareNew.parentID);
            Id oldMangId = tpOld.Manager_Approver__c;
            if(oldMangId!=null){
            	oldManagerIDset.add(oldMangId);
            }
        }
        //system.debug('oldManagerIDset '+oldManagerIDset);
        //system.debug('tpSuccessId '+tpSuccessId);
        if(tpSuccessId!= null && oldManagerIdset!= null){
        	list<territory_plan__share> tp_shareDel = [Select id, parentID, AccessLevel, RowCause, UserOrGroupId from territory_plan__share 
                                                       where Id not in : successTPShareIds and parentId in:tpSuccessId 
                                                       and RowCause='Manual' and UserOrGroupId in :oldManagerIdset];
        	//system.debug('tp_shareDel : '+tp_shareDel);
        	Delete tp_shareDel;
        }
    }
}