/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 2.0                  16.10       5Sept2015       Josie           Channel Lead 2.0
 * 3.0      15686       FY19-0602   27-Apr-2018     Shue            Story 4144896: Channel: Remove BANT Qualified leads process (Code)                        
 */
 
global class Batch_CMAPLeadAssignmentScheduler implements Schedulable {
       
    global void execute(SchedulableContext sc) {
        Id leadcleansingRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Cleansing & Scoring Complete');
        Id leadsbmsnRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');
        Id cl2RTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0'); // 2.0
        
        CMAP_Queue_Settings__c assQueueId = CMAP_Queue_Settings__c.getValues('Partner Assignment Queue');
        
        Batch_CMAPLeadAssignment batchObj = new Batch_CMAPLeadAssignment();
        batchObj.query = 'SELECT Id, Status, RecordTypeId, OwnerId, CreatedDate, Partner_User__r.IsActive, Partner_User__r.LanguageLocaleKey, Campaign__c, ' +
                         ' CreatedById, Partner_Account__c, Partner_User__c, Partner_Admin__r.LanguageLocaleKey, Send_Notification__c, ' + 
                         ' Owner_Language_Code__c, Partner_Admin__c, Accept_Reject_Reassign_Status__c, Partner_Lead_Status__c, Campaign__r.Partner_Event_or_Campaign__c, Partner_Event_or_Campaign__c' + 
                         ' FROM Lead Where (Status = \'Qualified - Channel Ready\' OR Status = \'Open - Channel Lead\') AND ' + 
                         ' (RecordTypeId = \'' + leadcleansingRTId + '\' OR RecordTypeId = \'' + leadsbmsnRTId + '\' OR RecordTypeId = \'' + cl2RTId + '\' ) AND ' + 
                         //' Campaign__r.Partner_Event_or_Campaign__c = TRUE AND ' + 
                         ' OwnerId = \'' + assQueueId.Queue_Id__c + '\'';       
              
        if(Test.isRunningTest()) {
               batchObj.query += ' limit 50';
        }
        System.debug('batchObj.query : ' + batchObj.query);
        
        Database.executeBatch(batchObj, 200);
    }
    
}