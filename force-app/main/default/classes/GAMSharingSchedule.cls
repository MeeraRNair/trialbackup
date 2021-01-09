/* 
Author: Natesh Alagiri

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     27-Jun-2011     Natesh Alagiri  Created for CR6236 and CR6238 (R13.1)
1.1     21-Dec-2011     Krishna			Kept the sales channel group name in custom label
1.2		10-Jan-2012		Krishna			(CRQ 0257 R13.1)Changed the filter logic on Sales channel Group from Name field to Group Id field
1.3		15-Aug-2012		Krishnamoorthi	R13.10 CR 7324 -Changed the select query logic to accommodate more than one Sales Channel Group	
*/
global class GAMSharingSchedule implements Schedulable{
    public Boolean isTest = False; 
    global void execute(SchedulableContext sc) {
        
        //deleting GAM groups of the accounts which are not global account anymore.
        Map<String,String> GAMgroupNameMap = new Map<String,String>();
        Map<String,Id> GAMGroupNameToIdMap = new Map<String,Id>();
        List<Group> groupListTodelete = new List<Group>();
        Set<Id> GroupIdSet = new Set<Id>();
        List<Account> globalAccountList = new List<Account>();
		String GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER = StringUtils.defaultString(Label.GAM_Global_sales_channel_group_identifier);
        List<Group> globalGroupList = new List<Group>();
        String message = '#Started deleting unwanted Groups at :' + DateTime.now() +  '';
        
        //Rev 1.3
         List<string> salesChGroupList = StringUtils.split(GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER, ',');    
         system.debug('###salesChGroupList####' + salesChGroupList);    
        
        
        //global account query
	    if(!isTest){
	    	globalAccountList = [SELECT Id, Name, Account_Id__c
								 FROM Account
								 WHERE Status__c IN ('Active','A')
								 //Rev 1.3
								 //AND Sales_Channel__r.Group_ID__c = :GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER
								 AND Sales_Channel__r.Group_ID__c IN :salesChGroupList
								 AND Account_Type_Integration__c = 'PAR Account'];
	        globalGroupList = [SELECT Id, Name
	        				   FROM Group
	        				   WHERE Name like 'GAM:%'];
	    }
	    else{
    		globalAccountList = [SELECT Id, Name, Account_Id__c
								 FROM Account
								 WHERE Status__c IN ('Active','A')
								 //Rev 1.3
								 //AND Sales_Channel__r.Group_ID__c = :GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER
								 AND Sales_Channel__r.Group_ID__c IN :salesChGroupList
								 AND Account_Type_Integration__c = 'PAR Account'
								 AND Account_ID__c like 'Test123456789%'];
	        globalGroupList = [SELECT Id, Name
	        				   FROM Group
	        				   WHERE Name like 'GAM:Test%'];
	    }
        for(Account acc :globalAccountList){
            GAMgroupNameMap.put('GAM:' + acc.Account_Id__c,'GAM:' + acc.Account_Id__c);
        }
        for(Group groupItem :globalGroupList){
        
            if(!GAMgroupNameMap.containsKey(groupItem.Name)){
                groupListTodelete.add(groupItem);
            }
            else{
                GAMGroupNameToIdMap.put(groupItem.Name,groupItem.Id);
                GroupIdSet.add(groupItem.Id);
            }
        }
	    
        if(groupListTodelete.size()>0){
            database.delete(groupListTodelete,false);
        }           
        message += '\n#Finished deleting ' + groupListTodelete.size()+ ' unwanted Group(s) at :' + DateTime.now() +  '';
        GAMbatchJobUtils.sendOptionalNotification('GAM : Starting Account Share manipulation job' , message);
        
        //Rev 1.3 -- changes Start
        String salesChGroups='';
        Integer i;
        if(!salesChGroupList.isEmpty()) {
        	salesChGroups = salesChGroups + '(';
        	for(i = 0 ; i < salesChGroupList.size() ; i++){
        		 if(i>0) {
        		 	salesChGroups +=',';
        		 }
        		 salesChGroups += '\'' + salesChGroupList[i]+ '\'';
        	}	
        	salesChGroups = salesChGroups + ')';
        }
        //Rev 1.3 -- changes End
        
        GAMSharingBatch batchObj = new GAMSharingBatch();
        batchObj.query = 'SELECT Id, Name, Account_ID__c FROM Account '+ 
                         'WHERE Status__c IN (\'Active\',\'A\') AND '+
                         //Rev 1.3
                         //'Sales_Channel__r.Group_ID__c = \''+GLOBAL_SALES_CHANNEL_GROUP_IDENTIFIER+'\' AND '+
                         'Sales_Channel__r.Group_ID__c IN '+salesChGroups+' AND '+
                         'Account_Type_Integration__c = \'PAR Account\'';
        system.debug('###batchObj.query####' + batchObj.query);
        batchObj.GAMGroupNameToIdMap = GAMGroupNameToIdMap;
        batchObj.GroupIdSet = GroupIdSet;
        database.executebatch(batchObj,1);
        
    }  
}