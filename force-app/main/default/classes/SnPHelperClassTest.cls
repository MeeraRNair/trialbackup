@isTest
private class SnPHelperClassTest {

    static testMethod void SnPHelperClassTestMethod(){
    	S_P_Vendor_Automation__c svAuto = new S_P_Vendor_Automation__c(Vendor_Name__c = 'test');
        Database.insert(svAuto);
        
        S_P_Vendor_Partner_Information__c svPi = new S_P_Vendor_Partner_Information__c(Partner_Id__c = 'test1234', S_P_Vendor_Automation_Id__c = svAuto.Id);
        S_P_Vendor_Automation_Exception__c svAe = new S_P_Vendor_Automation_Exception__c(Field_API_Name__c = 'test__c', S_P_Vendor_Automation_Id__c = svAuto.Id);
        Database.insert(svPi);
        Database.insert(svAe);
        
        System.assertEquals(1, SnPHelperClass.svAutoList.size());//[SELECT Vendor_Name__c FROM S_P_Vendor_Automation__c LIMIT 1].Vendor_Name__c);
        System.assertEquals(1,SnPHelperClass.svpiList.size());//[SELECT Partner_Id__c FROM S_P_Vendor_Partner_Information__c WHERE S_P_Vendor_Automation_Id__c =: svAuto.Id LIMIT 1].Partner_Id__c);
        System.assertEquals(1,SnPHelperClass.svaeList.size());//[SELECT Object_Name__c FROM S_P_Vendor_Automation_Exception__c WHERE S_P_Vendor_Automation_Id__c =: svAuto.Id LIMIT 1].Object_Name__c);
        
        SnPHelperClass.setAlreadySet();
        SnPHelperClass.isAlreadySet();
        
    }
    
}