/***********************************************************
* Revision      Release     Name         Date            Description
* 1.0           15.07       Rap Bernardo 30.06.2014      Created this helper class mainly for the static variables that calls generic SOQL queries.
*                                                        This is to avoid the Too Many SOQL errors. Other methods can be used for future SnP triggers to control recursive triggers.
************************************************************/

public class SnPHelperClass{

    //These 2 static lists are for the trigger, SnPVendorAfterUpdateBeforeInsertUpdateTrigger
    public static List<S_P_Vendor_Automation__c> svAutoList = [SELECT Vendor_Name__c, Is_Active__c, Automation_Type__c, CreatedDate FROM S_P_Vendor_Automation__c];
    public static List<S_P_Vendor_Partner_Information__c> svpiList = [SELECT Id, Name, Partner_ID__c, Segment__c, Country__c, Partner_Username__c, Is_Active__c, S_P_Vendor_Automation_ID__r.Vendor_Name__c FROM S_P_Vendor_Partner_Information__c];
    
    //Static list for the class, SnPDealRegistrationProcessSelector
    public static List<S_P_Vendor_Automation_Exception__c> svaeList = [SELECT Id, Name, Field_API_Name__c,Field_Name_Value__c, S_P_Vendor_Automation_ID__c, Is_Active__c FROM S_P_Vendor_Automation_Exception__c];
    
    private static Boolean alreadySet = false;
    
    public static boolean isAlreadySet() {
        return alreadySet;
    }
    
    public static void setAlreadySet() {
        alreadySet = true;
    }
    

}