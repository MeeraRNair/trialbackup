public with sharing class RedirectToLeadConvertExtension {
    public Id leadId ;
	public RedirectToLeadConvertExtension(ApexPages.StandardController stdController ){
		Lead  record = (Lead) stdController.getRecord();
		leadId = record.Id;
		
	}
	public PageReference  doRedirect(){
		System.debug('---- Do redirect called');
		PageReference ref = new PageReference ('/apex/leadConvertPage?scontrolCaching=1&id='+leadId);
		ref.setRedirect(true);
		  
	 return ref;
	} 
}