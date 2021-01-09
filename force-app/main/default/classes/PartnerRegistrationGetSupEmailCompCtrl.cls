public class PartnerRegistrationGetSupEmailCompCtrl {
	public Id partnerRequestId {get;set;}
	
	public String getPartnerSupportEmail(){
		System.debug('partnerRequestId = [' + partnerRequestId + ']');
		if(	partnerRequestId == null ){
			return null;
		}
		List<Partner_Request__c> requestList = [
			select id, country__r.Partner_Support_Email__c 
			from Partner_Request__c
			where id = :partnerRequestId];
		System.debug('requestList.isEmpty() = [' + requestList.isEmpty() + ']');
		if(requestList.isEmpty()){
			return null;
		}
		Partner_Request__c request = requestList.get(0);
		System.debug('request.country__r == null = [' + (request.country__r==null) + ']');
		if(request.country__r == null){
			return null;
		}
		return request.country__r.Partner_Support_Email__c;
	}
}