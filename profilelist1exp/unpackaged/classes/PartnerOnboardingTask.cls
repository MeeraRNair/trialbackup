public class PartnerOnboardingTask{
        
    //properties
    public String                                 label                         {get;set;}
    public String                                 taskCompleteFlagFieldName     {get;set;}
    public String                                 visibilityControlFieldName    {get;set;}
    public String                                 taskNAFlagFieldName           {get;set;}
    public PartnerRegistrationActionPanelCtrlExt  controller                    {get;set;}
    public String                                 visibilityControl             {get;set;}
    public Boolean                                complete                      {get;set;}
    public List<PartnerOnboardingTaskAction>      actions                       {get;set;}
    public Partner_Request__c                     request                       {get;set;}

	//CR 2759 - Optional Progression checkbox
    public String                                 showAfterNAFieldName          {get;set;} 
    
    
    //derived properties
    public Boolean notApplicable{get{
        return complete && taskNAFlagFieldName != null && (Boolean) request.get(taskNAFlagFieldName);
    }}
    
    //CR 2759 - Optional Progression checkbox - to avoid showing cross and strike after Mark as complete happen when NA field Exist
    public Boolean CompletedAfterNAMarked{get{
    	return this.notApplicable && !(Boolean) request.get(showAfterNAFieldName);   
    }}
    
    //CR 2759 - Optional Progression checkbox - if 'After NA Field Name' field and 'NA Flag' field set as true, means 'Mark as complete' is showing after N/A clicked   
    public Boolean isPartialNotComplete{get{
    	system.debug('### IsPartialNotcomplete :'+ (Boolean) (al.stringUtils.isBlank(showAfterNAFieldName) ? false :  request.get(showAfterNAFieldName)) + ', taskNAFlagFieldName :'+(Boolean)  (al.StringUtils.isBlank(taskNAFlagFieldName) ? false : request.get(taskNAFlagFieldName)));
    	return (Boolean) (al.stringUtils.isBlank(showAfterNAFieldName) ? false :  request.get(showAfterNAFieldName))  && (Boolean)  (al.StringUtils.isBlank(taskNAFlagFieldName) ? false : request.get(taskNAFlagFieldName));
    }}
    
    
    public Boolean show {get{
        //visibilityControl will equal one of following:
        //  null           --> true
        //  Show, Required --> true 
        //  Show, Optional --> true
        //  Hide           --> false
        return !al.StringUtils.contains(visibilityControl,'hide');
    }}

        //constructors
    public PartnerOnboardingTask(   String label, 
                                    String taskCompleteFlagFieldName, 
                                    PartnerRegistrationActionPanelCtrlExt controller){
        this(label,taskCompleteFlagFieldName,null,null,controller);
    }
    
    public PartnerOnboardingTask(   String label, 
                                    String taskCompleteFlagFieldName, 
                                    String visibilityControlFieldName, 
                                    String taskNAFlagFieldName, 
                                    PartnerRegistrationActionPanelCtrlExt controller){
        this.label                      = label;
        this.taskCompleteFlagFieldName  = taskCompleteFlagFieldName;
        this.visibilityControlFieldName = visibilityControlFieldName;
        this.taskNAFlagFieldName        = taskNAFlagFieldName;
        this.controller                 = controller;
        this.visibilityControl          = null;
        this.complete                   = false; 
        this.actions                    = new List<PartnerOnboardingTaskAction>();
        this.request                    = null;
    }
    
    
    //CR 2759 - Optional Progression checkbox - New field introduce for holding 
     public PartnerOnboardingTask(  String label, 
                                    String taskCompleteFlagFieldName, 
                                    String visibilityControlFieldName, 
                                    String taskNAFlagFieldName, 
                                    String showAfterNAFieldName,
                                    PartnerRegistrationActionPanelCtrlExt controller){
        this.label                      = label;
        this.taskCompleteFlagFieldName  = taskCompleteFlagFieldName;
        this.visibilityControlFieldName = visibilityControlFieldName;
        this.taskNAFlagFieldName        = taskNAFlagFieldName;
        this.showAfterNAFieldName       = showAfterNAFieldName; //CR 2759 - Optional Progression checkbox
        this.controller                 = controller;
        this.visibilityControl          = null;
        this.complete                   = false;              
        this.actions                    = new List<PartnerOnboardingTaskAction>();
        this.request                    = null;
    }    
    
    
        
    //methods
    public void setPartnerRequest(Partner_Request__c request){
    	if(request.id == null){
    		throw new al.IllegalArgumentException();
    	}
        this.request = request;
        this.visibilityControl = (visibilityControlFieldName == null) 
            ? null 
            : al.StringUtils.lowerCase((String)request.get(visibilityControlFieldName));
        System.debug('### this.complete: ' + this.complete);
        System.debug('### taskCompleteFlagFieldName: ' + taskCompleteFlagFieldName);      
        this.complete = (Boolean) request.get(taskCompleteFlagFieldName);
        this.complete = (this.complete == null ? false : this.complete);                 
        System.debug('### this.complete: ' + this.complete);
    }
    public PartnerOnboardingTaskAction addAction(PartnerOnboardingTaskAction action){
        this.actions.add(action);
        action.parent = this;
        return action;
    }
}