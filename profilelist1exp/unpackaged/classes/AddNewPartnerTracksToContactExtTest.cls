/* 
* Test Class logic related to AddNewPartnerTracksToContactExtension
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
*                                       27-Sep-2018     Sneha         Implement Test Data Factory
*                                    
*/
@isTest()
public class AddNewPartnerTracksToContactExtTest{
    static list<User> listUser;
    @testSetup static void prepareData() {
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Account> listAcc = TestDataFactory.createNAccount(1, 'Master Account');
        insert listAcc;
        List<User> listUsr = TestDataFactory.createNPortalUser(3);
        insert listUsr;
    }
    public static testMethod void addPartnerTracksTest(){  
        List<String> listsetConId = new List<String>();
        List<Contact> listCon = new List<Contact>();
        String strMasterGroupId;
        listUser = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Email like 'testcontact_%'];
        if(listUser.size() > 0){
            strMasterGroupId = String.valueOf(listUser[0].Contact.AccountId);
            for(User u :listUser){
                listsetConId.add(u.ContactId);
            }
            listCon = [SELECT Id,Name FROM Contact WHERE ID IN: listsetConId];
            Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
            insert trackObj;
            Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
            testPartnerTrackObj.Track_Id__c = trackObj.id;
            testPartnerTrackObj.Master_Group_Id__c = strMasterGroupId;
            testPartnerTrackObj.Partner_Track_Name__c= 'Test Partner Track Name';
            insert testPartnerTrackObj;
            Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
            testPartnerTrackObj2.Track_Id__c = trackObj.id;
            testPartnerTrackObj2.Master_Group_Id__c = strMasterGroupId;
            testPartnerTrackObj2.Partner_Track_Name__c= 'Test Partner Track Name 2';
            insert testPartnerTrackObj2;
            listCon[0].EligibleTracks__c = testPartnerTrackObj.Id+';'+testPartnerTrackObj2.Id;
            listCon[0].Audit_Track__c = testPartnerTrackObj.Id;
            listCon[0].Preferred_Track__c= testPartnerTrackObj.id;
            listCon[0].Selected_Track__c= testPartnerTrackObj.id;
            update listCon[0];
            System.assertEquals(testPartnerTrackObj.Master_Group_Id__c, strMasterGroupId);
            Test.starttest();
            PageReference pageRef = Page.AddNewPartnerTracksToContact;
            pageRef.getparameters().put('ConID',listCon[0].Id);
            pageRef.getparameters().put('PartnerTrack', 'true');
            pageRef.getparameters().put('AuditTrack', 'false');
            Test.setCurrentPage(pageRef);
            AddNewPartnerTracksToContactExtension pt = new  AddNewPartnerTracksToContactExtension();
            pt.getEligibleTracks();
            pt.selectTrack();
            pt.listleftselected.add(testPartnerTrackObj.id);
            pt.selectTrack();
            pt.getEligibleTracksSelected();
            pt.listrightselected.add(testPartnerTrackObj.id);
            pt.unselectTracks();
            pt.setEligibleTrackListIds();
            pt.savetracks();
            pt.cLoseTracks();
            test.stoptest();
        }
    }
    public static testMethod void addAuditTracksTest(){  
        List<String> listsetConId = new List<String>();
        List<Contact> listCon = new List<Contact>();
        String strMasterGroupId;
        listUser = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Email like 'testcontact_%'];
        if(listUser.size() > 0){
            strMasterGroupId = String.valueOf(listUser[0].Contact.AccountId);
            for(User u :listUser){
                listsetConId.add(u.ContactId);
            }
            listCon = [SELECT Id,Name FROM Contact WHERE ID IN: listsetConId];
            Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
            insert trackObj;
            Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
            testPartnerTrackObj.Track_Id__c = trackObj.id;
            testPartnerTrackObj.Master_Group_Id__c = strMasterGroupId;
            testPartnerTrackObj.Partner_Track_Name__c= 'Test Partner Track Name';
            insert testPartnerTrackObj;
            Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
            testPartnerTrackObj2.Track_Id__c = trackObj.id;
            testPartnerTrackObj2.Master_Group_Id__c = strMasterGroupId;
            testPartnerTrackObj2.Partner_Track_Name__c= 'Test Partner Track Name 2';
            insert testPartnerTrackObj2;
            listCon[0].EligibleTracks__c = testPartnerTrackObj.Id+';'+testPartnerTrackObj2.Id;
            listCon[0].Audit_Track__c = testPartnerTrackObj.Id;
            listCon[0].Preferred_Track__c= testPartnerTrackObj.id;
            listCon[0].Selected_Track__c= testPartnerTrackObj.id;
            update listCon[0];
            System.assertEquals(testPartnerTrackObj.Master_Group_Id__c, strMasterGroupId);
            Test.starttest();
            PageReference pageRef = Page.AddNewPartnerTracksToContact;
            pageRef.getparameters().put('ConID',listCon[0].Id);
            pageRef.getparameters().put('PartnerTrack', 'false');
            pageRef.getparameters().put('AuditTrack', 'true');
            Test.setCurrentPage(pageRef);
            AddNewPartnerTracksToContactExtension pt = new  AddNewPartnerTracksToContactExtension();
            pt.getEligibleTracks();
            pt.listleftselected.add(testPartnerTrackObj.id);
            pt.selectTrack();
            pt.getEligibleTracksSelected();
            pt.listrightselected.add(testPartnerTrackObj.id);
            pt.unselectTracks();
            pt.setEligibleTrackListIds();
            pt.savetracks();
            pt.cLoseTracks();
            test.stoptest();
        }
    }
}