/* 
REVISION HISTORY
======================================================================================================================
Version    Author    Date           Release#    CR#    Description
-------    ------    ----           --------    ---    -----------
1.0        Manju    30-Nov-2013     15.03       8830   Scheduler class to query all Lead records whose Campaign is false and status is -
                                                       'Qualified - Channel Ready' or Campaign is true and status is - 'Inactive'
*/
global class Batch_CMAPChannelLeadScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        Id leadcleansingRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Cleansing & Scoring Complete', 'Lead', true);
		Batch_CMAPChannelLead batchChannelLdUpd = new Batch_CMAPChannelLead();
		batchChannelLdUpd.query= 'SELECT l.Campaign__r.IsActive, l.Campaign__r.Status, l.Campaign__c, l.Status  '+
								  'FROM Lead l '+
								  'WHERE l.RecordTypeId = \''+leadcleansingRTId+'\' ' +
								  'AND((l.Campaign__r.IsActive = false AND l.Status = \'Qualified - Channel Ready\') '+
     							        'OR (l.Campaign__r.IsActive = true AND l.Status = \'Inactive\'))' ;
  		database.executebatch(batchChannelLdUpd,200);
        
    }  
}