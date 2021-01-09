public class Vf_OpportunityAposproductpopup
{
    public Opportunity opp{get;set;}
    public boolean showPopup{get;set;}
    
    public Vf_OpportunityAposproductpopup(ApexPages.StandardController ctrl)
    {
    
        opp = new Opportunity();
        opp = (Opportunity)ctrl.getRecord();                          
        showPopup = false;                             
    }
    
    Public void popupDisplay(){
         List<OpportunityLineItem> listoppline=[SELECT id,Product2.IsActive,Brand_Desc__c from OpportunityLineItem where Brand_Desc__c LIKE '%APOS%' and
         OpportunityId = :opp.Id AND Product2.IsActive = true AND Opportunity.Apos_Product__c = true];
       
          if(listoppline.size()>0){
                showPopup = true;
                opp.Apos_Product__c= false;
                update opp;

            }
              
       }    
       
       }