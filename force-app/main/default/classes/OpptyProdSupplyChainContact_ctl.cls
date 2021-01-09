/***********************************************************
* Name          : OpptyProdSupplyChainContact_ctl 
* Description   : Controller class for OpportunityLineItemSupplyChainContacts
* ---------------------------------------------------------
* Revision  Name            Date            Release Description
* 1.0       Dipin Raju      Jun 10, 2105    Creation
************************************************************/

public class OpptyProdSupplyChainContact_ctl {


public List<Supportability_Contacts__c> SupCnts {get; set;}
public Boolean No_Recs=false;
public Boolean Recs_Found=false;

public OpptyProdSupplyChainContact_ctl () {
        
        SupCnts = [SELECT Regional_Parent_Name__c, Regional_Sub_Parent_Name__c,  Focus__c, Contact_Name__r.Name, Contact_Email__c 
                   FROM Supportability_Contacts__c
                   ORDER BY Regional_Parent_Name__c ASC];
                   
       if(SupCnts.IsEmpty())   {
           No_Recs=true;
           Recs_Found =false;
           
       } 
       else{           
               No_Recs=false;
               Recs_Found = true;
               
        }

    }
    public Boolean getNo_Recs() {
        return No_Recs;
    } 
    
    public Boolean getRecs_Found() {
        return Recs_Found;
    }  
     
}