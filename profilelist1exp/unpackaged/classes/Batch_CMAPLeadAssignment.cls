/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Jiji        19-Nov-2013     14.10       --      Batch Class for Automatic Assignment
2.0         Jiji        16-Jul-2014     15.10       --      Change Status to Accepted for Partner created Leads during auto assignment
3.0         Shue        27-Apr-2018     DCS-0602    15686   Story 4144896: Channel: Remove BANT Qualified leads process (Code)
4.0         Rahul       05-June-2018    DSC-0703            Code Reduce
5.0         Shue        14-Aug-2018     FY19-0902           Add else statement for Defect to fix INC6537011: Channel leads assignment issue
*/

global class Batch_CMAPLeadAssignment implements Database.Batchable<sObject> {
    public Boolean isTest = False;
    public String query;
    
    global database.querylocator start(Database.BatchableContext BC){
        DBUtils.flushOutTheJobsQueue();
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            Id leadAssignmentRTId = IdLookupUtils.getRecordTypeId('Channel Lead - Assignment Complete', 'Lead', true);
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.EmailHeader.triggerUserEmail= false;
            dmo.EmailHeader.triggerOtherEmail = false;
            dmo.EmailHeader.triggerAutoResponseEmail = false;

            List<Lead> leadsToUpdateList = new List<Lead>();
            List<Lead> newLeadList = new List<Lead>();
            
            for(sObject obj :scope){
                Lead leadRecord  = (Lead)obj;
                //Ver 2.0: Start
                newLeadList.add(leadRecord );
            }

            for(Lead LeadRec :newLeadList){   
                //Ver 2.0: End
                if(LeadRec.Partner_User__c != NULL && LeadRec.Partner_User__r.IsActive == TRUE){
                    LeadRec.OwnerId = LeadRec.Partner_User__c ;
                    LeadRec.Owner_Language_Code__c = LeadRec.Partner_User__r.LanguageLocaleKey;
                    
                    //3.0 Remove BANT Qualified
                    if(LeadRec.Partner_Event_or_Campaign__c == 'No'){
                        LeadRec.Status = 'Assigned to Channel Partner';
                    }else{
                        LeadRec.Status = 'Accepted by Channel Partner';
                    }
                }else{    //5.0
                    if(LeadRec.Partner_Admin__c != NULL){
                        LeadRec.OwnerId = LeadRec.Partner_Admin__c ;
                        LeadRec.Owner_Language_Code__c = LeadRec.Partner_Admin__r.LanguageLocaleKey;
                        
                        //3.0 Remove BANT Qualified
                        if(LeadRec.Partner_Event_or_Campaign__c == 'No'){
                            LeadRec.Status = 'Assigned to Channel Partner';
                        }else{
                            LeadRec.Status = 'Accepted by Channel Partner';
                        }    
                    }
                }
                                      
                if(LeadRec.Status == 'Assigned to Channel Partner'){ 
                    LeadRec.Partner_Lead_Status__c = 'New';
                    LeadRec.RecordTypeId=leadAssignmentRTId;
                    leadsToUpdateList.add(LeadRec);
                }else{
                    if(LeadRec.Status == 'Accepted by Channel Partner'){
                        LeadRec.Send_email_for_Accepted_Status__c = TRUE;
                        LeadRec.Partner_Lead_Status__c = 'Accepted';
                        LeadRec.Accept_Reject_Reassign_Status__c = 'Accepted by Channel';
                        LeadRec.RecordTypeId=leadAssignmentRTId;
                        leadsToUpdateList.add(LeadRec);
                    }
                    //3.0 Remove BANT Qualified block
                }
            }
            
            database.SaveResult[] updateResults;
            if(leadsToUpdateList.Size() > 0){
                updateResults = Database.Update(leadsToUpdateList, dmo);
            }
            
        }catch (Exception e){
            system.debug('----System.Debug----'+e);
        } 
    }// end of execute method

    global void finish(Database.BatchableContext BC){ 
        datetime systime = system.now();
        integer dueHours = integer.ValueOf(System.Label.CMAP_Batch_Time_Label);
        String seconds, minutes, hours, dayOfMonth, month, dayOfWeek, year;

        // add 2 Hrs before scheduling the next job
        datetime TodayPlusSec = systime.addHours(dueHours); 
        seconds = string.valueOf(TodayPlusSec.second());
        minutes = string.valueOf(TodayPlusSec.minute()); 
        hours = string.valueOf(TodayPlusSec.hour());      
        dayOfMonth = string.valueOf(TodayPlusSec.day());
        month = string.valueOf(TodayPlusSec.month());
        dayOfWeek = '?';
        year = string.valueOf(TodayPlusSec.year()); 
        String schTime = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;

        Batch_CMAPLeadAssignmentScheduler u = new Batch_CMAPLeadAssignmentScheduler();
        system.schedule('Batch_CMAPLeadAssignment' + string.valueof(TodayPlusSec), schTime , u); 
    }
}