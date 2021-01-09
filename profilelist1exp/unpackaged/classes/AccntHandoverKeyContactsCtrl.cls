/***********************************************************
* Name          : AccntHandoverKeyContactsCtrl
* Description   : Controller class for AccntHandoverKeyContactsAll and AccntHandoverKeyContacts page
* ---------------------------------------------------------
* Revision      Release   Name           Date              Description   
* 1.0           R16.07    Jessie Tan     26-May-2015       To display contact info to AccntHandoverKeyContacts inline VF page (in page layout) and AccntHandoverKeyContactsAll standalone VF page
* 2.0           R16.10    Jessie Tan     17-Aug-2015       CR11824 - To exclude 'inactive' Contacts in Key/Critical Customer Contacts list.
************************************************************/

public class AccntHandoverKeyContactsCtrl{

    public Account_Handover__c accHandover {get;set;} 
    public List<Contact> contacts {get;set;}
    public String errorMessage { get; set; }
    
    public AccntHandoverKeyContactsCtrl(ApexPages.StandardController controller) {
    
        accHandover = [Select Account__c, Id, Name from Account_Handover__c where Id = :controller.getId()];
        
    }
             public void getContacts(){
        try{
                 contacts = [Select Id, Name, Title, Email, Phone, Phone_Extn__c, NPS_Category__c from Contact where AccountId = :accHandover.Account__c 
                and Decision_Making_Role__c IN ('Power Sponsor / Decision Maker', 'Sponsor/ Champion', 'Influencer') 
                and Status__c NOT IN ('Pending Verification','Invalid - Bad Email','Invalid - Bad Phone','Invalid - No longer w/ Company','Invalid - Unmarketable') 
                order by Name limit 11 ];        
           
            System.debug('#### contacts size :' + ((contacts == null || contacts.size() ==0 )?0:contacts.size()));
        
        }catch(Exception e){
            handleError(e);            
        }
        }
      
    public void getAllContacts(){
         try{
        
            contacts = [Select Id, Name, Title, Email, Phone, Phone_Extn__c, NPS_Category__c from Contact where AccountId = :accHandover.Account__c 
                and Decision_Making_Role__c IN ('Power Sponsor / Decision Maker', 'Sponsor/ Champion', 'Influencer') 
                and Status__c NOT IN ('Pending Verification','Invalid - Bad Email','Invalid - Bad Phone','Invalid - No longer w/ Company','Invalid - Unmarketable') 
                order by name limit 1000];        
                    
            System.debug('#### contacts size :' + ((contacts == null || contacts.size() ==0 )?0:contacts.size()));
        
        }catch(Exception e){
            handleError(e);            
        } 
         }
    
    @TestVisible private void handleError(Exception e){                
        //3.0 - Start 
        errorMessage = 'An unexpected error has occurred. Please contact the administrator.';     
     }    
}