/* 
Author: Natesh Alagiri

History:
Version Date            Modified By     Description     
---------------------------------------------------------------------------------------------------------------------------------
1.0     08-Jul-2011     Natesh Alagiri  Created for CR6236 and CR6238
2.0     10-Apr-2012     Krishnamoorthi  Modified for R13.4 Maintenance CR 6573 -- To Give Product Catalog visibility to GAM users
*/
global class GAMGroupMemberSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        
        GAMGroupMemberBatch batchObj = new GAMGroupMemberBatch();
        batchObj.query = 'SELECT Id,Group_ID__c,GAM_User__c,Operation__c,Child_Group_Id__c '+
                         'FROM Group_Member_Queue__c ' +
                         'WHERE CreatedDate = LAST_N_DAYS:3 ' +
                         'ORDER BY Operation__c';
        database.executebatch(batchObj,400);
    }
}