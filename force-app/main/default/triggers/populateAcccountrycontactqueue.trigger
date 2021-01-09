trigger populateAcccountrycontactqueue on Contact (after insert,after update) {
    Set<id> accIds = new Set<id>();
    for(Contact con : Trigger.new){
        if(Trigger.isInsert || (Trigger.isUpdate&&con.country__c != Trigger.oldmap.get(con.id).Country__c)){
            accIds.add(con.accountId);
        }
    }
    if(accIds.size()>0){
        PopulateAccountCountryQueue myq = new PopulateAccountCountryQueue(accIds);
        ID jobID = System.enqueueJob(myq);
    }
}