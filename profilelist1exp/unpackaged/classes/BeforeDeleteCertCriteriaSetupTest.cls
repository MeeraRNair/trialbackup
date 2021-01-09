@isTest
private class BeforeDeleteCertCriteriaSetupTest{

    public static testmethod void testBeforeDeleteCertCriteriaSetup(){
    
        Certification_Requirement_Setup__c certReqSetup = new Certification_Requirement_Setup__c();
        certReqSetup.name='test1';
        certReqSetup.Apply_Requirement_To__c='Global';
        certReqSetup.Certification_Name__c = 'Server';        
        insert certReqSetup;
        
        Demo_Unit_Setup__c duseql = new Demo_Unit_Setup__c(
                    Name = 'EQL Demo',
                    Active__c = true);
        insert duseql;
            
        List<Certification_Criteria_Setup__c> lstcertCriteriaSetup = new List<Certification_Criteria_Setup__c>();
        List<Certification_Criteria_Setup__c> del_lstCriteria = new List<Certification_Criteria_Setup__c>();
        for(integer i=0;i<4;i++){
            Certification_Criteria_Setup__c certCriteriaSetup = new Certification_Criteria_Setup__c();
            certCriteriaSetup.Certification_Requirement_Setup__c = certReqSetup.id;
            certCriteriaSetup.Certification_Criteria_Order__c = i;
            certCriteriaSetup.Certification_Criteria_Name__c = 'Demo Unit';
            certCriteriaSetup.Number_of_Demo_Units__c = 1;
            certCriteriaSetup.Certification_Criteria_Value__c = 'EQL Demo';
            lstcertCriteriaSetup.add(certCriteriaSetup);
            if (i <= 2 ){
                del_lstCriteria.add(certCriteriaSetup);
            }
        }
        insert lstcertCriteriaSetup;
        
        delete del_lstCriteria;
    
    }
}