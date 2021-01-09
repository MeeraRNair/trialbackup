/***********************************************************
    * Name          : BatchAccountHandover 
    * Description   : 
    * ---------------------------------------------------------
    * Revision  Name     CR      Release         Date            Description
    * 1.0       Swathi   13295   FY17-DCS-0801   01-July-2016    Remove the SOQL and use the scope soql to fix production issue - Too many query rows: 50001 and SCOPE query to get from scheduler class
    * 2.0       Rajkumar 14340   FY18-DCS-0602   12-May-2017     Fixed too many SOQL Queries / Fixed Insufficient cross reference entiry  / Inactive owner or user
    *  
************************************************************/
global class BatchAccountHandover implements Database.Batchable<SObject> {
       public String query;
       public Boolean bReRun;
       public Set<ID> setofids = New set<ID>();
       
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        //String soql = 'SELECT Id, Account__c, Incoming_rep__c, Outgoing_rep__c, Transition_Start_date__c, Account_Access_Share__c, Incoming_rep__r.Email, Account_ID__c FROM Account_Handover__c Where Account_Access_Share__c = false AND Incoming_rep__c != null AND Transition_Start_date__c <= Today';
                 
         if(System.Label.Account_Handover_Ids != 'Manual PIT Testing'){
             for(String strEachId :System.Label.Account_Handover_Ids.split(','))
                {                
                    setofids.add(strEachId);                               
                } 
         }           
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {

        List<Exception__c> lstException = new List<Exception__c>();
        List<AccountShare> newAccountShare = new List<AccountShare>();
        List<Account_Handover__c> updateAH = new List<Account_Handover__c>();
        //Set<String> acctTeamMembers = new Set<String>();
        Map<ID,List<AccountShare>> mapAccTeamMembers = new Map<Id,List<AccountShare>>();
        List<AccountShare> listAccountShare;
        AccountShare newAS;
        Set<Id> acctHandOver = new Set<Id>();       
        Map<ID, Account_Handover__c> mapToUpdateAH = new Map<ID, Account_Handover__c>();
        
        for (SObject s : scope) {
           Account_Handover__c AH_Each = (Account_Handover__c)s; 
           acctHandOver.add(AH_Each.Account__c);   
        }
        system.debug('test==acctHandOver : ' + acctHandOver);
        // End 1.0
        
        for (AccountShare acs : [SELECT UserOrGroupId, AccountAccessLevel, AccountId, OpportunityAccessLevel, CaseAccessLevel FROM AccountShare WHERE RowCause = 'Team' and AccountId in :acctHandOver]) {
            //2.0 acctTeamMembers.add(acs.UserOrGroupId);   
            if(mapAccTeamMembers.containsKey(acs.UserOrGroupId)){
                    listAccountShare = mapAccTeamMembers.get(acs.UserOrGroupId);
                    listAccountShare.add(acs);
                    mapAccTeamMembers.put(acs.UserOrGroupId,listAccountShare);//Doubt
                }else{
                    listAccountShare = new List<AccountShare>();
                    listAccountShare.add(acs);
                    mapAccTeamMembers.put(acs.UserOrGroupId,listAccountShare);
                }
            
        }
        for (SObject s : scope) {
            Account_Handover__c aho = (Account_Handover__c)s;   
            //2.0 Check for the user is Active & to avoid insufficient cross reference entity
            if((aho.Incoming_rep__r.isActive) && (aho.account__r.OwnerID <> aho.Incoming_Rep__c)){                
                if (!mapAccTeamMembers.containsKey(aho.Outgoing_rep__c)) {  
                    newAS = new AccountShare();              
                    newAS.AccountAccessLevel = 'Edit';
                    newAS.OpportunityAccessLevel = 'Edit';
                    newAS.CaseAccessLevel = 'Edit';
                    newAS.AccountId = aho.Account__c;
                    newAS.UserOrGroupId = aho.Incoming_rep__c;  
                    newAccountShare.add(newAS);              
                }else if (mapAccTeamMembers.containsKey(aho.Outgoing_rep__c)) {
                    for(AccountShare acs:mapAccTeamMembers.get(aho.Outgoing_rep__c)){
                        if(acs.AccountId == aho.Account__c){
                            newAS = new AccountShare(); 
                            newAS.AccountAccessLevel = acs.AccountAccessLevel; //'Read';
                            newAS.OpportunityAccessLevel = acs.OpportunityAccessLevel; //'Read';
                            newAS.CaseAccessLevel = acs.CaseAccessLevel ; //'Read';
                            newAS.AccountId = aho.Account__c;
                            newAS.UserOrGroupId = aho.Incoming_rep__c;
                            newAccountShare.add(newAS);
                        }
                    }                    
                }
                 aho.Account_Access_Share__c = true;
                 updateAH.add(aho);
            }                    
       
            // To make the Account_Access_Share checkbox TRUE     
           
        }
        
        system.debug('Test==newAccountShare: ' + newAccountShare.size());
        if (!newAccountShare.isEmpty()) {
            //insert newAccountShare;
            if(newAccountShare.size() > 0) {
               try {
                Database.SaveResult[] srList = Database.insert(newAccountShare, false);
            
                /*for (Database.SaveResult sr : srList) {
                    acctHandOver.add(sr.id);
                }*/
                for(Integer j=0; j<srList.size(); j++) {
                    if (srList.get(j).isSuccess()){
                        acctHandOver.add(srList.get(j).getId());
                    } else if(!srList.get(j).isSuccess()) {
                        // DML operation failed
                        lstException.add(new Exception__c(Title__c = 'Account Batch Handover - Batch Jobs', Error_Messages__c = '- Insertion Failed: Please refer to Notes field for Detailed Error Message', Object_type__c = 'AccountShare', Object_ID__c = newAccountShare.get(j).Id, Operation__c = 'Insert', Process_Name__c = 'BatchAccountHandover', Notes__c = '- Insertion Failed: ' + srList.get(j).getErrors()));
                    }
                }

               } catch(Exception e) {
                    lstException.add(new Exception__c(Title__c = 'Account Batch Handover - Batch Jobs', Error_Messages__c = '- BatchJob Failed: Please refer to Notes field for Detailed Error Message', Object_type__c = 'AccountShare', Operation__c = 'Insert', Process_Name__c = 'BatchAccountHandover', Notes__c = '- BatchJob Failed: ' + e.getMessage()));
               }
            
          }
            //To update only those Account Handover which are related to Account share getting created 
            Map<Id,AccountShare> Mapaccountids = new Map<Id, AccountShare>(  
                                          [Select Id, AccountId From AccountShare where id IN :acctHandOver ]);
            System.Debug('MapaccountIDS' + Mapaccountids);                            
            
            for(Id id : Mapaccountids.keySet()){
                for(Account_Handover__c AH :updateAH ){
            
                    if(AH.Account__c == Mapaccountids.get(id).AccountId){
                        mapToUpdateAH.put(AH.id,AH);
                    }  
                }
            }
        }
            update mapToUpdateAH.values();
            insert lstException;

    }

    global void finish(Database.BatchableContext info) {
        //Do nothing
    }
}