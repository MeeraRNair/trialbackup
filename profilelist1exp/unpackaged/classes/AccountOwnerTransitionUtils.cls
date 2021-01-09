/*Author: Azwanti Zuber
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     12-Oct-2010     Azwanti         R11.10, CR4117-create record in Work_Item__c when account owner is change.
2.0     29-Dec-2010     Men Mee         R12.1, CR5716 add parameter (inSecond) to BatchJobScheduleTime method 
2.1     28-Apr-2011     Azwanti         R12.5, CR6069 add method to schedule Batch Deletion Job on Work Item & Exception records 
3.0		25-Apr-2013		Men Mee			R14.3 CR8242 remove hardcode email recipient
*/
global class AccountOwnerTransitionUtils {  
    global string Operate,JobName;    
     //Rev 3.1
	public static List<String> emailList = getEmailIdList(); //initializes
	public static Boolean enabledNotification = StringUtils.equalsIgnoreCase(StringUtils.defaultString(Label.BatchUpdAccount_Enable_Exception),'TRUE');
		    
	 public static void createAccWorkItem(Set<Id> accIdSet, Map<Id, Id> oldOwnerMap, Map<Id, Id> newOwnerMap){   
        //declaration
        Map<Id, Work_Items__c> accntWorkItemMap = new Map<Id, Work_Items__c>();
        List<Work_Items__c> workItemListToUpdate = new List<Work_Items__c>();
        List<Work_Items__c> workItemListToInsert = new List<Work_Items__c>();
        Set<Id> inertUserIdSet = new Set<Id>{ dellConfig.glblDataAdminGUID,
                                         '005A0000000ac3yIAA', // inf_service_account@dell.com
                                         '00570000001KYKkAAO'  // wm_service_account@dell.com
                                         };
            for(Id accId : accIdSet) {
            // create Work Item record
            Work_Items__c newAccWorkItem = new Work_Items__c(Account__c = accId, Status__c = 'Pending', Previous_Owner__c = oldOwnerMap.get(accId), 
                                                            New_Owner__c = newOwnerMap.get(accId), Object_Type__c = 'Account');
            accntWorkItemMap.put(accId, newAccWorkItem);
        } 
        Work_Items__c NewWorkItem;
        Id processingAccountId,accountId;
        for(Work_Items__c oldWorkItem : [SELECT Account__c, Status__c, Object_Type__c, New_Owner__c,Previous_Owner__c FROM Work_Items__c 
                                         WHERE Account__c IN :accIdSet AND Status__c = 'Pending' and Object_Type__c = 'Account'
                                         ORDER BY Account__c,CreatedDate DESC]){
            accountId = oldWorkItem.Account__c;
            if (processingAccountId  != accountId) {    
                NewWorkItem = accntWorkItemMap.get(accountId);
                processingAccountId = accountId;    
            }   
            //assumption on state:  Account Id of oldWorkItem =  AccountId = processingAccountId =Account Id of WorkItem 
            if(NewWorkItem!=null && NewWorkItem.Previous_Owner__c == oldWorkItem.New_Owner__c){
                NewWorkItem.Previous_Owner__c = oldWorkItem.Previous_Owner__c;
            }
            
            oldWorkItem.Status__c = 'Closed-Duplicate';
            workItemListToUpdate.add(oldWorkItem);          
        }
        
        for(Id accId : accntWorkItemMap.keySet()){
            NewWorkItem = accntWorkItemMap.get(accId);
            //avoiding scenario: 1. A -> A and 2. Prev Owner = Global Data Admin/inf_service_account@dell.com/wm_service_account@dell.com
            if(NewWorkItem.Previous_Owner__c != NewWorkItem.New_Owner__c && !(inertUserIdSet.contains(NewWorkItem.Previous_Owner__c))){
            workItemListToInsert.add(NewWorkItem);
            }
        }
        
        if(workItemListToInsert.size()>0){
            insert workItemListToInsert;
        }       
        if(workItemListToUpdate.size() > 0){
            update workItemListToUpdate;
        }          
    }
    
    public static string BatchJobScheduleTime(datetime TodayDate){
        return BatchJobScheduleTime(TodayDate, 10);     
    }
        
    public static string BatchJobScheduleTime(datetime TodayDate, integer inSecond){
        String seconds, minutes, hours, dayOfMonth, month, dayOfWeek, year;
         // add 10 sec before scheduling the next job
        datetime TodayPlusSec = TodayDate.addSeconds(inSecond); 
        seconds = string.valueOf(TodayPlusSec.second());
        minutes = string.valueOf(TodayPlusSec.minute()); 
        hours = string.valueOf(TodayPlusSec.hour());      
        dayOfMonth = string.valueOf(TodayPlusSec.day());
        month = string.valueOf(TodayPlusSec.month());
        dayOfWeek = '?';
        year = string.valueOf(TodayPlusSec.year()); 
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String schTime = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
        return schtime;
    }
    public static void scheduleJobs(String NextJob){      	
     	scheduleJobs(NextJob, false);
     }
    
    public static void scheduleJobs(String NextJob, Boolean isTest){
        String seconds, minutes, hours, dayOfMonth, month, dayOfWeek, year;
        integer batchdeleteWICount, batchdeleteExcCount,dayOfMonthInt;
        datetime TodayDate = System.now();
        dayOfMonth = TodayDate.format('EEEE'); 
        dayOfMonthInt = TodayDate.day();
        boolean batchdeleteWIFlag = false;
        boolean batchdeleteExcFlag = false;
        if(NextJob == 'Delete Work Items'){
            //validating System.Label.Batch_Delete_Work_Item_Schedule_Day
            String delWorkItemDay = StringUtils.defaultString(System.Label.Batch_Delete_Work_Item_Schedule_Day).Trim(); 
            if(dayOfMonth == delWorkItemDay || isTest){
            //checking for BatchDeleteWorkItems batch job
                batchdeleteWICount = [Select count() from AsyncApexJob where ApexClass.Name = 'BatchDeleteWorkItems' 
                                        AND ((Status = 'Processing' AND CreatedDate = Today) OR (Status = 'Completed' AND CompletedDate = Today)) limit 1];
                
                if(batchdeleteWICount == 0 || isTest){                
                    BatchDeleteWorkItemsExec bdWI = new BatchDeleteWorkItemsExec();
                    //set schedule time         
                    string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate, 10);
                    system.schedule('Batch Delete Work Item ' + String.valueOf(datetime.now()), schTime, bdWI);
                }
                else{
                    NextJob = 'Delete Exceptions';
                }
            }
            else{
                NextJob = 'Delete Exceptions';  
            }  
        }        
        if(NextJob == 'Delete Exceptions'){
            //validating System.Label.Batch_Delete_Exception_Schedule_Day 
            Integer delException =  Integer.valueOf(System.Label.Batch_Delete_Exception_Schedule_Day);
            delException = (delException > 28 || delException < 1)? 1 : delException;   
            // Schedule BatchDeleteExceptionData batch job.        
            if(dayOfMonthInt == delException || isTest){
                //checking for BatchDeleteExceptionData 
                batchdeleteExcCount = [Select count() from AsyncApexJob where ApexClass.Name = 'BatchDeleteExceptionData' 
                                        AND ((Status = 'Processing' AND CreatedDate = Today) OR (Status = 'Completed' AND CompletedDate = Today))limit 1];
                
                if(batchdeleteExcCount == 0 || isTest){                
                    BatchDeleteExceptionDataExecute bdWI = new BatchDeleteExceptionDataExecute();
                    //set schedule time         
                    string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(TodayDate, 60);
                    system.schedule('Batch Delete Exception Data ' + String.valueOf(datetime.now()), schTime, bdWI);
                }
                else{
                    NextJob = 'Account Work Items';
                }
            } 
            else{
                NextJob = 'Account Work Items'; 
            }   
        }
        if(NextJob == 'Account Work Items'){
            //1. Scheduled BatchUpdAccountWorkItem after 1 hour/3600sec interval               
            BatchUpdateAccountWorkItemExecute buAccWI = new BatchUpdateAccountWorkItemExecute();
            Integer interval = Integer.valueOf(System.label.BatchUpdWorkItemToComplete_Interval);
            string schTime = AccountOwnerTransitionUtils.BatchJobScheduleTime(datetime.now(), interval);
            system.schedule('1. Batch Update Account Work Item ' + String.valueOf(datetime.now()), schTime, buAccWI);
        }
    }
    //Rev 3.1
	public static List<String> getEmailIdList(){
		List<String> emails = new List<String>();
		String EmailRecipientStr = StringUtils.defaultString(Label.BatchUpdAccount_Exception_email_recipients).replace(' ','');
		if(EmailRecipientStr.contains('@')){
			emails = EmailRecipientStr.split(';', -1);
		}
		return emails;
	} 

	//Rev 3.1		
	public static void sendOptionalNotification(String subject, String body){
		//once again checks teh attributes
		try{
			if(enabledNotification && emailList !=null && emailList.size()>0){
				body = '##System time: '+ DateTime.now()+'##\n' +body;
				emailUtils.sendTextEmail(emailList,subject,body);			
			}	
		}catch(Exception e){
			System.debug('##### Exception ' + e.getmessage());
		}
		
	}	    
}//end of class