global class BatchScopeQuery implements Database.Batchable<sObject> {
    
    global string query;

    global database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if(scope != null && scope.size() > 0){
            Batch_Scope_Query__c scopeQuery = null;
            BatchDataLoadScheduler dlBatchScheduler = null;
            TriggerExecutionControl__c control = null;
            List<TriggerExecutionControl__c> triggerExecutionControls = null;
            for(sObject obj : scope){
                system.debug('in BatchScopeQuery execute method');
                scopeQuery = (Batch_Scope_Query__c)obj;
                dlBatchScheduler = new BatchDataLoadScheduler();
                dlBatchScheduler.query = scopeQuery.Query__c;
                dlBatchScheduler.fieldToUpdate = scopeQuery.Field_to_update__c;
                dlBatchScheduler.newValue = scopeQuery.New_Value__c;
                dlBatchScheduler.objectName = scopeQuery.Name;
                dlBatchScheduler.batchSize = Integer.valueOf(scopeQuery.Batch_Size__c);
                dlBatchScheduler.needHelp = scopeQuery.Need_Helper__c;
                datetime todayNow = system.now().addMinutes(1);
                string runtime = todayNow.second() + ' ' + todayNow.minute() + ' ' + todayNow.hour() + ' ' + todayNow.day() + ' ' + todayNow.month() + ' ? ' + todayNow.year();
                system.schedule('Loading ' + scopeQuery.Name + ' @ ' + runtime, runtime, dlBatchScheduler);
            }
        }
    }

    global void finish(Database.BatchableContext BC){
    }
}