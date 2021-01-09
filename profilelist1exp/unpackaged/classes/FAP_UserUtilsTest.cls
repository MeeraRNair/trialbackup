/* ============================================================
* Find a Partner Utility Class
* ============================================================
* Version    Author          Date               Description
-------    ------          ----               -------------        
1.0        venu           6-dec-2019          Implimented TestDataFactory   
*/

@IsTest
private class FAP_UserUtilsTest {
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Account> listAccTdf1=TestDataFactory.createNAccount(1, 'Master Account');
        insert listAccTdf1;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    private static testmethod void testFAPWelcomeEmail(){
        TriggerExecutionController.setSkipAllTriggers(true);
        FAP_UserUtils.isCurrentUserSysAdmin();
        System.assertEquals(true,FAP_UserUtils.isCurrentUserSysAdmin());        
        System.assertEquals(false,FAP_UserUtils.isCurrentUserPortalUser());
        test.startTest();
        List<Partner_Track__c> listPTAccount = new List<Partner_Track__c>();
        List<Id> listPTAccountIds = new List<Id>();
        List<Account> listSMA = new List<Account>();
        List<User> listpartnerUser = new List<User>();
        List<Contact> listCont = new List<Contact>();
        Set<Id> setPT = new Set<Id>();
        
        System_Behavior_Bypasser__c bypass = System_Behavior_Bypasser__c.getOrgDefaults();
        Profile partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' and name like '%NA PRM%' order by CreatedDate DESC limit 1];
        bypass.Bypass_Account_PBs__c = true; 
        ProcessFlowTriggerController.isTest = true;
        list<Account> listAcc=[Select id,Master_Group_Affinity_Id__c from Account where Recordtype.name='Master Account'];
        listAcc[0].type='Master Group';
        listAcc[0].OwnerId = UserInfo.getUserId();
        update listAcc;
        
        Partner_Track__c pt=new Partner_Track__c();
        pt.Partner_Track__c='PT';
        pt.Master_Group_Id__c = listAcc[0].id;
        pt.Master_Group_Affinity_Id__c=listAcc[0].Master_Group_Affinity_Id__c;
        insert pt;
        listPTAccount.add(pt);
        
        list<Account> listAcc1=[Select id from Account where Recordtype.name='Partner Account'];
        listAcc1[0].type='Partner';
        listAcc1[0].Master_Group_Id__c=listAcc[0].id;
        listAcc1[0].Partner_Track__c = pt.id;
        listAcc1[0].OwnerId = UserInfo.getUserId();
        update listAcc1;
        listSMA.add(listAcc1[0]);
        setPT.add(listPTAccount[0].id);
        Contact cont = new Contact(FirstName='TestContact1', 
                                   LastName='TestContactlast1'+system.now().millisecond(), 
                                   accountId=listAcc[0].Id,
                                   Email='TestCon1_@ust-global.com', 
                                   fax='01987645',
                                   MobilePhone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond(),
                                   Status__c = 'Marketing Suspect',
                                   Selected_Track__c = listPTAccount[0].id,  
                                   EligibleTracks__c = listPTAccount[0].id,              
                                   Phone= String.valueOf(Math.round(Math.random()*1000)) + '00' +system.now().millisecond()); 
        listCont.add(cont);
        insert listCont;
        list<user> listUser=TestDataFactory.createNPortalUser(1);
        listUser[0].ProfileId = partnerProfiles.Id;
        listUser[0].ContactId = listCont[0].id;
        listUser[0].PortalRole = 'Manager';
        listUser[0].Enable_Partner_Admin__c = true;
        listUser[0].Is_Admin_for_Partner_Finder_Profile__c = true;
        insert listUser;
        listpartnerUser.add(listUser[0]);
        for(integer intPU = 0; intPU<listpartnerUser.size(); intPU++){  
            if(listpartnerUser[intPU].contactId != null){
                listCont[intPU].Partner_User__c = listpartnerUser[intPU].id;
            }
        }
        update listCont;
        for(integer intPT= 0; intPT<listPTAccount.size(); intPT++){  
            listPTAccountIds.add(listPTAccount[intPT].id);
        }
        TriggerExecutionController.setSkipAllTriggers(false); 
        ProcessFlowTriggerController.isTest = false;
        bypass.Bypass_Account_PBs__c = false;
        FAP_UserUtils.SendEmailToPartnerAdmin(listPTAccountIds);
        test.stopTest();
    }
}