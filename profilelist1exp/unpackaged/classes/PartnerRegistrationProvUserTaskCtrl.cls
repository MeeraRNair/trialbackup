public class PartnerRegistrationProvUserTaskCtrl {

    public Boolean success {get;set;}
    public String objectId {get;set;}
    public String errorDescription {get;set;}

    private final String action;
    private final String regId;
    private final String myAcctPersonPartyId;
    private final String prevObjectId;
    
    public static final String HTTP_PARAMETER_ID = 'id';
    public static final String HTTP_PARAMETER_ACTION = 'action';
    public static final String HTTP_PARAMETER_PERSONPARTYID = 'personPartyId';
    public static final String HTTP_PARAMETER_PREVOBJECTID = 'prevObjectId';

    public static final String ACTION_CREATE_CONTACT = 'CreateContact';
    public static final String ACTION_CREATE_USER = 'CreateUser';
    public static final String ACTION_UPDATE_REGISTRATION = 'UpdatePartnerRegistration';
    
	public PartnerRegistrationProvUserTaskCtrl(){
        regId = ApexPages.currentPage().getParameters().get(HTTP_PARAMETER_ID);
        action = ApexPages.currentPage().getParameters().get(HTTP_PARAMETER_ACTION);
        myAcctPersonPartyId = ApexPages.currentPage().getParameters().get(HTTP_PARAMETER_PERSONPARTYID);
        prevObjectId = ApexPages.currentPage().getParameters().get(HTTP_PARAMETER_PREVOBJECTID);
	}
	
	public PageReference doOnLoad(){
        if(StringUtils.isBlank(regId)){
        	return error('HTTP Parameter named \'' + HTTP_PARAMETER_ID + '\' is required.');
        }
        List<Partner_Request__c> records = 
            [select id, name, State__c, Salutation__c, Postal_Code__c, Phone__c, Newsletter_Opt_In__c, 
				Mobile__c, Last_Name__c, Job_Title__c, First_Name__c, Fax__c, 
				Email__c, City__c, Address_Line_3__c, Address_Line_2__c, Address_Line_1__c, 
				recordtype.name, account__c, account__r.IsPartner, account__r.id, account__r.name, 
				Country__r.User_Currency_Iso_Code__c, Country__r.User_Time_Zone_Sid_Key__c, Country__r.User_Email_Encoding_Key__c, 
				Country__r.User_Locale_Sid_Key__c, Country__r.User_Language_Locale_Key__c, Country__r.User_Profile_ID__c, Country__c,
				Provisioned_User__c, Provision_First_User_Is_Complete_Flag__c, Enable_As_Partner_Admin__c 
            from Partner_Request__c 
            where id = :regId limit 1];
        if(records.isEmpty()){
        	return error('Record not found.');
        }
    	final Partner_Request__c request = records.get(0); 

        if(StringUtils.isBlank(action)){
        	return error('HTTP Parameter named \'' + HTTP_PARAMETER_ACTION + '\' is required.');
        }
        if(StringUtils.isBlank(myAcctPersonPartyId)){
        	return error('HTTP Parameter named \'' + HTTP_PARAMETER_PERSONPARTYID + '\' is required.');
        }
        try{
	        if(ACTION_CREATE_CONTACT.equalsIgnoreCase(action)){
	        	return createPartnerContact(request);
	        } else if(ACTION_CREATE_USER.equalsIgnoreCase(action)){
	        	return createPartnerUser(request, myAcctPersonPartyId, prevObjectId);
	        } else if(ACTION_UPDATE_REGISTRATION.equalsIgnoreCase(action)){
	        	return updatePartnerRequest(request, prevObjectId);
	        }
        }catch (Exception e){
    		return error(e.getMessage());
        }
    	return error('Invalid action: ' + action);
	}

	private PageReference createPartnerContact(Partner_Request__c request){
		List<Contact> contactList = [
			select 
				id, Title, Status__c, Salutation, RecordTypeId, Phone, MobilePhone, MailingStreet, 
				MailingState, MailingPostalCode, MailingCountry, MailingCity, LastName, 
				HomePhone, FirstName, Fax, Email_Opt_In__c, Email 
			from Contact 
			where accountid = :request.account__r.id and email = :request.email__c];
		Contact partnerContact = null;
		if(contactList.isEmpty()){
			partnerContact = new Contact();
		} else {
			partnerContact = contactList.get(0);
		}
		
		partnerContact.Salutation 			= request.Salutation__c;
		partnerContact.FirstName 			= request.First_Name__c;
		partnerContact.LastName 			= request.Last_Name__c;
		partnerContact.Email 				= request.Email__c;
		partnerContact.Title 				= request.Job_Title__c;
		partnerContact.Phone 				= request.Phone__c;
		partnerContact.MobilePhone 			= request.Mobile__c;
		partnerContact.Fax 					= request.Fax__c;
		partnerContact.MailingStreet 		= request.Address_Line_1__c + '\n' 
											  + request.Address_Line_2__c + '\n' 
											  + request.Address_Line_3__c;
		partnerContact.MailingCity 			= request.City__c;
		partnerContact.MailingState 		= request.State__c;
		partnerContact.MailingPostalCode 	= request.Postal_Code__c;
		partnerContact.Email_Opt_In__c 		= (request.Newsletter_Opt_In__c ? 'Yes' : 'No');
		partnerContact.AccountId 			= request.account__c;

		if(partnerContact.id == null){
			insert partnerContact;	
		} else {
			update partnerContact;
		}
		return success(partnerContact.id);
	}	
	
	private PageReference createPartnerUser(
		Partner_Request__c request, 
		String personPartyId, 
		String contactId){
			
		if([select id from Contact where id = :contactId].isEmpty()){
			return error('Invalid Contact ID: ' + contactId);
		}
		final String newUserUsername = personPartyId + '@partner.dell.com';
		if(!([select id from User where username = :newUserUsername].isEmpty())){
			return error('User already exists with user name: ' + newUserUsername);
		}
		if(!([select id from User where ContactId = :contactId].isEmpty())){
			return error('User already exists for Contact with ID: ' + contactId);
		}
		User partnerUser = new User();
		partnerUser.Username 					= newUserUsername;
		partnerUser.Alias	 					= personPartyId;
		partnerUser.Email 						= StringUtils.lowerCase(request.Email__c);
		partnerUser.FirstName 					= request.First_Name__c;
		partnerUser.LastName 					= request.Last_Name__c;
		partnerUser.ProfileId 					= request.Country__r.User_Profile_ID__c;
		partnerUser.LanguageLocaleKey 			= request.Country__r.User_Language_Locale_Key__c;
		partnerUser.LocaleSidKey 				= request.Country__r.User_Locale_Sid_Key__c;
		partnerUser.EmailEncodingKey 			= request.Country__r.User_Email_Encoding_Key__c;
		partnerUser.TimeZoneSidKey 				= request.Country__r.User_Time_Zone_Sid_Key__c;
		partnerUser.Badge_Number__c				= null;
		partnerUser.ContactId 					= contactId;
		partnerUser.Title 						= request.Job_Title__c;
		partnerUser.Enable_Partner_Admin__c 	= request.Enable_As_Partner_Admin__c;
		try{
			//partnerUser.put('UserPermissionsSFContentUser',true);
		}catch(System.SObjectException e){
			System.debug('User.UserPermissionsSFContentUser doesn\'t exist');
		}
		try{
			insert partnerUser;
		}catch(System.DmlException e){
			return error('Failed to create user: ' + e.getMessage());
		}
		return success(partnerUser.id);
	}
	
	private PageReference updatePartnerRequest(
		Partner_Request__c request,
		String userRecordId){
			
		if([select id from User where id = :userRecordId].isEmpty()){
			return error('Invalid User ID: ' + userRecordId);
		}
		request.Provisioned_User__c = userRecordId;
		request.Provision_First_User_Is_Complete_Flag__c = true;
		request.Status__c = PartnerConstants.REG_STATUS_COMPLETE;
		update request;
		return success(request.id);
	} 		

	private PageReference error(String message){
		this.success = false;
		this.errorDescription = message;
		return null;
	}
	
	private PageReference success(Id objectId){
		this.success = true;
		this.objectId = objectId;
		return null;
	}
	

}