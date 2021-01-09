/***********************************************************
* Name          : newAccountPlanController 
* Description   : Controller class for record type selection for lightning
* ---------------------------------------------------------
* Revision      Release     				Name            Date            Description
* 1.0           FY19-DCS-0602(CR 15665)		Meera			20-April-2018   Controller class to support lightning compoenent for RT selection                                             
* 1.1			FY20-0102					Kamaal			24-Oct-2019		Method getRecTypeName added to fetch the Account RT
* 
* 
************************************************************/
public class NewAccountPlanController {	
    
   @AuraEnabled        
    public static List<RecordType> fetchRecordTypeValues(){
        return([SELECT Description,IsActive,Name FROM RecordType WHERE SobjectType = 'SFDC_Acct_Plan__c' AND IsActive = True]);
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String strRecordTypeLabel){
        return(IdLookupUtils.getRecordTypeId(strRecordTypeLabel,'SFDC_Acct_Plan__c', TRUE));
    }
    @AuraEnabled
    public static String getRecTypeName(String strAccId){
        String strRecTypeName;
        Account objAcc=[select id,recordtypeid from Account where id=:strAccId limit 1];
        strRecTypeName=Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(objAcc.RecordTypeId).getName();
        return strRecTypeName;
    } 
}