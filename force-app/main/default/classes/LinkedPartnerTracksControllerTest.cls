/* 
* Test Class logic related to LinkedPartnerTracksControllerTest
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
*                                       26-Sep-2018     Sneha         Implement Test Data Factory
*                                    
*/
@isTest()
public class LinkedPartnerTracksControllerTest{
    static list<User> listUser;
    @testSetup static void prepareData() {
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Account> listAcc = TestDataFactory.createNAccount(1, 'Master Account');
        insert listAcc;
        List<User> listUsr = TestDataFactory.createNPortalUser(3);
        insert listUsr;
    }
    public static testMethod void linkedPartnerTest(){
        List<String> listsetConId = new List<String>();
        List<Contact> listCon = new List<Contact>();
        String strMasterGroupId;
        listUser = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Email like 'testcontact_%'];
        if(listUser.size() > 0){
            strMasterGroupId = String.valueOf(listUser[0].Contact.AccountId);
            for(User u :listUser){
                listsetConID.add(u.ContactId);
            }
            listCon = [SELECT Id,Name FROM Contact WHERE ID IN: listsetConID];
            Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
            insert trackObj;
            Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
            testPartnerTrackObj.Track_Id__c = trackObj.id;
            testPartnerTrackObj.Master_Group_Id__c = strMasterGroupId;
            insert testPartnerTrackObj;
            listCon[0].EligibleTracks__c = testPartnerTrackObj.Id;
            listCon[0].Audit_Track__c = testPartnerTrackObj.Id;
            update listCon[0];
        }
        Test.startTest();
        System.assertEquals(3, listCon.size());
        PageReference pageRef = Page.LinkedPartnerTracks;
        pageRef.getparameters().put('recordId', listCon[0].Id);
        Test.setCurrentPage(pageRef);
        Apexpages.StandardController sc = new Apexpages.StandardController(listCon[0]);
        LinkedPartnerTracksController ext = new  LinkedPartnerTracksController(sc);
        ext.getTable();
        ext.showall();
        ext.FirstPage();
        ext.next();
        ext.LastPage();
        ext.getprev();
        ext.previous();
        ext.getnxt();
        ext.addAuditTracks();
        ext.addTrack();        
        Test.stopTest();
    }
}