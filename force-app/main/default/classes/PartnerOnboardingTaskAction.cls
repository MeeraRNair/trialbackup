public class PartnerOnboardingTaskAction{
        
    //properties
    public String                   label               {get;set;}
    public String                   redirectUrl         {get;set;} 
    public Boolean                  flipFlagOnComplete  {get;set;} 
    public Boolean                  showAfterComplete   {get;set;} 
    public String                   newStatusOnComplete {get;set;} 
    public String                   naFlagField         {get;set;}
    public PartnerOnboardingTask    parent              {get;set;}
    
    public Boolean 					showAfterNAMarked   {get;set;}      

    private List<PartnerOnboardingTask> dependencies = null;
    private Set<String> acceptableStatuses = null;

    //constructors 
    public PartnerOnboardingTaskAction( String label,
                                        Set<String> acceptableStatuses,
                                        PartnerOnboardingTask dependency){
        this(label,null,true,null,acceptableStatuses);
    }
    
    //CR 2759 - Optional Progression checkbox
  	public PartnerOnboardingTaskAction( String label,
                                        Set<String> acceptableStatuses,
                                        Boolean showAfterNAMarked,
                                        PartnerOnboardingTask dependency){
        this(label,null,true,null,acceptableStatuses,null,false,true);
    }
    
	

    public PartnerOnboardingTaskAction( String label, 
                                        String redirectUrl,
                                        Set<String> acceptableStatuses,
                                        PartnerOnboardingTask dependency){
        this(label,redirectUrl,false,null,acceptableStatuses,dependency);                                            
    }
        
    public PartnerOnboardingTaskAction( String label, 
                                        String redirectUrl,
                                        Set<String> acceptableStatuses,
                                        PartnerOnboardingTask dependency,
                                        Boolean showAfterComplete){
        this(label,redirectUrl,false,null,acceptableStatuses,dependency,showAfterComplete);                                            
    }
        
    public PartnerOnboardingTaskAction( String label, 
                                        String redirectUrl,
                                        Set<String> acceptableStatuses){
        this(label,redirectUrl,false,null,acceptableStatuses);                                            
    }
        
    public PartnerOnboardingTaskAction( String label, 
                                        String redirectUrl, 
                                        Boolean flipFlagOnComplete, 
                                        String newStatusOnComplete,
                                        Set<String> acceptableStatuses){
        this(label,redirectUrl,flipFlagOnComplete,newStatusOnComplete,acceptableStatuses,null);                    
    }
        
    public PartnerOnboardingTaskAction( String label, 
                                        String redirectUrl,
                                        String naFlagField,
                                        Set<String> acceptableStatuses,
                                        PartnerOnboardingTask dependency){
        this(label,null,true,null,acceptableStatuses,dependency);                    
        this.naFlagField = naFlagField;
    }        

    public PartnerOnboardingTaskAction( String label, 
                                        String redirectUrl, 
                                        Boolean flipFlagOnComplete, 
                                        String newStatusOnComplete,
                                        Set<String> acceptableStatuses,
                                        PartnerOnboardingTask dependency){
        this(label,redirectUrl,flipFlagOnComplete,newStatusOnComplete,acceptableStatuses,dependency,false);    
    }
    public PartnerOnboardingTaskAction( String label, 
                                        String redirectUrl, 
                                        Boolean flipFlagOnComplete, 
                                        String newStatusOnComplete,
                                        Set<String> acceptableStatuses,
                                        PartnerOnboardingTask dependency,
                                        Boolean showAfterComplete){
        this.label = label;
        this.redirectUrl = redirectUrl;
        this.flipFlagOnComplete = flipFlagOnComplete;
        this.newStatusOnComplete = newStatusOnComplete;
        this.dependencies = new List<PartnerOnboardingTask>();
        if(dependency != null){
            this.dependencies.add(dependency);
        }
        this.acceptableStatuses = acceptableStatuses;
        this.showAfterComplete = showAfterComplete;
    }
    
    //CR 2759 - Optional Progression checkbox
     public PartnerOnboardingTaskAction(String label, 
                                        String redirectUrl, 
                                        Boolean flipFlagOnComplete, 
                                        String newStatusOnComplete,
                                        Set<String> acceptableStatuses,
                                        PartnerOnboardingTask dependency,
                                        Boolean showAfterComplete, 
                                        Boolean showAfterNAMarked){
        this.label = label;
        this.redirectUrl = redirectUrl;
        this.flipFlagOnComplete = flipFlagOnComplete;
        this.newStatusOnComplete = newStatusOnComplete;
        this.dependencies = new List<PartnerOnboardingTask>();
        if(dependency != null){
            this.dependencies.add(dependency);
        }
        this.acceptableStatuses = acceptableStatuses;
        this.showAfterComplete = showAfterComplete;
        this.showAfterNAMarked = showAfterNAMarked;
        system.debug(' Field name calling contructor 9 :' + this.label);                                        	
		system.debug(' Field name showAfterComplete :' + this.showAfterComplete);  
		system.debug(' Field name showAfterNAMarked :' + this.showAfterNAMarked);
    }                                 
                                    
    public PageReference doAction(){
        if(flipFlagOnComplete){
            this.parent.request.put(this.parent.taskCompleteFlagFieldName,true);
            if(al.StringUtils.isNotBlank(this.naFlagField)){
                this.parent.request.put(this.naFlagField,true);
            }
            //CR 2759 - Optional Progression checkbox
            if(this.parent.complete == true){            	            	
            		this.parent.request.put(this.parent.showAfterNAFieldName,false);            	
            }
        }
        if(al.StringUtils.isNotBlank(this.newStatusOnComplete)){
            this.parent.request.status__c = this.newStatusOnComplete;
        }
        update this.parent.request;
        this.parent.controller.redirectUrl = this.redirectUrl;
        this.parent.controller.refresh();
        return null;
    }
 
    public Boolean show{
        get{
            //if task is already complete, don't show any task actions
            System.debug('### this.parent: ' + this.parent);
            System.debug('### this.parent.complete: ' + this.parent.complete);
            system.debug('### this.naFlagField:' +this.parent.taskNAFlagFieldName + ', value :'+ ( al.StringUtils.isBlank(this.parent.taskNAFlagFieldName) ? false : this.parent.request.get(this.parent.taskNAFlagFieldName)) );
          
          	Boolean isNaFieldCompleted = (Boolean) ( al.StringUtils.isBlank(this.parent.taskNAFlagFieldName) ? false : this.parent.request.get(this.parent.taskNAFlagFieldName));
          	          	          	                                               
            Boolean isShowAfterNAMarked = (Boolean)(StringUtils.isBlank(this.parent.showAfterNAFieldName) ? false : this.parent.request.get(this.parent.showAfterNAFieldName) ); 
           
            Boolean isShowAfterNAfield = (showAfterNAMarked==null?false:true);
            
           
            
            if( this.parent.complete && al.StringUtils.contains(al.StringUtils.lowerCase(this.parent.visibilityControl),'optional') && isShowAfterNAMarked && isNaFieldCompleted && isShowAfterNAfield ){
          		return true;          		
          	}
            
            
            if(!showAfterComplete && this.parent.complete){            	
                return false;
            }                       
            
            //check partner request status, if no acceptable status found, don't show actions
            if(!acceptableStatuses.contains(this.parent.request.status__c)){
                return false;
            }
            //if task dependencies aren't met, don't show
            for(PartnerOnboardingTask dependency : dependencies){
                if(dependency != null && dependency.show && !dependency.complete){
                    return false;
                }
            }
            
            //if n/a action & task should be shown but optional
            if(    al.StringUtils.isNotBlank(this.naFlagField)
                && !al.StringUtils.contains(al.StringUtils.lowerCase(this.parent.visibilityControl),'optional')){
                return false;
            }
            
            return true;
        }
    } 
    public void addDependency(List<PartnerOnboardingTask> dependencies){
        this.dependencies.addAll(dependencies);
    }
}