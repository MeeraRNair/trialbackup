/*
* Author  : Krishnakumar M
* Purpose : Buddy Request Functionality
* 
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      CR14112      05.02      20-Feb-2017     Krishnakumar    Buddy Request - Create Batch Processes to Add/Remove Buddy member to ATM
* 2.0      CR14556      07.02      29-Jun-2017     Krishnakumar    SE148 - Fix for the Defect 3497907 Buddy Access batch process 
* 2.1      D3535012     07.02      30-Jun-2017     Krishnakumar    Defect 3535012:SDET: Buddy is getting removed from ATM even though Buddy was already there in ATM.
* 3.0      CR16640      08.02      04-Jul-2017     Krishnakumar    SE149 - SE149 - Permanent Fix for the Defect 3497907 Buddy Access batch process 
* 3.1      D3636604     08.02      20-Jul-2017     Krishnakumar    Buddy is removed from ATM instead of updating the access level
* 4.0      CR14846      10.01      25-Aug-2017     Nagaraju        Updated the update statemnt with partial execution if any records fails it will update the other GSD record status.
*/

global class Batch_BuddyRevoke implements Database.Batchable<sObject>,Database.Stateful {
    
    
    public Set<ID> setGDMId = new Set<ID>();
    public Set<ID> setInitialGDMId = new Set<ID>();
    private static final Integer MAX_ATTEMPTS = 3;
    public BuddyUserHelper excep = new BuddyUserHelper();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Boolean bError = false;
        Integer iDateLimit = Integer.valueOf(Label.GDM_End_Date_Limit);
        Id idRecordType = IdLookupUtils.getRecordTypeId('ATM History For Buddy Access','GDM_Request__c',true);
        List<ID> listBuddyId = new List<ID>();        
        String strGDMQuery = 'select id,name,Buddy__c,GDM_Request__c,Buddy_Access_Status__c from GDM_Request__c where Buddy_Access_Status__c = \'Access provided\' and recordtype.developerName = \'Buddy_Access\' and Buddy_Access_End_Date__c = LAST_N_DAYS:'+iDateLimit;
        List<GDM_Request__c> listBuddyReq = Database.query(strGDMQuery); // [select id,name,Buddy__c,Rep_on_Leave__c,Buddy_Access_Start_Date__c,Buddy_Access_End_Date__c,Buddy_Access_Status__c,Notes__c,Request_Type__c,Reason_Requested__c,Comments2__c from GDM_Request__c where Buddy_Access_Status__c = '+Access provided+' and recordtype.developerName = '+Buddy_Access+' and Buddy_Access_End_Date__c = LAST_N_DAYS:iDateLimit];
        for(GDM_Request__c objGDM:listBuddyReq){
            objGDM.Buddy_Access_Status__c = 'Removing Access';
        }
        if(!listBuddyReq.isEmpty()){
            String strSubject='Buddy Revoke Request failed during GDM status update.';
            String strMsg='Hi Team, \n\n Error Occurred while changing status from \'Access Provided\' to \'Removing Access\' in Batch_BuddyRevoke Class. Below are the Error details.\n\n';
            TriggerExecutionController.setskipGDMRequestTriggers(true);
            Database.SaveResult[] srList = Database.update(listBuddyReq,false); //4.0 start
            for(Integer iCount=0;iCount<srList.size();iCount++){
                Database.SaveResult sr = srList.get(iCount);
                if (sr.isSuccess()) {
                    setInitialGDMId.add(sr.getId());
                    listBuddyId.add(listBuddyReq.get(iCount).Buddy__c);
                }else{
                    bError = true;                    
                }
            }
            TriggerExecutionController.setskipGDMRequestTriggers(false);
            if(bError){
                excep.processError(listBuddyReq,srList,strSubject,strMsg);
            }//4.0 End
        }
        //3.0
        // select all the backup for all buddy that supposed to be revoked from query above. This query shall return backup for future GDM request that has yet to expired. 
        // We need then to recalc the buddy access based on GDM backup that has yet to expire.  
        String strQuery ='select id,Account_ID__c,Is_New_Buddy__c,AccountAccessLevel__c,CaseAccessLevel__c,TeamMemberRole__c,OpportunityAccessLevel__c, '+
            'GDM_Request__c,GDM_Request__r.Buddy_Access_Start_Date__c,GDM_Request__r.Buddy_Access_End_Date__c,GDM_Request__r.Buddy__c,GDM_Request__r.Rep_on_Leave__c, '+
            'Rep_Account_Access_Level__c,Rep_Case_Access_Level__c,Rep_Opportunity_Access_Level__c '+
            ' from GDM_Request__c '+
            ' where recordtypeid = :idRecordType and  GDM_Request__r.Buddy_Access_Status__c in  (\'Access provided\',\'Removing Access\') and GDM_Request__r.Buddy__c = :listBuddyId order by Account_ID__c'; //3.1 Added Order by Account Id.
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, list<GDM_Request__c> listBuddyBackUp) {
        List<ID> listBuddy2Remove = new List<ID>();
        List<AccountTeamMember> listBuddy2Replace = new List<AccountTeamMember>();       
        List<ID> listAffirnityATM = new List<ID>(); 
        List<Id> listSuccessATM = new List<Id>();
        List<Exception__c> listException = new List<Exception__c>();
        // mapBackupBuddy hold the Account and a list of backup ATM (expired and non expired)
        Map<String,List<GDM_Request__c>> mapBackupBuddy = new Map<String,List<GDM_Request__c>>();  //3.0
        //mapRepGDM hold the acc + ROL and a list of backup ATM that is expired
        Map<String,List<GDM_Request__c>> mapRepGDM = new Map<String,List<GDM_Request__c>>(); 
        List<GDM_Request__c> listGDMBackUp;
        Set<ID> setRepId = new Set<ID>();
        Set<ID> setAccId = new Set<ID>();
        BuddyUserHelper helper = new BuddyUserHelper();
        Integer intRetry = 0;
        
        for(GDM_Request__c bckUpBuddyATM:listBuddyBackUp){            
            if(mapBackupBuddy.containsKey(bckUpBuddyATM.Account_ID__c)){
                listGDMBackUp = mapBackupBuddy.get(bckUpBuddyATM.Account_ID__c);
                listGDMBackUp.add(bckUpBuddyATM);
                mapBackupBuddy.put(bckUpBuddyATM.Account_ID__c,listGDMBackUp);    
            }else{
                listGDMBackUp = new List<GDM_Request__c>();
                listGDMBackUp.add(bckUpBuddyATM);
                mapBackupBuddy.put(bckUpBuddyATM.Account_ID__c,listGDMBackUp);
            }
            //To handle ROL removed scenario.
            if(bckUpBuddyATM.GDM_Request__r.Buddy_Access_End_Date__c <= System.today()){
                if(mapRepGDM.containsKey(bckUpBuddyATM.Account_ID__c+''+bckUpBuddyATM.GDM_Request__r.Rep_on_Leave__c)){
                    (mapRepGDM.get(bckUpBuddyATM.Account_ID__c+''+bckUpBuddyATM.GDM_Request__r.Rep_on_Leave__c)).add(bckUpBuddyATM);
                }else{                    
                    mapRepGDM.put(bckUpBuddyATM.Account_ID__c+''+bckUpBuddyATM.GDM_Request__r.Rep_on_Leave__c, new List<GDM_Request__c>()); 
                    (mapRepGDM.get(bckUpBuddyATM.Account_ID__c+''+bckUpBuddyATM.GDM_Request__r.Rep_on_Leave__c)).add(bckUpBuddyATM);
                } 
            }
        }
        
        //listInnercls should contain innerclass for all the gdm request that is expired
        List<AtmGDMRelationClass> listInnercls = helper.createGDMATMRelation(listBuddyBackUp,mapRepGDM);
        
        //When processing all future records, Inner class will be null.
        if(listInnercls ==null){
            return;
        }
        //mapBuddyAccess hold acc + Buddy and ATM info
        Map<String,AccountTeamMember> mapBuddyAccess = helper.calculateAccesslevels(listInnercls,mapBackupBuddy);
        Set<AccountTeamMember> setBuddy2Replace = new Set<AccountTeamMember>();
        Set<ID> setBuddy2Remove = new Set<ID>();
        Map<ID,List<AtmGDMRelationClass>> mapATMGDM = new Map<ID,List<AtmGDMRelationClass>>();
        for(AtmGDMRelationClass innerClass:listInnercls){
            if(mapATMGDM.containsKey(innerClass.idBuddyATM)){
                mapATMGDM.get(innerClass.idBuddyATM).add(innerClass);
            }else{
                mapATMGDM.put(innerClass.idBuddyATM, new List<AtmGDMRelationClass>());    
                mapATMGDM.get(innerClass.idBuddyATM).add(innerClass);
            }
            
            if(innerClass.idBuddyATM == null){
                setGDMId.add(innerClass.idGdmReq);
                continue;
            }
            
            if(innerClass.idLastModifiedBy == Label.AffinityInformaticaUserId){
                listAffirnityATM.add(innerClass.idBuddyATM);
                continue;
            }
            if(mapBuddyAccess.containsKey(innerClass.idBuddyUser+''+innerClass.idAccount)){
                setBuddy2Replace.add(mapBuddyAccess.get(innerClass.idBuddyUser+''+innerClass.idAccount));
            }else{
                setBuddy2Remove.add(innerClass.idBuddyATM); // To remove
            }                              
        }
        Database.DeleteResult[] listDeleteResult;    
        Database.Saveresult[] listSaveResults; 
        Savepoint sp = Database.setSavepoint();
        //3.0 start
        if(!setBuddy2Remove.isEmpty()){
            listBuddy2Remove.addAll(setBuddy2Remove);
            while(intRetry <= MAX_ATTEMPTS){
                try{
                    listDeleteResult = Database.delete(listBuddy2Remove);
                    intRetry = 4;
                }catch(Exception objExcep){
                    if(++intRetry > 3){                            
                        excep.processError(mapATMGDM, listBuddy2Remove, objExcep);                  
                        throw objExcep;
                    }
                }
                
            }            
        }
         if(!setBuddy2Replace.isEmpty()){
            intRetry = 0;
            listBuddy2Replace.addAll(setBuddy2Replace);   
            while(intRetry <= MAX_ATTEMPTS){
                try{
                    listSaveResults = Database.insert(listBuddy2Replace);
                    intRetry = 4;
                }catch(Exception objExcep){
                    if(++intRetry > 3){
                        excep.processError(mapATMGDM, listBuddy2Remove, objExcep);   
                        excep.processError(listInnercls, listBuddy2Replace, objExcep);
                        Database.rollback(sp);                    
                        throw objExcep;
                    }
                }
            }
        }
        if(listSaveResults !=null){
            for(Database.SaveResult objSaveResult : listSaveResults){
                if(objSaveResult.isSuccess()){
                    ID idBuddyATM = objSaveResult.getID();
                    for(AtmGDMRelationClass atmGDM:mapATMGDM.get(idBuddyATM)){
                        setGDMId.add(atmGDM.idGdmReq); 
                    }
                }
            }          
        } 
        
        if(listDeleteResult != null){
            for(Database.DeleteResult objDelResult : listDeleteResult){
                if(objDelResult.isSuccess()){
                    ID idBuddyATM = objDelResult.getId();
                    for(AtmGDMRelationClass atmGDM:mapATMGDM.get(idBuddyATM)){
                        setGDMId.add(atmGDM.idGdmReq); 
                    }
                }
            }
        }        
        
         if(!listAffirnityATM.isEmpty()){
            for(ID idBuddyATM:listAffirnityATM){                
                for(AtmGDMRelationClass atmGDM:mapATMGDM.get(idBuddyATM)){
                    setGDMId.add(atmGDM.idGdmReq); 
                }
            }            
        } 
        //3.0 End
    }
    
    global void finish(Database.BatchableContext BC) {
        //3.0
        List<GDM_Request__c> listGDMStatus = new List<GDM_Request__c>();
        List<Exception__c> listException = new List<Exception__c>();
        GDM_Request__c objGDM;
        Boolean bError = false;
        String strSubject='Buddy Revoke Request failed during GDM status update.';
        String strMsg='Hi Team, \n\n Error Occurred while changing status from \'Removing Access\' to \'Access Removed\' in Batch_BuddyRevoke Class. Below are the Error details.\n\n';
        for(ID idGDM:setGDMId){
            objGDM = new GDM_Request__c();
            objGDM.Id = idGDM;
            objGDM.Buddy_Access_Status__c = 'Access removed';  
            listGDMStatus.add(objGDM);
        }
        if(!setInitialGDMId.containsAll(setGDMId) || setGDMId.isEmpty()){
            for(ID idGDM:setInitialGDMId){
                if(!setGDMId.contains(idGDM) || setGDMId.isEmpty()){
                   objGDM = new GDM_Request__c();
                    objGDM.Id = idGDM;
                    objGDM.Buddy_Access_Status__c = 'Access provided';  
                    listGDMStatus.add(objGDM);
                    
                }
            }
            }
        if(!listGDMStatus.isEmpty()){
            TriggerExecutionController.setskipGDMRequestTriggers(true);
            Database.Saveresult[] objSR = Database.Update(listGDMStatus,false);//4.0 start
            TriggerExecutionController.setskipGDMRequestTriggers(false);
            for(integer i = 0; i< objSR.size();i++){
                if(!objSR[i].isSuccess()){
                    bError = true;
                }
            }
            excep.notifyError(BC.getJobId());
            if(bError){
               excep.processError(listGDMStatus,objSR,strSubject,strMsg);
            }//4.0 End
        }
         }
}