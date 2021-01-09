global class NetExam_EvaluateAccount implements Database.Batchable<sObject>,Database.Stateful{      
    PartnerCertDataStructures.AccountData acData;    
    String email;     
    
    global NetExam_EvaluateAccount(PartnerCertDataStructures.AccountData acct, String email){       
        acData = acct;                    
        this.email = email;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc) {        
        PartnerCertEvaluation partCertEval = new PartnerCertEvaluation();        
        List<String> Certifications = partCertEval.getCertificationNames();         
        List<Id> reqmtIds = partCertEval.getRequriementIds(Certifications, acData); 
        return Database.getQueryLocator ([select id, Criteria_Rule__c ,  Country__c,
                                            Apply_Requirement_To__c, Certification_Name__c , Region__c,
                                            Acquisition__c, Prerequisites__c, Prerequisite_Count__c,
                                            (select id, name,Certification_Requirement_Setup__c,
                                                Certification_Criteria_Name__c, Condition__c,
                                                Criteria_Value_Ids__c, Number_of_Demo_Units__c ,
                                                Criteria_Value_Ids_PostFixFormat__c,
                                                Certification_Criteria_Value__c
                                            from Certification_Criteria_Setups__r ),                                                         
                                            (select id, Certification_Requirement_Setup__c, Condition__c,
                                                Prerequisites__c, Prerequisites_Ids__c
                                            from Certification_Prerequisites_Setups__r)
                                         from Certification_Requirement_Setup__c
                                         where id in :reqmtIds ]);    
    } 
    
    global void execute(Database.BatchableContext BC, List<sObject> reqmtList){
        try{
            PartnerCertEvaluation partCertEval = new PartnerCertEvaluation();           
            for (sObject obj : reqmtList){                               
                Certification_Requirement_Setup__c certRequirment = (Certification_Requirement_Setup__c) obj; // cast type to reqmt Setup
                acData = partCertEval.evaluateReqmt_BatchClass(acData,certRequirment); 
            }    
        }
        catch ( exception e){
            System.debug ('Exception occured : ' + e.getMessage() );
        }            
    }
    
    global void finish(Database.BatchableContext BC){
        PartnerCertEvaluation partCertEval = new PartnerCertEvaluation();
        //system.debug('batch...debug...3'+  acData);        
        
        boolean flag = GlobalVariables.BYPASS_FUTURE_CALLS ; // get initial value of the flag
        GlobalVariables.BYPASS_FUTURE_CALLS  = true;        //set BYPASS_FUTURE_CALLS=True to bypass future method call in "accountTrigger"
        boolean result = partCertEval.UpdateTrackerRecords(acData); // update tracker record
        GlobalVariables.BYPASS_FUTURE_CALLS  = flag; // set flag back to original
        
        if (result){
            //if Tracker records are updated successfuly, call future method by-passed in above step to maintain CMI integration.
            // Can not call future method from batch  nor webservice after DML statements, so need to schedule another class to call future method
            NetExam_EvaluateAccountSchedule ns = new NetExam_EvaluateAccountSchedule();
            ns.AccountId = acData.AccountID;
            datetime myDate = datetime.now(); 
            myDate = myDate.addMinutes(2); // schedule class to run after few minutes, else scheduling can fail
            String sch =  '0 '  + myDate.minute() + ' ' + myDate.hour() + ' ' + myDate.day()  + ' ' + myDate.month() + ' ? ' + myDate.year();  //'0 30 8 10 2 ?';
            //System.schedule('CMI-Account Update -- NetExam Evaluation Batch', sch, ns);      
            System.schedule('CMI-Account Update -- NetExam Evaluation Batch' + datetime.now(), sch, ns);        
  
        }
        
        //send email to user for evalaution complete..
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information.    
        AsyncApexJob a = [Select Id, Status, NumberOfErrors,                       
                            JobItemsProcessed, TotalJobItems, CreatedBy.Email                        
                            from AsyncApexJob                         
                            where Id =:BC.getJobId()];                            
          

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setSenderDisplayName('no_reply');
        mail.setReplyTo('no_reply@dell.com');                                   
        mail.setSubject('Partner Competency Evaluation Status :' + a.Status); 
        String[] toAddresses = new String[] {this.email};    
        mail.setToAddresses(toAddresses);       
        mail.setUseSignature(true);     
        String msg='';
        if (a.NumberOfErrors > 0)
            msg = 'The competency evaluation process for account ' +  acData.AcctName + ' has failed due to some exception.';                
        else
            msg = 'The competency evaluation process for account ' +  acData.AcctName + ' has successfully completed.';
        
        mail.setPlainTextBody ('Dear Competency Admin, \n\n' 
                                    + msg 
                                    + '\n\n\n Partner Competency Automation \n Dell | Global Certified Partner Program & Channel');
        mail.setHTMLBody ('Dear Competency Admin, <br/><br/>' 
                                    + msg 
                                    + '<br/><br/><br/> Partner Competency Automation <br/> Dell | Global Certified Partner Program & Channel');
                                            
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
        
    }        
}