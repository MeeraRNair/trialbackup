/* 
Author: Natesh Alagiri

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     08-Jul-2011     Natesh Alagiri  Created for CR6236 and CR6238
*/
global class GAMMemberQueueSchedule implements Schedulable{
    global void execute(SchedulableContext sc) {
        
        GAMMemberQueueBatch batchObj = new GAMMemberQueueBatch();
        batchObj.query = 'SELECT Id FROM Group_Member_Queue__c';
        database.executebatch(batchObj,1000);
    }
}