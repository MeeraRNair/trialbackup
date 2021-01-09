/**************************************************************
* Name                  : PrintAccountPlanController
* Description   : Controller for PrintAccountPlan.page.
*
* Version               Date            Author          Remark
* -------------------------------------------------------------
* 1.0                   30-01-2012      Raymond         Created for CR6535
* 2.0                   12-12-2014      Syazwan         Modification for CR10721
***************************************************************/

public class PrintAccountPlanController {

    public string errorMessage {get; set;}
    
    /*
    public string MSTR_URL_EXCEL {get;set;}
    public string MSTR_URL_PDF {get;set;}
    public string MSTR_URL_PPT {get;set;}
    */
    
    public string BOBJ_Landing_Page {get;set;}
    
    private string userId;
    private string accountId;
    private string accountPlanId;
    private string userName;
    private SFDC_Acct_Plan__c targetAP;
    
    public boolean isTest;

    public PrintAccountPlanController(ApexPages.StandardController controller) {
        
        isTest = false;
        errorMessage = null;
        
        targetAP = (SFDC_Acct_Plan__c)controller.getRecord();
   
        if(targetAP.Id  == null) {       
            errorMessage = 'Account Plan is not specified';        
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }        

        
        try {
            //MSTR_URL_EXCEL = GlobalVariable__c.getValues('MSTR Excel URL').value__c;
            //MSTR_URL_PDF = GlobalVariable__c.getValues('MSTR PDF URL').value__c;
            //MSTR_URL_PPT = GlobalVariable__c.getValues('MSTR PowerPoint URL').value__c;
            
            BOBJ_Landing_Page = GlobalVariable__c.getValues('BOBJ Landing Page').value__c;
            
            if(isTest) {
                throw new DellUtil.DellException('PrintAccountPlanController Test Exception');
            }
            
        } catch(Exception e) {
            errorMessage = 'There is a problem loading Custom Settings for this function. Please contact the administrator. [' + e.getmessage() + ']';        
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        } 
        
        try {
            SFDC_Acct_Plan__c targetAP = (SFDC_Acct_Plan__c)controller.getRecord();
            accountId = targetAP.Account__c;
            accountPlanId= targetAP.Id;
            userId= UserInfo.getUserId();
            userName=UserInfo.getUserName().split('@')[0];
            System.Debug('----print Debug---'+accountId );
            System.Debug('----print Debug---'+accountPlanId );
            System.Debug('----print Debug---'+userId);
            System.Debug('----print Debug---'+userName);
            
            if(isTest) {
                throw new DellUtil.DellException('PrintAccountPlanController Test Exception');
            }
            
        } catch(Exception e) {
            errorMessage = 'There is a problem perparing data required for MSTR Security. Please contact the administrator. [' + e.getmessage() + ']';        
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }
       
        
    }
    
    public PageReference routeToBOBJ(){
    
        Boolean isSuccess = addMSTRSecurity(userId, accountId, accountPlanId, userName );
        
        if(isSuccess) {
            return new PageReference(BOBJ_Landing_Page);
        } else {
            return null;
        }
    
    }
    
    /*
    public PageReference generateMSTREXCEL() {
        Boolean isSuccess = addMSTRSecurity(userId, accountId, accountPlanId, userName );
        if(isSuccess) {
            return new PageReference(MSTR_URL_EXCEL);
        } else {
            return null;
        }
    }
    
    
    public PageReference generateMSTRPDF() {
        
        Boolean isSuccess = addMSTRSecurity(userId, accountId, accountPlanId, userName );

        if(isSuccess) {
            return new PageReference(MSTR_URL_PDF);
        } else {
            return null;
        }

    }
    
    public PageReference generateMSTRPPT() {
        
        Boolean isSuccess = addMSTRSecurity(userId, accountId, accountPlanId, userName );
        PageReference pr = new PageReference(MSTR_URL_PPT);
        pr.setRedirect(true);
        if(isSuccess) {
            return pr;
        } else {
            return null;
        }
    }
    */
    
    private boolean addMSTRSecurity(Id userId, Id accountId, Id accountPlanId, String username) {
        
        List<MSTR_Security__c> existingRecord = [SELECT Id FROM MSTR_Security__c WHERE User__c = :userId];
        
        MSTR_Security__c temp;
        if(existingRecord.size() > 0) {
                
                temp  = existingRecord[0];
        } else {
                temp = new MSTR_Security__c();
        }
        
        temp.User__c = userId;
        temp.MicroStrategy_Account_Id__c = accountId;
        temp.MicroStrategy_Account_Plan_Id__c = accountPlanId;
        temp.MicroStrategy_Username__c = username;
        
        
        
        try {
                
                if(isTest) {
                throw new DellUtil.DellException('PrintAccountPlanController Test Exception');
            }
            
            upsert temp;
            return true;            
            
        } catch(Exception e) {
            errorMessage = 'There is a problem preparing MSTR Security. Please contact the administrator. [' + e.getmessage() + ']';        
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            return false;
        }
    }
    
    public boolean getHasMessage() {
        return ApexPages.hasMessages();
    
    }

}