/***********************************************************
* Name          :   CalculateAccountShareForMG
* Description   :   Add/Remove Account Share based on the Account Team in respective SalesMotion Accounts
* ---------------------------------------------------------
* Revision  Name            Date                Description
* 1.0                       11t Oct 2019        created

************************************************************/

global class CalculateAccountShareForMG  implements Database.Batchable<sObject>,Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String strQuery;
        if(!Test.isRunningTest()){
           strQuery = System.Label.CalculateAccountShareForMG_Query;   
        }
        else{
        strQuery = 'SELECT AccountId,UserId,Published_MGShare_Event__c,OpportunityAccessLevel,AccountAccessLevel,Account.Master_Group_Id__c FROM AccountTeamMember WHERE Account.Master_Group_Id__c!= null and Published_MGShare_Event__c = FALSE'; //GROUP BY Account.Master_Group_Id__c';
        }
        System.debug('strQuery::'+Database.getQueryLocator(strQuery));
        return Database.getQueryLocator(strQuery);
    }
    global void execute(Database.BatchableContext bc, List<AccountTeamMember> listscope){
        // To hold the MG Ids
        Set<String> setMGIds = new Set<string>();
        // To hold the User Ids
        Set<String> setUsrIds = new Set<String>();        
        //To hold MG vs Set of ATMS
        Map<String,Set<AccountTeamMember>> mapMGVsAllATM = new Map<String,Set<AccountTeamMember>>();
        // To hold existing Account Share
        List<AccountShare> listAccShareExists = new List<AccountShare>();
       
        // To hold the Account Share to delete
        List<AccountShare> listAccShareDel = new List<AccountShare>();
        // To hold the Account Share to insert
        List<AccountShare> listAccShareinsert = new List<AccountShare>();
        //map to hold the User vs AccountId's
        Map<String,List<String>> mapShareAccToUsr = new Map<String,List<String>>();
        //To hold the updated ATM's
        List<AccountTeamMember> listATM = new List<AccountTeamMember>();
        //To hold the Exceptions
        List<Exception__c> listExcptn = new List<Exception__c>();
        try{
            for(AccountTeamMember atm : listscope){
                setMGIds.add(atm.Account.Master_Group_Id__c);
                setUsrIds.add(atm.UserId);
                if(mapMGVsAllATM.containsKey(atm.Account.Master_Group_Id__c)){
                    mapMGVsAllATM.get(atm.Account.Master_Group_Id__c).add(atm);
                }
                else{
                    mapMGVsAllATM.put(atm.Account.Master_Group_Id__c, new Set<AccountTeamMember>{(atm)});
                }
            }
            System.debug('mapMGVsAllATM::'+mapMGVsAllATM);
            listAccShareExists = [SELECT Id,AccountId,UserOrGroupId
                                  FROM AccountShare 
                                  WHERE AccountId IN: setMGIds
                                  AND RowCause =: 'Manual'
                                  AND UserOrGroupId IN: setUsrIds
                                 ];
            
            System.debug('listAccShareExists::'+listAccShareExists.size());
            
            if(listAccShareExists.size() > 0){
                for(AccountShare accSh : listAccShareExists){
                    if(mapShareAccToUsr.containsKey(accSh.AccountId)){
                        mapShareAccToUsr.get(accSh.AccountId).add(accSh.UserOrGroupId);
                    }
                    else{
                        mapShareAccToUsr.put(accSh.AccountId,new List<String>{ accSh.UserOrGroupId }); 
                    }
                    
                }
                System.debug('mapShareAccToUsr::'+mapShareAccToUsr);
            }
            
            for(String strMGIds : setMGIds){
                if(mapMGVsAllATM!= null && mapMGVsAllATM.get(strMGIds) != null){
                    for(AccountTeamMember atm : mapMGVsAllATM.get(strMGIds) ){
                        atm.Published_MGShare_Event__c = true;
                        System.debug('mapShareAccToUsr.get(strMGIds)::'+mapShareAccToUsr.get(strMGIds));
                        if(!mapShareAccToUsr.isEmpty() && mapShareAccToUsr.get(strMGIds)!= null && !mapShareAccToUsr.get(strMGIds).contains(atm.UserId)){
                            AccountShare accShre = new Accountshare();
                            accShre.AccountId = strMGIds;
                            accShre.UserOrGroupId = atm.UserId;
                            accShre.AccountAccessLevel = atm.AccountAccessLevel;
                            accShre.OpportunityAccessLevel= atm.OpportunityAccessLevel;
                            accShre.RowCause='Manual'; 
                            listAccShareInsert.add(accShre);
                        }
                        else{
                            AccountShare accShre = new Accountshare();
                            accShre.AccountId = strMGIds;
                            accShre.UserOrGroupId = atm.UserId;
                            accShre.AccountAccessLevel = atm.AccountAccessLevel;
                            accShre.OpportunityAccessLevel= atm.OpportunityAccessLevel;
                            accShre.RowCause='Manual'; 
                            listAccShareInsert.add(accShre);
                        }
                        listATM.add(atm);
                        
                    }
                }
                
            }
            
            System.debug('listAccShareInsert'+listAccShareInsert.size());
            System.debug('listATM'+listATM.size());
            if(listAccShareInsert.size() > 0){
                Database.SaveResult[] listSR = Database.insert(listAccShareInsert,false);
                for (Database.SaveResult sr : listSR) {
                    if(sr.isSuccess()){
                        System.debug('Inserted Successfully');
                    }
                    else {
                        system.debug('insert failed' + sr.getErrors());
                  /*   for(Database.Error objErr : sr.getErrors()) {
                            System.debug('The following error has occurred.');  
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            Exception__c exceptionRecord = new Exception__c();
                             exceptionRecord.Process_Name__c = 'MG Share';exceptionRecord.Object_type__c = 'AccountTeamMember'; exceptionRecord.Object_ID__c = sr.getId();
                             exceptionRecord.Error_Codes__c = String.valueOf(objErr.getStatusCode());exceptionRecord.Error_Messages__c = 'Error:: '+objErr.getMessage()+' effected Fields::'+objErr.getFields();
                             listExcptn.add(exceptionRecord);
                        } */
                    }
                    
                }
                
                
            }
            if(listATM.size() > 0){
                Database.SaveResult[] listSR = Database.insert(listATM,false);
                for (Database.SaveResult sr : listSR) {
                    if(sr.isSuccess()){
                        System.debug('Inserted Successfully');
                    }
                    else {
                        for(Database.Error objErr : sr.getErrors()) {
                            System.debug('The following error has occurred.');  
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            Exception__c exceptionRecord = new Exception__c();exceptionRecord.Process_Name__c = 'MG Share';
                          exceptionRecord.Object_type__c = 'AccountTeamMember';exceptionRecord.Object_ID__c = sr.getId();exceptionRecord.Error_Codes__c = String.valueOf(objErr.getStatusCode());
                          exceptionRecord.Error_Messages__c = 'Error:: '+objErr.getMessage()+' effected Fields::'+objErr.getFields();
                             listExcptn.add(exceptionRecord);
                        }
                    }
                }
                
                
            }
            
            if(listExcptn.size() > 0){
                insert listExcptn;
            }
        }
        catch(Exception e){
            Exception__c exceptionRecord = new Exception__c();
            exceptionRecord.Process_Name__c = 'MG Share';
            exceptionRecord.Object_type__c = 'AccountTeamMember';
            exceptionRecord.Object_ID__c = userinfo.getUserId();
            exceptionRecord.Error_Messages__c = e.getMessage()+'::'+e.getLineNumber();
            insert exceptionRecord;
        }
        
        
        
        
    }
    global void finish(Database.BatchableContext bc){}
    
    
}