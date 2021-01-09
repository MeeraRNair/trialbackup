/*
Author: Azwanti Zuber

History:
Version Date            Modified By     Description     
-----------------------------------------------------------------------------------------------------------------------------------------
1.0      17-June-2010   Azwanti         Created for CR2246, R11.7
1.1      8-Sept-2010    Alvin           Created for CR4187  R11.10
2.0      08-Jan-2018    Kokila          FY20-DCE-0202 - Lead 2.0 - Campaign Status enhancements - "Aborted" status renamed to "Cancelled" 
-----------------------------------------------------------------------------------------------------------------------------------------
*/
global class BatchUpdateCampaignMember implements Database.Batchable<sObject>{
    global String strQueryCampaignMember;
    
    global database.querylocator start(Database.BatchableContext bc){
        // Send an email notifying of job start.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] listToAddresses = new String[] {'azwanti_zuber@dell.com'};
        mail.setToAddresses(listToAddresses);
        mail.setSubject('Starting CampaignMember update Status batch');
        mail.setPlainTextBody
                ('Starting the batch Apex job at :'+  Datetime.now());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return Database.getQueryLocator(strQueryCampaignMember);
    }
    global void execute(Database.BatchableContext bc, List<sObject> listScope){
        List<CampaignMember> listCMStatusListForUpdate = new List<CampaignMember>();
        
        for(sObject s : listScope){        
            if(s.getSObjectType() == CampaignMember.sObjectType){                
                CampaignMember cm = (CampaignMember)s;
                //v2.0 - Start
                //if(cm.Campaign.Status == 'Aborted' && cm.campaign.Proceed_with_cancellation__c=='Yes'){
                if(cm.Campaign.Status == 'Cancelled'){ //v2.0 - End
                    cm.CM_Status__c = 'Cancelled';
                    listCMStatusListForUpdate.add(cm);
                }
                else if(cm.Campaign.IsActive == false && cm.CM_Status__c == 'Requires Follow-Up'){
                    cm.CM_Status__c = 'Inactive';
                    listCMStatusListForUpdate.add(cm);
                }
                else if(cm.Campaign.IsActive == true && cm.CM_Status__c == 'Inactive'){
                    cm.CM_Status__c = 'Requires Follow-Up';
                    listCMStatusListForUpdate.add(cm);
                }      
            }
        }
        if(listCMStatusListForUpdate.size() > 0){   
            Database.SaveResult[] listLsr = Database.update(listCMStatusListForUpdate,false);
 
            for(Database.SaveResult sr : listLsr){ 
                if (!sr.isSuccess()) { 
                    System.debug('###DEBUG### BatchUpdateCampaignMember update error - ' + sr);
                }
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }
}