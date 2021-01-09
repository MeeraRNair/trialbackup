public class PartnerRegistrationDupAcctOwnrMsgCtrl {
	
	private Id partnerRequestId;
	private Boolean initialized = false;
	public Partner_Request__c registration {get;set;}

	public void setPartnerRequestId(Id theId){
		partnerRequestId = theId;
		init();
	}
	
	public Id getPartnerRequestId(){
		return partnerRequestId;
	}
	
	public void init(){
		if(initialized){ return; }
		if(partnerRequestId == null){ return; }
		
		List<Partner_Request__c> requestList = [
			select id, Company__c, First_Name__c, Last_Name__c, name, CreatedDate, Phone__c, Email__c,
				Duplicate_Account__r.Id, Duplicate_Account__r.Name,
				Duplicate_Registration__r.id, Duplicate_Registration__r.Company__c, Duplicate_Registration__r.First_Name__c, 
					Duplicate_Registration__r.Last_Name__c, Duplicate_Registration__r.name, Duplicate_Registration__r.CreatedDate, 
					Duplicate_Registration__r.Phone__c, Duplicate_Registration__r.Email__c
			from Partner_Request__c
			where id = :partnerRequestId];
		if(requestList.isEmpty()){
			return;
		}
		registration = requestList.get(0);
		initialized = true;
	}
	
}