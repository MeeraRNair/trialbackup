public without sharing class StrategyDetailPage{

    //Use @AuraEnabled to enable client- and server-side access to the method
    @AuraEnabled
    public static String submitForReview(Id recordId,String commentsValue) {
        try
        {
            //Get the RecordId and update status field
            SFDC_Strategy__c  StrategyData;
            StrategyData= [select Id,Strategy_Status__c,Name from SFDC_Strategy__c WHERE Id=:recordId];
            StrategyData.Strategy_Status__c= 'Submitted for Review';
            StrategyData.Submit_for_Review_Comments__c=commentsValue; 
            update StrategyData;
            return StrategyData.Name;
         }
         catch(DmlException e) {
             System.debug('The following exception has occurred: ' + e.getMessage());
             return null;
             
         }

    }
}