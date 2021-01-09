global class VOVisitBundleUpdateScheduled Implements Schedulable{
	global void execute(SchedulableContext sc) {
    	Database.executeBatch(new VOVisitBundleUpdateBatch());
    }
}