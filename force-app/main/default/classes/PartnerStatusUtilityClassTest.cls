@isTest

public class PartnerStatusUtilityClassTest{

     private static testmethod void methodi(){
    
        PartnerStatusUtilityClass.RegisteredTypeList();
        PartnerStatusUtilityClass.RegisteredTypeContains('Test');
        PartnerStatusUtilityClass.RegisteredTypeNotContains('Test');
    
        PartnerStatusUtilityClass.PreferredTypeList();
        PartnerStatusUtilityClass.PreferredTypeContains('Test');
        PartnerStatusUtilityClass.PreferredTypeNotContains('Test');
        
        
        PartnerStatusUtilityClass.PremierTypeList();
        PartnerStatusUtilityClass.PremierTypeContains('Test');
        PartnerStatusUtilityClass.PremierTypeNotContains('Test');
        
        PartnerStatusUtilityClass.CertifiedTypeList();
        PartnerStatusUtilityClass.CertifiedTypeContains('Test');
        PartnerStatusUtilityClass.CertifiedTypeNotContains('Test');
        
        
        
        PartnerStatusUtilityClass.AuthorizedTypeList();
        PartnerStatusUtilityClass.AuthorizedTypeContains('Test');
        PartnerStatusUtilityClass.AuthorizedTypeNotContains('Test');
        
    }

}