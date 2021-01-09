/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0        13171       FY18-DCS-0502   13-April-2017   Azwanti         LM2_Fix missing Campaign Member - Reset triggers flag in batch processing
2.0        14654       FY18-DCS-11-1   21-Sept-2017    Shue            Reset triggers flag in batch processing (Oppty, OLI, Account)   
3.0        15056       FY18-DCS-0102   30-Oct-2017     Sajith          Reset triggers flag in batch processing for User Object
4.0        15781       FY19-DCE-0703   30-May-2018     Fenny           Skip Case triggers by Process flow
*/    
public class ResetProcessFlowTriggerController{
    
    public static boolean isTest = false; 
    
    @InvocableMethod(label='RESET Skip triggers by Process Flow on any Object' 
                     description='This method will reset the skip object triggers based on the given object API name in listObjectAPINames parameter')
    public static void skipOrResetObjTrigger(List<processFlowClass> processFlowClassParam){
        
        if(!Test.isRunningTest() || isTest){
            for(processFlowClass param : processFlowClassParam){
                //to cover the existing process builder using this class, since isSkip is introduce in FY18-DCS-0502
                boolean isSkipTrigger = (param.isSkip==null)?true:param.isSkip;
                system.debug('>>>>>>>>>> - isSkip: '+param.isSkip);
                List<string> listSubObjectAPINames = param.strObjectName.split('[,]{1}[\\s]?');
                for(string strObj : listSubObjectAPINames) {
                    skipOrResetTrigger(strObj, isSkipTrigger);
                }
            } 
        }
    }
    
    //Create a wrapper class for passing Two variable at a time 
    Public class processFlowClass{
        @InvocableVariable(label='listObjectAPINames')
        public string strObjectName;
        
        @InvocableVariable(label='isSkip')
        public boolean isSkip;
    }
    
    //Method that skip or reset the skip for given object.
    Public static void skipOrResetTrigger(string strObjName, boolean isSkip){
        //v4.1 for Lead  
        if(strObjName.equalsIgnoreCase('Lead')){
            if(isSkip){
                system.debug('>>>>>>>>>> - Skipping ' + strObjName + ' triggers');
                TriggerExecutionController.setSkipLeadTriggers(isSkip);    
            }
            else if(!isSkip){
                system.debug('>>>>>>>>>> - reset skip on ' + isSkip + ' triggers');
                TriggerExecutionController.setSkipLeadTriggers(isSkip);     
            }
        //v2 for Oppty
        }else if(strObjName.equalsIgnoreCase('Opportunity')){
            if(isSkip){
                system.debug('>>>>>>>>>> - Skipping ' + strObjName + ' triggers');
                TriggerExecutionController.setSkipOpportunityTriggers(isSkip);
            }
            else if(!isSkip){
                system.debug('>>>>>>>>>> - reset skip on ' + isSkip + ' triggers');
                TriggerExecutionController.setSkipOpportunityTriggers(isSkip);     
            }
        //v2 for OLI
        }else if(strObjName.equalsIgnoreCase('OpportunityLineItem')){
            if(isSkip){
                system.debug('>>>>>>>>>> - Skipping ' + strObjName + ' triggers');
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(isSkip);
            }
            else if(!isSkip){
                system.debug('>>>>>>>>>> - reset skip on ' + isSkip + ' triggers');
                TriggerExecutionController.setSkipOpportunityLineItemTriggers(isSkip);     
            }
        //v2 for Account
        }else if(strObjName.equalsIgnoreCase('Account')){
            if(isSkip){
                system.debug('>>>>>>>>>> - Skipping ' + strObjName + ' triggers');
                TriggerExecutionController.setSkipAccountTriggers(isSkip);
            }
            else if(!isSkip){
                system.debug('>>>>>>>>>> - reset skip on ' + isSkip + ' triggers');
                TriggerExecutionController.setSkipAccountTriggers(isSkip);     
            }
        //Set/Reset triggers for Contact object
        }else if(strObjName.equalsIgnoreCase('Contact')){
            if(isSkip){
                system.debug('>>>>>>>>>> - Skipping ' + strObjName + ' triggers');
                TriggerExecutionController.setSkipContactTriggers(isSkip);
            }
            else if(!isSkip){
                system.debug('>>>>>>>>>> - reset skip on ' + isSkip + ' triggers');
                TriggerExecutionController.setSkipContactTriggers(isSkip);     
            }
        //3.0 Set/Reset triggers for USER object
        }
        else if(strObjName.equalsIgnoreCase('User')){
            if(isSkip){
                system.debug('>>>>>>>>>> - Skipping ' + strObjName + ' triggers');
                TriggerExecutionController.setSkipUserTriggers(isSkip);
            }
            else if(!isSkip){
                system.debug('>>>>>>>>>> - reset skip on ' + isSkip + ' triggers');
                TriggerExecutionController.setSkipUserTriggers(isSkip);     
            }
        //4.0 Set/Reset triggers for Case object
        }else if(strObjName.equalsIgnoreCase('Case')){
            if(isSkip){
                system.debug('>>>>>>>>>> - Skipping ' + strObjName + ' triggers');
                TriggerExecutionController.setSkipCaseTriggers(isSkip);
            }
            else if(!isSkip){
                system.debug('>>>>>>>>>> - reset skip on ' + isSkip + ' triggers');
                TriggerExecutionController.setSkipCaseTriggers(isSkip);     
            }
        }
    }
}