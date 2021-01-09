global class AppProtocolControlPolicyCondition implements TxnSecurity.PolicyCondition {

 public boolean evaluate(TxnSecurity.Event e) {
 
List<Application__c> ApplicationsList = Application__c.getAll().Values(); 
Set<String> ApplicationSet = new Set<String>();  
for(Application__c objApp : ApplicationsList ){
    ApplicationSet.add(objApp.Name);
}
    
LoginHistory eObj = [SELECT Application FROM LoginHistory WHERE Id = :e.data.get('LoginHistoryId')];
System.debug('---Application object::'+eObj);
if(ApplicationSet.contains(eObj.Application)) {
return false;
}

 return true; 
}
 }