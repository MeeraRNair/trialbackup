global class BatchDealLostCancel implements Database.Batchable<sObject> {
    public String query;
    public Boolean isTest=false;
    public void setTest(){
        isTest=true;
    } 
    
    global database.querylocator start(Database.BatchableContext BC){
        System.debug('----------IN START---------');
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Opportunity> updatedList=new List<Opportunity>();   
        try{System.debug('scope--------------------'+scope+'----------------');
            for(sObject obj :scope){
                 Opportunity dealRecord = (Opportunity)obj;
                if(dealRecord!=Null){
                    dealRecord.StageName='Lost, Cancelled - 0%';
                    dealRecord.Reason_Won_Lost__c='Partner Registration of Deal Expired';
                    dealRecord.Competitor_Lost_To__c='Other';
                    dealRecord.Other_Competitor_Lost_To__c='None';
                    dealRecord.ForecastCategoryName='Omitted';
                    dealRecord.Forecast_Category_Override__c='';
                    System.debug('-----dealRecord----------'+dealRecord +'---------');
                    //TriggerExecutionController.setSkipOpportunityTriggers(True);
                    
                    updatedList.add(dealRecord);
                        

               }
                            }               
            database.update(updatedList);
            System.debug('updatedList----------'+updatedList+'---------');
   
        }catch (Exception e){
         }
    }// end of execute method
    
    global void finish(Database.BatchableContext BC){
       }
}