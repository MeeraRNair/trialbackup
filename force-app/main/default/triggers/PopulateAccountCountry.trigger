trigger PopulateAccountCountry on Contact (after insert, after update) {
   System.debug('CPU time1:'+Limits.getCpuTime());
    Set<id> accIds = new Set<id>();
    for(Contact con : Trigger.new){
        if(Trigger.isInsert || (Trigger.isUpdate&&con.country__c != Trigger.oldmap.get(con.id).Country__c)){
            accIds.add(con.accountId);
        }
    }
    if(accIds.size()>0){
        //Query and get All contacts
    Map<id,String> accidtoContactsMap = new Map<id,String>();
    for(Contact con : [Select id, Country__c,accountID from Contact where accountid IN :accIds] ) {
        if(accidtoContactsMap.get(con.accountid) != null && !accidtoContactsMap.get(con.accountid).contains(con.Country__c)){
            String cntry = accidtoContactsMap.get(con.accountid)+','+con.Country__c;
            accidtoContactsMap.remove(con.accountid);
            accidtoContactsMap.put(con.accountid,cntry);
        }
        else{
            accidtoContactsMap.put(con.accountID, con.Country__c); 
        }
    }
    
    //Create list of accounts to be updated
    List<Account> acctoupd = new List<Account>();
    for(Id accid : accidtoContactsMap.keyset()){
        acctoupd.add(new Account(id=accid, Account_Country__c =accidtoContactsMap.get(accid)) );
    }
    if(acctoupd.size()>0){
        update acctoupd;
      }
    }
    System.debug('CPU time2:'+Limits.getCpuTime());
}