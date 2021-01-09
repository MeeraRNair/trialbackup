@isTest
private class VFCntrlr_MasterProgram_lookupTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Master_Program_Setup__c> listMasterProSetTdf=TestDataFactory.createNMasterProSetup(1);
        insert listMasterProSetTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    public static testmethod void testMPLookup(){
        /*
Master_Program_Setup__c mp = new Master_Program_Setup__c(Master_Program_Name__c = 'TestMP', Apply_Requirement_To__c ='Global',
Active__c=true, Certification_Name__c='Security ; Networking');

insert mp;
*/
        Master_Program_Setup__c mp= [select id,Master_Program_Name__c,Apply_Requirement_To__c,Active__c,Certification_Name__c from Master_Program_Setup__c where Apply_Requirement_To__c ='Global' Limit 1];
        VFCntrlr_MasterProgram_lookup vfCntrlr = new  VFCntrlr_MasterProgram_lookup();
        vfCntrlr.search_MP = 'Test';
        vfCntrlr.go();
        vfCntrlr.getResults();
        system.assertNotEquals(mp.id, null);
    }
}