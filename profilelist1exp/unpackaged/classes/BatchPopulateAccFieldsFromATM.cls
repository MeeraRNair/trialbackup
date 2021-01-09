/*
* Author   : Anuj Shah
* Purpose  : Populate Account User fields based on Account Team Members
*        
* Revision Ref Number  Release No  Date            Modified By     Description
* -------- ----------  ----------  -----------     ------------    -----------
* 1.0      6742302     0802      12-JUN-2019     Anuj Shah        Populate Account User fields based on Account Team Members            
* 2.0      7223897     0802      21-AUG-2019     Anuj Shah        Update start method SOQL query to improve performance
*
*/ 



global class BatchPopulateAccFieldsFromATM implements Database.Batchable<sObject>,Database.stateful {
    public Set<String> setProcessedAccountIds = new Set<String>();
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String strQuery = 'SELECT Id, Account__c, ATM_Status__c FROM Account_Team__c ';
        strQuery = strQuery + 'WHERE ATM_Status__c = \'Waiting To Process\' AND Team_Member_Role__c in (\'Account Executive\',\'Client & Compute Sales Exec\',\'Client & Compute Global Sales Exec\',\'Partner Development Manager\',\'Distribution Partner Development Manager\',\'Inside Sales Rep\',\'Client & Compute Inside Sales Rep\',\'Inside Channel Account Manager\')';
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Account_Team__c> listScope)
    {
        boolean bAbortFlag = True;
        DateTime dtCurrentTime = system.now();
        List<Abort_CMAP_Job__c> listAbortTimings = Abort_CMAP_Job__c.getall().values();
        for(Abort_CMAP_Job__c abortTime: listAbortTimings){
            Time tStartTime = Time.newInstance(abortTime.Start_Date__c.hour(),abortTime.Start_Date__c.minute(), abortTime.Start_Date__c.second(), abortTime.Start_Date__c.millisecond()); 
            Time tEndTime = Time.newInstance(abortTime.End_Date__c.hour(),abortTime.End_Date__c.minute(), abortTime.End_Date__c.second(), abortTime.End_Date__c.millisecond()); 
            
            DateTime dtTimeToStart = DateTime.newInstance(Date.today(), tStartTime);
            DateTime dtTimeToAbort = DateTime.newInstance(Date.today(), tEndTime);
            system.debug('**&&currentTime **' +dtCurrentTime.format('yyyy-MM-dd,kk:mm') );
            system.debug('**&&AbortStartTime **' +dtTimeToStart.format('yyyy-MM-dd,kk:mm') );
            system.debug('**&&AbortEndTime **'   +dtTimeToAbort.format('yyyy-MM-dd,kk:mm') );
            
            
            system.debug('****&&' +dtTimeToStart.format('yyyy-MM-dd,kk:mm') < dtCurrentTime.format('yyyy-MM-dd,kk:mm'));
            system.debug('**&&&**' +dtTimeToAbort.format('yyyy-MM-dd,kk:mm') > dtCurrentTime.format('yyyy-MM-dd,kk:mm'));    
            
            
            if((dtTimeToStart.format('yyyy-MM-dd,kk:mm') < dtCurrentTime.format('yyyy-MM-dd,kk:mm') && dtTimeToAbort.format('yyyy-MM-dd,kk:mm') > dtCurrentTime.format('yyyy-MM-dd,kk:mm'))){
                   system.debug('**&&Abort **' );
                   bAbortFlag = False;
            }
        }
        
        if(bAbortFlag){
            system.abortJob(bc.getJobId());
        }else{
            List<Account> listAccsToUpdate = new List<Account>();
            List<Account_Team__c> listATMToUpdate = new List<Account_Team__c>();
            Map<String,String> mapAccIdToUserICAM = new Map<String,String>();
            Map<String,String> mapAccIdToUserAE = new Map<String,String>();
            Set<String> setAccountIds = new Set<String>();
            
            for(Account_Team__c objATM : listScope)
            {
                if(objATM.Account__c != null && !setProcessedAccountIds.contains(objATM.Account__c))
                {
                    setAccountIds.add(objATM.Account__c);
                }
                objATM.ATM_Status__c = 'Completed';    
                listATMToUpdate.add(objATM);
            }
            
            //FOR ICAM
            for(Account_Team__c objATM : [SELECT Id, Team_Member_Role__c, User__c, Account__c, ATM_Status__c ,ICAM_Priority__c, AE_PDM_Priority__c, Status__c FROM Account_Team__c WHERE Account__c In :setAccountIds and ICAM_Priority__c > 0 and Status__c = 'Active' order by Account__c, ICAM_Priority__c ])
            {
                if(!mapAccIdToUserICAM.containsKey(objATM.Account__c))
                {
                    mapAccIdToUserICAM.put(objATM.Account__c, objATM.User__c);
                } 
            }
            
            //FOR PDM
            for(Account_Team__c objATM : [SELECT Id, Team_Member_Role__c, User__c, Account__c, ATM_Status__c ,ICAM_Priority__c, AE_PDM_Priority__c, Status__c FROM Account_Team__c WHERE Account__c In :setAccountIds and AE_PDM_Priority__c > 0 and Status__c = 'Active' order by Account__c, AE_PDM_Priority__c ])
            {
                if(!mapAccIdToUserAE.containsKey(objATM.Account__c))
                {
                    mapAccIdToUserAE.put(objATM.Account__c, objATM.User__c);
                }
            }
            
            for(String strObjAccId : setAccountIds)
            {
                Account objAcc = new Account();
                objAcc.Id = strObjAccId;
                objAcc.Inside_Sales_Rep_ICAM__c = mapAccIdToUserICAM.get(strObjAccId);
                objAcc.Account_Executive_PDM__c = mapAccIdToUserAE.get(strObjAccId);
                listAccsToUpdate.add(objAcc);
                
            }
            
            if(!listAccsToUpdate.isEmpty())
            {
                update listAccsToUpdate;
                setProcessedAccountIds.addAll(setAccountIds);
            }
            
            if(!listATMToUpdate.isEmpty())
            {
                update listATMToUpdate;
            }
        }
    } 
    
    
    global void finish(Database.BatchableContext bc)
    {
    }
}