public class AfterSubmitCancelController{
    Boolean requestFlag=false;
    public List<Event_Location__c> locationList=new List<Event_Location__c>();
    public List<String>siteNameList = new List<String>();
    public Customer_Engagement__c updateCE{get; set;}
    public String siteSelected{get; set;}
    
    public afterSubmitCancelController(ApexPages.StandardController controller) {
        String engagement;
        this.updateCE= (Customer_Engagement__c)controller.getRecord(); 
        try{
           updateCE=[select Name,Cancel_Request__c,Change_Cancel_Reason__c ,Event_Start_Date_Changed_To__c,Event_Type__c,
                   Start_DateF__c,GSL_Start_Date__c, Id,Event_Status__c ,Site_Changed_To__c ,
                   Change_Cancel_Request_Flag__c,RecordType.Name From Customer_Engagement__c where Id=:updateCE.Id];
           if(updateCE.RecordType.Name=='Executive Briefing Center'){
               engagement='EBC';  
           }
           else{
               engagement='DSC';
           }
           locationList=[select Event__c,Id,Name FROM Event_Location__c where recordType.name='sites' and 
                       Active__c=true and Engagement_Type__c=:engagement];
           if(updateCE.Cancel_Request__c=='Change Request'){
               requestFlag=true;
           }  
        }
        catch(Exception e){
            System.debug('Exception Occured:'+e);
            PageUtils.addError('Please check the Customer Engagement'); 
        }
    }
    public PageReference cancelButtonAction() {
        return PageUtils.redirect('/'+updateCE.Id);
    }
    
    public PageReference SaveButtonAction() {
        if((updateCE.Cancel_Request__c!='Change Request')&&(updateCE.Cancel_Request__c!='Cancel Request')){
            PageUtils.addError('Please select an Action Type to submit the request'); 
            return null;  
        }
        getCEUpdateDetails();
        update updateCE;
        return PageUtils.redirect('/'+updateCE.Id);
    }
        
    public Boolean getrequestFlag(){
        return requestFlag;        
    }
    /* Generates site dropdown */
    public List<SelectOption> getSiteNameList(){
        List<SelectOption> options = new List<SelectOption>();
        if(options.size()==0){
            options.add(new SelectOption('', '-- Select One --'));
            if(locationList.size()==0){
                PageUtils.addError('No Site matching the criteria.  Please check the Customer Engagement.');
            }
            else{
                for (Event_Location__c loc: locationList){
                    options.add(new SelectOption(loc.Id, loc.Name));
                }
            }
        }
        return options;
    }
    public PageReference checkRequest(){
        if(updateCE.Cancel_Request__c=='Change Request'){
            requestFlag=true;
        }        
        if(updateCE.Cancel_Request__c=='Cancel Request'){
            requestFlag=false;
        } 
        return null;
    }
    
    public Customer_Engagement__c getCEUpdateDetails() {
        if(updateCE.Cancel_Request__c!=null){
            if(updateCE.Cancel_Request__c=='Change Request'){ 
                updateCE.Change_Cancel_Request_Flag__c=true;
                updateCE.Cancel_Request__c='Change Request';   
                updateCE.Site_Changed_To__c=siteSelected;
            }
            else{
                updateCE.Change_Cancel_Request_Flag__c=true;
                updateCE.Cancel_Request__c='Cancel Request';
            }
            return updateCE; 
        }
        else{
            return null;
        }           
    }
}