/* 
Description : The batch apex schedulable for integrating data to CMI based on CMI Data Queue records in In progress status

History:
Version Date            Modified By     	Description     
--------------------------------------------------------------------------------------
1.0     12-Dec-2011   	KP		     		CR 6708(R13.1) Created for Http callout to CMI based on CMI Data Queue records in In progress status
2.0		12-Dec-2012		Krishnamoorthi 		R14.2 Maintenance CR 7777 - As part of this CR, moved the 2 "addIntegrationException" methods to PartnerProfileIntegration class	
*/

global class BachCMIdataIntegration implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
	public String query;
	public Boolean isTest = false;
	public String response = '';
	
	global database.querylocator start(Database.BatchableContext BC){
		system.debug('## Inside Start method');
		return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	system.debug('## Inside Execute method');   	
    	CMI_Data_Queue__c cmiDataQueueRecord;    	
    	
    	for(sObject obj :scope){
	    	cmiDataQueueRecord = (CMI_Data_Queue__c)obj;
	    	
	    	Boolean isSuccess = false;
	    	Boolean error = false;
	    	try{
		    	if(cmiDataQueueRecord.Type__c == 'Account' && cmiDataQueueRecord.Account__c != null){	    		
		    		if(!isTest){
		    			response = PartnerProfileIntegration.sendAccountInfoWithResponse(cmiDataQueueRecord.Account__c);	
		    		}
		    		
		    		isSuccess = checkResponse(response,cmiDataQueueRecord.Type__c);
		    	}
	    	}catch(Exception e){
	    		isSuccess = false;
	    		error = true; 		
	    		PartnerProfileIntegration.addIntegrationException(cmiDataQueueRecord.Type__c,cmiDataQueueRecord.Account__c,e.getTypeName(),e.getMessage(),response);	    		
	    	}
	    	
	    	
	    	if(isSuccess){
	    		Database.delete(cmiDataQueueRecord,false);
	    	}
	    	else{	    		
	    		
	    		if(!error){
	    			PartnerProfileIntegration.addIntegrationException(cmiDataQueueRecord.Type__c,cmiDataQueueRecord.Account__c,response);
	    		}
	    		Decimal numberOfRetries = cmiDataQueueRecord.No_of_retries__c;
	    		//increment by one
	    		numberOfRetries = numberOfRetries == null?1:(numberOfRetries +1);
	    		
	    		if (numberOfRetries >= Decimal.valueOf(StringUtils.defaultString(Label.REUD_Maximum_number_of_possible_CMI_callout_tries))){
	    			//delete the CMI data Queue record
	    			Database.delete(cmiDataQueueRecord, false);
	    		}
	    		else{
	    			cmiDataQueueRecord.Status__c = 'Pending';
	    			cmiDataQueueRecord.No_of_retries__c = numberOfRetries;
	    			Database.update(cmiDataQueueRecord, false);
	    		}
	    		
	    	}
	    }
    	
    	
    }// end of execute method
    
    global void finish(Database.BatchableContext BC){
    	system.debug('## Inside finish method');
    	  	
    	//schedule CMI queue update job
    	
    	BatchUpdateCMIDataQueueSchedule CMIstatusUpdate = new BatchUpdateCMIDataQueueSchedule();
        Integer interval = Integer.valueOf(StringUtils.defaultString(Label.REUD_Interval_in_CMI_callout_cycle_in_sec));
        string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(datetime.now(), interval);
        system.schedule('Batch Update CMI Data Queue ' + String.valueOf(datetime.now()), schTime, CMIstatusUpdate);    	
    	
    }
    
    /* Utility methods */
    public static Boolean checkResponse(String response, String type){
    	response+='';    	
    	if (type == 'Account'){    		
    		return response.contains('<InsertSegmentationDataResult>true</InsertSegmentationDataResult>');
    	}
    	return false;
    }
    	
}