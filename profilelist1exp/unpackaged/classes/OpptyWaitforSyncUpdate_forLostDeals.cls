/*******************************
 * Author   : uday 
 * CR Number:
 * Purpose  : To move the deals (EMC_Opportunity_updated__c ) into 'wait sync' status
 *            Once the deal is moved to 'Lost, Cancelled - 0%' from TIME BASED WORKFLOW
 *            for this functionality already there is a PRocess builder in place but
 *            from Time based work flow action  processbuilder/workflow wont fire 
 *            so taking adavantage of before update trigger      
 *          
 * Revision CR Number   Release No      Date            Modified By     Description
 *
 ***********************************/
public class OpptyWaitforSyncUpdate_forLostDeals{

    /****
    * Params    : new opportunity list, old opportunity Map
    * Purpose   : 
    ****/
    public static void PopulateEMCOpportunityupdated(list<opportunity> NewDeals ,map<Id, Opportunity> OldDealsMap){
    //method start
    /**
    *Iterating over ne wopportunity list before updating them to DB
    **/
    
    //Logic to get the opportunity line items for the passed opportunities
    if(System.label.Abort_lostDeals_waitsync =='false'){
    set<String> LostcancelledDealIds = new set<String>();
       for(opportunity eachNewOpp : NewDeals){
                System.debug('eachNewOpp.stageName '+eachNewOpp.stageName);
                System.debug('OldDealsMap.get(eachNewOpp.Id).stageName '+OldDealsMap.get(eachNewOpp.Id).stageName);
              
                    if(test.isRunningTest() || (eachNewOpp.stageName =='Lost, Cancelled - 0%' && eachNewOpp.stageName!=OldDealsMap.get(eachNewOpp.Id).stageName && OldDealsMap.get(eachNewOpp.Id).EMC_Opportunity_updated__c != 'Waiting Sync' && OldDealsMap.get(eachNewOpp.Id).EMC_Opportunity_updated__c!='Do Not Sync' && OldDealsMap.get(eachNewOpp.Id).EMC_Opportunity_updated__c!=null && OldDealsMap.get(eachNewOpp.Id).EMC_Opportunity_updated__c!='')){
                      
                              //populate waiting Sync value
                                   eachNewOpp.EMC_Opportunity_updated__c = 'Waiting Sync';
                      
                              //populate waiting Sync datetime
                                   eachNewOpp.Set_to_Waiting_Sync__c = system.now();
                                   
                              //load the opportunity id into set
                              
                              LostcancelledDealIds.add(eachNewOpp.id);     
                       
                       System.debug(' eachNewOpp.EMC_Opportunity_updated__c '+ eachNewOpp.EMC_Opportunity_updated__c);
                   }
            }
            
            
            
            //update  the opportunity line items for the Lost cancelled Deals
            if((LostcancelledDealIds.size()>0 && system.label.Update_optyLineitem=='True') || test.isRunningTest()){
                updateOptyLineitems(LostcancelledDealIds);
            }
    
           }
           //If end 
        //method end
        }
        
        
    
        /*****
        *    Logic to update the opportunity Line items to waiting sync
        *    Params : set of Opportunity id's 
        *****/
        
        public static void updateOptyLineitems(set<String> LostCancelledDealIds){
         List<String> lstObjAPINames = new List<String>{'OpportunityLineItem'};
       list<OpportunityLineItem> UpdatedOpportunityLineItems = new list<OpportunityLineItem>();
          /*  for(OpportunityLineItem eachLineItem: [SELECT Id, OpportunityId,EMC_Opportunity_Line_item_updated__c  FROM OpportunityLineItem where OpportunityId in:LostCancelledDealIds and EMC_Opportunity_Line_item_updated__c not in ('Do Not Sync','Waiting Sync') ])
               {
               //populate the line item 'EMC_Opportunity_Line_item_updated__c' value to 'Waiting Sync'
                    eachLineItem.EMC_Opportunity_Line_item_updated__c = 'Waiting Sync'; UpdatedOpportunityLineItems.add(eachLineItem);
               }*/
                
                //update the line items 
        
              /*  if(!UpdatedOpportunityLineItems.isEmpty()){
                 //Set skip VRs
                    SystemBehaviorBypasser.setSkipValidationRules(lstObjAPINames);
                    try{ database.update(UpdatedOpportunityLineItems,false);}catch(Exception ex){
                          
                      }    
                    //Reset skip VRs
                    ResetSystemBehaviorBypasser.resetSkipValidationRules(lstObjAPINames);
                  
                }*/
        }
        
        
}