/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13322       FY17-DCS-0902   09-Sep-2016     Fenny           @InvocableMethod for skipping VRs by process flow   
2.0         13656       FY17-DCS-0103   28-Oct-2016     Jessie          Add Bypass_Campaign_VRs__c  to bypass for Campaign VR
3.0         13811       FY17-DCS-0103   20-Dec-2016     Jessie          Add Bypass_Account_VRs__c  to bypass for Account VR
4.0         15781       FY19-DCE-0703   30-May-2018     Fenny           Add Bypass_Case_VRs__c  to bypass for Case VR
5.0         16100       FY19-DCE-0802   09-July-2018    Venkat Sharan   Removed comments as part of code Reduce for the story 5240515
6.0 					FY20-DCE-0801	01-Aug-2019		Mahesh			Added code to skip checking custom setting for Boomi Integration Users story 7107127
*/    
public class SystemBehaviorBypasser{
    
    public static string RECORD_EVENT;
    
    @InvocableMethod(label='Skip VRs' 
                    description='This method will skip object validation rules based on the given object API name in strObjectAPINamesCommaDeliminated parameter')
    public static void setSkipValidationRules(List<string> listObjectAPINamesCommaDeliminated){   
       Boolean skipVRs = FeatureManagement.checkPermission('Skip_VRs_for_Integ_Users');
        system.debug('$$$SKip Start');
        if(!skipVRs){
            system.debug('$$$Inside Skip');
        System_Behavior_Bypasser__c bypasser = System_Behavior_Bypasser__c.getInstance(UserInfo.getUserId());        
        boolean isNew = false;
        
        if((bypasser == null) || (bypasser.Id == null)){
            bypasser = new System_Behavior_Bypasser__c(SetupOwnerId = UserInfo.getUserId());
            isNew =true;
        }
        
        //V5.0 call generic method and pass true as third parameter to skip VR's
        ResetSystemBehaviorBypasser.resetExemptValidationRulesAvailability(bypasser, listObjectAPINamesCommaDeliminated, true);
        
        if(isNew){            
            insert bypasser;
            RECORD_EVENT = 'INSERT';
        }else{            
            update bypasser;
            RECORD_EVENT = 'UPDATE';
        }
    }
    }  
    
}