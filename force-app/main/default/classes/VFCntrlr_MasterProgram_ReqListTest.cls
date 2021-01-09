@isTest
private class VFCntrlr_MasterProgram_ReqListTest{
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        List<Master_Program_Setup__c> listMasterProSetTdf=TestDataFactory.createNMasterProSetup(1);
        listMasterProSetTdf[0].Master_Program_Name__c = 'TestMP';
        insert listMasterProSetTdf;
        List<Certification_Requirement_Setup__c> listCertiReqSetupTdf=TestDataFactory.createNCertificationReqSetUp(29);
        insert listCertiReqSetupTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    public static testmethod void testMPReqList(){
        /*  Master_Program_Setup__c mp = new Master_Program_Setup__c(Master_Program_Name__c = 'TestMP', Apply_Requirement_To__c ='Global',
Active__c=true, Certification_Name__c='Security ; Networking');

insert mp;
*/
        Master_Program_Setup__c mp=[select id,Master_Program_Name__c,Apply_Requirement_To__c,Active__c,Certification_Name__c from Master_Program_Setup__c where Master_Program_Name__c = 'TestMP' Limit 1];
        //list<Certification_Requirement_Setup__c> reqlst = new list<Certification_Requirement_Setup__c>();
        /* for (integer i = 1 ; i <= 30 ; i++){
Certification_Requirement_Setup__c certReqSetup1 = new Certification_Requirement_Setup__c();
certReqSetup1.name='test1';
certReqSetup1.Apply_Requirement_To__c='Global';       
certReqSetup1.Certification_Name__c = 'Security';    
certReqSetup1.Acquisition__c = 'A'+i;               
certReqSetup1.Active__c = true;
certReqSetup1.Prerequisites__c =true;
reqlst.add(certReqSetup1);
}
insert reqlst;
*/
        List<Certification_Requirement_Setup__c> listCertiReqSetup=[select id,name,Apply_Requirement_To__c,Certification_Name__c,Acquisition__c,Active__c,Prerequisites__c from Certification_Requirement_Setup__c where Prerequisites__c =true limit 2];
        system.assertNotEquals(listCertiReqSetup[0].id, null);
        PageReference pageRef = Page.MasterProgram_ReqList;      
        pageRef.getParameters().put('id',mp.id);
        Test.setCurrentPageReference(pageRef);  
        ApexPages.StandardController sc = new ApexPages.StandardController(mp);
        VFCntrlr_MasterProgram_ReqList vfCntrlr = new  VFCntrlr_MasterProgram_ReqList(sc);
        vfCntrlr.getReqList();
        vfCntrlr.next();
        vfCntrlr.previous();
        vfCntrlr.getHasPreviousAndNext();
    }
}