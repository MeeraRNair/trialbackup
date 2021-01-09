/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 13379                02-Aug-2016     Meera         Customer Selection - Check Duplicates before Adding New Customer
 * 
 * 
 *      
 */


public class DealReg_CustomerSelectionHelper {
    
    //Method to check duplicate for an end customer
    public static End_Customer__c checkEndCustomerDuplicate(String dunsnum, String customername, Id partneraccid){
       List<End_Customer__c>  endcustlist = new List<End_Customer__c>();
        End_Customer__c duplicateEndCustomer = null ;
        if(dunsnum != null){
             endcustlist = [SELECT id,Name, Mailing_country__c, Mailing_street__c, Mailing_city__c, Tax_Id__c, Mailing_State__c, Zip_Code__c, Account_Department__c, Segment__c, Website__c FROM End_Customer__c WHERE Status__c = 'Active' AND  DUNS_Number__c =:dunsnum AND Partner_Account__c = :partneraccid limit 1 ];
        }
        
        else if(customername != null){
            endcustlist = [SELECT id,Name,Mailing_country__c, Mailing_street__c, Mailing_city__c, Tax_Id__c, Mailing_State__c, Zip_Code__c, Account_Department__c, Segment__c, Website__c FROM End_Customer__c WHERE Name =:customername AND Status__c = 'Active' AND Partner_Account__c = :partneraccid limit 1 ];
        }
        
        if(endcustlist.size()>0){
            duplicateEndCustomer = new End_Customer__c();
            duplicateEndCustomer = endcustlist[0];
        }
        return duplicateEndCustomer;
    }
    
    //Method to check duplicate for an end customer contact
    public static String checkEndCustomerContactDuplicate(String email, String endcustomerid){
       List<End_Customer_Contact__c>  endcustcontactlist = new List<End_Customer_Contact__c>();
        String duplicate = 'None';
        if(email != null && endcustomerid != null){
            endcustcontactlist = [SELECT id,Name,Last_Name__c FROM End_Customer_Contact__c WHERE email__c =:email AND Status__c = 'Active'  AND End_Customer__c = :endcustomerid limit 1 ];
        }       
               
        if(endcustcontactlist.size()>0){
            duplicate = endcustcontactlist[0].Name + ' '+endcustcontactlist[0].Last_Name__c;
        }
        return duplicate;
    }
    
    //Method to check with Dunsnumber and insert End User Account Name:

    public static End_Customer__c EndCustomerDunsNumber(string selectedduns){
          End_Customer__c duplicateDuns = New End_Customer__c();    
          List<End_Customer__c> endCustomerDunsList = new List<End_Customer__c>();
          endCustomerDunsList = [Select id,DUNS_Number__c,End_User_Account__c,End_User_Account__r.Account_ID__c  from End_Customer__c where Status__c = 'Active' AND Source_System__c = 'Deal Registration' 
                                 AND End_User_Account__r.Calculated_Status__c = 'Active' AND End_User_Account__r.Account_ID__c != Null 
                                 AND End_User_Account__r.Unassigned_End_User_Account__c = false AND DUNS_Number__c =:selectedduns];
       
        /* endCustomerDunsList = [Select id,DUNS_Number__c,End_User_Account__c from End_Customer__c where DUNS_Number__c =:selectedduns AND End_User_Account__r.Calculated_Status__c = 'Active'
                                  AND End_User_Account__r.Account_ID__c != Null AND End_User_Account__r.Unassigned_End_User_Account__c = false
                                  AND Status__c = 'Active' AND Source_System__c = 'Deal Registration']; 

                                  End_Customer__c duplicateDuns = DealReg_CustomerSelectionHelper.EndCustomerDunsNumber(selectedduns);
*/
        system.debug('***endcusLIst:'+endCustomerDunsList);
          if(endCustomerDunsList.size() >0 ){
            set<id> endCustomersUserAccount = new set<id>();
            for (End_Customer__c endCustomer: endCustomerDunsList){
                 endCustomersUserAccount.add(endCustomer.End_User_Account__c);
               }
            if (endCustomersUserAccount.size()==1){
                duplicateDuns = endCustomerDunsList[0];
                system.debug('***duplicateDuns:'+duplicateDuns);
                return duplicateDuns;
              
              }
            } 
             return null;
    }  
}