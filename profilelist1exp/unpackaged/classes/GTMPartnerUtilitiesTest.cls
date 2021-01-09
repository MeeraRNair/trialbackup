/*
2.0     10-Jan-2011     Krishna         CR 6887(Emergency): Changed the Partner role selection from Partner Executive to Partner User
                                            -Changed the Group Type as Role from RoleAndSubordinates
                                            -Renamed variable name from partnerExecRoleIdSet to partnerUserRoleIdSet
                                            */

@isTest
private class GTMPartnerUtilitiesTest{
 /*  
   
   static testMethod void testGTMPartnerAssignment(){
        List<Profile> partnerProfiles=[select id,name from Profile where UserType = 'PowerPartner' 
                                        and  name like 'R11.7%'];
        List<Account> accounts = new List<Account>();
        List<Account> endUserAccounts = new List<Account>();
        List<Account> updateAccountList;
        List<Contact> contacts = new List<Contact>();
        List<User> users = new List<User>();
        Set<Id> idset=new Set<Id>(); 
        Set<Id> AccountIdset=new Set<Id>();
        Set<Id> gtmAccntIdset=new Set<Id>();
        Set<Id> partnerUserRoleIdSet=new Set<Id>();
        Set<Id> groupIdSet=new Set<Id>();
        Date expirydate = Date.newInstance(2010,09,29);
        List<AccountShare> accountshareList=new List<AccountShare>();
        
        Map<id,group> groupMap=new Map<id,group>(); 
        Map<id,Account> endUserAccountMap=new Map<id,Account>();
        
        Account accountObject=new Account();
        
        for(integer i=0;i<5;i++){
            Account accountObj=new Account(
                name='TestAccount'+i,
                Account_Country_Code__c = 'AI',
                Account_Country__c = 'ANGUILIA'
            ); 
            accounts.add(accountObj);
        }
        
        insert accounts;
        
        for(Account account:accounts){
            account.IsPartner = true;
            account.Is_GTM_Partner__c=true;
            account.RecordTypeId= System.Label.RecType_Partner_Account;
        }
        
        update accounts;
        
        for(Integer i = 0; i <5; i++){
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
        
        for(Integer i = 0; i < 5; i++){
            //Integer userNumber = getNextUserSerialNumber();
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
        
        for(Integer i = 0; i < accounts.size(); i++){
        
            Account accountObj=new Account(
                name='TestAccount'+i,
                Account_Country_Code__c = 'AI',
                Account_Country__c = 'ANGUILIA'
                            ); 
            
            endUserAccounts.add(accountObj);
            
        }
        
        insert endUserAccounts;
        
        
        updateAccountList=new List<account>();
        
        for(Integer i = 0; i < accounts.size(); i++){
            endUserAccounts[i].Preferred_GTM_Partner_Account__c=accounts[i].id;
            endUserAccounts[i].GTM_Linkage_Expiry_Date__c=expirydate;
                updateAccountList.add(endUserAccounts[i]);
        }
        update updateAccountList;
        
        
        for(account accountElt:endUserAccounts){
                idset.add(accountElt.id);
                endUserAccountMap.put(accountElt.id,accountElt);
        }
        
        for(account accountElt:accounts){
                gtmAccntIdset.add(accountElt.id);
        }
        
         
        
        for(UserRole userRoleObject:[Select  PortalAccountId,Name,Id
                                    From UserRole  where  
                                    name like '%Partner User'
                                    and PortalAccountId in:gtmAccntIdset
                                    order by PortalAccountId]){
            partnerUserRoleIdSet.add(userRoleObject.Id); 
        }
        
        for(Group groupElement:[Select Type, RelatedId,Name,
                            Id From Group where 
                            Type='Role' and RelatedId in:partnerUserRoleIdSet
                            order by RelatedId]){       
                groupMap.put(groupElement.RelatedId,groupElement); 
                groupIdSet.add(groupElement.id);                
        } 
        System.debug('###endUserAccounts size'+endUserAccounts.size());

        System.debug('###endUserAccounts'+endUserAccounts);
              Integer i=0;                                    
        for(AccountShare accountShareElt:[Select UserOrGroupId,Id, AccountId From AccountShare 
                                                where UserOrGroupId in:groupIdSet 
                                                and AccountId in :idset order by AccountId]){
                                              
            Account accountElt=endUserAccountMap.get(accountShareElt.AccountId);
                    if(accountShareElt.UserOrGroupId==accountElt.GTM_partner_group__c){
                        System.assertEquals(accountShareElt.UserOrGroupId, accountElt.GTM_partner_group__c);
                        System.assertEquals(true, accountElt.Shared_to_GTM_Partner__c);
                        System.debug('###accountElt'+'i'+i+' :-->   '+accountElt);
                    }
                    i++;
                    
                    System.debug('###accountShareElt'+'i'+i+' :-->   '+accountShareElt);
        }
        
        updateAccountList=new List<account>();
        
        endUserAccounts[0].GTM_Linkage_Expiry_Date__c=System.Today()+1;
        endUserAccounts[1].Preferred_GTM_Partner_Account__c=accounts[1].id;
        endUserAccounts[2].Preferred_GTM_Partner_Account__c=null;
        endUserAccounts[2].GTM_De_linkage_Reason__c='test';
        endUserAccounts[3].Preferred_GTM_Partner_Account__c=accounts[1].id;
        endUserAccounts[4].Preferred_GTM_Partner_Account__c=null;
        endUserAccounts[4].GTM_De_linkage_Reason__c='test';
        updateAccountList.add(endUserAccounts[0]);
        updateAccountList.add(endUserAccounts[1]);
        updateAccountList.add(endUserAccounts[2]);
        updateAccountList.add(endUserAccounts[3]);
        updateAccountList.add(endUserAccounts[4]);

        update updateAccountList;
        
        Map<id,Account> accountMapFromDB=new Map<id,Account>();
        
        
        
                
        for(Account accountElt:[select id,GTM_partner_group__c,Shared_to_GTM_Partner__c,
        GTM_Linkage_Expiry_Date__c,Preferred_GTM_Partner_Account__c,GTM_De_linkage_Reason__c from account 
        where id in:idset]){
            accountMapFromDB.put(accountElt.id,accountElt);
            if(accountElt.id==endUserAccounts[2].id){
                 //accountObject=endUserAccountMap.get(endUserAccounts[2].id);
                System.assertEquals(null,accountElt.GTM_partner_group__c);
                System.assertEquals(false,accountElt.Shared_to_GTM_Partner__c);
   
            }
            
            if(accountElt.id==endUserAccounts[4].id){
                 //accountObject=endUserAccountMap.get(endUserAccounts[2].id);
                System.assertEquals(null, accountElt.GTM_partner_group__c);
                System.assertEquals(false, accountElt.Shared_to_GTM_Partner__c);
   
            }
           if(accountElt.id==endUserAccounts[0].id && System.Today()==endUserAccounts[0].GTM_Linkage_Expiry_Date__c){ 
            accountObject=endUserAccountMap.get(endUserAccounts[0].id);
            System.assertEquals(null,accountElt.GTM_partner_group__c);
            System.assertEquals(false,accountElt.Shared_to_GTM_Partner__c);
            System.assertEquals(null,accountElt.GTM_Linkage_Expiry_Date__c);
            System.assertEquals(null,accountElt.Preferred_GTM_Partner_Account__c);
            System.assertEquals('['+accounts[0].Id+' '+ System.Today()+']'+'expired',accountElt.GTM_De_linkage_Reason__c);
         }

        }
        
        for(AccountShare accountShareElt:[Select UserOrGroupId,Id, AccountId From AccountShare 
                                                where UserOrGroupId in:groupIdSet 
                                                and AccountId in :idset order by AccountId]){
                                                
            Account accountElt=accountMapFromDB.get(accountShareElt.AccountId);
                    if(accountElt.Id==endUserAccounts[1].id){
                        //System.debug();
                        System.assertEquals(accountShareElt.UserOrGroupId, accountElt.GTM_partner_group__c);
                        System.assertEquals(true, accountElt.Shared_to_GTM_Partner__c);
                    }
                     if(accountElt.Id==endUserAccounts[3].id){
                        //System.debug();
                        System.assertEquals(accountShareElt.UserOrGroupId, accountElt.GTM_partner_group__c);
                        System.assertEquals(true, accountElt.Shared_to_GTM_Partner__c);
                    }

        }

     
        
        
        
   }
   */
}