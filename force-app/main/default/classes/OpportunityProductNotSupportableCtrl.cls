/***********************************************************
    * Name          : OpportunityProductNotSupportableCtrl 
    * Description   : Class to retrieve Opportunity related value. Referred by OpportunityProduct_Not_Supportable component.
    * ---------------------------------------------------------
    * Revision  Name         Date        Description
    * 1.0       Azwanti    15.06.2015    MAJ16.07 CR11617: created 
    
    ************************************************************/
public class OpportunityProductNotSupportableCtrl {

    public String opptyId {get; set;} 
    public Opportunity opptyRec;
    
    public String accName{get; set;}
    public String accBUID{get; set;}
    public String salesRepName{get; set;}
    public String salesRepEmail{get; set;}
   
    public OpportunityProductNotSupportableCtrl(String oid){
        opptyId = oid;
    }
    
    public OpportunityProductNotSupportableCtrl(){
        
    } 
    
    public Opportunity getOpptyRec(){     
        if(opptyId != null){
            opptyRec = [SELECT Account.Name, Account.BU_ID__c, Owner.Name, Owner.Email FROM Opportunity WHERE Id = :opptyId LIMIT 1];   
        }
        return opptyRec;
    }
    
}