@isTest
public class ManageAccessForSalesMotion_Test {
    @testSetup static void setup(){
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Master Account'); 
        insert listAccTdf;
        list<Account> listAccTdf1=TestDataFactory.createNAccount(6, 'Partner Account');
        insert listAccTdf1;
    }
    static testMethod void testgrantRevokeAccess(){
        TriggerExecutionController.setSkipAccountTriggers(true);
        list<Account> listAcc1=[SELECT ID,Master_Group_Affinity_Id__c FROM Account WHERE Recordtype.name='Master Account' LIMIT 1];
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc1[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc1[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc1[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc1[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj1;
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = listAcc1[0].id;
        testPartnerTrackObj2.Master_Group_Affinity_Id__c = listAcc1[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj2;
        list<Account> listAcc=[SELECT ID FROM Account WHERE Recordtype.name='Partner Account' LIMIT 6];
        listAcc[0].Partner_Track__c = testPartnerTrackObj2.id;
        listAcc[1].Master_Group_Id__c = listAcc1[0].id;
        listAcc[1].Partner_Track__c = testPartnerTrackObj.id;
        listAcc[2].Master_Group_Id__c = listAcc1[0].id;
        listAcc[2].Partner_Track__c = testPartnerTrackObj1.id;
        listAcc[3].Master_Group_Id__c = listAcc1[0].id;
        listAcc[3].Partner_Track__c = testPartnerTrackObj.id;
        listAcc[4].Partner_Track__c = testPartnerTrackObj.id;
        listAcc[4].Master_Group_Id__c = listAcc1[0].id;
        listAcc[5].Partner_Track__c = testPartnerTrackObj2.id;
        listAcc[5].Master_Group_Id__c = listAcc1[0].id;
        system.assertEquals(testPartnerTrackObj.Master_Group_Id__c,listAcc1[0].id);
        Test.startTest();
        TriggerExecutionController.setSkipAllTriggers(True);
        list<user> listUser=TestDataFactory.createNPortalUser(2);
        insert listUser;
        Map<String, List<String>> mapUsrToSM = new Map<String, List<String>>();
        List<String> listnewListString = new List<String>();
        for(Account accRecord : listAcc ){
            listnewListString .add(accRecord.Id);
        }
        mapUsrToSM.put(listUser[0].id,listnewListString ); 
        List<AccountShare> listtestAS = new List<AccountShare>();
        AccountShare acctS = new AccountShare();
        acctS.AccountId = listAcc[0].Id;
        acctS.UserOrGroupId = listUser[0].Id;
        acctS.AccountAccessLevel = 'Read';
        acctS.OpportunityAccessLevel = 'None';
        acctS.RowCause='Manual';
        listtestAS.add(acctS);
        AccountShare acctS1 = new AccountShare();
        acctS1.AccountId = listAcc[1].Id;
        acctS1.UserOrGroupId = listUser[0].Id;
        acctS1.AccountAccessLevel = 'Read';
        acctS1.OpportunityAccessLevel = 'None';
        acctS1.RowCause='Manual';
        listtestAS.add(acctS1);
        insert listtestAS ;
        system.debug('listtestAS !!!'+listtestAS );
        ManageAccessForSalesMotion obj = new ManageAccessForSalesMotion(mapUsrToSM,'GRANT');
        DataBase.executeBatch(obj);
        ManageAccessForSalesMotion obj1 = new ManageAccessForSalesMotion(mapUsrToSM,'Revoke');
        DataBase.executeBatch(obj1);
        Test.stopTest();
    }
}