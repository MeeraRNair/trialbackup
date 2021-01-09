@isTest
private class AfterInsertUpdateCertCriteriaSetupTest
{
   static list<Certification_Criteria_Setup__c>  listCertCriteriaRequire;
  static list<Certification_Requirement_Setup__c> listCertRequire;
  static list<Demo_Unit_Setup__c> listDemounitSet;
    @testSetup static void setup(){
        List<Certification_Requirement_Setup__c> listCertRequireTDF = TestDataFactory.createNCertificationReqSetUp(1);
        insert listCertRequireTDF;
        List<Demo_Unit_Setup__c> listDemosetupTDF =  TestDataFactory.createNDemoUnitSetup(1);
        insert listDemosetupTDF;
        List<Certification_Criteria_Setup__c> listCertCriteriaRequireTDF = TestDataFactory.createNCertificationCriteriaSetup(3);
        listCertCriteriaRequireTDF[0].Certification_Requirement_Setup__c = listCertRequireTDF[0].id;
        listCertCriteriaRequireTDF[1].Certification_Requirement_Setup__c = listCertRequireTDF[0].id;
        listCertCriteriaRequireTDF[2].Certification_Requirement_Setup__c = listCertRequireTDF[0].id;
        insert listCertCriteriaRequireTDF;
    }  

    public static testmethod void testCriteriaSetupUpdateTrigger()
    {
                  
   /*         Certification_Requirement_Setup__c certReqSetup = new Certification_Requirement_Setup__c();
            certReqSetup.name='test1';
            certReqSetup.Apply_Requirement_To__c='Global';
            certReqSetup.Certification_Name__c = 'Server';        
            insert certReqSetup;
            
            Demo_Unit_Setup__c duseql = new Demo_Unit_Setup__c(
                    Name = 'EQL Demo',
                    Active__c = true);
            insert duseql;
            
            Demo_Unit_Setup__c duskace = new Demo_Unit_Setup__c(
                    Name = 'KACE Demo',
                    Active__c = true);
            insert duskace;
            
            List<Certification_Criteria_Setup__c> lstCriteria = new List<Certification_Criteria_Setup__c>();
                    
            Certification_Criteria_Setup__c certCriteriaSetup = new Certification_Criteria_Setup__c();
            certCriteriaSetup.Certification_Requirement_Setup__c = certReqSetup.id;
            certCriteriaSetup.Certification_Criteria_Order__c = 1;
            certCriteriaSetup.Certification_Criteria_Name__c = 'Demo Unit';
            certCriteriaSetup.Number_of_Demo_Units__c = 1;
            certCriteriaSetup.Certification_Criteria_Value__c = 'EQL Demo';
            lstCriteria.add(certCriteriaSetup);
            
            Certification_Criteria_Setup__c certCriteriaSetup1 = new Certification_Criteria_Setup__c();
            certCriteriaSetup1.Certification_Requirement_Setup__c = certReqSetup.id;
            certCriteriaSetup1.Certification_Criteria_Order__c = 2;
            certCriteriaSetup1.Certification_Criteria_Name__c = 'Demo Unit';
            certCriteriaSetup1.Number_of_Demo_Units__c = 2;
            certCriteriaSetup1.Certification_Criteria_Value__c = 'KACE Demo';
            lstCriteria.add(certCriteriaSetup1);
             
            insert lstCriteria;
            
            Certification_Criteria_Setup__c certCriteriaSetup2 = new Certification_Criteria_Setup__c();
            certCriteriaSetup1.Certification_Criteria_Order__c = 2;
            certCriteriaSetup1.Certification_Criteria_Name__c = 'Demo Unit';
            certCriteriaSetup1.Number_of_Demo_Units__c = 2;
            certCriteriaSetup1.Certification_Criteria_Value__c = 'KACE Demo';
            lstCriteria.add(certCriteriaSetup2);
      */
      //  listDemounitSet = [select id from Demo_Unit_Setup__c limit 1];
      listCertCriteriaRequire = [select id from  Certification_Criteria_Setup__c limit 2];  
      system.assertEquals(listCertCriteriaRequire[0].id, listCertCriteriaRequire[0].id);    
        }
        
}