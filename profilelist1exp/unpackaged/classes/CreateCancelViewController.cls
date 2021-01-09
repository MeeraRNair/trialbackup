public class CreateCancelViewController{
    public Customer_Engagement__c CEId;
    public Customer_Engagement__c CEDetail;
    String engagement;
    Set<String> statusEBCBeforeSubmit = new Set<String>{'Pending','Canceled','Completed'};
    Set<String> statusDSCBeforeSubmit = new Set<String>{'Pending','Canceled','Completed','Rejected'};
    
    public CreateCancelViewController(ApexPages.StandardController controller) {
        this.CEId= (Customer_Engagement__c)controller.getRecord(); 
        try{
            CEDetail=[select Name, Id,Event_Status__c,RecordTypeId From Customer_Engagement__c where Id=:CEId.Id];
        }
        catch(Exception e){
            System.debug('Exception Occured:'+e);
        }
        if(CEDetail.RecordTypeId==IdLookupUtils.getRecordTypeId('Executive Briefing Center','Customer_Engagement__c',true)){
           engagement='EBC';  
        }
        else{
           engagement='DSC';
        }
    }
   public PageReference submitStatus() {
        if((engagement=='DSC')&&(statusDSCBeforeSubmit.contains(CEDetail.Event_Status__c))||
            (engagement=='EBC')&&(statusEBCBeforeSubmit.contains(CEDetail.Event_Status__c))){
            return PageUtils.redirect('/apex/CancelRequest?id='+CEId.Id);  
        }
        else{
           return PageUtils.redirect('/apex/AfterSubmitCancel?id='+CEId.Id); 
       }
    }
}