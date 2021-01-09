/*
* Revision Ref Number  Release No     Date            Modified By     Description
* -------- ----------  ----------     -----------     ------------    -----------
* 1.0       13766      FY17-DCS-0103 25-Nov-2016     Sajith         LM2_Setting GMO site form (with SFDC site) form
* 2.0       16741      FY19-DCS-0102 29-Oct-2018     Kishore        Added skip trigger logic on Case Insertion to bypass errors
* 3.0       18329      FY20-DCS-0102 25-Nov-2019     Kokila         Updated test class with latest renamed picklist values
*/
@isTest
public class GLMICaseCreationCtrlTest {
    
    static testMethod void testGLMICaseCreationCtrl() {
        
        Id idCaseRT= StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake'); 
        Attachment attach=new Attachment();
        attach.Name='GLMITest.doc';
        case objGLMICase = new Case(SuppliedName='GLMICase-From Test Class');
        objGLMICase.RecordTypeId =idCaseRT;
        objGLMICase.SUPPLIEDEMAIL='TestGLMI@dell.com';
        objGLMICase.SUBJECT='Test GLMI Case - Test Class';
        objGLMICase.Description='This is a test case created from GLMICaseCreationCtrlTest class';
        objGLMICase.Sub_Type_Internal_User__c ='Lead Load Request';
        objGLMICase.Sub_Type_GLMI__c ='Lead Load';
        objGLMICase.Lead_Type__c='Inbound Lead';
        objGLMICase.Requesting_Region__c='APJ';
        objGLMICase.Send_to_LQR__c=true;
        objGLMICase.origin ='Web';
        objGLMICase.status='Open';
        TriggerExecutionController.setSkipCaseTriggers(True); //2.0
        insert objGLMICase; 
        TriggerExecutionController.setSkipCaseTriggers(False); //2.0
        ApexPages.StandardController stdCaseObj= new ApexPages.StandardController(objGLMICase); 
        GLMICaseCreationCtrl caseObjController = new GLMICaseCreationCtrl(stdCaseObj);
        test.startTest();
     /*   caseObjController.getCaseType();
        caseObjController.getRegion();
        caseObjController.getLeadType();*/
        Blob bodyBlob=Blob.valueOf('GLMI Unit Test Attachment Body');
        caseObjController.fileBody=bodyBlob;
        caseObjController.fileName=attach.Name;
        caseObjController.submitCase();
        caseObjController.UploadFile(objGLMICase.Id);
        test.stopTest();
    }
    
    static testMethod void testGLMICaseCreationControllerXReason() {
        
        Id idCaseRT= StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake'); 
        case objGLMICase = new Case(SuppliedName='GLMICase-From Test Class');
        objGLMICase.RecordTypeId =idCaseRT;
        objGLMICase.SUPPLIEDEMAIL='';
        objGLMICase.SUBJECT='Test GLMI Case - Test Class';
        objGLMICase.Description='This is a test case created from GLMICaseCreationCtrlTest class';
        objGLMICase.Sub_Type_Internal_User__c ='--None--';
        objGLMICase.Lead_Type__c='--None--';
        objGLMICase.Requesting_Region__c='--None--';
        objGLMICase.Send_to_LQR__c=true;
        objGLMICase.origin ='Web';
        objGLMICase.status='Open';
        
        PageReference pageRef = Page.GLMICaseCreation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCaseObj= new ApexPages.StandardController(objGLMICase); 
        GLMICaseCreationCtrl caseObjController = new GLMICaseCreationCtrl(stdCaseObj);
        caseObjController.objCase =objGLMICase;
        test.startTest();
       /* caseObjController.getCaseType();
        caseObjController.getRegion();
        caseObjController.getLeadType();*/
        caseObjController.submitCase();
        test.stopTest();       
    }
    static testMethod void testGLMICaseCreationControllerValidation() {
        case objGLMICase = new Case(SuppliedName='GLMICase-From Test Class');
        Id idCaseRT= StaticFactory.getRecordTypeIdByName('Case', 'Global Lead Management Intake'); 
        objGLMICase.RecordTypeId =idCaseRT;
        objGLMICase.SUPPLIEDEMAIL='Test';
        objGLMICase.SUBJECT='';
        objGLMICase.Description='';
        objGLMICase.Sub_Type_Internal_User__c ='Lead Load Request';
        objGLMICase.Sub_Type_GLMI__c ='Lead Support';
        objGLMICase.Lead_Type__c='Inbound Lead';
        objGLMICase.Requesting_Region__c='';
        objGLMICase.origin ='Web';
        objGLMICase.status='Open';
        Attachment attach=new Attachment();
        attach.Name='GLMITest.doc';
        Blob bodyBlob=Blob.valueOf('GLMI Unit Test Attachment Body');
        PageReference pageRef = Page.GLMICaseCreation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCaseObj= new ApexPages.StandardController(objGLMICase); 
        GLMICaseCreationCtrl caseObjController = new GLMICaseCreationCtrl(stdCaseObj);
        caseObjController.objCase =objGLMICase;
        test.startTest();
        caseObjController.fileBody=bodyBlob;
        caseObjController.fileName=attach.Name;
        //caseObjController.UploadFile(objGLMICase.Id);
        caseObjController.submitCase();
        test.stopTest();       
    }
}