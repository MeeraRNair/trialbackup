global class Batch_AutoCloseOpportunities implements Database.Batchable<sObject> {
    
    public String oppQuery;
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        // Query to retrive the opportunities for backup and running the batch
        oppQuery = 'SELECT StageName, Description, Won_Lost_Comment__c,Competitor_Lost_To__c, Reason_Won_Lost__c, Past_Due_Auto_Closed__c ';
        
        if(Test.isRunningtest()){
            //oppQuery = oppQuery + ' FROM Opportunity where closeDate < LAST_N_DAYS:179 AND (Type = \'Deal/Bid - Direct\' OR Type = \'Extension\' OR Type = \'Renewal\' OR Type = \'Try and Buy\') AND Scheduled_Opportunity__c = False AND Source_System__c = null AND (StageName != \'Win - 100%\' AND StageName != \'Lost, Cancelled - 0%\') AND (RecordTypeId = \'012300000004zf2AAA\' OR RecordTypeId = \'012A0000000Vhy7IAC\' ) ORDER BY CloseDate desc LIMIT 1' ;
              oppQuery = oppQuery + ' FROM Opportunity where closeDate < LAST_N_DAYS:179 AND AutoCloseOpp_Criteria__c = true ORDER BY CloseDate desc LIMIT 1' ;
        } else {           
            //oppQuery = oppQuery + ' FROM Opportunity where closeDate < LAST_N_DAYS:179 AND (Type = \'Deal/Bid - Direct\' OR Type = \'Extension\' OR Type = \'Renewal\' OR Type = \'Try and Buy\') AND Scheduled_Opportunity__c = False AND Source_System__c = null AND (StageName != \'Win - 100%\' AND StageName != \'Lost, Cancelled - 0%\') AND (RecordTypeId = \'012300000004zf2AAA\' OR RecordTypeId = \'012A0000000Vhy7IAC\' ) ORDER BY CloseDate desc '; //  LIMIT '+ queryLimit;            
              oppQuery = oppQuery + ' FROM Opportunity where closeDate < LAST_N_DAYS:179 AND AutoCloseOpp_Criteria__c = true ORDER BY CloseDate desc '; //  LIMIT '+ queryLimit;
        }   
         
        system.debug(LoggingLevel.DEBUG, 'Opportunity Query: '+ oppQuery);
        return Database.getQueryLocator(oppQuery);
    }
    
    global void execute(Database.BatchableContext BC, list<Opportunity> oppList){
    
       GlobalVariables.BYPASS_FUTURE_CALLS = true; 
        system.debug('-------Execute Method Starts: '+ oppList);
        
        Opportunity currentOppty;
        
        if(oppList!= null && oppList.size() > 0){
            currentOppty = oppList.get(0);
        }
        
        list<Opportunity> updatedOppList = new list<Opportunity>();
        
        if(oppList != null){
            for(Opportunity opp: oppList){
                opp.StageName = 'Lost, Cancelled - 0%';
                opp.Description = 'Automatically closed out because Book Date is past due over 6 months.';
                opp.Won_Lost_Comment__c = 'Automatically closed out because Book Date is past due over 6 months.';
                opp.Past_Due_Auto_Closed__c = True;
                if(opp.Competitor_Lost_To__c == null){
                    opp.Competitor_Lost_To__c = 'Unknown';
                }
                opp.Reason_Won_Lost__c = 'Past Due Auto Closed';
                updatedOppList.add(opp);
            }
        }
        
        // Set Savepoint for rollback if any error occurs in DML Operation
        Savepoint sp = Database.setSavepoint();
        
        // Updating the opportunity list for Auto close functionality
        try{
         if( updatedOppList != null ){
             update updatedOppList;
         }
        }catch(Exception e){
         
           Exception__c execRec = new Exception__c();
         /*    Error_Messages__c = e.getMessage();
          String errmsg = e.getMessage();
           IF(e.getMessage().length()>255){
        String  errmsg = e.getMessage().substring(0,255);
          execRec.Error_Messages__c =errmsg;
           }
           else
           execRec.Error_Messages__c = e.getMessage(); */
            execRec.Error_Messages__c='Please refer to Notes field for Detailed Error Message';
            execRec.Notes__c=e.getMessage();
            execRec.Object_type__c='Opportunity';
            execRec.Object_ID__c= currentOppty.Id;
            execRec.Process_Name__c='Opportunity Auto Close';
            insert execRec;
           // system.debug('----Exception while DML Operation: '+ e);
          //  Database.rollback(sp);
        }
    }
    
    global void finish(Database.BatchableContext BC){
       
    }
    
}