public class PartnerRegistrationActionHandlerCtrlExt {

    private final String action;
    private Partner_Request__c request;
    
    public static final String ACTION_MARK_AS_COMPLETE 								= 'MarkAsComplete';
    public static final String ACTION_MARK_CREDIT_CHECK_COMPLETE 					= 'MarkCreditCheckComplete';
    public static final String ACTION_MARK_EXPORT_COMPLIANCE_CHECK_COMPLETE 		= 'MarkExportComplianceCheckComplete';
    public static final String ACTION_MARK_DENIED_PARTY_COMPLETE 					= 'MarkDeniedPartyCheckComplete';
    public static final String ACTION_MARK_HARD_COPY_RECEIVED_COMPLETE 				= 'MarkHardCopyReceivedComplete';
    public static final String ACTION_APPROVE 										= 'Approve';
    /*
			 Author    : Alvin Chew  
		 	 Date      : 9 July 2009 		
			 CR        : 1382
			 Description : Additional three steps added (Enable Order Management access ,Enable Premier Pages access ,  Send Welcome Packet to Partner. )
	*/	 
    public static final String ACTION_MARK_ORDER_MANAGEMENT_ACCESS_COMPLETE 		= 'MarkEnableOrderManagementAccess';
    public static final String ACTION_MARK_ENABLE_PREMIER_PAGES_ACCESS_COMPLETE 	= 'MarkEnablePremierPagesAccessComplete';
    public static final String ACTION_MARK_SEND_WELCOME_PACKET_TO_PARTNER_COMPLETE 	= 'MarkSendWelcomePacketToPartnerComplete';        
	
	/* End Of Modification */

	public PartnerRegistrationActionHandlerCtrlExt(ApexPages.StandardController c){
        request = (Partner_Request__c) c.getRecord();
        action = ApexPages.currentPage().getParameters().get('action');
        
		if(request == null || request.id == null){
        	PageUtils.addError('You have reached this screen in error.');
			return;
		}
        if(StringUtils.isBlank(action)){
        	PageUtils.addError('You have reached this screen in error.  An HTTP Parameter named \'action\' is required for this page.');
        	return;	
        }
        List<Partner_Request__c> requestList = [select id, status__c, Review_for_Completeness_Is_Complete_Flag__c, 
            	Perform_Credit_Check_Is_Complete_Flag__c, Export_Compliance_Check_Is_Complete_Flag__c,  
            	Check_Denied_Party_List_Is_Complete_Flag__c, Agreement_Hard_cpy_Rcvd_Is_Complete_Flag__c, 
            	Enable_Order_Management_access_Flag__c , Enable_Premier_Pages_access_Flag__c, Send_Welcome_Packet_to_Partner_Flag__c             	 
            from Partner_Request__c 
            where id = :request.id limit 1]; 
		if(requestList.size() > 0){
			request = requestList.get(0);
		}
	}
	
	public PageReference doOnLoad(){
		System.debug('(request == null || request.id == null) = ' + (request == null || request.id == null));
		if(request == null || request.id == null){
			return null;
		}
        if(ACTION_MARK_AS_COMPLETE.equalsIgnoreCase(action)){
        	request.Status__c = PartnerConstants.REG_STATUS_INREVIEW;
			request.Review_for_Completeness_Is_Complete_Flag__c = true;
        } else if(ACTION_MARK_CREDIT_CHECK_COMPLETE.equalsIgnoreCase(action)){
			request.Perform_Credit_Check_Is_Complete_Flag__c = true;
        } else if(ACTION_MARK_EXPORT_COMPLIANCE_CHECK_COMPLETE.equalsIgnoreCase(action)){
			request.Export_Compliance_Check_Is_Complete_Flag__c = true;
        } else if(ACTION_MARK_DENIED_PARTY_COMPLETE.equalsIgnoreCase(action)){
			request.Check_Denied_Party_List_Is_Complete_Flag__c = true;
        } else if(ACTION_MARK_HARD_COPY_RECEIVED_COMPLETE.equalsIgnoreCase(action)){
			request.Agreement_Hard_cpy_Rcvd_Is_Complete_Flag__c = true;
        } else if(ACTION_APPROVE.equalsIgnoreCase(action)){
        	request.Status__c = PartnerConstants.REG_STATUS_APPROVED;
			request.Approve_Is_Complete_Flag__c = true;
		
		/* CR : 1382
		   Description : mark checkbox if related link was clicked 
		*/		
        } else if(ACTION_MARK_ORDER_MANAGEMENT_ACCESS_COMPLETE.equalsIgnoreCase(action)){
			request.Enable_Order_Management_access_Flag__c = true;	
		} else if(ACTION_MARK_ENABLE_PREMIER_PAGES_ACCESS_COMPLETE.equalsIgnoreCase(action)){
			request.Enable_Premier_Pages_access_Flag__c = true;	
		} else if(ACTION_MARK_SEND_WELCOME_PACKET_TO_PARTNER_COMPLETE.equalsIgnoreCase(action)){
			request.Send_Welcome_Packet_to_Partner_Flag__c = true;
		/*End Of Modification*/	
					
        } else {
        	PageUtils.addError('You have reached this screen in error.  Invalid action: ' + action);
        	return null;	        
        }
        try{
        	System.debug('request.Company__c = [' + request.Company__c + ']');
			update request;
        } catch (Exception e){
			ApexPages.addMessages(e);
			return null;
        } 

        if(ACTION_MARK_AS_COMPLETE.equalsIgnoreCase(action)){
			return PageUtils.redirect(Page.PartnerRegistrationDupSearch.getUrl() + '?id=' + request.id);
        }
		return PageUtils.redirect('/' + request.id);
	}

    public Boolean getIsError() { return ApexPages.hasMessages(); }
}