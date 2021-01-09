global class BatchStageUpdate implements Database.Batchable<sObject> {
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
        Id protectedDealRT=PageUtils.getRecordTypeId('Opportunity','Protected Deal', true);
        try{System.debug('scope--------------------'+scope+'----------------');
            for(sObject obj :scope){
                Opportunity dealRecord = (Opportunity)obj;
                if(dealRecord.RecordTypeId!=protectedDealRT){
                    dealRecord.StageName='Lost, Cancelled - 0%';
                    //dealRecord.Region__c='ABU';
                    dealRecord.Reason_Won_Lost__c='Partner Registration of Deal Expired';
                    dealRecord.Competitor_Lost_To__c='Other';
                    dealRecord.Other_Competitor_Lost_To__c='None';
                    System.debug('-----dealRecord----------'+dealRecord +'---------');
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