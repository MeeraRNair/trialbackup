/* 
REVISION HISTORY
================
Version     Author      Date            Release#        CR#     Description
-------     ------      ----            --------        ---     -----------
1.0         Sandhya     07-Nov-2012     14.2            --      Test class for CMAP_MassLeadUploadCntrlr.
2.0         Sui Yee     16-Dec-2016     FY17-DCS-0103   13780   campaign validation rules impacting Mascot integration
3.0         Shue        19-Mar-2019     FY20-0402       ----    Partner Account assigneent
4.0         Shue        26-Mar-2019     FY20-0402       ----    PMD Violation fix
*/
@isTest
private class CMAP_MassLeadUploadCntrlr_Test {
    
    static testMethod void myUnitTest() {
        CMAP_Helper.skipinsert = true;
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        
        
        TriggerExecutionController.setSkipAllTriggers(true);
        testData.getAccount(true);        
        testData.getContact(true);
        testData.getPartnerUser(true);
        testData.getCampaign(true);
        Campaign campRec = testData.campObj;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        //CMAP_Helper.skipinsert = true;
        Mass_Upload_Lead_Request__c mulrObj = new Mass_Upload_Lead_Request__c(Campaign__c = campRec.Id,
                                                                              Partner_User__c = testData.contObj.Partner_User__c,
                                                                              Partner_Email_ID__c = testData.partnerUser.Email,
                                                                              //Partner_Account__c = testData.accountObj.Id,
                                                                              Partner_Account__c = testData.smaObj.Id,  //3.0
                                                                              Status__c = 'New');
        
        insert mulrObj;
        Test.stopTest(); 
        PageReference  pr = new PageReference('/apex/MassLeadUpload?campId='+testData.campObj.Id+'&Name='+testData.campObj.Name);
        Test.setCurrentPage(pr);
        //pr.getParameters().put('accName',testData.accountObj.name);
        pr.getParameters().put('accName',testData.smaObj.id); //3.0
        system.runAs(testData.partnerUser){
            CMAP_MassLeadUploadCntrlr controller = new CMAP_MassLeadUploadCntrlr();
            Attachment attach=new Attachment(); 
            String campaignName ;   
            attach.Name='CMAPTest.doc';
            attach.OwnerId = testData.partnerUser.Id;
            attach.ParentId = mulrObj.Id;
            Blob blbBodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=blbBodyBlob;
            campaignName = testData.campObj.Name;
            controller.fileBody=blbBodyBlob;
            controller.attach = attach;
            //controller.isFormat = TRUE;
            controller.submitAction();         
            attach.Name='CMApTest.xlsx';
            controller.attach = attach;
            
            PageReference  pageRefReqActual = controller.submitAction();
            System.assertEquals(null,pageRefReqActual);
        }   
        delete mulrObj;   //Anamika - cmap16.03 on 23rd feb 2015
    }
    
    //2.0
    static testMethod void testCampCloseDate() {
        CMAP_Helper.skipinsert = true;
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();

        TriggerExecutionController.setSkipAllTriggers(true);
        testData.getAccount(true);        
        testData.getContact(true);
        testData.getUser2(true);
        User u2 = testData.user2;
        testData.getCampaign2(true);
        Campaign campRec = testData.campObj2;
        system.runAs(u2){            
            campRec.Close_Date_for_Leads__c = date.today().adddays(-2);
            update campRec;
        }
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        try{
            Mass_Upload_Lead_Request__c mulrObj = new Mass_Upload_Lead_Request__c(Campaign__c = campRec.Id,Status__c = 'New');
            insert mulrObj;
        }catch(Exception ex){
            system.debug('Exception occured--'+ex.getStackTraceString());            
        }
        //System.assertEquals(campRec.Region__c date.today().adddays(-2), campRec.Close_Date_for_Leads__c);
        System.assertEquals('ABU', campRec.Region__c);
        Test.stopTest(); 
    }
}