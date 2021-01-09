/* 
REVISION HISTORY
======================================================================================================================
Version    Author    Date           Release#    CR#    Description
-------    ------    ----           --------    ---    -----------
1.0        Manju    30-Nov-2013     15.03       8830   Batch class to change Lead status based on the 'isActive' field of Campaign
*/
global class Batch_CMAPChannelLead implements Database.Batchable<sObject> {
    public String query;
    global database.querylocator start(Database.BatchableContext BC){
    	DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(query);
    }
    
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		try{
			List<Lead> leadToUpdate = new List<Lead>();
			for(sObject sObj : scope){        
			    Lead lead = (Lead)sObj;
			    if(lead.Campaign__r.IsActive == false && lead.Status == 'Qualified - Channel Ready'){
			    	system.debug('in if...');
			    	lead.Status = 'Inactive';
			    	leadToUpdate.add(lead);
			     }
			     else if(lead.Campaign__r.IsActive == true && lead.Status == 'Inactive'){
			     	lead.Status = 'Qualified - Channel Ready';
			        leadToUpdate.add(lead);
			     }
			}
		    database.SaveResult[] updateResults;
		    if(leadToUpdate.Size() > 0){
		    	system.debug('### leadToUpdate:' + leadToUpdate);
		    	updateResults = Database.Update(leadToUpdate, false);
		    }
		}catch (Exception e){
          system.debug('----System.Debug----'+e);
        } 
	}// end of execute method
	    
	global void finish(Database.BatchableContext BC){
		
		//Manju - modified for EST Testing. Will be reverted once testing is over.
		
	   /*String seconds, minutes, hours, dayOfMonth, month, dayOfWeek, year;
       datetime systime = datetime.now();
       datetime TodayPlusSec = systime.addMinutes(15);
       seconds = string.valueOf(TodayPlusSec.second());
       minutes = string.valueOf(TodayPlusSec.minute()); 
       hours = string.valueOf(TodayPlusSec.hour());      
       dayOfMonth = string.valueOf(TodayPlusSec.day());
       month = string.valueOf(TodayPlusSec.month());
       dayOfWeek = '?';
       year = string.valueOf(TodayPlusSec.year()); 
       //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
       String schTime = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
       Batch_CMAPChannelLeadScheduler u = new Batch_CMAPChannelLeadScheduler (); 
	   system.schedule('Batch_CMAPChannelLeadScheduler' + string.valueof(systime), schTime, u);*/
       
       //Modification ends
       
	}
}