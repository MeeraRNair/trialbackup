/**
 * Responsible for re-directing a user from the SFDC Partner Portal
 * to the correct Dell Public Partner Portal Home Page URL.  A link will
 * be displayed in the SFDC Partner header which will point to this 
 * page.
 * 
 * The logic for this page is the following:
 * (1) Load Partner Account Country Code for current user's username/account.  
 *     Only partner users will have a partner portal account so standard
 *     license users will not have an associated account.
 * (2) Get Public Portal Home based on Account Country code. 
 */
public class PartnerPortalHomeRedirectCtrl {

	public String userCountryCode {get;set;}
	public PageReference doOnload(){
		try{
			final User usr = 
				[select id, name,Contact.Account.Account_Country_Code__c 
				from user 
				where id = :UserInfo.getUserId()
				and ContactId != null];
						
			userCountryCode = usr.Contact.Account.Account_Country_Code__c;		
			if(usr.Contact != null && usr.Contact.Account != null){
				final Country__c country = 
					[select id, Public_Portal_Home_URL__c 
					from Country__c 
					where code__c = :usr.Contact.Account.Account_Country_Code__c];
				if(StringUtils.isNotBlank(country.Public_Portal_Home_URL__c)){
					return PageUtils.redirect(country.Public_Portal_Home_URL__c);			
				}
				
			}
		}catch(QueryException e){}
		return PageUtils.redirect('/home/home.jsp');
	}
}