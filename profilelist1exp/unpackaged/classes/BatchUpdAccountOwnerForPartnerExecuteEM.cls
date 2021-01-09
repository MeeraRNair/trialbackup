/***********************************************************
* Name          : BatchUpdAccountOwnerForPartnerExecuteEM
* Description   : Update Parnter Account Owner
* ---------------------------------------------------------
* Revision      Release Name    Date            Description
* 1.0           12.1    MenMee  22.12.2010      CR5716 Processing Account owner change using batch Apex
* 1.1           12.1    MenMee  28.01.2011      Parameterize batch size in custom label
* 1.2                   MenMee  22.03.2011      CR6022 Exception Handling
* 2.01                  Hitha                   Update Account Owner depending on region

***********************************************************/

global class BatchUpdAccountOwnerForPartnerExecuteEM implements Schedulable {
    //static String batchtemp = System.Label.BatchUpdPartnerAccountOwnerAPJ_Batch_Size;
    
    global static void execute(SchedulableContext SC) {     
       /* Id batchinstanceid;
        integer batchSize;
        
        System.debug('### Execute');
        if (batchtemp != '-') {
            if(Test.isRunningTest()){batchtemp = '-';}
            //Rev 1.2
            try {       
                batchSize = Integer.valueOf(batchtemp);
            }
            catch (TypeException te) {
                batchSize = 10;
            }
        
            batchinstanceid = database.executeBatch(new BatchUpdAccountOwnerForPartnerEMEA(), batchSize);
        }
        else {
            batchinstanceid = database.executeBatch(new BatchUpdAccountOwnerForPartnerEMEA());
        }*/
    } 
 }