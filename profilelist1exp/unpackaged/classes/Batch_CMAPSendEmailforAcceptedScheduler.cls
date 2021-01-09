/*
 * Revision CR Number   Release No  	Date            Modified By     		Description
 * -------- ---------   ----------  	-----------     ------------    		-----------
 * 1.0      CR 10496    14.10       	19-Nov-2013     Jiji            		Batch Class for sending Email for accepted partner created leads
 * 2.0      CR 10742    16.03       	02-Jan-2015     Anamika/Ragu    		Allow the partner admin or partner company to indicate who receives the notices for “Leads are ready” and who doesn't.
 * 3.0      CR 15627    FY19-DCE-0502   11-Apr-2018     Subramani Ramamurthy   	Channel: Reactivate "Channel Email for Accepted Leads” email notifiation
 
*/

global class Batch_CMAPSendEmailforAcceptedScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        Id leadassignmnetRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete', 'Lead', true);
              Batch_CMAPSendEmailforAccepted batchObj = new Batch_CMAPSendEmailforAccepted();
        
        /*---- 3.0 Start---*/
        batchObj.query ='SELECT Id, Status, RecordTypeId,OwnerId, CreatedDate, Partner_User__c,Send_email_for_Accepted_Status__c,Owner_Language_Code__c from Lead where Status=\'Accepted By Channel Partner\' AND RecordTypeID=\''+leadassignmnetRTId+'\' AND  Send_email_for_Accepted_Status__c =TRUE AND CreatedDate>='+System.Label.Batch_Processing_Date+''; 
        system.debug('###batchObj.query####' + batchObj.query);
        database.executebatch(batchObj,200);
         /*---- 3.0 End---*/
    }  
}