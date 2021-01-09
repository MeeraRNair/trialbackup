public with sharing class RedirectRouteToChannelExtension {
	public Id leadId ;
	public RedirectRouteToChannelExtension(ApexPages.StandardController stdController ){
	    Lead  record = (Lead) stdController.getRecord();
	    leadId = record.Id;
    
  	}
	public PageReference  doRedirect(){
	    System.debug('---- Do redirect called');
	    
	    PageReference ref = new PageReference ('/apex/RouteLeads?id='+leadId+'&action=Route To Channel');
	    ref.setRedirect(true);
      
   		return ref;
  } 
}