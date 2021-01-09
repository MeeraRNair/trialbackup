/*-----------------------------------------------------------------------------------------
Description: Class  for migrating sharing functionalities from Account to  LOB Registration 
CR #2549

Rev     Date            Author          Remarks
1.0                     Hanan/Manju     created 
2.0     16-Dec-2011     Azwanti         CR5786 CRQ0241 : change reference to LOB_Name__c field.
2.1    10-Jan-2011    Krishna      CR 6887(Emergency): Changed the Partner role selection from Partner Executive to Partner User
                      -Changed the Group Type as Role from RoleAndSubordinates
                      -Renamed variable name from partnerExecRoleIdSet to partnerUserRoleIdSet
--------------------------------------------------------------------------*/
@isTest(SeeAllData=true)

private class LOBRegistrationUtilitiesTest {
    
     //Hanan :- Test method for migrating the sharing functionality from Account to LOB Reg. Object
     
     static User  GCCPgmMgrObject;
     static Profile profileRec;
     static UserRole userRoleRec; 
     
     public static User createUser(){
        profileRec = [select id from profile where name = 'GBL PRM Operations']; 
        userRoleRec=[Select  PortalAccountId,Name,Id From UserRole  where  name like '%WW_Exec' Limit 1];
                                    
        GCCPgmMgrObject=new User(
            Username='testuserGBLPRM'+'@dell.com',
            Alias = 'tGBLPRM', 
            Email='testuserGBLPRM'+'@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = profileRec.Id, 
            Division = 'Deal Registration',
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='testuserGBLPRM',
            userRoleId=userRoleRec.id,
            Title='GCC Program Manager'                    
        );
        return GCCPgmMgrObject; 
                
     }
    static testMethod void testLOBRegistrationAssignment() {
       System.RunAs(createUser())
       {   
        Id endUserAccountId;
        Id partnerAccountId;
        String groupId;
        String roleId;
        Set<String> lobNameSet = new Set<String>();
        Set<Id> prefGtmPartnSet = new Set<Id>();
        Set<Id> endUserSet = new Set<Id>();
        Map<Id,LOB_Registration__c> lobObjMap = new Map<Id,LOB_Registration__c>();
        Map<Id,Id> PortalAccountIdTOROleIdMap=new Map<Id,Id>();
        Map<Id,Id> PortalRoleIdTOGroupIdMap=new Map<Id,Id>();
        Map<Id,Id> GroupIdPartnerAccountIdMap=new Map<Id,Id>();
        Map<Id,Id> PAIdEUAIdMap=new Map<Id,Id>();
        List<Profile> partnerProfiles=[SELECT id,name FROM Profile WHERE UserType = 'PowerPartner'];
                                        //AND  name like 'R11.7%'];
        List<Account> accounts = new List<Account>();
        List<Account> partnerAccounts = new List<Account>();
        List<Account> endUserAccounts = new List<Account>();
         List<Account> partnerAccountsNew= new List<Account>();
        List<Account> updateAccountList;
        List<LOB_Registration__c> updateLOBRegList;
        List<LOB_Registration__c> lOBRegList;
        List<Contact> contacts = new List<Contact>();
        List<User> users = new List<User>();
        Set<Id> endUserAccountIdset=new Set<Id>(); 
        Set<Id> partnerAccountIdSet=new Set<Id>(); 
        Set<Id> gtmLOBRegIdset=new Set<Id>();
        Set<Id> partnerUserRoleIdSet=new Set<Id>();
        Set<Id> groupIdSet=new Set<Id>();
        Date expirydate = System.Today()+1;
        //List<AccountShare> accountshareList=new List<AccountShare>();
        Map<id,group> groupMap=new Map<id,group>(); 
        Map<id,Account> endUserAccountMap=new Map<id,Account>();
        Map<id,LOB_Registration__c> LOBMap=new Map<id,LOB_Registration__c>();
        Account partnerAccount1;
        Account partnerAccount2;
        Account accountObject=new Account();
        
        LOB_Registration__c   lobObject=new LOB_Registration__c();
        
        RecordType recType = [SELECT r.SobjectType, r.Name, r.Id FROM RecordType r 
                              WHERE  r.SobjectType = 'LOB_Registration__c' and name = 'LOB registration(Partner Approved)'];
            
        Test.startTest();
        for(integer i=0;i<5;i++){
            Account accountObj=new Account(name='TestAccount'+i,
                                           Account_Country_Code__c = 'AI',
                                           Account_Country__c = 'ANGUILIA'); 
            accounts.add(accountObj);
        }
        
        insert accounts;
        
        for(Account account:accounts){
            account.IsPartner = true;
            account.Is_GTM_Partner__c=true;
            account.RecordTypeId= System.Label.RecType_Partner_Account;
            
        }
        
        update accounts;
        
         for(integer i=0;i<5;i++){
            Account accountObj=new Account(name='TestPartnerAccount'+i,
                                           Account_Country_Code__c = 'AI',
                                           Account_Country__c = 'ANGUILIA'); 
            partnerAccounts.add(accountObj);
        }
        
        insert partnerAccounts;
        
        for(Account account:partnerAccounts){
            account.IsPartner = true;
            account.Is_GTM_Partner__c=true;
            account.RecordTypeId= System.Label.RecType_Partner_Account;
        }
        
        
        
        update partnerAccounts;
        
       
       partnerAccount1=new Account(name='TestpartnerAccount11',
                                   Account_Country_Code__c = 'AI',
                                   Account_Country__c = 'ANGUILIA'); 
       partnerAccountsNew.add(partnerAccount1);
      
       partnerAccount2=new Account(name='TestpartnerAccount22',
                                   Account_Country_Code__c = 'AI',
                                   Account_Country__c = 'ANGUILIA'); 
       partnerAccountsNew.add(partnerAccount2);
        
        
        insert partnerAccountsNew; 
        
        partnerAccount1.IsPartner = true;
        partnerAccount1.Is_GTM_Partner__c=true;
        partnerAccount1.RecordTypeId= System.Label.RecType_Partner_Account;
        partnerAccount2.IsPartner = true;
        partnerAccount2.Is_GTM_Partner__c=true;
        partnerAccount2.RecordTypeId= System.Label.RecType_Partner_Account;
        
        update partnerAccount1;
        update partnerAccount2;
        
        for(Integer i = 0; i <4; i++){
            contacts.add(
                new Contact(
                    AccountId=accounts.get(i).id,
                    Email=''+i+'@dell.com', 
                    FirstName = 'John', 
                    LastName = 'Doe'+i,
                    Title='VP',
                    MailingStreet='123 Main',
                    MailingCity='Peoria',
                    MailingState='IL',
                    MailingPostalCode='33333',
                    Phone='3213213211',
                    MobilePhone='3213213211',
                    Fax='3213123211'                    
                )
            );
        }
        insert contacts;
        
        /*Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u = new User(Alias = 'stand404', Email='stuser404@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='600456', UserName='stuser404@dell.com');
        System.RunAs(u)
        {
            for(Integer i = 0; i < 4; i++){
                users.add(
                    new User(
                        Username='testuser'+i+'@dell.com',
                        Alias = 'test'+i, 
                        Email='testuser'+i+'@test.com', 
                        FirstName='John', 
                        LastName='Doe'+i, 
                        ProfileId = partnerProfiles.get(i).Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c=null, 
                        ContactId = contacts.get(i).id 
                       )
                );
            }
            insert users;
        }*/
        

        RecordType reTyp = [SELECT SobjectType, Name, Id FROM RecordType  
                            WHERE  SobjectType = 'Account' and name = 'End-User Account'];
        for(Integer i = 0; i < accounts.size(); i++){
            Account accountObj=new Account(name='TestAccount'+i,
                                           Account_Country_Code__c = 'AI',
                                           Account_Country__c = 'ANGUILIA',
                                           Participating_in_LOB_Program__c = true,
                                           RecordTypeId = reTyp.Id); 
            endUserAccounts.add(accountObj);
        }
        
        insert endUserAccounts;
        Test.stopTest();

        lOBRegList=new List<LOB_Registration__c>();
        
        for(Integer i = 0; i < 4; i++){
            LOB_Registration__c LOBobj=new LOB_Registration__c(                                                          
                                                               Shared_to_GTM_Partner__c=false,
                                                               LOB_registration_status__c='Rejected'); 
            
            if(i==0){
              //CRQ0241 reminder : uncomment after type change
                LOBobj.LOB_Name__c='Client';
                LOBobj.Registered_End_User__c=endUserAccounts[0].id;
                 LOBobj.State_Province_Region__c = 'State'; 
                 LOBobj.City__c = 'city'; 
                 LOBobj.Justification__c = 'justify yourself!';
                 LOBobj.LOB_Award_Type__c = 'Account' ;
                 
            }
            if(i==1){
                //CRQ0241 reminder : uncomment after type change
                LOBobj.LOB_Name__c='Server';
                LOBobj.Registered_End_User__c=endUserAccounts[0].id;
                LOBobj.State_Province_Region__c = 'State'; 
                 LOBobj.City__c = 'city';
                 LOBobj.Justification__c = 'justify yourself!';
                 LOBobj.LOB_Award_Type__c = 'Account' ;
            }
            if(i==2){
                 //CRQ0241 reminder : uncomment after type change
                LOBobj.LOB_Name__c='Storage';  
                LOBobj.Registered_End_User__c=endUserAccounts[0].id;
                LOBobj.State_Province_Region__c = 'State'; 
                 LOBobj.City__c = 'city';
                 LOBobj.Justification__c = 'justify yourself!';
                 LOBobj.LOB_Award_Type__c = 'Account' ;
            }
            if(i==3){
              //CRQ0241 reminder : uncomment after type change
                LOBobj.LOB_Name__c='Storage';  
                LOBobj.Registered_End_User__c=endUserAccounts[1].id;
                LOBobj.State_Province_Region__c = 'State'; 
                 LOBobj.City__c = 'city';
                 LOBobj.Justification__c = 'justify yourself!';
                 LOBobj.LOB_Award_Type__c = 'Account' ;
            }
            lOBRegList.add(LOBobj);
            
        }
        insert lOBRegList;
        endUserAccountIdset.add(endUserAccounts[0].id);
        endUserAccountIdset.add(endUserAccounts[1].id);
        
       updateLOBRegList = new List<LOB_Registration__c>();
        
        for(Integer i = 0; i < lOBRegList.size(); i++){
            lobObject =lOBRegList[i];
            lobObject.RecordTypeId=recType.id;
            lobObject.GTM_Linkage_Expiry_Date__c=System.today()+1;
            lobObject.LOB_registration_status__c='Partner(approved)';
              
                    
                lobObject.Preferred_GTM_Partner_Account__c=accounts[i].id;
                partnerAccountIdSet.add(accounts[i].id);
                gtmLOBRegIdset.add(accounts[i].id);
                PAIdEUAIdMap.put(lobObject.Preferred_GTM_Partner_Account__c,lobObject.Registered_End_User__c);
                       
            
            updateLOBRegList.add(lobObject);
            
        }
        update updateLOBRegList; 
        
        partnerAccountIdSet.add(partnerAccount1.id);
        partnerAccountIdSet.add(partnerAccount2.id);
        gtmLOBRegIdset.add(partnerAccount1.id);
        gtmLOBRegIdset.add(partnerAccount2.id);
        
        for(UserRole userRoleObject:[SELECT  PortalAccountId,Name,Id
                                     FROM UserRole  WHERE  
                                     name like '%Partner User'
                                     and PortalAccountId in:gtmLOBRegIdset
                                     order by PortalAccountId]){
            partnerUserRoleIdSet.add(userRoleObject.Id);
            PortalAccountIdTOROleIdMap.put(userRoleObject.PortalAccountId,userRoleObject.Id); 
        }
        
        for(Group groupElement:[SELECT Type, RelatedId,Name,Id FROM Group WHERE 
                                Type='Role' and RelatedId in:partnerUserRoleIdSet
                                order by RelatedId]){       
            PortalRoleIdTOGroupIdMap.put(groupElement.RelatedId,groupElement.Id); 
            groupIdSet.add(groupElement.id); 
                            
        }
        
        for(Id partnerAccntIdItem : gtmLOBRegIdset){                
            roleId=PortalAccountIdTOROleIdMap.get(partnerAccntIdItem);
            groupId=PortalRoleIdTOGroupIdMap.get(roleId);
            GroupIdPartnerAccountIdMap.put(groupId,partnerAccntIdItem);               
       }
                
       Integer i=0;
       LOBMap.clear();
       LOBMap=new Map<Id,LOB_Registration__c>();
       
       
       updateLOBRegList = new List<LOB_Registration__c>();
        
       List<AccountShare> accountShareList=[SELECT UserOrGroupId,Id, AccountId FROM AccountShare WHERE UserOrGroupId in:groupIdSet 
                                            and AccountId in :endUserAccountIdset order by AccountId];
                                            
       for(LOB_Registration__c lobRegObject:[select GTM_partner_group__c,Shared_to_GTM_Partner__c,Preferred_GTM_Partner_Account__c,
                                            Registered_End_User__c,recordTypeId,LOB_registration_status__c  from LOB_Registration__c where Registered_End_User__c 
                                            in :endUserAccountIdset]){
            if(lobRegObject.Preferred_GTM_Partner_Account__c!=null){
                updateLOBRegList.add(lobRegObject);     
            }                                    
                                            
            for(AccountShare accountShareElt:accountShareList){
                partnerAccountId=GroupIdPartnerAccountIdMap.get(accountShareElt.UserOrGroupId);
                endUserAccountId=PAIdEUAIdMap.get(partnerAccountId);
                
                            
                if(endUserAccounts[0].id==lobRegObject.Registered_End_User__c){
                    
                    if(lobRegObject.Registered_End_User__c==accountShareElt.AccountId && 
                       lobRegObject.GTM_partner_group__c==accountShareElt.UserOrGroupId){
                        System.assertEquals(accountShareElt.AccountId,lobRegObject.Registered_End_User__c);   
                        System.assertEquals(accountShareElt.UserOrGroupId,lobRegObject.GTM_partner_group__c); 
                        System.assertEquals(true,lobRegObject.Shared_to_GTM_Partner__c);  
                    }               
                                    
                    
                }
                if(endUserAccounts[1].id==lobRegObject.Registered_End_User__c ){
                   
                    if(lobRegObject.Registered_End_User__c==accountShareElt.AccountId && 
                       lobRegObject.GTM_partner_group__c==accountShareElt.UserOrGroupId){
                        System.assertEquals(accountShareElt.AccountId,lobRegObject.Registered_End_User__c);   
                        System.assertEquals(accountShareElt.UserOrGroupId,lobRegObject.GTM_partner_group__c); 
                        System.assertEquals(true,lobRegObject.Shared_to_GTM_Partner__c);  
                    }                       
                }
            }
        }
        
        
        List<LOB_Registration__c> lobRegEltList=new List<LOB_Registration__c>();
        Map<Id, Id> endUserAccountIdOldGroupMap=new Map<Id,Id>();
        
        updateLOBRegList[1].LOB_registration_status__c='Partner(submit for approval)';
        updateLOBRegList[1].Preferred_GTM_Partner_Account__c=accounts[0].id;
        updateLOBRegList[2].LOB_registration_status__c='Partner(approved)';
        updateLOBRegList[2].Preferred_GTM_Partner_Account__c=accounts[0].id;
        lobRegEltList.add(updateLOBRegList[1]);
        lobRegEltList.add(updateLOBRegList[2]);
        
        update lobRegEltList;
          //CRQ0241 reminder : uncomment after type change 
        lobNameSet.add(updateLOBRegList[1].LOB_Name__c);
        lobNameSet.add(updateLOBRegList[2].LOB_Name__c);
        prefGtmPartnSet.add(updateLOBRegList[1].Preferred_GTM_Partner_Account__c);
        prefGtmPartnSet.add(updateLOBRegList[2].Preferred_GTM_Partner_Account__c);
        endUserSet.add(updateLOBRegList[1].Registered_End_User__c);
        endUserSet.add(updateLOBRegList[2].Registered_End_User__c);
        lobObjMap.put(updateLOBRegList[1].id,updateLOBRegList[1]);
        lobObjMap.put(updateLOBRegList[2].id,updateLOBRegList[2]);
        
        endUserAccountIdOldGroupMap.put(updateLOBRegList[1].Registered_End_User__c,updateLOBRegList[1].GTM_partner_group__c);
        endUserAccountIdOldGroupMap.put(updateLOBRegList[2].Registered_End_User__c,updateLOBRegList[2].GTM_partner_group__c);
        
        LOBRegistrationUtilities.addErrorMethod(lobNameSet,prefGtmPartnSet,endUserSet,lobObjMap);
        LOBRegistrationUtilities.deleteOldShares(lobObjMap,endUserAccountIdOldGroupMap,prefGtmPartnSet);
        }
   }
    
    //Test method to blank out the Preferred GTM Partner Account field depending on the LOB Reg. Status field
    static testMethod void testLOBRegStatusField() {
            RecordType rT = [SELECT SobjectType, Name, Id FROM RecordType  
                            WHERE  SobjectType = 'Account' and name = 'End-User Account'];
            RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                     WHERE  SobjectType = 'LOB_Registration__c' and name = 'LOB registration(Partner Approved)'];
            Account testEUAccount = new Account(Name='EU Test Account',Type = 'End User',
                                                Participating_in_LOB_Program__c = true,
                                                RecordTypeId = rT.Id);
            insert testEUAccount;
            Account testPartnerAccount = new Account(Name='Partner 01',Type = 'Partner');
            insert testPartnerAccount;
            testPartnerAccount.RecordTypeId= System.Label.RecType_Partner_Account;
            testPartnerAccount.IsPartner = true;
            testPartnerAccount.Is_GTM_Partner__c=true;
            update testPartnerAccount;
               //CRQ0241 reminder : uncomment after type change
            LOB_Registration__c lobObj=new LOB_Registration__c(RecordTypeId=recordType.id,LOB_Name__c='Client',
                                                               LOB_registration_status__c='Partner(approved)',
                                                               Preferred_GTM_Partner_Account__c=testPartnerAccount.id,
                                                               Registered_End_User__c=testEUAccount.id); 
            insert lobObj;
            lobObj.LOB_registration_status__c='Expired';
            lobObj.GTM_De_linkage_Reason__c='Need to change status';
            update lobObj;
            LOB_Registration__c lobRec = [SELECT Preferred_GTM_Partner_Account__c, Registered_End_User__c, Shared_to_GTM_Partner__c
                                          FROM LOB_Registration__c
                                          WHERE Registered_End_User__c=:testEUAccount.id];
            String prefGtmPartnerAccount = lobRec.Preferred_GTM_Partner_Account__c;
            boolean sharedToGtmPartner = lobRec.Shared_to_GTM_Partner__c;
            System.assertnotEquals(null,prefGtmPartnerAccount);
            System.assertEquals(false,sharedToGtmPartner);
            
    }
    
    
    //Test method for generating LOB Registration Objects
    static testMethod void testLOBRegRecordsGeneration() {
        System.RunAs(createUser())
        {
        Test.startTest();
        RecordType recTyp = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'Account' and name = 'End-User Account'];
        Map<Id,LOB_Registration__c> lobMap=new Map<Id,LOB_Registration__c>(); 
        List<LOB_Registration__c> listOfLobRecs=new List<LOB_Registration__c>();
        List<LOB_Registration__c> updateLOBRegList = new List<LOB_Registration__c>(); 
        List<String> pickList = new List<String>();
        List<String> activeLOBRegName = new List<String>();
        LOB_Registration__c lobObj = new LOB_Registration__c();
        Account testAccount = new Account(Name='Test Account 01',Type = 'End User',
                                          Participating_in_LOB_Program__c = true,
                                          RecordTypeId = recTyp.Id);
        insert testAccount;
        Account testPartnerAccount = new Account(Name='Partner Account Test 03',Type = 'Partner');
        insert testPartnerAccount;
        testPartnerAccount.RecordTypeId= System.Label.RecType_Partner_Account;
        testPartnerAccount.IsPartner = true;
        testPartnerAccount.Is_GTM_Partner__c=true;
        update testPartnerAccount;
        Account testPartnerAccount1 = new Account(Name='Partner Account Test 04',Type = 'Partner');
        insert testPartnerAccount1;
        testPartnerAccount1.RecordTypeId= System.Label.RecType_Partner_Account;
        testPartnerAccount1.IsPartner = true;
        testPartnerAccount1.Is_GTM_Partner__c=true;
        update testPartnerAccount1;
        Set<String> lobNameSet = new Set<String>();
        Set<String> prefGtmPartnSet = new Set<String>();
        Set<String> endUserSet = new Set<String>();
        Set<String> locationSet = new Set<String>();
        List<LOB_Registration__c> lobObjlist = new List<LOB_Registration__c>();
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'LOB_Registration__c' and name = 'LOB registration(Partner Approved)'];
        PageReference  pr=new PageReference('/apex/LOBRegistration?accid='+testAccount.id);
        Test.setCurrentPage(pr);
        LOBRegistrationController controller= new LOBRegistrationController(new ApexPages.StandardController(testAccount));
        
        PageReference  pageRefExpected=new PageReference('/'+testAccount.id);
        PageReference  pageRefActual=controller.generateLOBRegRecords();
        String expected=pageRefExpected.getUrl();
        String actual=pageRefActual.getUrl();
        System.assertEquals(expected,actual);
           //CRQ0241 reminder : uncomment after type change
        List<LOB_Registration__c> listOfLobRec = [SELECT Registered_End_User__c,
                                                LOB_Name__c,
                                                    LOB_registration_status__c,
                                                  Preferred_GTM_Partner_Account__c, RecordTypeId
                                                  FROM LOB_Registration__c 
                                                  WHERE Registered_End_User__c=:testAccount.Id];
         //CRQ0241: change reference to LOB_Name__c field 
        for(LOB_Administration__c activeLOBReg : [SELECT Name FROM LOB_Administration__c WHERE Active__c = true]){
                activeLOBRegName.add(activeLOBReg.Name);
        }
   /*     Schema.Describefieldresult F = LOB_Registration__c.LOB_Name__c.getDescribe();
        List<Schema.Picklistentry> P = F.getPicklistValues();
        PageReference pageReference = controller.generateLOBRegRecords();
        for(Schema.Picklistentry pickListValue : P){
            pickList.add(pickListValue.getLabel()); 
        }*/
        controller.createLOB(activeLOBRegName);
        System.assertEquals(activeLOBRegName.size(), listOfLobRec.size());
        activeLOBRegName.add('Test');
        if(activeLOBRegName.size() > listOfLobRec.size()){
            PageReference pageRefe = controller.generateLOBRegRecords();
            controller.createLOB(activeLOBRegName);
        } 
           //CRQ0241 reminder : uncomment after type change
        lobObj=new LOB_Registration__c(RecordTypeId=recordType.id,LOB_Name__c='Test1',
                                       LOB_registration_status__c='Rejected',
                                       //Preferred_GTM_Partner_Account__c=testPartnerAccount.id,
                                       Registered_End_User__c=testAccount.id);
        listOfLobRecs.add(lobObj);
           //CRQ0241 reminder : uncomment after type change
        lobObj=new LOB_Registration__c(RecordTypeId=recordType.id,LOB_Name__c='Test2',
                                       LOB_registration_status__c='Rejected',
                                      //Preferred_GTM_Partner_Account__c=testPartnerAccount1.Id,
                                       Registered_End_User__c=testAccount.id);
        listOfLobRecs.add(lobObj); 
        insert listOfLobRecs;  
        lobNameSet.add('Client');
        prefGtmPartnSet.add(testPartnerAccount.id);
        endUserSet.add(testAccount.id);
        locationSet.add('Abc');
        
        listOfLobRecs[0].LOB_registration_status__c='Partner(approved)';
        listOfLobRecs[0].Preferred_GTM_Partner_Account__c = testPartnerAccount.id;
        listOfLobRecs[1].LOB_registration_status__c='Partner(approved)';
        listOfLobRecs[1].Preferred_GTM_Partner_Account__c = testPartnerAccount1.id;
        updateLOBRegList.add(listOfLobRecs[0]);
        updateLOBRegList.add(listOfLobRecs[1]);
        update updateLOBRegList;
         updateLOBRegList=new List<LOB_Registration__c>();
         //listOfLobRecs[1].LOB_registration_status__c='Partner(approved)';
        listOfLobRecs[1].Preferred_GTM_Partner_Account__c = testPartnerAccount.id;
        updateLOBRegList.add(listOfLobRecs[1]);
        lobMap.put(listOfLobRecs[1].Id,listOfLobRecs[1]);
        PageReference pageRefe = controller.generateLOBRegRecords();
        
        //LOBRegistrationUtilities.preventDuplicateLOB(lobNameSet,endUserSet,listOfLobRecs, locationSet);
        LOBRegistrationUtilities.preventDuplicateLOB(listOfLobRecs);
        PageReference pagerefCtn=controller.continuePage();
        System.assertEquals(pageRefExpected.getUrl(),pagerefCtn.getUrl());
        Boolean noduplicate=controller.getnoDuplicates();
        Boolean noRecs=controller.getnoRecords();
        Boolean showTable=controller.getshowList();
        PageReference pageref=controller.back();
        Test.stopTest();
        System.assertEquals(pageRefExpected.getUrl(),pageref.getUrl());
        }
    }
    
    //Test method for deleting duplicate LOB records considering Account Share
    /*
    static testMethod void testLOBRegRecordsDeletion() {
        RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                 WHERE  SobjectType = 'LOB_Registration__c' and name = 'LOB registration(Partner Approved)'];
        LOB_Registration__c lobObj = new LOB_Registration__c();
        List<LOB_Registration__c> lobInsertList=new List<LOB_Registration__c>(); 
        Account testEUAccount = new Account(Name='EU Test Account',Type = 'End User');
        insert testEUAccount;
        Account testPartnerAccount = new Account(Name='Partner 03',Type = 'Partner');
        insert testPartnerAccount;
        testPartnerAccount.RecordTypeId= System.Label.RecType_Partner_Account;
        testPartnerAccount.IsPartner = true;
        testPartnerAccount.Is_GTM_Partner__c=true;
        update testPartnerAccount;
        Test.startTest();
        for(Integer i=0; i<1; i++){
            lobObj=new LOB_Registration__c(RecordTypeId=recordType.id,LOB_Name__c='Client',
                                           LOB_registration_status__c='Partner(approved)',
                                           Preferred_GTM_Partner_Account__c=testPartnerAccount.id,
                                           Registered_End_User__c=testEUAccount.id);
            lobInsertList.add(lobObj);                               
        }  
        insert lobInsertList;
        lobInsertList[0].LOB_registration_status__c='Expired';
        lobInsertList[0].GTM_De_linkage_Reason__c='Need to change status';
        update lobInsertList[0];
        
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM LOB_Registration__c WHERE Registered_End_User__c = :testEUAccount.id]);
        System.assertEquals(lobInsertList[0].id, [SELECT id FROM LOB_Registration__c WHERE Registered_End_User__c = :testEUAccount.id limit 1].id);
    }*/
}//End of Class