/*
* Author   : SuiYee
* Purpose  : This page is for external DAM to create Case in Salesforce 
* 
* Revision CR Number   Release No    Date            Modified By     Description
* -------- ---------   ----------    -----------     ------------    -----------
* 1.0       13478      FY17-DCS-1101 30-Aug-2016     SuiYee          Setting DAM web2case (with SFDC site) form
* 2.0       13766      FY17-DCS-0103 15-Dec-2016     Sajith          Corrections for View State Error
*/
public without sharing class DAMCaseCreationCtrl extends DAMGLMICaseCreationBaseCls{ 
    
    //2.0 variables to control validations
   
    public String strIsInvalidReason {get;set;}
    public String strIsInvalidPriority {get;set;}
    
    // default constructor     
    public DAMCaseCreationCtrl(ApexPages.StandardController controller) {      
        
        objCase = (case) controller.getRecord();
        initCase(false);
        initLocalPageVar();
        
    }    
  
    public PageReference submitCase() {
        
        initLocalPageVar();
        initializeVar();
       
        try {
            
            if (objCase.Reason == null || objCase.Reason == '--None--'){
                strIsInvalidReason = 'display:block';
                isError = true;
            }
            validateEmailSubjectDesc();
            if (objCase.Priority == null  || objCase.Priority == '--None--'){
                strIsInvalidPriority = 'display:block';
                isError = true;
            }
            saveCase();
        
        }catch(DmlException excp){
            
           ApexPages.addMessages(excp);
           return null;
        }
        return pageRef;
        
    } 
    public void initLocalPageVar() {
        
         strIsInvalidReason = 'display:none';
         strIsInvalidPriority = 'display:none';
    }
    
}