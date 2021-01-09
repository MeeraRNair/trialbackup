@isTest
private class SystemBehaviorBypasserTest{
    
    static testmethod void testSkipAndResetValidationRules(){
        List<string> listObjectNames = new List<string>();
        listObjectNames.add('Account_Play__c, Certification_Tracker__c, Contact, Lead, Case, Campaign, Account');
        
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        
        System_Behavior_Bypasser__c bypasser = System_Behavior_Bypasser__c.getInstance(UserInfo.getUserId());
                                                
        system.assert(bypasser.Bypass_Account_Play_VRs__c);
        system.assert(bypasser.Bypass_Competency_Tracker_VRs__c);
        system.assert(bypasser.Bypass_Contact_VRs__c);
        system.assert(bypasser.Bypass_Lead_VRs__c);
        system.assert(!bypasser.Bypass_Opportunity_Line_Item_VRs__c);
        system.assert(!bypasser.Bypass_Opportunity_VRs__c);
        system.assert(!bypasser.Bypass_Trip_Report_VRs__c);
        system.assert(bypasser.Bypass_Case_VRs__c);
        system.assert(bypasser.Bypass_Campaign_VRs__c);
        system.assert(bypasser.Bypass_Account_VRs__c);
        
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjectNames);
        
        bypasser = System_Behavior_Bypasser__c.getInstance(UserInfo.getUserId());
                    
        system.assert(bypasser == null || bypasser.Id == null);

        listObjectNames.clear();
        listObjectNames.add('Account_Play__c, Certification_Tracker__c, Contact, Lead, OpportunityLineItem, Opportunity, CustomerInteraction__c');
        
        SystemBehaviorBypasser.setSkipValidationRules(listObjectNames);
        
        bypasser = System_Behavior_Bypasser__c.getInstance(UserInfo.getUserId());
       
        system.assert(bypasser.Bypass_Account_Play_VRs__c);
        system.assert(bypasser.Bypass_Competency_Tracker_VRs__c);
        system.assert(bypasser.Bypass_Contact_VRs__c);
        system.assert(bypasser.Bypass_Lead_VRs__c);
        system.assert(bypasser.Bypass_Opportunity_Line_Item_VRs__c);
        system.assert(bypasser.Bypass_Opportunity_VRs__c);
        system.assert(bypasser.Bypass_Trip_Report_VRs__c);

        listObjectNames.clear();
        listObjectNames.add('OpportunityLineItem, Opportunity, CustomerInteraction__c, Case, Campaign, Account');
        
        ResetSystemBehaviorBypasser.resetSkipValidationRules(listObjectNames);
        
        bypasser = System_Behavior_Bypasser__c.getInstance(UserInfo.getUserId());
        
        system.assert(bypasser.Bypass_Account_Play_VRs__c);
        system.assert(bypasser.Bypass_Competency_Tracker_VRs__c);
        system.assert(bypasser.Bypass_Contact_VRs__c);
        system.assert(bypasser.Bypass_Lead_VRs__c);
        system.assert(!bypasser.Bypass_Opportunity_Line_Item_VRs__c);
        system.assert(!bypasser.Bypass_Opportunity_VRs__c);
        system.assert(!bypasser.Bypass_Trip_Report_VRs__c);
        system.assert(!bypasser.Bypass_Case_VRs__c);
        system.assert(!bypasser.Bypass_Campaign_VRs__c);
        system.assert(!bypasser.Bypass_Account_VRs__c);
    }
}