/*
Author: Raymond Yip

History:
Version  Date      Modified By    Description
--------------------------------------------------------------------------------------
1.0     20-Apr-2010  Raymond     Created for CR2561, R11.5

*/

global class BatchUpdateOpptyForEOLProductExecute2 implements Schedulable {

    global static void execute(SchedulableContext SC) {
        Id batchinstanceid = database.executeBatch(new BatchUpdateOpptyForEOLProduct2()); 
    }

    public static void executeBatch(BatchUpdateOpptyForEOLProduct2 batch) {
        Id batchinstanceid = database.executeBatch(batch); 
        System.debug('###DEBUG### batchinstanceid ' + batchinstanceid);
    }
}