public virtual class PartnerRegistrationTab{
	public String tabLabel{get;private set;}
	public String name{get;private set;}
	public PartnerRegistrationTab next{get;set;}
	public PartnerRegistrationTab previous{get;set;}

	public PartnerRegistrationTab(String tabLabel, String name){
		this.tabLabel = tabLabel;
		this.name = name;
	}

	public Boolean nextEnabled{ get{ return next != null;}} 
	public Boolean previousEnabled{ get{ return previous != null;}} 
	public List<PartnerRegistrationField> fields{ 
		get{
			if(fields == null){ 
				fields = new List<PartnerRegistrationField>();
				decorate(fields); 
			}
			return fields;
		}
		set{}
	}
	public virtual void decorate(List<PartnerRegistrationField> fields){}

}