public virtual class PartnerRegistrationFormTabHelper {    
    @AuraEnabled
    public String tabLabel{get;private set;}
    @AuraEnabled
	public String name{get;private set;}
  
 
	public PartnerRegistrationFormTabHelper(String tabLabel, String name){
		this.tabLabel = tabLabel;
		this.name = name;
	}

   @AuraEnabled
	public List<PartnerRegistrationFormFieldHelper> fields{ 
		get{
			if(fields == null){ 
				fields = new List<PartnerRegistrationFormFieldHelper>();
				decorate(fields); 
			}
			return fields;
		}
		set{}
	}
	public virtual void decorate(List<PartnerRegistrationFormFieldHelper> fields){
        
    }
}