/* ------------------------------------------------------------------------------------------------------------------------
Version   Date             Release No       CR      By              Purpose
1.0       18 Aug 2015                       11856   Dipin Raju      Auto close all open direct leads based on Campaign field  Close Date for Leads
2.0       30-June-2016     FY17-DCS-0801    13288   Azwanti         LM3_13- Fix CR11856 close date default value not updating existing leads after change
3.0       01-Sept-2016     FY17-DCS-1002    13438   Azwanti         LM2_17- Disable code in Lead 2.0 object to update leads to "Cancelled - LQR inactivity" when campaign reaches close date    
4.0       28-Nov-2017      FY18-DCS-0203            Ashok           Marketing LTO - Updating cancel process with new status    

--------------------------------------------------------------------------------------------------------------------------- */

global class BatchUpdateLeadStatusUponEndDate implements Database.Batchable <sObject> , Database.Stateful {
    global String strQueryOpenLead;
    
    public BatchUpdateLeadStatusUponEndDate() {
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {        
        //v2.0 :only process records within this date range       
        Date dtStartDate = System.now().dateGMT() - (integer.valueOf(system.label.LM2_LastNDays_for_CampaignCloseDate));
        Date dtEndDate = System.now().dateGMT(); 
        system.debug('wanti dtStartDate: '+dtStartDate+' ; dtEndDate: '+dtEndDate);
        //v2.0 end
                
        return Database.getQueryLocator([select Id, Status, Owner.Profile.Name 
                                         from Lead where Campaign__r.RecordType.Name = 'Campaign 2.0' 
                                         and RecordType.Name = 'Direct Lead 2.0' and Status in ('New') //v4.0                                          
                                         and Campaign__r.Close_Date_for_Leads__c >= :dtStartDate //v2.0
                                         and Campaign__r.Close_Date_for_Leads__c  <= :dtEndDate //v2.0
                                         and (Owner.Profile.Name like '%Sales%' OR Owner.Profile.Name like '%Marketing%') //v2.0 added
                                         and Owner.Type = 'User']); //v2.0 added         
    }
    
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        try{
            CampaignValidator.bSkipCampaignValidator = true; // v2.0
            LeadValidator.bSkipLeadValidator = true; // v2.0
            system.debug('wanti CampaignValidator.bSkipCampaignValidator: '+ CampaignValidator.bSkipCampaignValidator+LeadValidator.bSkipLeadValidator); 
            List<Lead> updatedLeads = new list<Lead>();
            for(Lead obj : (list<Lead>) scope){ 
                if(obj.Owner.Profile.Name.contains('Sales')){
                    obj.Status = 'Cancelled - Sales Inactivity';                
                }
                updatedLeads.add(obj);  
            }
            // v2.0 added false parameter, to allow the rest of records get updated
            Database.SaveResult[] insResults = database.update(updatedLeads, false);

            for(integer i = 0; i< insResults.size(); i++){  
                Database.Error[] insErrors = insResults[i].getErrors();
                system.debug('BatchUpdateLeadStatusUponEndDate insErrors: '+insErrors);
            }
        }
        catch (Exception e){
            system.debug('BatchUpdateLeadStatusUponEndDate: '+e);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
    }

}