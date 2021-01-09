public class PR_Email_Approval_SDCntrl {
    @AuraEnabled
    public static Partner_Request__c gettingData(String id) {
        system.debug('==========PR ID======>>'+id);
        try{
            return [SELECT id,Status__c,Approve_Is_Complete_Flag__c,Rejection_Reason__c  FROM Partner_Request__c where id =: id];
        }
        catch(Exception e){ system.debug('test');return null;}
    }
    @AuraEnabled
    public static String update_PR_Data(Partner_Request__c pr_data) {
        try{
            if(pr_data.Approve_Is_Complete_Flag__c)
                pr_data.Status__c =PartnerConstants.REG_STATUS_APPROVED;
            else
                pr_data.Status__c = PartnerConstants.REG_STATUS_REJECTED;
            
            update pr_data;
            return 'success';
        }catch(exception e){return 'error';}
    }
    @AuraEnabled
    public static void close() {
      //  window.close();
    }
}