/*

Author: Jessie Tan
History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      16-May-2015    Jessie          Created for CR11468/CR11467 - To update 8 statuses (if the associated steps are not null) and Overall Status to 'Complete')
2.0      04-July-2015   Jessie          Modified for CR11662 - To update Transition Completed Date to today's date when 'All Transition Steps Completed' button is clicked.
3.0      10-Nov-2016    Syuhada         CR13705	- Story 2539296:Modify functionality in Account Handover
*/

public class TransitionStepCompleteCtrl{
    
    Account_Handover__c targetAccountHandover ;
    
    public TransitionStepCompleteCtrl(ApexPages.StandardController controller) { 
        
        try {
        
            String accountHandoverId  = controller.getId();
             
            //3.0 remove Status01 field- Status08 field
            targetAccountHandover = [SELECT Id, Step_1__c, Step_2__c, Step_3__c, Step_4__c, Step_5__c, Step_6__c, Step_7__c,Step_8__c,
                    Overall_Status__c, Date_for_Warm_Handover_Call__c FROM Account_Handover__c WHERE ID = :accountHandoverId ];
        }catch(Exception e) {
           handleError(e);
       }
        
    }

    public PageReference doComplete() {
     
        try {
            targetAccountHandover.Overall_Status__c = 'Complete';
            
            //v2.0 - start
            targetAccountHandover.Date_for_Warm_Handover_Call__c = System.Today();
            //v2.0 - end 
             
            update targetAccountHandover;
            
        }catch(Exception e) {
            handleError(e);
        }
        
        return  new PageReference('/'+targetAccountHandover.Id);
                        
    }
    
    // Handle all exceptions
    @TestVisible private void handleError(Exception e) {
        
        System.debug('### Error Stack Trace : ' + e.getStackTraceString());
        System.debug('### Message : ' + e.getMessage());
        
        apexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'An unexpected error has occurred. Please contact the administrator.'));
    
    }
    
}