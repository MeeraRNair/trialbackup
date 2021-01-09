global class BatchRunAllTestClassesExecute implements Schedulable {
    global static void execute(SchedulableContext ctx) {
        BatchRunAllTestClasses batch = new BatchRunAllTestClasses();
        batch.queryString = 'SELECT Id FROM ApexClass WHERE Name != \'BatchRunAllTestClasses\' AND Name != \'BatchRunAllTestClassesTest\' AND Name != \'BatchRunAllTestClassesExecute\'';
        Database.executeBatch(batch);
    }   
}