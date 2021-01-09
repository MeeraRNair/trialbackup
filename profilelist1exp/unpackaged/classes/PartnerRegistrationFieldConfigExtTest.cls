@ isTest
public class PartnerRegistrationFieldConfigExtTest {
    
    Static Partner_Type__c pt1                                              = null;
    static List<Partner_Type_Field_Configuration__c> tempFieldConfigList    = null;
    
    private static void initializedData(){
        
        Country__c ctry = [SELECT Id FROM Country__c LIMIT 1];
        pt1 = new Partner_Type__c(Name='test PT1',Country__c=ctry.Id, Is_Active__c=true, Sort_Order__c=2);
        insert pt1;
        
        PageReference pageRef = new PageReference('/apex/PartnerRegistrationFieldConfig?ptid='+pt1.Id);
        Test.setCurrentPage(pageRef);
      
        
        
    }
    
    public static testMethod void testPartnerRegistrationFieldConfigCreation(){
        initializedData();      
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Partner_Type_Field_Configuration__c());
        PartnerRegistrationFieldConfigExt ptfcController = new PartnerRegistrationFieldConfigExt(stdController);        
       // system.assertEquals(0, ptfcController.tempFieldConfigList.size());        
       // system.assertEquals(true, ptfcController.isNewPartnerTypeFlag);
        
        ptfcController.doPageLoad();
        system.assertEquals(false, ptfcController.isNewPartnerTypeFlag);
        system.assert(ptfcController.tempFieldConfigList.size()==ptfcController.fieldConfigOutputList.size());
        system.debug('fieldConfigOutputList=='+ptfcController.fieldConfigOutputList.size());
        
        system.assertEquals(true,ptfcController.isAtLeastOneAgreementSelected(ptfcController.fieldConfigSegmentOutputList));
        PageReference retPageRef = ptfcController.doSave();        
        PageReference defaultRetpageRef = PageUtils.redirect('/'+pt1.id);
        system.debug('url ='+retPageRef.getUrl());
        system.debug('defaultRetpageRef ='+defaultRetpageRef.getUrl());
        system.assertEquals(retPageRef.getUrl(), defaultRetpageRef.getUrl());
    } 
    
}