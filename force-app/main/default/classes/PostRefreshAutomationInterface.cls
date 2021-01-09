/***********************************************************
    * Name          : PostRefreshAutomationInterface 
    * Description   : Interface class for Post Refresh Automation
    * ---------------------------------------------------------
    * Revision  Name             Date         Description
    * 1.0       Jessie Tan       21-Dec-2014  Basic interface to run the sandbox post refresh automation
************************************************************/

public interface PostRefreshAutomationInterface {
    
    void initialize();
    
    void doAutomation4Document();
    
    void doAutomation4EmailTemplate();    
    
}