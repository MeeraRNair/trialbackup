@isTest
public class ManageUsersCtrlTest{
    
    private static Integer intNextUserSerialNumber = -1;
    private static Integer getNextUserSerialNumber(){
        intNextUserSerialNumber++;
        return intNextUserSerialNumber;
    }

    private static testMethod void contactAdminWithPartnerTracksInactive(){
        
        TriggerExecutionController.setSkipUserTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
       // list<User> listCreateUserPartnerAdminInactive = createPartnerInactiveUsers(false,2,null);
        list<User> listUser=TestDataFactory.createNPortalUser(1);
  listUser[0].Enable_as_Partner_Group_Administrator__c=false;
        listUser[0].Enable_Partner_Admin__c=true;
        listUser[0].Enable_As_Partner_Lead_Super_User__c=false;
        listUser[0].Enable_Partner_Deal_Registration__c=false;
         listUser[0].Enable_Partner_Lead_Management__c=false;
       //  listUser[0].IsActive = false;
                insert listUser;
        Id accId= [select id,accountid from contact where id=:listUser[0].contactId].accountid;
        account accmid=[select Master_Group_Affinity_Id__c from account Where Id=:accId Limit 1];
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        system.debug('trackObj*****'+trackObj); 
        
        //system.debug('UserRec:'+listCreateUserPartnerAdminInactive[0]+'AccRec:'+accId+'UserIsActive:'+listCreateUserPartnerAdminInactive[0].IsActive);
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = accId;
                testPartnerTrackObj.Master_Group_Affinity_Id__c=accmid.Master_Group_Affinity_Id__c;

        testPartnerTrackObj.Partner_Track_Name__c = 'TestTrack';
        insert testPartnerTrackObj;
        system.assertEquals(testPartnerTrackObj.Master_Group_Id__c, accId);
        System.runAs(listUser[0]){
            test.startTest(); 
            ManageUsersCtrl testConAdminInactive = new ManageUsersCtrl();
            testConAdminInactive.contactSetup();
            testConAdminInactive.bContactSelError= false;
            testConAdminInactive.bContactSelSuccess= false;
            testConAdminInactive.bContactInactiveError= false;
            testConAdminInactive.strOfLastName = '';
            testConAdminInactive.strOfContactStatus= '';
            testConAdminInactive.strOfSelTrackAdmin= '';
            testConAdminInactive.first();
            testConAdminInactive.last();
            testConAdminInactive.getTotalPages();
            testConAdminInactive.bhasNext=true;
            testConAdminInactive.bhasPrevious=true;
            
            ApexPages.currentPage().getParameters().put('saveContactConId',listUser[0].contactId);
            ApexPages.currentPage().getParameters().put('strOfSaveContactId',listUser[0].contactId);
            ApexPages.currentPage().getParameters().put('ToolAccessForAction','listUser[0].Partner_User_Deal_Registration__c,listUser[0].Enable_Partner_Lead_Management__c,listUser[0].Partner_User_Lead_Super_User__c,listUser[0].Enable_User_for_MyRewards__c,listUser[0].OSC_Create_Quote__c,listUser[0].OSC_Create_Quote__c,listUser[0].OSC_Specialty_Product_Create_Quote__c,listUser[0].OSC_Specialty_Product_Create_Order__c');
            
            try{
                testConAdminInactive.toolAccessAddRemoveAction();}catch(exception e){}
            testConAdminInactive.strOfSaveToolAccessForAction = 'listUser[0].Partner_User_Deal_Registration__c,listUser[0].Partner_User_Lead_Management__c,listUser[0].Partner_User_Lead_Super_User__c,listUser[0].Enable_User_for_MyRewards__c,listUser[0].OSC_Create_Quote__c,listUser[0].OSC_Create_Quote__c,listUser[0].OSC_Specialty_Product_Create_Quote__c,listUser[0].OSC_Specialty_Product_Create_Order__c';
            try{
                testConAdminInactive.partnerTracksAddRemoveAction();}catch(exception e){}
            
            testConAdminInactive.allActionLogic();
           // testConAdminInactive.exportAction();
           // testConAdminInactive.exportActionAll();
            
            test.stopTest();
            
            TriggerExecutionController.setSkipUserTriggers(false);
            TriggerExecutionController.setSkipAccountTriggers(false);
            TriggerExecutionController.setSkipContactTriggers(false);
        }
    }  
    private static testMethod void contactAdminWithPartnerTracks(){
        
        TriggerExecutionController.setSkipUserTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        list<User> listUser=TestDataFactory.createNPortalUser(1);
        insert listUser;
        system.debug('listUser>'+listUser);
        // User createUserPartnerAdmin = createAPartnerUser(true);
        
        Id accId= [select id,accountid from contact where id=:listUser[0].contactId].accountid;
        Contact newcon=[select EligibleTracks__c from Contact where id=:listUser[0].contactId Limit 1];
        //newcon.Partner_User_Active__c=false;
        newcon.EligibleTracks__c='fyugfuihiu';
        update newcon;
        account accm=[select Master_Group_Affinity_Id__c from account Where Id=:accId Limit 1];
        system.debug('accId'+accId);
        // system.debug('UserRec:'+createUserPartnerAdmin+'AccRec:'+accId+'UserIsActive:'+createUserPartnerAdmin.IsActive);
        
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        system.debug('trackObj*****'+trackObj);
        
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = accId;
        testPartnerTrackObj.Master_Group_Affinity_Id__c=accm.Master_Group_Affinity_Id__c;
        testPartnerTrackObj.Partner_Track_Name__c = 'TestTrack';
        insert testPartnerTrackObj;
        //  system.assertEquals(testPartnerTrackObj.Master_Group_Id__c, accId);
        
        
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = accId;
        testPartnerTrackObj1.Partner_Track_Name__c = 'TestTrack1';
        testPartnerTrackObj1.Master_Group_Affinity_Id__c=accm.Master_Group_Affinity_Id__c;
        
        insert testPartnerTrackObj1;
        //system.assertEquals(testPartnerTrackObj1.Master_Group_Id__c, accId);
        
        Partner_Track__c testPartnerTrackObj2 = new Partner_Track__c();
        testPartnerTrackObj2.Track_Id__c = trackObj.id;
        testPartnerTrackObj2.Master_Group_Id__c = accId;
        testPartnerTrackObj2.Partner_Track_Name__c = 'TestTrack2';
        testPartnerTrackObj2.Master_Group_Affinity_Id__c=accm.Master_Group_Affinity_Id__c;
        
        insert testPartnerTrackObj2;
        //system.assertEquals(testPartnerTrackObj2.Master_Group_Id__c, accId);
        
        Partner_Track__c testPartnerTrackObj3 = new Partner_Track__c();
        testPartnerTrackObj3.Track_Id__c = trackObj.id;
        testPartnerTrackObj3.Master_Group_Id__c = accId;
        testPartnerTrackObj3.Partner_Track_Name__c = 'TestTrack3';
        testPartnerTrackObj3.Master_Group_Affinity_Id__c=accm.Master_Group_Affinity_Id__c;
        
        insert testPartnerTrackObj3;
        //system.assertEquals(testPartnerTrackObj3.Master_Group_Id__c, accId);
        
        Partner_Track__c testPartnerTrackObj4 = new Partner_Track__c();
        testPartnerTrackObj4.Track_Id__c = trackObj.id;
        testPartnerTrackObj4.Master_Group_Id__c = accId;
        testPartnerTrackObj4.Partner_Track_Name__c = 'TestTrack4';
        testPartnerTrackObj4.Master_Group_Affinity_Id__c=accm.Master_Group_Affinity_Id__c;
        
        insert testPartnerTrackObj4;
        //system.assertEquals(testPartnerTrackObj4.Master_Group_Id__c, accId);
        
        
        contact updateConEligibleTrack = [select id,eligibletracks__c,Selected_Track__c,Preferred_Track__c,Premier_Partner__c,Enable_User_for_MyRewards__c,
                                          Allow_RFP_and_Proposal_Express_Tool__c,Allow_Partner_Central_User__c,Allow_Program_Tracker__c,
                                          Is_MDF_User__c,Is_Rebate_User__c,Partner_User__c,Partner_User_Active__c from contact where id=:listUser[0].contactid];
        updateConEligibleTrack.Partner_User__c = listUser[0].id;
        updateConEligibleTrack.eligibletracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';' + testPartnerTrackObj2.id + ';' + testPartnerTrackObj3.id + ';' + testPartnerTrackObj4.id;
        updateConEligibleTrack.Selected_Track__c = testPartnerTrackObj.id;             
        updateConEligibleTrack.Preferred_Track__c = testPartnerTrackObj.id;
        updateConEligibleTrack.Premier_Partner__c = false;
        updateConEligibleTrack.Enable_User_for_MyRewards__c = false;
        updateConEligibleTrack.Allow_Partner_Central_User__c = false;
        updateConEligibleTrack.Allow_Program_Tracker__c = false;
        updateConEligibleTrack.Is_MDF_User__c = false;
        updateConEligibleTrack.Is_Rebate_User__c = false;
        updateConEligibleTrack.Allow_RFP_and_Proposal_Express_Tool__c = false;
        
        
        
        
        
        update updateConEligibleTrack;
        system.debug('ConRec:'+updateConEligibleTrack);
        
        contact updateConEligibleTrack1 = [select id,eligibletracks__c,Selected_Track__c,Preferred_Track__c,Premier_Partner__c,Enable_User_for_MyRewards__c,
                                           Allow_RFP_and_Proposal_Express_Tool__c,Allow_Partner_Central_User__c,Allow_Program_Tracker__c,
                                           Is_MDF_User__c,Is_Rebate_User__c,Partner_User__c,Partner_User_Active__c from contact where id=:listUser[0].contactid];
        updateConEligibleTrack1.Partner_User__c = listUser[0].id;
        updateConEligibleTrack1.eligibletracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id + ';' + testPartnerTrackObj2.id + ';' + testPartnerTrackObj3.id + ';' + testPartnerTrackObj4.id;
        updateConEligibleTrack1.Selected_Track__c = testPartnerTrackObj.id;             
        updateConEligibleTrack1.Preferred_Track__c = testPartnerTrackObj.id;
        updateConEligibleTrack1.Premier_Partner__c = true;
        updateConEligibleTrack1.Enable_User_for_MyRewards__c = true;
        updateConEligibleTrack1.Allow_Partner_Central_User__c = true;
        updateConEligibleTrack1.Allow_Program_Tracker__c = true;
        updateConEligibleTrack1.Is_MDF_User__c = true;
        updateConEligibleTrack1.Is_Rebate_User__c = true;
        updateConEligibleTrack1.Allow_RFP_and_Proposal_Express_Tool__c = true;
        
        update updateConEligibleTrack1;
        system.debug('ConRec:'+updateConEligibleTrack1);
        
        Map<String,String> mapWrapString = new Map<String,String>();
        mapWrapString.put('EligibleTracks__c', updateConEligibleTrack.eligibletracks__c);
        mapWrapString.put('EligibleTracks__c_of_Size', updateConEligibleTrack.eligibletracks__c);
        
        System.runAs(listUser[0]){
            test.startTest();
            ManageUsersCtrl testConAdmin = new ManageUsersCtrl();
            ManageUsersCtrl.contactWrapper testWrap = new ManageUsersCtrl.contactWrapper(updateConEligibleTrack,mapWrapString,true,true);
            testConAdmin.bErrorPartnerGroupTrackAdmin= false;
            
            testConAdmin.strOfSaveContactId= null;
            testConAdmin.strOfSavePtnrTrackCheckForAction= null;
            testConAdmin.strOfSaveToolAccessForAction = null;
            testConAdmin.bContactSelError= true;
            testConAdmin.bContactSelSuccess= true;
            testConAdmin.bContactInactiveError= true;
            Apexpages.currentPage().getParameters().put('ptnrTrackCheck',testPartnerTrackObj.id + ',' + testPartnerTrackObj1.id);
            testConAdmin.strOfLastName = 'test';
            testConAdmin.strOfContactStatus= 'False';
            testConAdmin.strOfSelTrackAdmin= 'False';
            testConAdmin.contactSetup();
            testConAdmin.strOfContactId = updateConEligibleTrack.id;
            testConAdmin.strOfActionOptions = label.Provide_Tools_Access_to_selected_users;
            testConAdmin.strOfActionOptions = label.Add_selected_users_to_Tracks;
            try{testConAdmin.partnerTracksAddRemoveAction();}catch(exception e){}
            testConAdmin.strOfActionOptions = label.Remove_selected_users_from_Tracks;
            try{
                testConAdmin.partnerTracksAddRemoveAction();}catch(exception e){}
            testConAdmin.allActionLogic();
            try{testConAdmin.strOfSaveToolAccessForAction='Partner_User_Deal_Registration__c,Partner_User_Lead_Management__c,Premier_Partner__c,Partner_User_Lead_Super_User__c,OSC_Create_Quote__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Quote__c,OSC_Specialty_Product_Create_Order__c';
                testConAdmin.toolAccessAddRemoveAction();
                testConAdmin.strOfActionOptions = label.Remove_Tools_Access_to_selected_users;}catch(exception e){}
            testConAdmin.saveAction();
            
            testConAdmin.cancel();
            testConAdmin.contactSetup();
            testConAdmin.editContact();
            testConAdmin.getPartnerTrackAdmin();
            testConAdmin.getPartnerTracks();
            testConAdmin.getContactStatus();
            testConAdmin.newContact();
            testConAdmin.getActions();
            testConAdmin.getToolAccess();
            testConAdmin.previous();
            testConAdmin.next();             
            ManageUsersCtrl testConAdmin1 = new ManageUsersCtrl();
            
            
            ManageUsersCtrl.contactWrapper testWrap1 = new ManageUsersCtrl.contactWrapper(updateConEligibleTrack,mapWrapString,true,true);
            testConAdmin1.bErrorPartnerGroupTrackAdmin= true;
            Apexpages.currentPage().getParameters().put('ptnrTrackCheck',testPartnerTrackObj.id + ',' + testPartnerTrackObj1.id);
            testConAdmin1.strOfLastName= 'test';
            testConAdmin1.strOfContactStatus= 'true';
            testConAdmin1.strOfSelTrackAdmin= 'true';
            testConAdmin1.contactSetup();
            testConAdmin1.strOfContactId = updateConEligibleTrack.id; 
            String strCon= updateConEligibleTrack.Id +','+ updateConEligibleTrack.Id;
            //String strEg= testPartnerTrackObj1.Id;
            ApexPages.currentPage().getParameters().put('saveContactConId',strCon);
            ApexPages.currentPage().getParameters().put('strOfSaveContactId',strCon);
            ApexPages.currentPage().getParameters().put('ptnrTrackCheck',strCon);
            ApexPages.currentPage().getParameters().put('ptnrTrackCheckForAction',listUser[0].id+','+listUser[0].id);
            ApexPages.currentPage().getParameters().put('appAccCheck',strCon);
            ApexPages.currentPage().getParameters().put('ToolAccessForAction','Partner_User_Deal_Registration__c,Partner_User_Lead_Management__c,Partner_User_Lead_Super_User__c,contact.Premier_Partner__c,Partner_User__r.Enable_User_for_MyRewards__c,contact.Allow_RFP_and_Proposal_Express_Tool__c,contact.Allow_Partner_Central_User__c,contact.Allow_Program_Tracker__c,contact.Is_MDF_User__c,contact.Is_Rebate_User__c,OSC_Create_Quote__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Quote__c,OSC_Specialty_Product_Create_Order__c');
            testConAdmin1.strOfSaveContactId= updateConEligibleTrack.Id + ',' + updateConEligibleTrack1.Id;
            testConAdmin1.strOfSavePtnrTrackCheckForAction= testPartnerTrackObj.id + ',' + testPartnerTrackObj1.id + ',' + testPartnerTrackObj2.id + ',' + testPartnerTrackObj3.id + ',' + testPartnerTrackObj4.id;
            testConAdmin1.strOfSaveToolAccessForAction = 'Partner_User_Deal_Registration__c,Partner_User_Lead_Management__c,Partner_User_Lead_Super_User__c,Premier_Partner__c,Enable_User_for_MyRewards__c,Allow_RFP_and_Proposal_Express_Tool__c,Allow_Partner_Central_User__c,Allow_Program_Tracker__c,Is_MDF_User__c,Is_Rebate_User__c,OSC_Create_Quote__c__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Quote__c,OSC_Specialty_Product_Create_Order__c';
            testConAdmin1.strOfActionOptions = label.Provide_Tools_Access_to_selected_users;
            testConAdmin1.bContactSelError= false;
            testConAdmin1.bContactSelSuccess= false;
            testConAdmin1.bContactInactiveError= false;
            //testConAdmin1.mapOfFieldsStrWarp.put('test','cont');
            testConAdmin1.strOfAppAcc='';
            testConAdmin1.allActionLogic();
            try{
                testConAdmin1.partnerTracksAddRemoveAction();}catch(exception e){}
            try{
                testConAdmin1.toolAccessAddRemoveAction();}catch(exception e){}
            try{testConAdmin1.saveAction();}catch(exception e){}
            testConAdmin1.cancel();
            try{
                testConAdmin1.contactSetup();}catch(exception e){}
            testConAdmin1.newContact();
            // testConAdmin1.editContact();
            testConAdmin1.getPartnerTrackAdmin();
            testConAdmin1.getPartnerTracks();
            testConAdmin1.getActions();
            testConAdmin1.getToolAccess();
            testConAdmin1.getContactStatus();
            testConAdmin1.strOfActionOptions = label.Remove_Tools_Access_to_selected_users;
            
            testConAdmin1.getToolAccess();
            try{
                testConAdmin1.partnerTracksAddRemoveAction();}catch(exception e){}
            try{
                testConAdmin1.toolAccessAddRemoveAction();}catch(exception e){}
            testConAdmin1.strOfActionOptions = label.Add_selected_users_to_Tracks;
            testConAdmin1.getToolAccess();
            try{
                testConAdmin1.partnerTracksAddRemoveAction();}catch(exception e){}
            try{
                testConAdmin1.toolAccessAddRemoveAction();}catch(exception e){}
           // testConAdmin1.exportAction();
          //  testConAdmin1.exportActionAll();
            ApexPages.currentPage().getParameters().put(ManageUsersCtrl.HTTP_PARAMETER_USERID,''+ listUser[0].id);
            //ManageUsersCtrl.synchronizeToCMI('String userId', 'String requestId');
            testConAdmin1.doActivateOrInactivateUser();
            testConAdmin1.createInactivateUserPartnerRequest();
            testConAdmin1.doConfirmActivateOrInactivateUser();
            UpdateContactCtrl.updateContactStatus(listUser[0].ContactId);
            ManageUsersCtrl.synchronizeToCMI(listUser[0].id, testConAdmin1.inactivationRequest.id);
            testConAdmin1.doCancelActivateOrInactivateUser();
            ApexPages.currentPage().getParameters().put('selectedConIDToExport',updateConEligibleTrack.id);
            ApexPages.currentPage().getParameters().put('loggedInUsr',listUser[0].id);
            ManageUsersCtrlExport testConAdminEXport = new ManageUsersCtrlExport();
            test.stopTest();
            
            
        }
        TriggerExecutionController.setSkipUserTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipContactTriggers(false);
        
    }
      private static testMethod void contactAdminWithPartnerexport(){
        
        TriggerExecutionController.setSkipUserTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        list<User> listUser=TestDataFactory.createNPortalUser(1);
        listUser[0].Enable_as_Partner_Group_Administrator__c=true;
        listUser[0].Enable_Partner_Admin__c=true;
        listUser[0].Enable_As_Partner_Lead_Super_User__c=false;
        listUser[0].Enable_Partner_Deal_Registration__c=false;
         listUser[0].Enable_Partner_Lead_Management__c=false;
        insert listUser;
  System.runAs(listUser[0]){
            test.startTest();
            ApexPages.currentPage().getParameters().put('conIDExport','23423636');
  ManageUsersCtrl testConAdmin = new ManageUsersCtrl();
 testConAdmin.strFinalQuery= 'select id,AccountId,Name,FirstName,LastName,Email,phone,Premier_Partner__c,Partner_User__r.OSC_Specialty_Product_Create_Order__c,Partner_User__r.OSC_Specialty_Product_Create_Quote__c,Partner_User__r.OSC_Create_Order__c,Partner_User__r.OSC_Create_Quote__c,Partner_User__r.Email,Partner_User__r.Enable_As_Partner_Lead_Super_User__c,Partner_User__r.Enable_Partner_Lead_Management__c,Partner_User__r.Enable_Partner_Deal_Registration__c,Partner_User_Deal_Registration__c,OSC_Create_Quote__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Quote__c,OSC_Specialty_Product_Create_Order__c,Partner_User_Lead_Management__c,Partner_User_Lead_Super_User__c,EligibleTracks__c,Enable_as_Partner_Group_Administrator__c,Partner_User_Partner_Admin__c,Status__c,Partner_Application_Access__c,Enable_User_for_MyRewards__c,Allow_RFP_and_Proposal_Express_Tool__c,Allow_Partner_Central_User__c,Allow_Program_Tracker__c,Account.Master_Group_Affinity_ID__c,Partner_User__c,Partner_User_Active__c,Is_MDF_User__c,Is_Rebate_User__c FROM Contact';
         testConAdmin.strOfConIDToExport='1214245';
           testConAdmin.exportAction();
            testConAdmin.exportActionAll();
             ManageUsersCtrlExport testConAdminEXport = new ManageUsersCtrlExport();
            test.stopTest();
            }
            TriggerExecutionController.setSkipUserTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipContactTriggers(false);
            }
}