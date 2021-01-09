/*
* Author   : Anuj
* Purpose  : Utility class to populate case fields for CSH Case 
*        
* Revision CR Number   Release No  Date            Modified By     Description
* -------- ---------   ----------  -----------     ------------    -----------
* 1.0      18158        1101       01-OCT-2019     Anuj            Populate field for CSH case
* 2.0					1101	   10-OCT-2019     Subhasini	   Formatting of dell and emc emails containing '_' which is changed by
*																   Outlook with '.' in Email-to-Case
* 3.0	   18203   		1101	   18-OCT-2019     Anuj    	       Added logic for populating username and email for the cases created from UA Form
*----------------------------------------------------------------------------------------
*/
public class CaseCSHEmailPopulator {
    
    public static void populateFieldsOnBeforeInsert(list<Case> listNewCases) {
        
        set<String> setSenderEmails = new set<String>();        
        map<String,User> mapCaseEmailToUser = new map<String,User>();
        
        for(Case newCase : listNewCases) { 
             setSenderEmails.add(newCase.SuppliedEmail);
            if((newCase.SuppliedEmail.containsIgnoreCase('emc') || newCase.SuppliedEmail.containsIgnoreCase('dell') )
               && ((newCase.SuppliedEmail).substring(0,(newCase.SuppliedEmail).indexOf('@'))).contains('.')) {
                   setSenderEmails.addAll(checkEmailFormat(newCase.SuppliedEmail));
               }  
        }    
        for(User objUser : [SELECT Id,Email FROM User WHERE Email IN :setSenderEmails  and IsActive = true and IsPortalEnabled = false]) {
            mapCaseEmailToUser.put(objUser.Email,objUser);
        }
       
        for(Case newCase : listNewCases)
        {
            if(newCase.Origin == 'EmailESP' && newCase.Priority == 'Normal' && newCase.RecordTypeId == StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk (internal only)')) { 
                newCase.Sub_Type_Order_Support__c = 'Execution Support Process';
                newCase.Case_Reason_Order_Support__c = 'Web Methods';                
                
                Set<String> setEmailToFind = checkEmailFormat(newCase.SuppliedEmail); 
                for(String strEmail : setEmailToFind ) {
                    if(mapCaseEmailToUser.containsKey(strEmail)) {
                        
                        newCase.CaseRTMigrate__Contact_Name_User__c =  mapCaseEmailToUser.get(strEmail).Id;
                        newCase.CaseRTMigrate__Contact_Email1__c = mapCaseEmailToUser.get(strEmail).Email;
                    }
                }
            }
        }
    }
    public static Set<String> checkEmailFormat(String strEmailToFormat) {        
        
        Set<String> setEmails = new Set<String>();
        setEmails.add(strEmailToFormat);
        String strEmcDomain = '@emc.com';
        String strDellDomain = '@dell.com';
        String strDellTeamDomain = '@dellTeam.com';
        String strEmailNew ;           
        
        Integer intIndex = strEmailToFormat.indexOf('@');
        String strEmail = strEmailToFormat.substring(0,intIndex);        
        String strDomain = strEmailToFormat.substring(intIndex,strEmailToFormat.length());       
        
        strEmailNew = strEmail.replaceAll('[.]','_')  ;
        strEmailToFormat = strEmailNew + strDomain;            
        setEmails.add(strEmailToFormat);
        
        if(strEmailToFormat.containsIgnoreCase('emc')) {
            
            setEmails.add(strEmail+strDellDomain);
            setEmails.add(strEmail+strDellTeamDomain);
            setEmails.add(strEmailNew+strDellDomain);
            setEmails.add(strEmailNew+strDellTeamDomain);
            
        }
        else if(strEmailToFormat.containsIgnoreCase('dell')) {
            setEmails.add(strEmailNew+strEmcDomain);
            setEmails.add(strEmail+strEmcDomain);
            
        }
        System.debug('setEmails'+setEmails);
        return setEmails;
    }
    
    public static void populateRequestorFieldFromUAForm(list<Case> listNewCases)
    {
        Set<String> setUserEmails = new Set<String>();
        map<String,String> mapUserEmailToId = new map<String,String>();
        for(Case c : listNewCases)
        {
            setUserEmails.add(c.Unauthenticated_Contact_Email__c);
        }
        
        for(User objUser : [SELECT Id,Email FROM User WHERE Email In :setUserEmails AND IsActive = true])
        {
            mapUserEmailToId.put(objUser.Email, objUser.Id);
        }
        
        for(Case c : listNewCases)
        {
            if(mapUserEmailToId.containsKey(c.Unauthenticated_Contact_Email__c))
            {
                    c.CaseRTMigrate__Contact_Name_User__c =  mapUserEmailToId.get(c.Unauthenticated_Contact_Email__c);
            		c.CaseRTMigrate__Contact_Email1__c = c.Unauthenticated_Contact_Email__c; 
            }           
        }
    }
    
}