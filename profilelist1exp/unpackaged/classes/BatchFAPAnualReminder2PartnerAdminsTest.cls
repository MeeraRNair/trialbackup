/* ------------------------------------------------------------------------------------------------------------------------
Version   Date             CR     By            Purpose
1.0       6 Jan 2016       12485   Dipin Raju    test class for BatchFAPAnualReminder2PartnerAdmins
--------------------------------------------------------------------------------------------------------------------------- */
@isTest

private class BatchFAPAnualReminder2PartnerAdminsTest {
    
    static testMethod  void testBatchFAPAnualReminder2PartnerAdmins() {
        /*     
String domain = 'dell.com.fdev';
String email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
String languageCode = 'en_US';    


Contact con = createPartnerContact(newAcc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + domain);  

User u1 = createPartnerUser(con.Id, email, languageCode, true, true, true);  

System.debug('#### NEW Account is --> '+newAcc);
System.debug('#### NEW Contact is --> '+con);
System.debug('#### NEW Contact id is --> '+con.Id);

List<Id> accPartnerFinder = new List<Id>();
accPartnerFinder.add(newAcc.Id);
*/
        String strCountryCode = 'FR';
        test.startTest();
        list<Account> listacc = createPartnerAccount(strCountryCode, true);
        TriggerExecutioncontroller.setSkipAccountTriggers(True);
        list<contact> listcon = TestDataFactory.CreateNContacts(1);
        listcon[0].AccountID = listAcc[0].id;
        insert listcon;
        Triggerexecutioncontroller.setSkipContactTriggers(True);
        list<user> listuser = TestDataFactory.createNPortalUser(1);
        listuser[0].contactid = listcon[0].id;
        insert listuser;
        BatchFAPAnualReminder2PartnerAdmins batchFapReminder = new BatchFAPAnualReminder2PartnerAdmins();         
        database.executebatch(batchFapReminder);
        
        List<User> listAdmins = [SELECT email, LanguageLocaleKey FROM User WHERE Contact.AccountId = :listuser[0].Contact.AccountId limit 1];
        test.stopTest();
        
        System.debug('#### NEW Admin is --> '+listAdmins);
        system.AssertEquals(1, listAdmins.size());
        //     system.AssertEquals(email, admins[0].Email);
        //     system.AssertEquals(languageCode, admins[0].LanguageLocaleKey);  
        
    }
    private static list<Account> createPartnerAccount(String strCountryCode, Boolean bisPartner){
        list<Account> listacc = TestDataFactory.createNAccount(1, 'Partner Account');
        listAcc[0].Account_Country_Code__c = strCountryCode;
        listAcc[0].Approved_for_Partner_Finder__c = True;
        listAcc[0].Profile_Published_to_Partner_Finder__c = 'Yes'; 
        listAcc[0].Partner_User_Agreed_to_PF_Terms_Cond__c=  '005A00000019yk6';                                     
        listAcc[0].Date_of_Profile_Update__c=System.Today()-365;
        TriggerExecutioncontroller.setSkipAccountTriggers(True);
        insert listAcc;
        listacc[0].IsPartner = bisPartner;
        update listacc;
        return listacc;
    }
    
    
    /*    

private static Contact createPartnerContact(String accountId){
return CreatePartnerContact(accountId, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev');
}

private static Contact createPartnerContact(string accountId, string email){
Contact con1 = new Contact(AccountId = accountId, Email = email, Lastname = 'UT');
insert con1;
return con1;
}

private static User createPartnerUser(String contactId, String email, String languageCode, Boolean isActive, Boolean isPartnerAdmin, Boolean isAdminForPartnerFinder){

Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' LIMIT 1];
User u1 = new User(ContactId = contactId, IsActive = isActive, Email = email, LanguageLocaleKey = languageCode, Enable_Partner_Admin__c = isPartnerAdmin,
Is_Admin_for_Partner_Finder_Profile__c = isAdminForPartnerFinder,
ProfileId = p.Id, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LastName = 'UT', Alias = 'UT', EmailEncodingKey = 'ISO-8859-1', UserName = email, Badge_Number__c='FAP'+String.ValueOf(Math.round(Math.random()*100000)));
insert u1;
return u1; 
}  
*/
}