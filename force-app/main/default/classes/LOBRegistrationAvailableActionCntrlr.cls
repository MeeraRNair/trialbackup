/*-------------------------------------------------------------------------
Description: Class  for update LOB Registration Status records based on Approve/Reject/Set to Close
CR #9019
Version:1.0 

History:
    
Rev    Date          Author          Remarks 
1.0    30/01/2014    Jaya Kumar      CR9019: Update LOB_registration_status__c  
2.0    03/12/2015    Devika          To update the Open value to Rejected.
--------------------------------------------------------------------------*/
public class LOBRegistrationAvailableActionCntrlr {
    public LOB_Registration__c LOBObj;
    public String action;
    public String pageURL;
    public LOBRegistrationAvailableActionCntrlr (ApexPages.StandardController controller) {      
        this.LOBObj= (LOB_Registration__c)controller.getRecord();
        action = '';
        pageURL = '/'+LOBObj.Id+'/e?';
        action = ApexPages.currentPage().getParameters().get('action');
        if(action != null){
            if(action == 'Approve'){
                LOBObj.LOB_registration_status__c = 'Partner(approved)';
                
                pageURL ='/'+LOBObj.Id;                
            }
            if(action == 'Reject'){
                LOBObj.LOB_registration_status__c = 'Rejected'; //v2.0 'Open';
                LOBObj.Preferred_GTM_Partner_Account__c = null;
                LOBObj.Partner_Sales_Rep_Contact__c = null;
   
                pageURL ='/'+LOBObj.Id;                
            } 
            /* v2.0
            if(action == 'SetToClose'){
                LOBObj.LOB_registration_status__c = 'Closed';
                LOBObj.Preferred_GTM_Partner_Account__c = null;
                LOBObj.Partner_Sales_Rep_Contact__c = null;
                
                pageURL ='/'+LOBObj.Id;                
            }
            */
            if((action != 'Approve')&&
               (action != 'Reject')
               /* v2.0 && (action != 'SetToClose')*/){
                PageUtils.addError(System.Label.CMAP_Default_Error_Message);
            }
        }
        else{
            PageUtils.addError(System.Label.CMAP_Default_Error_Message);
        }
    }
    
    public PageReference redirect(){
        if(action == 'Approve' || action == 'Reject' /* v2.0 || action == 'SetToClose' */){                
            try {
                update LOBObj;
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
              //  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0));
              //  ApexPages.addMessage(myMsg);     
                return null;               
             }
        }    
        return(PageUtils.redirect(pageURL));  
    }
}