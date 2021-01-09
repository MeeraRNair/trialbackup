/*******************************
 * Opportunity Triger to update Opportunity name with Account name
 * 
 * ********************************/
trigger OppTrigger on Opportunity (before insert) {
    Set<id> accids = new Set<id>();
    for (Opportunity opp : Trigger.new){
        accids.add(opp.accountid);
    }
    //Query account to fetch name
    Map<id,Account> accMap = new Map<id,Account>([select id,name from Account where id IN :accids]);
    for(Opportunity opp : Trigger.new){
        opp.name = accMap.get(opp.accountid).name+' '+opp.name;
    }
}