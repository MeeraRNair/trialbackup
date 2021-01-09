trigger triggeronflowerror on FlowExecutionErrorEvent (after insert) {
    
    List<Exception__c> ecelist = new List<Exception__c>();
    for(FlowExecutionErrorEvent ex : Trigger.new){
        Exception__c excep = new Exception__c();
        excep.Object__c = ex.ContextObject;
        excep.Operation__c='Populate Account Partnership Level from Floww trigger';
        excep.Record_ID__c=ex.ContextRecordId;
        excep.Exception_Details__c =  ex.ErrorMessage;
        ecelist.add(excep);
    }
    
    if(ecelist.size()>0){
        insert ecelist;
    }
}