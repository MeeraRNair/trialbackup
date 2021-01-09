/*
 * Author   : Abhishek Vishwakarma
 * Purpose  : Calculate number of Active Contacts to Account field 
 
 * Revision CR Number       Release No      Date            Modified By     Description
 * -------- ---------       ----------      -----------     ------------    -----------
 * 1.0                      Fy20 0802       10-July-2019     Abhishek         
 */
 
public class DCSEActiveContacts{

  //method to calculate the numner of contacts on the Account fieid
  public static void updateContactCount(List<Contact> listContacts,Map<Id,Contact> mapOldValues){
    
        set<Id> setAccountIds = new set<Id>();
         
        for(Contact objCon : listContacts){
            //store the opportunity ids based on the insert/delete case
            if(objCon.AccountId!=null && mapOldValues==null){
                setAccountIds.add(objCon.AccountId);
                
                }
            //store the opportuntity ids based on update case
            else if(objCon.AccountId!= null && mapOldValues!=null && objCon.Account_Active_Contact__c != mapOldValues.get(objCon.Id).Account_Active_Contact__c){
                if(objCon.AccountId!=mapOldValues.get(objCon.Id).AccountId){
                setAccountIds.add(mapOldValues.get(objCon.Id).AccountId);
                }
                setAccountIds.add(objCon.AccountId);
            }
        }
        
        //get all the filtered contacts in a Map 
        Map<Id,List<Contact>> mapFilteredContacts = new Map<Id,List<Contact>>();
        
        for(Contact objCon : [Select Id, AccountId from Contact where AccountId=:setAccountIds 
                                    AND Account_Active_Contact__c!=null]){
        
            if(mapFilteredContacts.containsKey(objCon.AccountId)){
                mapFilteredContacts.get(objCon.AccountId).add(objCon);
            }
            else
                mapFilteredContacts.put(objCon.AccountId,new List<Contact>{objCon});
        }
        
        List<Account> lstFilteredAccounts = new List<Account>();
        //iterate the account Id and set the count in the field
        for(Id objAccountId : mapFilteredContacts.keyset()){
            lstFilteredAccounts.add(new Account(Id=objAccountId, No_of_Active_Contacts__c=mapFilteredContacts.get(objAccountId).size()));
        }
        
        for(Id accId: setAccountIds){
            if(!mapFilteredContacts.containsKey(accId)){
                lstFilteredAccounts.add(new Account(Id=accId, No_of_Active_Contacts__c=0));
            }
        }
        //update the listofAccounts when it is not empty
        if(!lstFilteredAccounts.isEmpty())
            update lstFilteredAccounts;
    }   
}