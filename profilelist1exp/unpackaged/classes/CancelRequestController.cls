public class CancelRequestController{
    Id engagementId;
    public Customer_Engagement__c CEId;
    public boolean Info{get;set;}
    public Customer_Engagement__c updateCE;
    public List<Calendar_Management__c>updateCM=new List<Calendar_Management__c>();
     
    public cancelRequestController(ApexPages.StandardController controller) {
        this.CEId= (Customer_Engagement__c)controller.getRecord(); 
        try{
            updateCE=[select Name, Id,Event_Status__c ,Reason_for_Cancellation__c,RecordTypeId From Customer_Engagement__c 
                      where Id=:CEId.Id];
            engagementId=IdLookupUtils.getRecordTypeId('Executive Briefing Center','Customer_Engagement__c',true);
            if(updateCE.RecordTypeId==engagementId){
                updateCM=[Select Id,Site__c,Status__c From Calendar_Management__c where 
                          Customer_Engagement_Event__c = :CEId.Id];
            }
        }catch(Exception e){
            System.debug('Exception Occured:'+e);
            showInfo('Please check the Customer Engagement Record');
        }
        getshowMessage();
    }
    
    public void getshowMessage(){
        if(updateCE.Event_Status__c!=null){
            if(updateCE.Event_Status__c=='Canceled'){
                showInfo('Customer Engagement Record already canceled.Please click on \' No\' to go back.');
            }
            else if((updateCE.Event_Status__c=='Completed')||
                    (updateCE.Event_Status__c=='Rejected')){
                showInfo('Customer Engagement Record cannot be canceled/changed as Event Status is '+updateCE.Event_Status__c+'. Please click on \' No\' to go back.');
            }
            else{
                showInfo('Are you sure you want to cancel the request ?');
            }
        }
        else{
            showInfo('Customer Engagement Record Event Status cannot be null.Please click on \' No\' to go back.');
        }
    }
    
    public PageReference changeStatus(){
        if(updateCE.Event_Status__c=='Pending'){
            updateCE.Reason_for_Cancellation__c='Canceled Before Submitting';
            updateCE.Event_Status__c='Canceled';
            update updateCE;
            if(updateCE.RecordTypeId==engagementId){
                for(Calendar_Management__c calender:updateCM){
                    calender.Status__c='Canceled';
                }
                update updateCM;
            }
            return PageUtils.redirect('/'+CEId.Id);
        }
        else{ 
            getshowMessage();
            return null;
        }  

    }
      
    private void showInfo (String errorMessage){      
        PageUtils.addInfo(errorMessage);    
        Info = true;      
    }
}