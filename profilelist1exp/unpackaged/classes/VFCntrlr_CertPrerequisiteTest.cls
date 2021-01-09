@isTest
private class VFCntrlr_CertPrerequisiteTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Certification_Requirement_Setup__c> listCertiReqSetupTdf=TestDataFactory.createNCertificationReqSetUp(1);
        listCertiReqSetupTdf[0].name='test1';
        insert listCertiReqSetupTdf;
        List<Certification_Prerequisites_Setup__c> listCertiPreReqSetupTdf=TestDataFactory.createNCertificationPreReqSetUp(1);
        listCertiPreReqSetupTdf[0].Certification_Requirement_Setup__c=listCertiReqSetupTdf[0].id;
        insert listCertiPreReqSetupTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    
    public static testmethod void testCertPreReq(){
        
        /* Certification_Requirement_Setup__c certReqSetup = new Certification_Requirement_Setup__c();
certReqSetup.name='test1';            
certReqSetup.Apply_Requirement_To__c='Global';            
certReqSetup.Certification_Name__c = 'Server';                    
insert certReqSetup;        

Certification_Prerequisites_Setup__c certPreReqSetup = new Certification_Prerequisites_Setup__c();
certPreReqSetup.Certification_Requirement_Setup__c = certReqSetup.id;        
certPreReqSetup.Condition__c = 'All';
certPreReqSetup.Prerequisites__c='D101 - Dell Course 1 OR D102 - Dell Course2 ; D103 - Dell Course 3 ; D104 - Dell Course 4';
certPreReqSetup.Prerequisites_Ids__c = 'D101 OR D102 ; D103 ; D104';
insert certPreReqSetup;
*/
        Certification_Requirement_Setup__c certReqSetup=[select id,name,Apply_Requirement_To__c,Certification_Name__c from Certification_Requirement_Setup__c Limit 1];
        Certification_Prerequisites_Setup__c certPreReqSetup=[select id,Certification_Requirement_Setup__c,Condition__c,Prerequisites__c,Prerequisites_Ids__c from Certification_Prerequisites_Setup__c where Condition__c = 'All' Limit 1];
        PageReference pageRef = Page.CertPrerequisiteSetup;        
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('retURL',certReqSetup.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(certPreReqSetup);
        
        VFCntrlr_CertPrerequisite  vfCntrlr1  = new VFCntrlr_CertPrerequisite (sc);      
        vfCntrlr1.getcpSetup();
        system.assertNotEquals(certReqSetup.id, null);
        pageRef.getParameters().put('id',certPreReqSetup.id);             
        VFCntrlr_CertPrerequisite  vfCntrlr  = new VFCntrlr_CertPrerequisite (sc);      
        vfCntrlr.getcpSetup();
        vfCntrlr.getCertTraining();
        //vfCntrlr.certCriteria.get(0).isSelected = true;
        vfCntrlr.deleteCourse();
        vfCntrlr.OptionNum = 1;
        vfCntrlr.delCourse();        
        
        vfCntrlr.save();
        vfCntrlr.saveClose();   
    }
}