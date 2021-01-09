public class CERecordTypecntrler {
    public Customer_Engagement__c customerEngagement{get; set;}
    public CERecordTypecntrler(){
    }
    public CERecordTypecntrler(ApexPages.StandardController controller) {
        this.customerEngagement= (Customer_Engagement__c)controller.getRecord(); 
    }
    public PageReference redirect(){
        customerEngagement=new Customer_Engagement__c();   
        Id dscRTId=IdLookupUtils.getRecordTypeId('Dell Solution Centers','Customer_Engagement__c',true);
        PageReference pageRef = new PageReference('/a17/e?RecordType='+dscRTId+'&ent=01IA00000016E4S&nooverride=1&retURL=/a17/o');
        system.debug(pageRef);
        return pageRef ;
    }
}