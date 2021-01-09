public class PartnerRegistrationProgressBarCtrlExt {

    public Double percentComplete {get;set;}
    public static Long TOTAL_COMPLETE_FLAG_COUNT = 13;
    
    public PartnerRegistrationProgressBarCtrlExt(ApexPages.StandardController c){
    	percentComplete = 0;
        Partner_Request__c registration = (Partner_Request__c) c.getRecord();
        final List<Partner_Request__c> records = 
            [select 
            	Review_for_Completeness_Is_Complete_Flag__c, Provision_First_User_Is_Complete_Flag__c, 
            	Perform_Credit_Check_Is_Complete_Flag__c, Agreement_Hard_cpy_Rcvd_Is_Complete_Flag__c,
            	Link_to_Account_Record_Is_Complete_Flag__c, 
            	Export_Compliance_Check_Is_Complete_Flag__c, Check_For_Duplicates_Is_Complete_Flag__c, 
            	Check_Denied_Party_List_Is_Complete_Flag__c, Approve_Is_Complete_Flag__c, Provisioned_User__c, 
            	Enable_Order_Management_access_Flag__c , Enable_Premier_Pages_access_Flag__c, 
            	Send_Welcome_Packet_to_Partner_Flag__c , Send_Account_Suggestion_Is_Complete_Flag__c,recordtype.name
            from Partner_Request__c 
            where id = :registration.id limit 1];
        if(!records.isEmpty()){
	    	registration = records.get(0);
	    	Integer completeCount = 0;
	    	if(registration.Review_for_Completeness_Is_Complete_Flag__c){ 
	    		completeCount++;
	    	}
	    	if(registration.Check_For_Duplicates_Is_Complete_Flag__c) {
	    		completeCount++;
	    	}
	    	if(registration.Export_Compliance_Check_Is_Complete_Flag__c) {
	    		completeCount++;
	    	}
	    	if(registration.Check_Denied_Party_List_Is_Complete_Flag__c) {
	    		completeCount++;
	    	}
	    	if(registration.Perform_Credit_Check_Is_Complete_Flag__c) {
	    		completeCount++;
	    	}
	    	if(registration.Agreement_Hard_cpy_Rcvd_Is_Complete_Flag__c) {
	    		completeCount++;
	    	}
	    	if(registration.Approve_Is_Complete_Flag__c) {
	    		completeCount++;
	    	}
	    	if(registration.Link_to_Account_Record_Is_Complete_Flag__c) {
	    		completeCount++;
	    	}
	    	if(registration.Provision_First_User_Is_Complete_Flag__c){ 
	    		completeCount++;
	    	}
	    	if(registration.Enable_Order_Management_access_Flag__c){ 
	    		completeCount++;
	    	}
	    	if(registration.Enable_Premier_Pages_access_Flag__c){ 
	    		completeCount++;
	    	}
	    	if(registration.Send_Welcome_Packet_to_Partner_Flag__c){ 
	    		completeCount++;
	    	}
	    	if(registration.Send_Account_Suggestion_Is_Complete_Flag__c){ 
	    		completeCount++;
	    	}
	    	if(StringUtils.equalsIgnoreCase(registration.recordtype.name, 'Existing Partner')){
	    		TOTAL_COMPLETE_FLAG_COUNT = 12;
	    	}

System.debug('Review_for_Completeness_Is_Complete_Flag__c = [' + registration.Review_for_Completeness_Is_Complete_Flag__c + ']');
System.debug('Check_For_Duplicates_Is_Complete_Flag__c = [' + registration.Check_For_Duplicates_Is_Complete_Flag__c + ']');
System.debug('Export_Compliance_Check_Is_Complete_Flag__c = [' + registration.Export_Compliance_Check_Is_Complete_Flag__c + ']');
System.debug('Check_Denied_Party_List_Is_Complete_Flag__c = [' + registration.Check_Denied_Party_List_Is_Complete_Flag__c + ']');
System.debug('Perform_Credit_Check_Is_Complete_Flag__c = [' + registration.Perform_Credit_Check_Is_Complete_Flag__c + ']');
System.debug('Agreement_Hard_cpy_Rcvd_Is_Complete_Flag__c = [' + registration.Agreement_Hard_cpy_Rcvd_Is_Complete_Flag__c + ']');
System.debug('Approve_Is_Complete_Flag__c = [' + registration.Approve_Is_Complete_Flag__c + ']');
System.debug('Link_to_Account_Record_Is_Complete_Flag__c = [' + registration.Link_to_Account_Record_Is_Complete_Flag__c + ']');
System.debug('Provision_First_User_Is_Complete_Flag__c = [' + registration.Provision_First_User_Is_Complete_Flag__c + ']');
	    	
	    	percentComplete = (completeCount*100)/TOTAL_COMPLETE_FLAG_COUNT;

System.debug('completeCount = [' + completeCount + ']');
System.debug('TOTAL_COMPLETE_FLAG_COUNT = [' + TOTAL_COMPLETE_FLAG_COUNT + ']');
System.debug('percentComplete = [' + percentComplete + ']');
        } 
    }

}