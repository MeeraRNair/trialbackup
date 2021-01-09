/* 
History:
Version     Date            Modified By         CR          Description     
--------------------------------------------------------------------------------------
1.0         2-Feb-2016      Shahiruni Wahida    12627       Create Schedule to execute batch to update Sales Channel field in Account
*/


global class BatchAccnt_SalesChannelUpdate_Schedule implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        BatchAccnt_SalesChannelUpdate batchObj = new BatchAccnt_SalesChannelUpdate();
        Database.executeBatch(batchObj,200);   
    }    
}