/*
* Author   : Sajith
* Purpose  : This page is for external GLMI Team to create Case in Salesforce 
* 
* Revision CR Number    Release No    Date            Modified By    Description
* -------- ---------    ----------    -----------     ------------   -----------
* 1.0       13766       FY17-DCS-0103 25-Nov-2016     Sajith         LM2_Setting GMO site form (with SFDC site) form
* 2.0       16741       FY19-DCS-0102 29-Oct-2018     Kishore        STORY 5717519: Lead 2.0 - Enhancements to GLMI Case Intake
* 2.1       16741       FY19-DCS-0102 29-Oct-2018     Shue           DEFECT 5825024 'Lead Type'’' is not  shown mandatory when Request Type = Lead Management
* 2.2       16741       FY19-DCS-0102 29-Oct-2018     Shue           DEFECT 5824938 When "Send to LQR" checkbox is selected  with Request Type as "Lead Management", error message is confusing
* 3.0       18329       FY20-DCS-0102 25-Nov-2019     Kokila         STORY 5979510: Lead 2.0 [GMO] - Update error messages
*/
public without sharing class GLMICaseCreationCtrl extends DAMGLMICaseCreationBaseCls{ 
    
   
    public String strIsInvalidCaseType {get;set;}
    //public String strIsInvalidLeadType {get;set;} //v3.0
    public String strIsInvalidSendToLQR {get;set;}
   
    public String strIsInvalidRegion {get;set;}
   
    // default constructor     
    public GLMICaseCreationCtrl(ApexPages.StandardController controller) {       
        
        objCase = (case) controller.getRecord();
        initCase(true);
        initLocalPageVar();
        
    }    
    
    public PageReference submitCase() {
        
        initLocalPageVar();
        initializeVar();
        
   
        try{
        
            if(String.isBlank(objCase.Sub_Type_Internal_User__c)){
                strIsInvalidCaseType = 'display:block';
                isError = true;
            }
            validateEmailSubjectDesc();
            if(String.isBlank(objCase.Requesting_Region__c)){
                strIsInvalidRegion  = 'display:block';
                isError = true;
            }
            
            //v3.0 - Start - Commented Error Messages from code and handled through Validation Rule
            /*if(objCase.Sub_Type_Internal_User__c == 'Lead Management' && String.isBlank(objCase.Lead_Type__c)){ // 2.0 Changed comparsion value from "Lead Load Request" to "Lead Management"
                strIsInvalidLeadType = 'display:block';
                isError = true;
            }*/ 
            //v3.0 - End - Commented Error Messages from code and handled through Validation Rule
            //if(objCase.Sub_Type_Internal_User__c != 'Lead Management' && objCase.Sub_Type_GLMI__c != 'Lead Load' && objCase.Send_to_LQR__c){ //2.0 Changed Sub_Type_Internal_User__c comparsion value from "Lead Load Request" to "Lead Management"
           /* if
            (
                (objCase.Sub_Type_Internal_User__c == 'Lead Management' && objCase.Sub_Type_GLMI__c == 'Lead Load' && objCase.Send_to_LQR__c == false) 
                //|| 
                //(objCase.Sub_Type_Internal_User__c != 'Lead Management' && objCase.Sub_Type_GLMI__c != 'Lead Load' && objCase.Send_to_LQR__c == false)
            )
            { //2.0 Changed Sub_Type_Internal_User__c comparsion value from "Lead Load Request" to "Lead Management"
                strIsInvalidSendToLQR = 'display:block';
                isError = true;
            }*/
           
            saveCase();
            
        }catch(Exception excp){
           
            ApexPages.addMessages(excp);
            return null;
        }
        
        return pageRef;
        
    } 
    public void initLocalPageVar() {
        
        strIsInvalidCaseType = 'display:none';
       //strIsInvalidLeadType = 'display:none'; //v3.0
        strIsInvalidSendToLQR = 'display:none';
        strIsInvalidRegion = 'display:none';
    }
   
    
}