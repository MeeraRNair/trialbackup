@isTest
private class VFCntrlr_CertCriteria_AddEditTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Certification_Requirement_Setup__c> listCertiReqSetupTdf=TestDataFactory.createNCertificationReqSetUp(1);
        listCertiReqSetupTdf[0].name='test1';
        insert listCertiReqSetupTdf;
        List<Certification_Criteria_Setup__c> listCriteriaSetupTdf=TestDataFactory.createNCertificationCriteriaSetup(2);
        listCriteriaSetupTdf[0].Certification_Requirement_Setup__c=listCertiReqSetupTdf[0].id;
        listCriteriaSetupTdf[0].Criteria_Value_Ids__c = 'D101 OR D102 ; D103 ; D104';
        listCriteriaSetupTdf[0].Certification_Criteria_Order__c = 1;
        listCriteriaSetupTdf[0].Certification_Criteria_Name__c = 'First Sales Training';
        listCriteriaSetupTdf[0].Certification_Criteria_Value__c = 'D101 - Dell Course 1 OR D102 - Dell Course2 ; D103 - Dell Course 3 ; D104 - Dell Course 4';
        listCriteriaSetupTdf[1].Certification_Requirement_Setup__c=listCertiReqSetupTdf[0].id;
        listCriteriaSetupTdf[1].Certification_Criteria_Value__c = 'Y';
        listCriteriaSetupTdf[1].Criteria_Value_Ids__c    = '';
        listCriteriaSetupTdf[1].Certification_Criteria_Name__c = 'Approval Contract';
        insert listCriteriaSetupTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    public static testmethod void testCertCriteriaAddEdit(){
        /*Certification_Requirement_Setup__c certReqSetup = new Certification_Requirement_Setup__c();
certReqSetup.name='test1';            
certReqSetup.Apply_Requirement_To__c='Global';            
certReqSetup.Certification_Name__c = 'Server';                    
insert certReqSetup; 

Certification_Criteria_Setup__c certCriteriaSetup = new Certification_Criteria_Setup__c();
certCriteriaSetup.Certification_Requirement_Setup__c = certReqSetup.id;
certCriteriaSetup.Certification_Criteria_Order__c = 1;
certCriteriaSetup.Certification_Criteria_Name__c = 'First Sales Training';
certCriteriaSetup.Condition__c = 'All';      
certCriteriaSetup.Number_of_Demo_Units__c = 1;
certCriteriaSetup.Certification_Criteria_Value__c = 'D101 - Dell Course 1 OR D102 - Dell Course2 ; D103 - Dell Course 3 ; D104 - Dell Course 4';     
certCriteriaSetup.Criteria_Value_Ids__c = 'D101 OR D102 ; D103 ; D104';
insert certCriteriaSetup;

Certification_Criteria_Setup__c certCriteriaSetup1 = new Certification_Criteria_Setup__c();
certCriteriaSetup1.Certification_Requirement_Setup__c = certReqSetup.id;
certCriteriaSetup1.Certification_Criteria_Order__c = 2;
certCriteriaSetup1.Certification_Criteria_Name__c = 'Approval Contract';     
certCriteriaSetup1.Number_of_Demo_Units__c = 1;
certCriteriaSetup1.Certification_Criteria_Value__c = 'Y';     
certCriteriaSetup1.Criteria_Value_Ids__c    = '';
insert certCriteriaSetup1;
*/
        Certification_Requirement_Setup__c certReqSetup=[select id from Certification_Requirement_Setup__c Limit 1]; 
        list<Certification_Criteria_Setup__c> listCertiReqSetup=[select id,Condition__c,Certification_Criteria_Value__c,Number_of_Demo_Units__c,Certification_Requirement_Setup__c,Certification_Criteria_Name__c,Certification_Criteria_Order__c,Criteria_Value_Ids__c from Certification_Criteria_Setup__c where Certification_Requirement_Setup__c=:certReqSetup.id limit 2];
        system.assertNotEquals(certReqSetup.id, null);
        PageReference pageRef = Page.CertCriteria_AddEdit;        
        Test.setCurrentPageReference(pageRef);             
        pageRef.getParameters().put('retURL',certReqSetup.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(listCertiReqSetup[0]);
        
        VFCntrlr_CertCriteria_AddEdit vfCntrlr1  = new VFCntrlr_CertCriteria_AddEdit(sc);      
        vfCntrlr1.getccSetup();
        
        pageRef.getParameters().put('id',listCertiReqSetup[0].id);             
        VFCntrlr_CertCriteria_AddEdit vfCntrlr  = new VFCntrlr_CertCriteria_AddEdit(sc);      
        vfCntrlr.getccSetup();
        vfCntrlr.getCertTraining();
        //vfCntrlr.certCriteria.get(0).isSelected = true;
        vfCntrlr.deleteCourse();
        vfCntrlr.OptionNum = 1;
        vfCntrlr.delCourse();
        vfCntrlr.save();
        vfCntrlr.saveClose();       
        pageRef.getParameters().put('id',listCertiReqSetup[1].id);    
        VFCntrlr_CertCriteria_AddEdit vfCntrlr2  = new VFCntrlr_CertCriteria_AddEdit(sc);      
        vfCntrlr2.getccSetup();
        vfCntrlr2.getCertTraining();
    }
}