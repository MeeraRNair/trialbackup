public with sharing class ApprovalProcess {
    public static void processint(List<Alliance_Rebate_Request__c> listAlliance) {
         //Get all approval process records from an approval process definition
        List<ProcessInstance> listinstances = [SELECT Id,TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps  ORDER BY CreatedDate DESC LIMIT 1) 
                                           FROM ProcessInstance 
                                           Where TargetObjectId =:listAlliance ORDER BY CreatedDate DESC LIMIT 1];     
         Set<String> setobjectIds = new Set<String>();    
        //Create a set of object Ids which has process instance
            for(ProcessInstance pi:listinstances){
                setobjectIds.add(pi.TargetobjectId);
            }     
        //Query for related records
        Map<Id,Alliance_Rebate_Request__c > mapAlliance = new Map<Id,Alliance_Rebate_Request__c >([Select Approver_Rejection_Comments__c 
                                                                                                   from Alliance_Rebate_Request__c 
                                                                                                   Where Id in:setobjectIds ]);    
        //populate object's comment field from approval comments
            for(ProcessInstance pi:listinstances){               
               for (ProcessInstanceStep step : pi.Steps) {            
                    if(step.StepStatus == 'Approved') {
                        mapAlliance.get(pi.TargetObjectId).Approver_Rejection_Comments__c  = step.Comments;
                    }else if(step.StepStatus == 'Rejected'){
                            mapAlliance.get(pi.TargetObjectId).Approver_Rejection_Comments__c  = step.Comments;
                    }
               }
            }        
        //Update your object
        if(mapAlliance.size()>0){
            update mapAlliance.values();
        }
    }
}