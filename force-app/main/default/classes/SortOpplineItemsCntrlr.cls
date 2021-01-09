/************************************************************************
Name: SortOpplineItemsCntrlr  
Author: Mohammad Ghouse

Test Class for code coverage: SortOpplineItemsCntrlrTest


************************************************************/


public class SortOpplineItemsCntrlr {
    //capture the contact id
    public Id thisOpportunityId {get;set;}
    //a list to hold this year's gifts
    public List<OpportunityLineItem> Sorted = new List<OpportunityLineItem>();
    public map<id,string> Qualifiedprgmsmap {get ; set ;}
    public string status {get ; set ;}
    //get the gifts into the list
    public List<OpportunityLineItem> getSorted() {
         Qualifiedprgmsmap = new map<id,string> ();
         status ='';
        //criteria for opps
        Sorted = [SELECT Id,Opportunity.Deal_Registration_Status__c,PricebookEntry.Product2.Name,product2.id,Quantity FROM OpportunityLineItem
            WHERE OpportunityId =: thisOpportunityId
            ORDER BY Quantity desc,PricebookEntry.Product2.Name ASC LIMIT 20];  
             List<string> prids = new List<string>();
     //This code is added for new column i.e Qualified Programs into te template
     system.debug('::::::::::;;test:::::::;;'+Sorted+'           '+thisOpportunityId);
        for(OpportunityLineItem OL : Sorted )
        {            
            prids.add(OL.product2.id); 
                       
        }
        
        if(Sorted.size() != 0)
         status = Sorted[0].Opportunity.Deal_Registration_Status__c;
          
        List<Qualified_Program__c> Qprgs = new List<Qualified_Program__c>();
        
        Qprgs = [Select Deal_Program__r.Deal_Program_Name__c,Product__r.id  from Qualified_Program__c Where Product__r.id IN :prids AND Opportunity__r.id =: thisOpportunityId];
        
        for(OpportunityLineItem pr : Sorted )
        {
           string qlist = '';
            for(Qualified_Program__c Q: Qprgs )
            {
                if(q.Product__r.id  == pr.product2.id ){qlist+=Q.Deal_Program__r.Deal_Program_Name__c+',';}            
            }
            if(qlist != '')
                qlist = qlist.removeEnd(',');            
            Qualifiedprgmsmap.put(pr.product2.id,qlist);
        }

            
            
              
        return Sorted;    
    }
    
}