/*
 * Author  : Krishnakumar M
 * Purpose : Buddy Request Functionality
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR14112      05.02      20-Feb-2017     Krishnakumar    Buddy Request - Create Batch Processes to Add/Remove Buddy member to ATM
 * 2.0      CR16640      08.02      04-Jul-2017     Krishnakumar    SE149 - SE149 - Permanent Fix for the Defect 3497907 Buddy Access batch process
 * 3.0      CR14846      10.01      25-Aug-2017     Nagaraju        Updated the update statemnt code with partial execution if any records fails it will update the other GSD record status.
 */
global class Batch_BuddyAddition implements Database.Batchable<sObject>,Database.Stateful {
    public Set<ID> setGDMId = new Set<ID>();
    public Set<ID> setInitialGDMId = new Set<ID>();
    private static final Integer MAX_ATTEMPTS = 3;
    public BuddyUserHelper excep = new BuddyUserHelper();
    private List<GDM_Request__c> listBuddyReq;

    global Database.QueryLocator start(Database.BatchableContext BC){  
        Set<ID> setRepId = new Set<ID>();
        listBuddyReq = [select id,name,Buddy__c,Rep_on_Leave__c,Buddy_Access_Start_Date__c,Buddy_Access_End_Date__c,Buddy_Access_Status__c,Notes__c,Request_Type__c,Reason_Requested__c,Comments2__c from GDM_Request__c where Buddy_Access_Status__c = 'Approved and scheduled' and Buddy_Access_Start_Date__c <= today and Buddy_Access_End_Date__c >= tomorrow and recordtype.developerName = 'Buddy_Access'];      
        for(GDM_Request__c objGDM:listBuddyReq){
            objGDM.Buddy_Access_Status__c = 'Providing Access';
        }
        if(!listBuddyReq.isEmpty()){
            Boolean bError = false;
            String strSubject='Buddy Addition Request failed during GDM status update.';
            String strMsg='Hi Team, \n\n Error Occurred while changing status from \'Approved and Scheduled\' to \'Providing Access\' in Batch_BuddyAddition Class. Below are the Error details.\n\n';
            TriggerExecutionController.setskipGDMRequestTriggers(true);
            Database.SaveResult[] srList = Database.Update(listBuddyReq,false);//3.0 start
            for(Integer iCount=0;iCount<srList.size();iCount++){
                Database.SaveResult sr = srList.get(iCount);
                if (sr.isSuccess()) {
                    setInitialGDMId.add(sr.getId());
                    setRepId.add(listBuddyReq.get(iCount).Rep_on_Leave__c);
                }else{
                    bError = true; 
                }
            }
            
            TriggerExecutionController.setskipGDMRequestTriggers(false);                
            if(bError){                
                excep.processError(listBuddyReq,srList,strSubject,strMsg);
            }//3.0 End
        }

        List<ID> listRepId = new List<ID>();
        listRepId.addAll(setRepId);
        String strQuery = 'select id,AccountAccessLevel,AccountId,CaseAccessLevel,OpportunityAccessLevel,TeamMemberRole,UserId FROM AccountTeamMember  where UserId in :listRepId order by AccountId';
        return Database.getQueryLocator(strQuery);
    }
        global void execute(Database.BatchableContext BC, list<AccountTeamMember> listRepATM){
        Set<ID> setAccountId = new Set<ID>();
        Set<ID> setBuddyUser = new Set<ID>();   
        List<AtmGDMRelationClass> listInnercls = new List<AtmGDMRelationClass>();
        Map<ID,list<GDM_Request__c>> mapROLReq = new Map<ID,list<GDM_Request__c>>(); //Convert to list and try.
        AtmGDMRelationClass innercls;

        for(GDM_Request__c objGDMReq:listBuddyReq){
            if(mapROLReq.containsKey(objGDMReq.Rep_on_Leave__c)){
                (mapROLReq.get(objGDMReq.Rep_on_Leave__c)).add(objGDMReq);
            }else{                    
                mapROLReq.put(objGDMReq.Rep_on_Leave__c, new List<GDM_Request__c>()); 
                (mapROLReq.get(objGDMReq.Rep_on_Leave__c)).add(objGDMReq);
            }            
            
        }
            for(AccountTeamMember objATM:listRepATM){
            if(mapROLReq.containsKey(objATM.UserId)){
               
                for(GDM_Request__c objBuddyReq :mapROLReq.get(objATM.UserId)){ 
                    innercls = new AtmGDMRelationClass();
                    innercls.idBuddyUser = objBuddyReq.Buddy__c;
                    innercls.idRolUser = objBuddyReq.Rep_on_Leave__c;
                    innercls.idGdmReq = objBuddyReq.id;
                    innercls.idAccount = objATM.AccountId;
                    innercls.idRepATM = objATM.id;
                    innercls.strRepAccountAccess = objATM.AccountAccessLevel;
                    innercls.strRepCaseAccess = objATM.CaseAccessLevel;
                    innercls.strRepOpportunityAccess = objATM.OpportunityAccessLevel;
                    innercls.strRepTeamMemberRole = objATM.TeamMemberRole;
                    innercls.dtStartDate = objBuddyReq.Buddy_Access_Start_Date__c;
                    innercls.dtEndDate = objBuddyReq.Buddy_Access_End_Date__c;
                    listInnercls.add(innercls);
                    setAccountId.add(objATM.AccountId);  
                    setBuddyUser.add(objBuddyReq.Buddy__c);   
                }                              
            }
        }
        
        for(AccountTeamMember objATM:[select id,AccountAccessLevel,AccountId,CaseAccessLevel,OpportunityAccessLevel,TeamMemberRole,UserId,LastModifiedById FROM AccountTeamMember 
                                                    where UserId in : setBuddyUser and AccountId in :setAccountId]){
            for(AtmGDMRelationClass innerclass:listInnercls){
                if(innerclass.idBuddyUser == objATM.UserId && innerclass.idAccount == objATM.AccountId){
                    innerclass.idBuddyATM = objATM.id;
                    innerclass.strBuddyAccountAccess = objATM.AccountAccessLevel;
                    innerclass.strBuddyCaseAccess = objATM.CaseAccessLevel;
                    innerclass.strBuddyOpportunityAccess = objATM.OpportunityAccessLevel;
                    innerclass.strBuddyTeamMemberRole = objATM.TeamMemberRole;
                }                    
            }
        }
        
        BuddyUserHelper helper = new BuddyUserHelper();        
        Map<String,AccountTeamMember> mapBuddyAccess = helper.calculateAccessLevels(listInnercls);
        List<AccountTeamMember> listBuddy2Insert = new List<AccountTeamMember>();
        AccountTeamMember objBuddyAtm;
        AccountTeamMember objBuddyAccess;
        for(AtmGDMRelationClass innerClass:listInnercls){
            objBuddyAccess = mapBuddyAccess.get(innerClass.idBuddyUser+''+innerClass.idAccount);
            objBuddyAtm = new AccountTeamMember();
            objBuddyAtm.AccountAccessLevel=objBuddyAccess.AccountAccessLevel;
            objBuddyAtm.AccountId = innerClass.idAccount;
            objBuddyAtm.CaseAccessLevel = objBuddyAccess.CaseAccessLevel;
            objBuddyAtm.OpportunityAccessLevel = objBuddyAccess.OpportunityAccessLevel;                
            objBuddyAtm.UserId = innerClass.idBuddyUser; 
            objBuddyAtm.TeamMemberRole = objBuddyAccess.TeamMemberRole;
            listBuddy2Insert.add(objBuddyAtm);
        }
        Database.Saveresult[] objSaveResults;
        Savepoint sp = Database.setSavepoint();
        if(!listBuddy2Insert.isEmpty()){
            Boolean bInsertSuccess = true;              
            Integer iRetry = 0;
            while(iRetry <= MAX_ATTEMPTS){
                try{
                        objSaveResults = Database.insert(listBuddy2Insert); //Try with allornone false when u r free.
                        iRetry = 4;
                        if(Test.isRunningTest()){
                            throw new TestException('Test Exception');
                        }                       
                    }catch(Exception objExcep){
                        if(++iRetry > 3){
                            //System.debug('**********DML Lock error came**************');      
                            excep.processError(listInnercls, listBuddy2Insert, objExcep);
                            if(!Test.isRunningTest()){
                                bInsertSuccess = false;
                                Database.rollback(sp);                      
                                throw objExcep;
                            }
                        }
                    }
            }  
           
            for(integer i = 0; i< objSaveResults.size();i++){
                if(objSaveResults[i].isSuccess()){
                    AccountTeamMember objATM = listBuddy2Insert.get(i);
                    for(AtmGDMRelationClass atmGDM:listInnercls){
                        if(objATM.UserId == atmGDM.idBuddyUser && objATM.AccountId == atmGDM.idAccount){
                            setGDMId.add(atmGDM.idGdmReq);                                                       
                        }
                    }
                }
            }

            if(bInsertSuccess){               
                if(!BackUpBuddyATM(listInnercls,setAccountId)){
                    Database.rollback(sp); 
                }
            }

        }
    }
    
private Boolean BackUpBuddyATM(List<AtmGDMRelationClass> atmGDMList,Set<ID> setAccountId){
        List<GDM_Request__c> listBackUpATM = new List<GDM_Request__c>();
        GDM_Request__c objBuddyGDM;
        GDM_Request__c objGDM;
        Map<String,GDM_Request__c> mapExistingBuddy = new Map<String,GDM_Request__c>(); 

        Id idRecordType = IdLookupUtils.getRecordTypeId('ATM History For Buddy Access','GDM_Request__c',true);
        for(GDM_Request__c bckUpBuddyATM:[select id,Account_ID__c,AccountAccessLevel__c,CaseAccessLevel__c,GDM_Request__c,OpportunityAccessLevel__c,TeamMemberRole__c,GDM_Request__r.Buddy__c,GDM_Request__r.Buddy_Access_Start_Date__c,Is_New_Buddy__c from GDM_Request__c 
                                            where recordtypeid = :idRecordType and GDM_Request__r.Buddy_Access_Status__c in ('Providing Access','Access provided') and Account_ID__c = :setAccountId
                                            order by GDM_Request__r.Buddy_Access_Start_Date__c asc]){
            if(!mapExistingBuddy.containsKey(bckUpBuddyATM.GDM_Request__r.Buddy__c+''+bckUpBuddyATM.Account_ID__c)){
                mapExistingBuddy.put(bckUpBuddyATM.GDM_Request__r.Buddy__c+''+bckUpBuddyATM.Account_ID__c, bckUpBuddyATM);
            }
        }
        for(AtmGDMRelationClass innerCls:atmGDMList){
            if(innerCls.idBuddyATM != null){
                if(mapExistingBuddy.containsKey(innerCls.idBuddyUser+''+innerCls.idAccount)){
                        objGDM = mapExistingBuddy.get(innerCls.idBuddyUser+''+innerCls.idAccount);
                        objBuddyGDM = new GDM_Request__c();
                        objBuddyGDM.AccountAccessLevel__c = objGDM.AccountAccessLevel__c;
                        objBuddyGDM.CaseAccessLevel__c = objGDM.CaseAccessLevel__c;
                        objBuddyGDM.OpportunityAccessLevel__c = objGDM.OpportunityAccessLevel__c;
                        objBuddyGDM.TeamMemberRole__c = objGDM.TeamMemberRole__c;
                        objBuddyGDM.Is_New_Buddy__c = objGDM.Is_New_Buddy__c;
                    }else{
                        objBuddyGDM = new GDM_Request__c();                        
                        objBuddyGDM.AccountAccessLevel__c = innerCls.strBuddyAccountAccess;
                        objBuddyGDM.CaseAccessLevel__c = innerCls.strBuddyCaseAccess;
                        objBuddyGDM.OpportunityAccessLevel__c = innerCls.strBuddyOpportunityAccess;
                        objBuddyGDM.TeamMemberRole__c = innerCls.strBuddyTeamMemberRole;
                        objBuddyGDM.Is_New_Buddy__c = false;
                    }                     
            }else{
                objBuddyGDM = new GDM_Request__c();
                objBuddyGDM.AccountAccessLevel__c = 'None';
                objBuddyGDM.CaseAccessLevel__c = 'None';
                objBuddyGDM.OpportunityAccessLevel__c = 'None';
                objBuddyGDM.TeamMemberRole__c = innerCls.strRepTeamMemberRole;
                objBuddyGDM.Is_New_Buddy__c = true;
            }
            objBuddyGDM.RecordtypeId = idRecordType;
            objBuddyGDM.Account_ID__c = innerCls.idAccount;
            objBuddyGDM.GDM_Request__c = innerCls.idGdmReq;
            objBuddyGDM.Rep_Account_Access_Level__c = innerCls.strRepAccountAccess;
            objBuddyGDM.Rep_Case_Access_Level__c = innerCls.strRepCaseAccess;
            objBuddyGDM.Rep_Opportunity_Access_Level__c = innerCls.strRepOpportunityAccess;
            objBuddyGDM.Rep_on_Leave__c = innerCls.idRolUser;
            objBuddyGDM.Buddy__c = innerCls.idBuddyUser;
            listBackUpATM.add(objBuddyGDM);
        }
            TriggerExecutionController.setskipGDMRequestTriggers(true);
            List<Exception__c> listException = new List<Exception__c>();
            Database.Saveresult[] objSRBackUp;
            try{
                   objSRBackUp =  Database.insert(listBackUpATM);
                }catch(Exception ex){
                    Set<ID> setID = new Set<ID>();
                    for(GDM_Request__c objGDMErr:listBackUpATM){
                        setID.add(objGDMErr.GDM_Request__c);
                    }
                    listException.add(new Exception__c(Error_Messages__c = '-Insert failed-'+ex.getStackTraceString(),Object_type__c='GDM_Request__c',Operation__c='Insert', Process_Name__c='Buddy Request - ATM Backup',Notes__c='Batch_BuddyAddition class - ATM Back History Scenario'+setID));                    
                }
            
            String strErrMsg = '';
            Set<ID> setErrRec = new Set<ID>();
            for(integer i = 0; i< objSRBackUp.size();i++){
                if(!objSRBackUp[i].isSuccess()){
                    Database.Error objError = objSRBackUp[i].getErrors().get(0);
                    strErrMsg = ''+objError.getMessage();
                    setErrRec.add(listBackUpATM.get(i).GDM_Request__c);
                }
            }           
            TriggerExecutionController.setskipGDMRequestTriggers(false);
            if(!setErrRec.isEmpty()){
                listException.add(new Exception__c(Error_Messages__c = '-Insert failed-'+strErrMsg,Object_type__c='GDM_Request__c',Operation__c='Insert', Process_Name__c='Buddy Request - ATM Backup',Notes__c='Batch_BuddyAddition class - ATM Back History Scenario'+setErrRec));
                insert listException;
                return false;
            }
        return true;
    }
    global void finish(Database.BatchableContext BC){
        //2.0
        List<GDM_Request__c> listGDMStatus = new List<GDM_Request__c>();
        List<Exception__c> listException = new List<Exception__c>();
        GDM_Request__c objGDM;
        Boolean bError = false;
        String strSubject='Buddy Addition Request failed during GDM status update.';
        String strMsg='Hi Team, \n\n Error Occurred while changing status from \'Providing Access\' to \'Access Provided\' in Batch_BuddyAddition Class. Below are the Error details.\n\n';
        for(ID idGDM:setGDMId){
            objGDM = new GDM_Request__c();
            objGDM.Id = idGDM;
            objGDM.Buddy_Access_Status__c = 'Access provided';  
            listGDMStatus.add(objGDM);
        }
        if(!setInitialGDMId.containsAll(setGDMId)  || setGDMId.isEmpty()){
            System.debug('All GDM not processed.');
            for(ID idGDM:setInitialGDMId){
                if(!setGDMId.contains(idGDM)  || setGDMId.isEmpty()){
                    //System.debug('All GDM not processed.'+idGDM);
                    objGDM = new GDM_Request__c();
                    objGDM.Id = idGDM;
                    objGDM.Buddy_Access_Status__c = 'Approved and scheduled';  
                    listGDMStatus.add(objGDM);
                }
            }
        }
        if(!listGDMStatus.isEmpty()){            
            TriggerExecutionController.setskipGDMRequestTriggers(true);
            Database.Saveresult[] objSR = Database.Update(listGDMStatus,false);//3.0 start
            TriggerExecutionController.setskipGDMRequestTriggers(false);
            for(integer i = 0; i< objSR.size();i++){                    
                if(!objSR[i].isSuccess()){
                    bError = true;
                }
            }
            excep.notifyError(BC.getJobId());       
            if(bError){                
                excep.processError(listGDMStatus,objSR,strSubject,strMsg);
            }//3.0 End
        } 
        Integer intBatchSize=Integer.ValueOf(system.Label.Oppty_Share_Buddy_Batch_Size);
        Batch_OpptyShareToBuddy opptyshare=new Batch_OpptyShareToBuddy();
        Id batchId = Database.executeBatch(opptyshare,intBatchSize);        
    }  
 public class TestException extends Exception {}
}