@isTest
public class ShareRecordTriggerHandlerAITest {
	
    static List<AccountTeamMember> listATM;
    static list<User> listUser;
    static list<Account> listAccs;
    
    @testSetup static void setup() {
        
        List<Account> listAcc = createNAccount(1, 'Partner Account');
        insert listAcc;
        
        List<User> listUsr = createNPortalUser(3);
        insert listUsr;
    }
    
    public static List<Account> createNAccount(Integer intNumRecords,String strAccountType){
        
        String strMasterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
        String strPartnerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        String strEndUserAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId();
        List<Account> listAcc = new List<Account>();
        
        for(Integer inti = 1; inti <= intNumRecords ; inti++){
            Account acc = new Account();
            acc.Name = 'Test Account Version'+inti+'_'+string.valueof(Math.abs(Crypto.getRandomInteger()));
            acc.NPS_Qualified_Contacts__c = 1;
            acc.Website = 'www.dell.com';
            
            if(strAccountType.equals('Master Account')){
                acc.Master_Group_Affinity_ID__c='MGAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger())); 
                acc.RecordTypeId = strMasterAccountRecordTypeId;
            }
            else if(strAccountType.equals('Partner Account') ){
                acc.Account_ID__c='SMAff1211'+string.valueof(Math.abs(Crypto.getRandomInteger()));
                acc.RecordTypeId = strPartnerAccountRecordTypeId;
            }
            else{
                acc.Account_ID__c='EUAAff1211'+string.valueof(Math.abs(Crypto.getRandomInteger()));
                acc.RecordTypeId = strEndUserAccountRecordTypeId;
                acc.Participating_in_LOB_Program__c=true;
            }
            
            listAcc.add(acc);
        }
        return listAcc;
    }
    
    public static List<User> createNPortalUser(Integer intNumRecords){
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        List<Account>listMA = createNAccount(1,'Master Account');
        if(listMA.size() > 0){
            insert listMA;
        }
        
        List<Contact> listActiveCon = new List<Contact>();
        for(Integer inti = 1; inti <= intNumRecords ; inti++){
            
            Contact con = new Contact(AccountId = listMA[0].Id,
                                      Email='testcontact_'+inti+'@DELLTEAM.com',
                                      FirstName = 'Test Contact', 
                                      LastName = 'Version'+inti+'_'+String.valueOf(Math.abs(Crypto.getRandomInteger())),
                                      Status__c = 'Customer',phone = '6739543210',
                                      //EligibleTracks__c = listPT[i-1].Id,
                                      Allow_Partner_Central_User__c=true, Premier_Partner__c = true
                                     );
            listActiveCon.add(con);
            
        }
        Integer intuserNumber = Math.abs(Crypto.getRandomInteger());
        String strnewusername = 'Test '+intuserNumber +'_data'+'@DELLTEAM.com'; 
        String strbadgeNumber = String.valueOf(intuserNumber )+string.valueof(Math.abs(Crypto.getRandomInteger()));
        
        
        insert listActiveCon;
        
        List<Profile> listp = new List<Profile>([select Id,name from Profile where UserType =:'PowerPartner' limit 2]);
        List<User> listActiveUsr = new List<User>();
        for(Integer inti = 1; inti <= intNumRecords ; inti++){
            User newUser = new User(profileId = listp [1].id,username =listActiveCon[inti-1].Email,
                                    email = listActiveCon[inti-1].Email,Badge_Number__c=null, 
                                    emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                                    timezonesidkey = 'America/Los_Angeles',alias='nuser'+inti,
                                    lastname=listActiveCon[inti-1].LastName,
                                    contactId = listActiveCon[inti-1].id,
                                    Enable_Partner_Deal_Registration__c = true, Enable_Partner_Lead_Management__c = true, 
                                    Enable_As_Partner_Lead_Super_User__c = true, isActive = true);
            listActiveUsr.add(newUser);
        }
        return listActiveUsr;
        
    }
    
    public static testMethod void afterInsertTest(){
        List<Account> listAccUpd = new List<Account>();
        List<Contact> listCon = new List<Contact>();
        List<AccountTeamMember> listATMS =new List<AccountTeamMember>();
        List<Share_Records__e> listShareRecords = new List<Share_Records__e>();
        String strMasterGroupId;
        listUser = [SELECT Id,ContactId,Contact.AccountId, isActive FROM User WHERE Email like 'testcontact_%' AND isActive=true];
        listAccs = [SELECT Id,Account_ID__c,Master_Group_Id__c FROM Account WHERE Account_ID__c like 'SMAff1211%'];
        if(listUser.size() > 0){
            strMasterGroupId = String.valueOf(listUser[0].Contact.AccountId);
            for(Account acc :listAccs){
                acc.Master_Group_Id__c = strMasterGroupId;
                listAccUpd.add(acc);  
            }
            
            if(listAccUpd.size() > 0){
                //TriggerExecutionController.setSkipAllTriggers(true);
                update listAccUpd;
            }
            
            for(User u : listUser){
                AccountTeamMember atm = new AccountTeamMember();
                atm.UserId = u.Id;
                atm.AccountAccessLevel = 'Edit';
                atm.AccountId = listAccs[0].Id;
                atm.TeamMemberRole = 'Account Executive';
                atm.Published_MGShare_Event__c = true;
                listATMS.add(atm);
            }
            
            Test.startTest();
            if(listATMS.size() > 0){
                insert listATMS;
            }
            for(AccountTeamMember atm : listATMS){
                Share_Records__e shareRecObj = new Share_Records__e();
                shareRecObj.AccountId__c = atm.AccountId;
                shareRecObj.User_Id__c = atm.UserId;
                shareRecObj.Account_Access_Level__c = atm.AccountAccessLevel;
                listShareRecords.add(shareRecObj); 
            }
            if(!listShareRecords.isEmpty()){
                //insert listShareRecords;
                EventBus.publish(listShareRecords);
            }
            delete listATMS[0];
            System.assertEquals(3, listUser.size());
            Test.stopTest();
        }
    }
}