public class PartnerRegistrationGetDupDetailsCtrl {
	public Id partnerRequestId {get;set;}
	
	private String companyName = '';
	public String getCompanyName(){ init(); return companyName; }
	private String requestNumber = '';
	public String getRequestNumber(){ init(); return requestNumber; }
	private String requestorName = '';
	public String getRequestorName(){ init(); return requestorName; }
	
	private Boolean initialized = false;
	public void init(){
		if(initialized){ return; }
		if(partnerRequestId == null){ return; }
		
		List<Partner_Request__c> requestList = [
			select id, 
				Duplicate_Account__r.Name, Duplicate_Account__r.Partner_Registration__r.Name, 
					Duplicate_Account__r.Partner_Registration__r.First_Name__c, Duplicate_Account__r.Partner_Registration__r.Last_Name__c,
				Duplicate_Registration__r.Name, Duplicate_Registration__r.First_Name__c, 
					Duplicate_Registration__r.Last_Name__c, Duplicate_Registration__r.Company__c
			from Partner_Request__c
			where id = :partnerRequestId];
		if(!requestList.isEmpty()){
			Partner_Request__c request = requestList.get(0);
			if(request.Duplicate_Account__r != null){
				companyName 	= request.Duplicate_Account__r.Name;
				if(request.Duplicate_Account__r.Partner_Registration__r != null){
					requestNumber 	= request.Duplicate_Account__r.Partner_Registration__r.name;
					requestorName 	= request.Duplicate_Account__r.Partner_Registration__r.First_Name__c + ' ' + 
						request.Duplicate_Account__r.Partner_Registration__r.Last_Name__c;
				}
			} else if(request.Duplicate_Registration__r != null){
				companyName 	= request.Duplicate_Registration__r.Company__c;
				requestNumber 	= request.Duplicate_Registration__r.Name;
				requestorName 	= request.Duplicate_Registration__r.First_Name__c + ' ' +
					request.Duplicate_Registration__r.Last_Name__c;
			}
			initialized = true;
		}
	}
	
}