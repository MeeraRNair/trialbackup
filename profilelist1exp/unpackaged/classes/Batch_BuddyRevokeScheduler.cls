/*
 * Author  : Krishnakumar M
 * Purpose : Buddy Request Functionality
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR14112      05.02      20-Feb-2017     Krishnakumar    Buddy Request - Create Batch Processes to Add/Remove Buddy member to ATM
 * 2.0      CR14556      07.02      29-Jun-2017     Krishnakumar    SE148 - Fix for the Defect 3497907 Buddy Access batch process 
 * 3.0      CR16640      08.02      04-Jul-2017     Krishnakumar    SE149 - SE149 - Permanent Fix for the Defect 3497907 Buddy Access batch process
 */
global class Batch_BuddyRevokeScheduler implements Schedulable{
	global Integer intScope {get;set;}
    global void execute(SchedulableContext sc){        
        Batch_BuddyRevoke buddyRevokeBatch= new Batch_BuddyRevoke ();
        Integer iDateLimit = Integer.valueOf(Label.GDM_End_Date_Limit);
        //buddyRevokeBatch.strQuery='select id,name,Buddy__c,Rep_on_Leave__c,Buddy_Access_Start_Date__c,Buddy_Access_End_Date__c,Buddy_Access_Status__c,Notes__c,Request_Type__c,Reason_Requested__c,Comments2__c from GDM_Request__c where Buddy_Access_Status__c = \'Access provided\' and recordtype.developerName = \'Buddy_Access\' and Buddy_Access_End_Date__c = LAST_N_DAYS:'+iDateLimit  ;
        //system.debug('Query to Revoke--'+buddyRevokeBatch.strQuery);
        database.executebatch(buddyRevokeBatch,intScope);        
    }  
}