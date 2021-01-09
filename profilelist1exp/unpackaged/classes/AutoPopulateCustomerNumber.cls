/*
Description: CR 9360 - Class to autopopulate customer number on an opportunity everytime an account is added/modified
Version: 1.0
Author: Devika Pujari
History:
1.0 - 04-aug-2011: Creation
2.0  Mohammad 13 may 2014 : Update Partner Account Owner Email field.
*/
public class AutoPopulateCustomerNumber{
  
  
  
 /*
 Mohammad- Auto Populate Partner Account Owner Email 
 
 ------Start------------
 */ 
  public void updatePartnerAccountEmail(list<Opportunity> oppList){
      map<Id, Account> oppAccMap = new map<Id, Account>();
      set<Id> accIds = new set<Id>();
      for(Opportunity opp: oppList){
          accIds.add(opp.PartnerAccountId);
      }
      system.debug('------accIds: '+accIds);
      list<Account> accList = new list<Account>();
      accList = [Select Id, Name, Owner.Email from Account where Id IN: accIds];
      map<Id, Account> accountMap = new map<Id, Account>();
      for(Account acc: accList){
          accountMap.put(acc.Id, acc);
      }
      system.debug('------accountMap: '+accountMap);
      for(Opportunity opp: oppList){
          oppAccMap.put(opp.Id, accountMap.get(opp.PartnerAccountId));
      }
      system.debug('------oppAccMap: '+oppAccMap);
      for(Opportunity opp: oppList){
          if(opp.PartnerAccountId != null){
              opp.Partner_Account_Owner_Email__c = oppAccMap.get(opp.Id).Owner.Email;
              opp.Partner_Account_Name__c = oppAccMap.get(opp.Id).Name;
          }
      }
  }
  /*
  ----END-------------
    Mohammad- Auto Populate Partner Account Owner Email 
  */
  
}