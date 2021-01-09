@IsTest
private class PartnerPortalHomeRedirectCtrlTest {

	private static testmethod void testAsStandardUser(){
		PartnerPortalHomeRedirectCtrl ctrl = new PartnerPortalHomeRedirectCtrl();
		PageReference page = ctrl.doOnload();
		System.assertNotEquals(null,page);
	}
	
	private static testmethod void testAsPortalUser(){
        User partner = null;
		try{
			partner = 
				[select id,name,Contact.Account.Account_Country_Code__c 
				from User 
				where Profile.UserType = 'PowerPartner'
				and IsActive = true
				and ContactId != null
				and Contact.Account.Account_Country_Code__c != null 
				limit 1];
		}catch(QueryException e){}
		system.debug('partner id ='+ partner.id);
		System.debug('country code: ' + partner.Contact.Account.Account_Country_Code__c );
		System.assert(partner!=null,'Environment Dependency: no partner users available in your org.');
        Country__c country = null;
		try{
			country = 
				[select id, Public_Portal_Home_URL__c 
					from Country__c 
					where code__c = :partner.Contact.Account.Account_Country_Code__c];
		}catch(QueryException e){}
		if(country == null){
			country = new Country__c(
				name='test',
				code__c=partner.Contact.Account.Account_Country_Code__c,
				Inc_Vendor_Name__c = 'Dell Achievers',  // Fenny added on 1-Apr-2013
				Inc_Vendor_End_Point__c = 'test'); // Fenny added on 1-Apr-2013
			insert country;
		}
		country.Inc_Vendor_Name__c = 'Dell Achievers';  // Fenny added on 1-Apr-2013
		country.Inc_Vendor_End_Point__c = 'test'; // Fenny added on 1-Apr-2013
		country.Public_Portal_Home_URL__c = 'http://www.google.com';
		update country;
        System.runAs(partner){
			PartnerPortalHomeRedirectCtrl ctrl = new PartnerPortalHomeRedirectCtrl();
			PageReference page = ctrl.doOnload();
			System.assertNotEquals(null,page);
			if(StringUtils.isNotBlank(ctrl.userCountryCode)){
				System.assertEquals('http://www.google.com',page.getUrl());
			}else{
				System.assertEquals('/home/home.jsp',page.getUrl());
			}
		}		
	}

}