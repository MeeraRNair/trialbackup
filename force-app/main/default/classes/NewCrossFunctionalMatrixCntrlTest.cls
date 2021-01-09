@isTest(seeAllData = true)
public class NewCrossFunctionalMatrixCntrlTest{
    static testmethod void testLoadData(){
        Test.startTest();     
        ApexPages.StandardController sc = new ApexPages.standardController(new Cross_Functional_Matrix__c ());
        NewCrossFunctionalMatrixCntrl obj = new NewCrossFunctionalMatrixCntrl(sc);
        PageReference f = obj.InsertCFMx();
        
        NSS_Category__c NSS = new NSS_Category__c(Name='ONLINE');
        insert NSS;
        NSS_Category__c NSSObj = [SELECT ID from NSS_Category__c LIMIT 1];
        obj.CFMT.NSS_Category__c=NSSObj .Id;
        obj.Country = 'INDIA';
        obj.Segment= 'segment1';
        obj.SubSegment= 'sub seg';
        f = obj.InsertCFMx();
        f = obj.UpdateCFMx();
        Cross_Functional_Matrix__c cfmx = [SELECT NSS_Category__c, Country__c, Segment__c, Sub_Segment__c, Owner__c, CC_Owner__c, Functional_Call_To_Action__c FROM Cross_Functional_Matrix__c LIMIT 1  ];
        ApexPages.currentPage().getParameters().put('id',cfmx.id);
        Test.stopTest();
        
    }
}