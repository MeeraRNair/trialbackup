@IsTest
private class FAP_PartnerSearchResultTest {
    static list<Account> listAcc;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(2,'Partner Account');
        listAccTdf[0].Approved_for_Partner_Finder__c = true;
        listAccTdf[0].Partner_User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId();
        listAccTdf[0].Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now();
        insert listAccTdf;
    }
    private static Account getAcct1(String strname){
        // Configuration_Variable__mdt var = null;
        try{
            Configuration_Variable__mdt var= [
                select id,developername 
                from Configuration_Variable__mdt
                where developername = :fap_PartnerSearchConstants.CONFIG_KEY_TERMS_AND_CONDITIONS_URL];
        }catch(QueryException e){
            //   var = new Configuration_Variable__c(name = PartnerSearchConstants.CONFIG_KEY_TERMS_AND_CONDITIONS_URL);
            // insert var;
        }
        // var.value__c = 'test123';
        // update var;
        listAcc = [Select Id from Account limit 1];
        listAcc[0].Approved_for_Partner_Finder__c = true;
        listAcc[0].Partner_User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId();
        listAcc[0].Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now();
        listAcc[0].IsPartner = true;
        update listAcc;
        /*Account acct = new Account(
name = name,
Approved_for_Partner_Finder__c = true,
Profile_Published_to_Partner_Finder__c = 'Yes',
Partner_User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId(),
Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now());
insert acct;
acct.IsPartner = true;
update acct;*/
        return listAcc[0];
    }
    private static testmethod void testBuild(){
        Logo__c logo1=new logo__c();
        insert logo1;
        listAcc = [Select Id from Account limit 1];
        listAcc[0].IsPartner = true;
        update listAcc;
        /*Account acct = new Account(
name = 'name',
nameLocal='name',
Approved_for_Partner_Finder__c = true,
Profile_Published_to_Partner_Finder__c = 'Yes',
Partner_User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId(),
logo__c=logo1.id,
BillingCountry='United States',
BillingCity='City',
BillingStreet='Street',
BillingPostalCode='12732',
Website='1@g.com',
Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now());
insert acct;
acct.IsPartner = true;
update acct;*/
        Partner_Track__c partnerTrack = new Partner_Track__c(
            Partner_Track_Account_Local_Name__c = 'name',
            Approved_for_Partner_Finder__c = true,
            Primary_SMAffinity_Account__c=listAcc[0].id,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            User_Agreed_to_PF_Terms_Cond__c = UserInfo.getUserId(),
            logo__c=logo1.id,
            Partner_Date_Agreed_to_PF_Terms_Cond__c = Datetime.now());
        insert partnerTrack;
        partnerTrack.Partner_Account__c = true;
        //PartnerTrack.Primary_SMAffinity_Account__c=acct.id;
        update partnerTrack;
        
        system.debug('Legal Name'+partnerTrack.Primary_SMAffinity_Account__c+':::Primary_Sales_Motion_Account_Legal_Name__c::'+PartnerTRACK.Primary_Sales_Motion_Account_Legal_Name__c);
        Partner_Location__c loc = new Partner_Location__c();
        loc.Name = 'test location';
        loc.Longitude__c = 0;
        loc.Latitude__c = 0;
        loc.Is_Primary__c = true;
        loc.Account__c = listAcc[0].id;
        loc.Partner_Track__c = partnerTrack.id;
        
        insert loc;
        Partner_Track__c pt=[Select id,name,Primary_Sales_Motion_Account_Legal_Name__c,Partner_Track__c.Legal_Address_City__c,Partner_Track_Account_Local_Name__c,Approved_for_Partner_Finder__c,Primary_SMAffinity_Account__c,Profile_Published_to_Partner_Finder__c, User_Agreed_to_PF_Terms_Cond__c,
                             logo__c,Legal_Address_Postal_Code__c,Partner_Date_Agreed_to_PF_Terms_Cond__c,Partner_Account__c from Partner_Track__c where id=:partnerTrack.id];
        
        loc.Partner_Track__c=pt.id;
        partner_location__c loc1=[select id,name,Website__c,Partner_Track__c,Partner_Track__r.Legal_Address_Country__c,Partner_track__r.Legal_Address_Postal_Code__c,account__r.Partner_Finder_Recommended_Flag__c,Account__r.Name,Point_of_Contact_Name__c,Point_of_Contact_Phone__c,Partner_Track__r.Website__c,Account__c,Partner_Track__r.Legal_Address_State_Province__c,Partner_Track__r.Legal_Address_Street__c,Partner_Track__r.Legal_Address_City__c, Street__c,Latitude__c,Longitude__c,State_Province__c,Postal_Code__c,Country__c,Partner_Track__r.logo__c,Is_Primary__c,Partner_Track__r.Primary_Sales_Motion_Account_Legal_Name__c,Account__r.Logo__c,City__c FROM Partner_location__c where id =:loc.id];
        FAP_PartnerSearchResult fp=new FAP_PartnerSearchResult(loc1);
        system.assertNotEquals(fp.companyId, null);
    }
}