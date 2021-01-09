public class PartnerRegistrationMarkIncompltCtrlExt{
 
	public Partner_Request__c registration {get; set;}
	
    public PartnerRegistrationMarkIncompltCtrlExt(ApexPages.StandardController c){
        registration = (Partner_Request__c) c.getRecord();
        List<Partner_Request__c> recordList = 
            [select id, name, status__c, Incomplete_Description__c
            from Partner_Request__c 
            where id = :registration.id limit 1];
        if(recordList.isEmpty()){ 
        	PageUtils.addError('Record not found.');
            return;
        }
    	registration = recordList.get(0);
    	registration.Incomplete_Description__c = '';

        if(!currentStateIsAnyOf(registration,new String[]{
        	null,'',PartnerConstants.REG_STATUS_DRAFT,PartnerConstants.REG_STATUS_RESUBMITTED})){
        		
            PageUtils.addError('Invalid state.  Partner Registration with status \'' + registration.status__c 
            	+ '\' cannot be marked as incomplete.');
            return;
        } 
    }

	public PageReference doSave(){
		if(StringUtils.isBlank(registration.Incomplete_Description__c)){
			PageUtils.addError('Please enter a message');
			return null;
		}
        registration.Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
        registration.Marked_As_Incomplete_User__c = UserInfo.getUserId();
        registration.Incomplete_Registration_Security_Token__c = RandomStringUtils.randomAlphanumeric(32);
		try{
			update registration;
		}catch( Exception e ){
			PageUtils.addError('Failed update Registration status to: ' + PartnerConstants.REG_STATUS_INCOMPLETE 
				+ '.  Error is: ' + e.getMessage());
			return null;
		}
		return PageUtils.redirect('/' + registration.id);
	}

	public PageReference doCancel(){
		return PageUtils.redirect('/' + registration.id);
	}
	
    private static Boolean currentStateIsAnyOf(
    	Partner_Request__c registration,
    	String[] statuses){
        if(statuses == null || statuses.size() <= 0){
            return false;   
        }
        Set<String> statusesAsSet = new Set<String>();
        for(String status : statuses){
            statusesAsSet.add(StringUtils.lowerCase(status));  
        }
        return statusesAsSet.contains(StringUtils.lowerCase(registration.Status__c));
    }

}