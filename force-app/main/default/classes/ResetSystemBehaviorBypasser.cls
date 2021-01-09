/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13322       FY17-DCS-0902   09-Sep-2016     Fenny           @InvocableMethod for bringing VRs back to normal
2.0         13935       FY17-DCS-0104   19-Jan-2016     Gan             Fixing the 101 error during lead conversion
3.0         15781       FY19-DCE-0703   30-May-2018     Fenny           Add Bypass_Case_VRs__c  to bypass for Case VR
4.0         16100       FY19-DCE-0802   09-July-2018    Venkat Sharan   Removed comments as part of code Reduce for the story 5240515
5.0 					FY20-DCE-0801	01-Aug-2019		Mahesh			Added code to skip checking custom setting for Boomi Integration Users story 7107127
6.0         US7067965   FY20-DCE-1101   09-Oct-2019     Sazleen         Add Bypass_Account_Plan_VRs__c to bypass for Account Plan VR 
*/  


/** @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 * 
 * IMPORTANT NOTE:
 * ---------------
 * If to add new field in System_Behavior_Bypasser__c, add new line of codes at label
 * - UPDATE_OR_DELETE
 * - RESET_VR_FLAG
 * 
 * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
 
public class ResetSystemBehaviorBypasser{
    
    @InvocableMethod(label='Reset/Enable VRs' 
                    description='This method will bring object validation rules back to normal based on the given object API name in strObjectAPINamesCommaDeliminated parameter')
    public static void resetSkipValidationRules(List<string> listObjectAPINamesCommaDeliminated){  
        system.debug('$$$Reset Start');
       Boolean skipVRs = FeatureManagement.checkPermission('Skip_VRs_for_Integ_Users');
        if(!skipVRs){
            system.debug('$$$Reset Inside');
        System_Behavior_Bypasser__c bypasser = System_Behavior_Bypasser__c.getInstance(UserInfo.getUserId());
        
        if(bypasser != null && bypasser.Id != null){
            //V4.0 call generic method and pass false as third parameter to reset VR's             
            resetExemptValidationRulesAvailability(bypasser, listObjectAPINamesCommaDeliminated, false);
            
            /** @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
             * Label: UPDATE_OR_DELETE
             * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
            
            if(bypasser.Bypass_Account_Play_VRs__c || bypasser.Bypass_Competency_Tracker_VRs__c || bypasser.Bypass_Contact_VRs__c || bypasser.Bypass_Lead_VRs__c || bypasser.Bypass_Opportunity_Line_Item_VRs__c 
                || bypasser.Bypass_Opportunity_VRs__c || bypasser.Bypass_Trip_Report_VRs__c || bypasser.Bypass_Case_VRs__c || bypasser.Bypass_Account_Plan_VRs__c){                
                update bypasser;
            }else{                
                delete bypasser;
                /**@@@@@@@@@@@@@@@@@ Added below for improving performace 0702 for TTI EMERGENCY CLQ @@@@@@@@@@@@@@@@@@@@@*/
                Database.EmptyRecycleBinResult emptyRecycleBinResult = Database.emptyRecycleBin(bypasser);
                if(!emptyRecycleBinResult.isSuccess()){ 
                    List<Database.Error> errlst = emptyRecycleBinResult.getErrors(); 
                    for(Database.Error err : errlst) { 
                        System.debug(err.getMessage() + ' ' + err.getStatusCode()); 
                    } 
                }
                /**@@@@@@@@@@@@@@@@@ End of Change TTI EMERGENCY CLQ @@@@@@@@@@@@@@@@@@@@@*/ 
            }           
        }
    }
    }
    
    //V4.0 - Generic method to skip as well as reset VR's
    public static void resetExemptValidationRulesAvailability(System_Behavior_Bypasser__c bypasser, List<string> listObjectAPINamesCommaDeliminated, Boolean resetExemptVRFlag){
         system.debug('$$$Reset Start');
        Boolean skipVRs = FeatureManagement.checkPermission('Skip_VRs_for_Integ_Users');
        if(!skipVRs){
             system.debug('$$$Reset Inside');
        if((bypasser != null) && (listObjectAPINamesCommaDeliminated != null) && (listObjectAPINamesCommaDeliminated.size() > 0)){
            
            for(string strObjectAPINamesCommaDeliminated : listObjectAPINamesCommaDeliminated){
                
                for(string strObjectAPIName : strObjectAPINamesCommaDeliminated.split(',')){
                    
                    /** @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                     * Label: RESET_VR_FLAG
                     * @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
                    //4.0
                    switch on strObjectAPIName.trim().toLowerCase(){
                        when 'account_play__c'{
                            bypasser.Bypass_Account_Play_VRs__c = resetExemptVRFlag;
                        }
                        when 'certification_tracker__c'{
                            bypasser.Bypass_Competency_Tracker_VRs__c = resetExemptVRFlag;
                        }
                        when 'contact'{
                            bypasser.Bypass_Contact_VRs__c = resetExemptVRFlag;
                        }
                        when 'lead'{
                            bypasser.Bypass_Lead_VRs__c = resetExemptVRFlag;
                        }
                        when 'opportunitylineitem'{
                            bypasser.Bypass_Opportunity_Line_Item_VRs__c = resetExemptVRFlag;
                        }
                        when 'opportunity'{
                            bypasser.Bypass_Opportunity_VRs__c = resetExemptVRFlag;                            
                        }
                        when 'customerinteraction__c'{
                            bypasser.Bypass_Trip_Report_VRs__c = resetExemptVRFlag;
                        }
                        when 'case'{
                            bypasser.Bypass_Case_VRs__c = resetExemptVRFlag;
                        }
                        when 'campaign'{
                            bypasser.Bypass_Campaign_VRs__c = resetExemptVRFlag; 
                        }
                        when 'account'{
                            bypasser.Bypass_Account_VRs__c = resetExemptVRFlag;
                        }
                        when 'sfdc_acct_plan__c'{
                            bypasser.Bypass_Account_Plan_VRs__c = resetExemptVRFlag;
                        }
                        when else{}
                    }                   
                }
            }
        }
    } 
    }
}