/*
Author: Carmen

History:
Version  Date          Modified By     Description       
--------------------------------------------------------------------------------------
1.0      18-Nov-2010   Carmen          Created for CR4460
2.0      02-Dec-2010   Carmen          Added Send Account Suggestion flag 
3.0		 01-Apr-2013   Men Mee		   CR8082 Create custom label to store last n days
*/
    
global class BatchLinkAccountExecute implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchLinkAccount bLinkAccount = new BatchLinkAccount();
        String query = 'SELECT l.Status, l.Account__c, l.Suggestion_ID__c, l.RecordType.Name, l.Partner_Request__r.Account__c, l.Partner_Request__r.Send_Account_Suggestion_Is_Complete_Flag__c, l.Partner_Request__r.Link_to_Account_Record_Is_Complete_Flag__c, l.Partner_Request__r.Status__c';
        query += ' FROM Lead l WHERE l.Partner_Request__r.Update_Account_In_GAMA_Is_Complete_Flag__c = True AND';
        query += System.Label.Query_All != 'True' ? ' l.LastModifiedDate >= LAST_N_DAYS:' + System.Label.Query_Last_n_days + ' AND' : ''; 
        query += ' (((l.Partner_Request__r.Status__c = \'Account Suggestion Submitted\' OR l.Partner_Request__r.Status__c = \'Lead Draft\') AND (l.Status = \'Account Suggestion Submitted\' OR l.Status = \'Account Suggestion Completed\'))';
        query += ' OR';
        query += ' (l.Suggestion_ID__c = null AND (l.RecordType.Name = \'Account Suggestion\' OR l.RecordType.Name = \'Account Suggestion Locked\') AND (l.Account__c != null OR l.Partner_Request__r.Account__c != null)))';
        bLinkAccount.query = query;                 
        ID batchprocessid1 = Database.executeBatch(bLinkAccount,200); 
    }
    
     global void activate(){
    }
}