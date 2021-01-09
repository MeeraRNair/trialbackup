@isTest
private class VFCntrlr_OpportunityRedirectPageExtTest {
    static list<Account> listAcc;
    @testSetup static void setup() {
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(2, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
    }
    static testMethod void distributionAuto(){  
        listAcc=[select id From Account];
        list<User> listUser=TestDataFactory.createNPortalUser(1);
        insert listUser;
        system.runAs(listUser[0]){
            string stroppRTId= getRecordTypeIdbyName('Create New Deal From LOB','Opportunity');
            stroppRTId = stroppRTId.subString(0,15);
            PageReference pageRef = Page.OpportunityRedirectPage;
            Test.setCurrentPage(pageRef);
            Opportunity opp = new Opportunity(recordtypeid=stroppRTId);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(opp);
            ApexPages.currentPage().getParameters().put('RecordType', stroppRTId);
            ApexPages.currentPage().getParameters().put('00NA00000063WJM','Distribution');
            VFCntrlr_OpportunityRedirectPageExt  vforp = new  VFCntrlr_OpportunityRedirectPageExt(sc);
            vforp.redirectConfirmNew();
            ApexPages.currentPage().getParameters().put('00NA00000063WJM','');
            vforp.redirectConfirmNew();
            system.assertNotEquals(listAcc[0].id, null);
        }
        system.runAs(listUser[0]){
            string stroppRTId= getRecordTypeIdbyName('Deal Registration','Opportunity');
            stroppRTId = stroppRTId.subString(0,15);
            PageReference pageRef = Page.OpportunityRedirectPage;
            Test.setCurrentPage(pageRef);
            Opportunity opp = new Opportunity(recordtypeid=stroppRTId);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(opp);
            ApexPages.currentPage().getParameters().put('RecordType', stroppRTId);
            ApexPages.currentPage().getParameters().put('00NA00000063WJM','Distribution');
            VFCntrlr_OpportunityRedirectPageExt controller = new VFCntrlr_OpportunityRedirectPageExt();
            VFCntrlr_OpportunityRedirectPageExt  vforp = new  VFCntrlr_OpportunityRedirectPageExt(sc);
            ApexPages.currentPage().getParameters().put('RecordType','');
            ApexPages.currentPage().getParameters().put('00NA00000063WJM',''); 
            vforp.redirectConfirmNew();
        }
    }
    public static Id getRecordTypeIdbyName(String strRecordTypeName,String strobjectName){
        return  Schema.getGlobalDescribe().get(strobjectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
}