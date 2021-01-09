/* 
History:
Version     Date            Modified By                         CR          Description     
--------------------------------------------------------------------------------------
1.0         16-May-2016     Noorul Syuhada                      13094       Story 1120079:Update HR email changes automatically in SFDC
*/


global class BatchUserEmailUpdateScheduler implements Schedulable{
   global void execute(SchedulableContext SC) {
      BatchUserEmailUpdate userBatchRecord = new BatchUserEmailUpdate ();
      database.executebatch(userBatchRecord,200); 
   }
}