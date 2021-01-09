trigger contacteventTrigger on ContactChangeEvent (after insert) {
    System.debug('CPU time1:'+Limits.getCpuTime());
    Set<id> accIds = new Set<id>();
    for(ContactChangeEvent ce : Trigger.new){
        System.debug(ce);
        System.debug(ce.AccountId);
         EventBus.ChangeEventHeader header = ce.ChangeEventHeader;
        if(header.changetype == 'CREATE'){
            if(ce.country__c != null){
                accIds.add(ce.AccountId);
            }
        }
    }
     if(accIds.size()>0){
        //Query and get All contacts
    Map<id,String> accidtoContactsMap = new Map<id,String>();
    for(Contact con : [Select id, Country__c,accountID from Contact where accountid IN :accIds] ) {
        if(accidtoContactsMap.get(con.accountid) != null && !accidtoContactsMap.get(con.accountid).contains(con.Country__c)){
            String cntry = accidtoContactsMap.get(con.accountid)+','+con.Country__c;
            System.debug('cntry:'+cntry);
            accidtoContactsMap.remove(con.accountid);
            accidtoContactsMap.put(con.accountid,cntry);
            System.debug('accidtoContactsMapinside loop if:'+accidtoContactsMap);
        }
        else if(accidtoContactsMap.get(con.accountid) == null){
            accidtoContactsMap.put(con.accountID, con.Country__c); 
                        System.debug('accidtoContactsMapinside loop else:'+accidtoContactsMap);
        }
    }
    System.debug('accidtoContactsMap:'+accidtoContactsMap);
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