/*

Author: Jessie Tan
History:
Version Date            Modified By     Description
--------------------------------------------------------------------------------------
1.0      28-Aug-2015    Jessie          Created for CR11895 - To unlink opportunities from Strategy
*/

public class UnlinkOppFromStrategyCtrl{
    
    private Opportunity opp ;
    public String strategyId {get; set;}
    public Boolean showError {get;set;}
    
    public UnlinkOppFromStrategyCtrl(ApexPages.StandardController controller) { 
        
        try {
             showError = false;
         
            String oppId = controller.getId();
             
            opp = [SELECT Related_Strategy__c FROM Opportunity WHERE Id = :oppId];
            
            strategyId = opp.Related_Strategy__c;
            
        }catch(Exception e) { handleError(e); }
        
    }

    public void  unlink() {
        
        try {
            
            opp.Related_Strategy__c = null;
            
            update opp ;
          
            
        }catch(Exception e) { 
            system.debug('Error is'+e);
            showError = true;
            handleError(e);
     //           return  null; 
            
        }
        
     //   return  new PageReference('/' + strategyId );
                        
    }
    
    public PageReference back(){        
        return new PageReference('/' + strategyId);        
    }
    
    
    // Handle all exceptions
    @TestVisible private void handleError(Exception e) {
        
        System.debug('### Error Stack Trace : ' + e.getStackTraceString());
        System.debug('### Message : ' + e.getMessage());
        
    }
    
}