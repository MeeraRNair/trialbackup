/* 
History:
Version     Date            Modified By     CR          Description     
--------------------------------------------------------------------------------------
1.0         19-Aug-2015     Shue            11838       Schedule created to Reduce emails-combining emails 
2.0         19-May-2015     Rajkumar        14340       Added Query in Scheduler Class 
3.0         23-May-2016     Rajkumar        14445       Notification to Account Transition Owner
*/


global class BatchAccountHandoverSendEmailSchedule implements schedulable{
   
    
    global void execute (SchedulableContext SC){
      
       DateTime theDate = DateTime.now().addDays(-1);  
        string query;
        //2.0   - Added Query in Scheduler Class
        //3.0   - Added Account Transition Owner
        query = 'Select User.Id from User where User.Id in (SELECT Account_Transition_Owner__c FROM Account_Handover__c WHERE Account_Transition_Owner__c != null AND Transition_Start_date__c != null AND CreatedDate >= :theDate)';
        // Commented the below query because Incoming_Rep__C is not an reciepient henceforth
        // 'Select User.Id from User where User.Id in (SELECT Incoming_rep__c FROM Account_Handover__c WHERE Incoming_rep__c != null AND Transition_Start_date__c != null AND CreatedDate >= :theDate)';  
       
        BatchAccountHandoverSendEmail  BatchAHSE = new BatchAccountHandoverSendEmail();
        BatchAHSE.theDate = theDate;
        BatchAHSE.query=  query;
        database.executebatch(BatchAHSE,Integer.valueOf(Label.Account_Handover_Incoming_Rep_Batch_Limit));
    }
}