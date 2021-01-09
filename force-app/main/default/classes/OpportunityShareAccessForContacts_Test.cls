/************************************************************
* 
* Name          : OpportunityShareAccessForContacts_Test 
* Description   : Test class to "OpportunityShareAccessForContacts" 
* ----------------------------------------------------------
* Revision  Name            Date                 CR                                         
* 1.0       Uday         06.09.2017
* 2.0       Emily        08.01.2019              CR 16970 - Remove virtualization__c                                       
************************************************************/
@isTest
public class OpportunityShareAccessForContacts_Test {
    public static list<Account> listAcc;
    public static list<Opportunity> listOpp;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(True);
        list<Account> listAccTdf=TestDataFactory.createNAccount(5, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(4, 'Deal Registration');
        insert listOppTdf;
    }
    
    public static testMethod void orderSuport() {
        TriggerExecutionController.setSkipAccountTriggers(True);
        TriggerExecutionController.setSkipContactTriggers(True);
        TriggerExecutionController.setSkipOpportunityTriggers(True);
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        listAcc=[SELECT ID FROM Account LIMIT 2];
        listAcc[0].type='End User';
        listAcc[1].type='End User';
        listAcc[1].Master_Group_Id__c=listAcc[0].id;
        update listAcc;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[1].id;
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[0].id;
        insert testPartnerTrackObj1;
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = listAcc[0].id;
        insert testPartnerTrackObj2;
        
        Contact testContact = new Contact(FirstName='first', LastName='last', Phone='044223667788', EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';',
                                          Email='s@s.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                          Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,Have_Dealtype_Access__c='plan 1%',
                                          AccountId= listAcc[1].id);
        insert testContact;
        
        listOpp=[SELECT ID FROM Opportunity LIMIT 1];
        listOpp[0].AccountId=listAcc[1].id;
        update listOpp;
        list<String> listids = new list<String>();
        listids.add(listOpp[0].id);
        system.assertNotEquals(listOpp[0].id, null);
        OpportunityShareAccessForContacts.getAccountNames(listids);
        ApexPages.StandardController standardController = new ApexPages.StandardController(testContact);
        
        
        ApexPages.Currentpage().getParameters().put('access','show');
        
        OpportunityShareAccessForContacts os  = new OpportunityShareAccessForContacts(standardController);
        os.selectedtrack = testPartnerTrackObj1.id;
        os.selectedAccount = listAcc[1].id;
        try{
            os.processRequest();
            os.removealrt();
            os.RemoveAccess();
        }catch(Exception ex){}
        
        try{
            os.getPieData();
        }catch(Exception ex){}
        try{
            os.getChangeData();
        }catch(Exception ex){}
        try{
            os.goBack();
        }catch(Exception ex){}
        try{
            os.getAccounts();
        }catch(Exception ex){}
        try{
            os.getPartnerTrackList();
        }catch(Exception ex){}
        try{
            os.conoppstages();
        }catch(Exception ex){}
        
        ApexPages.Currentpage().getParameters().put('access','remove');
        
        try{
            os.processRequest();
        }catch(Exception ex){}
        
        UserDealAccess us = new UserDealAccess('show',new Contact(),new user(),new list<String>(),'ASYNC',listAcc[1].id);
        try{
            
            us.shareAccess(new Contact(),new user(),new list<String>(),'SYNC',listAcc[1].id );
        }catch(Exception ex){}
        
        try{
            
            us.removeAccess(new user(),new Contact(),listAcc[1].id);
        }catch(Exception ex){}
        
        
        try{
            
            us.execute(null);
        }catch(Exception ex){}
        
    }
    
    public static testMethod void testShowAccess() {
        TriggerExecutionController.setSkipAccountTriggers(True);
        TriggerExecutionController.setSkipContactTriggers(True);
        TriggerExecutionController.setSkipOpportunityTriggers(True);
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[SELECT ID,Account_ID__c FROM Account LIMIT 5];
        listAcc[0].RecordTypeId=TestDataFactory.getRecordTypeIdbyName('Master Account', 'Account');
        listAcc[0].Master_Group_Affinity_ID__c='MGAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        update listAcc;
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        //Partner Request insertion
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj.partner_Track_affinityId__c = '1232'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj.Partner_Registration_Number__c = '';
        testPartnerTrackObj.Primary_SMAffinity_Account__c = listAcc[1].Id;
        
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj1.partner_Track_affinityId__c = '1252'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj1.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj1.Primary_SMAffinity_Account__c = listAcc[1].Id;
        
        insert testPartnerTrackObj1;
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data2';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj2.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj2.partner_Track_affinityId__c = '1242'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj2.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj2.Primary_SMAffinity_Account__c = listAcc[1].Id;
        
        insert testPartnerTrackObj2;
        
        List<Account> listAccToUpdate = new List<Account>();
        
        Account acc4 = listAcc.get(0);
        Account acc5 = listAcc.get(1);
        Account acc6 = listAcc.get(2);
        Account acc7 = listAcc.get(3);
        Account acc8 = listAcc.get(4);
        
        acc5.Master_Group_Id__c = listAcc[0].id;
        acc5.IsPartner = true;
        acc5.Partner_Track__c  = testPartnerTrackObj.id;
        listAccToUpdate.add(acc5);
        
        acc6.Master_Group_Id__c = listAcc[0].id;
        acc6.Partner_Track__c  = testPartnerTrackObj1.id;
        acc6.IsPartner = true;
        listAccToUpdate.add(acc6);
        
        acc7.Master_Group_Id__c = listAcc[0].id;
        acc7.Partner_Track__c  = testPartnerTrackObj2.id;
        acc7.IsPartner = true;
        listAccToUpdate.add(acc7);
        
        acc8.Master_Group_Id__c = listAcc[0].id;
        acc8.IsPartner = true;
        acc8.Partner_Track__c  = testPartnerTrackObj2.id;
        listAccToUpdate.add(acc8);
        update listAccToUpdate;
        
        Contact testContact = new Contact(FirstName='first', LastName='last'+string.valueof(Math.abs(Crypto.getRandomInteger())), Phone='044223667788', 
                                          Email='s22@s12.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                          Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                          AccountId= listAcc[0].id, Preferred_Track__c = testPartnerTrackObj.id,EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj2.id + ';'+testPartnerTrackObj1);
        insert testContact;
        
        listOpp=[SELECT ID FROM Opportunity LIMIT 4];
        for(Opportunity opp : listOpp){
            opp.Partneraccountid=listAcc[2].id;
        }
        update listOpp;
        system.assertNotEquals(listOpp[0].id, null);
        list<User> listusr=TestDataFactory.createNPortalUser(1);
        listusr[0].contactId = testContact.id;
        insert listusr;
        
        List<ContactOpportunityStages__c> listConStage = new List<ContactOpportunityStages__c>();
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(testContact);
        ApexPages.Currentpage().getParameters().put('access','show');
        test.startTest();
        OpportunityShareAccessForContacts os  = new OpportunityShareAccessForContacts(standardController);
        
        try{
            os.selectedtrack = testPartnerTrackObj1.id;
            os.getAccounts();
            os.SelectedAccount = listAcc[2].id;
            os.getPieData();
            ContactOpportunityStages__c conStage1 = new ContactOpportunityStages__c();
            conStage1.SalesmotionAccount__c = listAcc[2].id ;
            conStage1.Contact__c = testContact.Id;
            conStage1.Opportunity_Stage__c = 'Propose - 60%';
            listConStage.add(conStage1);
            insert listConStage;
            os.conoppstages();
            os.conopplist.Opportunity_Stage__c = 'Plan - 1% ;Propose - 60%';
            os.getChangeData();
            os.conopplist.Opportunity_Stage__c = 'Plan - 1% ;Propose - 60%';
            test.stopTest();
            List<String> listopptyStage = os.conopplist.Opportunity_Stage__c.split(';');
            testContact.Partner_User__c =listusr.get(0).Id;
            update testContact;
            Account acc11 = listAcc.get(2);
            
            UserDealAccess usm = new UserDealAccess('show',testContact,listusr[0],listopptyStage,'ASYNC',acc11.id);
            system.debug('param1:'+testContact);
            system.debug('param2:'+listusr[0]);
            system.debug('param3:'+listopptyStage);
            system.debug('param4:'+acc11);
            usm.shareAccess(testContact,listusr[0],listopptyStage,'SYNC',acc11.id);
        } 
        catch(Exception ex){}}
    
    public static testMethod void testRemoveAccess() {
        TriggerExecutionController.setSkipAccountTriggers(True);
        TriggerExecutionController.setSkipContactTriggers(True);
        TriggerExecutionController.setSkipOpportunityTriggers(True);
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Account> listAcc = new List<Account>();
        
        listAcc=[SELECT ID,Account_ID__c FROM Account LIMIT 5];
        listAcc[0].RecordTypeId=TestDataFactory.getRecordTypeIdbyName('Master Account', 'Account');
        listAcc[0].Master_Group_Affinity_ID__c='MGAff1212'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        update listAcc; 
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        
        //Partner Request insertion
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj.partner_Track_affinityId__c = '1232'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj.Partner_Registration_Number__c = '';
        testPartnerTrackObj.Primary_SMAffinity_Account__c = listAcc[1].Id;
        
        insert testPartnerTrackObj;
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj1.partner_Track_affinityId__c = '1252'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj1.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj1.Primary_SMAffinity_Account__c = listAcc[1].Id;
        
        insert testPartnerTrackObj1;
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data2';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj2.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_ID__c;
        testPartnerTrackObj2.partner_Track_affinityId__c = '1242'+string.valueof(Math.abs(Crypto.getRandomInteger()));
        testPartnerTrackObj2.Primary_Sales_Motion_Affinity_ID__c=listAcc[1].Account_ID__c;
        testPartnerTrackObj2.Primary_SMAffinity_Account__c = listAcc[1].Id;
        
        insert testPartnerTrackObj2;
        
        List<Account> listAccToUpdate = new List<Account>();
        
        Account acc4 = listAcc.get(0);
        Account acc5 = listAcc.get(1);
        Account acc6 = listAcc.get(2);
        Account acc7 = listAcc.get(3);
        Account acc8 = listAcc.get(4);
        
        acc5.Master_Group_Id__c = listAcc[0].id;
        acc5.IsPartner = true;
        acc5.Partner_Track__c  = testPartnerTrackObj.id;
        listAccToUpdate.add(acc5);
        
        acc6.Master_Group_Id__c = listAcc[0].id;
        acc6.Partner_Track__c  = testPartnerTrackObj1.id;
        acc6.IsPartner = true;
        listAccToUpdate.add(acc6);
        
        acc7.Master_Group_Id__c = listAcc[0].id;
        acc7.Partner_Track__c  = testPartnerTrackObj2.id;
        acc7.IsPartner = true;
        listAccToUpdate.add(acc7);
        
        acc8.Master_Group_Id__c = listAcc[0].id;
        acc8.IsPartner = true;
        acc8.Partner_Track__c  = testPartnerTrackObj2.id;
        listAccToUpdate.add(acc8);
        update listAccToUpdate;
        
        Contact testContact = new Contact(FirstName='first', LastName='last'+string.valueof(Math.abs(Crypto.getRandomInteger())), Phone='044223667788', 
                                          Email='s22@s12.com',Decision_Making_Role__c='Influencer', Job_Function__c='Finance',
                                          Job_Function_Role__c='Finance Manager', Primary_Contact__c=false,
                                          AccountId= listAcc[0].id, EligibleTracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj2.id + ';'+testPartnerTrackObj1);
        insert testContact;
        
        listOpp=[SELECT ID FROM Opportunity LIMIT 4];
        listOpp[0].Partneraccountid=listAcc[1].id;
        listOpp[1].Partneraccountid=listAcc[2].id;
        listOpp[2].Partneraccountid=listAcc[3].id;
        listOpp[3].Partneraccountid=listAcc[4].id;
        update listOpp;
        System.assertNotEquals(null, listOpp[0].Id);
        list<String> listids = new list<String>();
        listids.add(listOpp[0].id);
        
        list<User> listusr=TestDataFactory.createNPortalUser(1);
        listusr[0].contactId = testContact.id;
        insert listusr;
        
        OpportunityShareAccessForContacts.getAccountNames(listids);
        
        List<OpportunityShare> listOS = new List<OpportunityShare>();
        
        // Build the account share
        OpportunityShare opptyShare = new OpportunityShare();
        opptyShare.OpportunityId = listOpp[0].Id;
        opptyShare.UserOrGroupId = listusr[0].Id;  
        opptyShare.OpportunityAccessLevel = 'Read';
        listOS.add(opptyShare);
        
        OpportunityShare opptyShare1 = new OpportunityShare();
        opptyShare1.OpportunityId = listOpp[1].Id;
        opptyShare1.UserOrGroupId = listusr[0].Id;  
        opptyShare1.OpportunityAccessLevel = 'Read';
        listOS.add(opptyShare1);
        
        OpportunityShare opptyShare2 = new OpportunityShare();
        opptyShare2.OpportunityId = listOpp[2].Id;
        opptyShare2.UserOrGroupId = listusr[0].Id;  
        opptyShare2.OpportunityAccessLevel = 'Read';
        listOS.add(opptyShare2);
        
        OpportunityShare opptyShare3 = new OpportunityShare();
        opptyShare3.OpportunityId = listOpp[3].Id;
        opptyShare3.UserOrGroupId = listusr[0].Id;  
        opptyShare3.OpportunityAccessLevel = 'Read';
        listOS.add(opptyShare3);
        
        insert listOS;
        system.debug('testAS!!!'+listOS); 
        
        List<ContactOpportunityStages__c> listConStage = new List<ContactOpportunityStages__c>();
        
        ContactOpportunityStages__c conStage1 = new ContactOpportunityStages__c();
        conStage1.SalesmotionAccount__c = listAcc[4].id ;
        conStage1.Contact__c = testContact.Id;
        conStage1.Opportunity_Stage__c = 'Propose - 60%';
        listConStage.add(conStage1);
        
        insert listConStage;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(testContact);
        ApexPages.Currentpage().getParameters().put('access','remove');
        test.startTest();
        OpportunityShareAccessForContacts os  = new OpportunityShareAccessForContacts(standardController);
        os.dealTypes.add('Propose - 60%');
        os.dealTypes.add('Plan - 1%');
        try{
            os.selectedtrack = testPartnerTrackObj2.id;
            os.getAccounts();
            os.SelectedAccount = listAcc[4].id;
            os.conoppstages();
            os.getPieData();
            os.getChangeData();
            os.dealTypes.add('Plan - 1%');
            os.processRequest();
            os.getChangeData();
            os.removealrt();
            os.RemoveAccess();
            UserDealAccess us = new UserDealAccess('remove',new Contact(),new user(),new list<String>(),'ASYNC',listAcc[4].id);
            try{ 
                us.removeAccess(listusr[0],testContact,listAcc[4].id);
                us.updateContact(testContact);
                test.stopTest();
            }
            catch(Exception ex){}
        } 
        catch(Exception ex){}
    }
}