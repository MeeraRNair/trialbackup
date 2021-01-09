/***********************************************************
* Name          : PostRefreshAutomationCtrl
* Description   : Controller class for PostRefreshAutomation page
* ---------------------------------------------------------
* Revision      Name           Date              Description   
* 1.0           Jessie Tan     19-Nov-2014       To automate the post refresh process
*
************************************************************/
public class PostRefreshAutomationCtrl{

    public PostRefreshAutomationInterface postRefreshAutomation { get; set; }
    public Boolean isValidEnvironment { get; set; }
    
    public PostRefreshAutomationCtrl() {
    
        try{
        
            postRefreshAutomation = new PostAutomationForFullRefreshSandbox ();
            postRefreshAutomation.initialize();
            
            isValidEnvironment = true;
            
        }catch(PostAutomationForFullRefreshSandbox.ForbiddenEnvironmentException e){
            isValidEnvironment = false;
           // handleError(e);            
        }catch(Exception e){
            handleError(e);            
        }
        
    }
    
    public PageReference automate4Document(){
     
        try{
            
            postRefreshAutomation.doAutomation4Document();            
            
        }catch(Exception e){
            handleError(e); 
            return null;           
        }
        
        createSuccessMsg('The Document Automation process has completed.');      
        return null;                
    }
    
    public PageReference automate4EmailTemplate(){
     
        try{
            
            postRefreshAutomation.doAutomation4EmailTemplate();            
            
        }catch(Exception e){
            handleError(e); 
            return null;           
        }
        
        createSuccessMsg('The Email Template Automation process has completed.');      
        return null;                
    }
    
    private void handleError(Exception e){                
        
        System.debug('### Error : ' + e.getStackTraceString());
        System.debug('### Error Message: ' + e.getMessage());
        
        createErrorMsg('The following errors happen while automating the Post Refresh process: <br/>' + e.getMessage());      
          
    }    
 
    private void createErrorMsg(String errMsg){
        
        apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errMsg));   
        
    }
          
    private void createSuccessMsg(String successMsg){
        
        apexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, successMsg));   
        
    }   
         
}