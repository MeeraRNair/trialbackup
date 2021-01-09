/*
* Revision Ref Number  Release No     Date            Modified By     Description
* -------- ----------  ----------     -----------     ------------    -----------
* 1.0       13478      FY17-DCS-1101  30-Aug-2016     SuiYee          Setting DAM web2case (with SFDC site) form
* 2.0       13766      FY17-DCS-1101  15-Dec-2016     Sajith          Corrections for View State Error
* 
*/
@isTest
public class DAMCaseCreationCtrlTest {
    
    static testMethod void testDAMCaseCreationCtrl() {
        
        Id IdCaseRT= StaticFactory.getRecordTypeIdByName('Case', 'Digital Asset Management'); 
        Attachment attach=new Attachment();
        attach.Name='DAMTest.doc';
        case objDamCase = new Case(SuppliedName='SuiyeeDamCase');
        objDamCase.RecordTypeId =IdCaseRT;
        objDamCase.SUPPLIEDEMAIL='sui_yee_khoo@dell.com';
        objDamCase.SUPPLIEDPHONE='1234';
        objDamCase.SuppliedCompany='SuiYeeCompany';
        objDamCase.SUBJECT='SuiYeeSubject';
        objDamCase.Description='SuiYeeDescription';
        objDamCase.Reason='How Do I';
        objDamCase.PRIORITY='Urgent';
        objDamCase.origin ='Web';
        objDamCase.status='Open';
        insert objDamCase; 
        ApexPages.StandardController stdCaseObj= new ApexPages.StandardController(objDamCase); 
        DAMCaseCreationCtrl CaseObjController = new DAMCaseCreationCtrl(stdCaseObj);
        test.startTest();
       /* CaseObjController.getPRIORITY();
        CaseObjController.getReason();*/
        Blob bodyBlob=Blob.valueOf('DAM Unit Test Attachment Body');
        CaseObjController.fileBody=bodyBlob;
        CaseObjController.fileName=attach.Name;
        CaseObjController.UploadFile(objDamCase.Id);
        CaseObjController.submitCase();
        test.stopTest();
    }
    
    static testMethod void testDAMCaseCreationControllerXReason() {
        
        Id IdCaseRT= StaticFactory.getRecordTypeIdByName('Case', 'Digital Asset Management'); 
        case objDamCase = new Case(SuppliedName='SuiyeeDamCase');
        objDamCase.RecordTypeId =IdCaseRT;
        objDamCase.SUPPLIEDEMAIL=null;
        objDamCase.SUPPLIEDPHONE='1234';
        objDamCase.SuppliedCompany='SuiYeeCompany';
        objDamCase.SUBJECT='SuiYeeSubject';
        objDamCase.Description='SuiYeeDescription';
        objDamCase.origin ='Web';
        objDamCase.status='Open';
        objDamCase.Reason='--None--';
        objDamCase.PRIORITY='--None--';
        
        //insert Dam;
        PageReference pageRef = Page.DAMCaseCreation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCaseObj= new ApexPages.StandardController(objDamCase); 
        DAMCaseCreationCtrl CaseObjController = new DAMCaseCreationCtrl(stdCaseObj);
        CaseObjController.objCase =objDamCase;
        test.startTest();
     /*   CaseObjController.getPRIORITY();
        CaseObjController.getReason();*/
        CaseObjController.submitCase();
        test.stopTest();
        
    }
    //2.0 Method to check validation rules
    static testMethod void testDAMCaseCreationControllerNegative() {
        
        Id IdCaseRT= StaticFactory.getRecordTypeIdByName('Case', 'Digital Asset Management'); 
        Attachment attach=new Attachment();
     
        case objDamCase = new Case(SuppliedName='SuiyeeDamCase');
        objDamCase.RecordTypeId =IdCaseRT;
        objDamCase.SUPPLIEDEMAIL='TestValidation';
        objDamCase.SUBJECT=null;
        objDamCase.Description=null;
        objDamCase.origin ='Web';
        objDamCase.status='Open';
        objDamCase.Reason='';
        objDamCase.PRIORITY='';
         attach.Name='DAMTest.doc';
        //insert Dam;
        PageReference pageRef = Page.DAMCaseCreation;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCaseObj= new ApexPages.StandardController(objDamCase); 
        DAMCaseCreationCtrl CaseObjController = new DAMCaseCreationCtrl(stdCaseObj);
        CaseObjController.objCase =objDamCase;
        test.startTest();
        Blob bodyBlob=Blob.valueOf('DAM Unit Test Attachment Body');
        CaseObjController.fileBody=bodyBlob;
        CaseObjController.fileName=attach.Name;
        CaseObjController.submitCase();
        test.stopTest();  
    }
}