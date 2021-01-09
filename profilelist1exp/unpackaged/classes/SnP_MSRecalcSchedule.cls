global class SnP_MSRecalcSchedule Implements Schedulable
{
    
    global void execute(SchedulableContext sc)
    {
        processQueues(); //begin processing queues
    }
    
    public void processQueues()
    {
        if([SELECT count() FROM S_P_Vendor_Queue__c WHERE Status__c = 'Pending' LIMIT 1] > 0) //check whether there are Pending queues
        {
            SnP_MSRecalcSchedule__c rs = getOrCreateRecalcSchedule(); //creates or gets the custom setting SnP_MSRecalcSchedule__c
            
            if(rs.BatchID__c == null || (rs.BatchID__c != null && [SELECT count () FROM AsyncApexJob WHERE (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing') AND Id = :rs.BatchID__c] == 0))
            {
                
                if([SELECT count () FROM AsyncApexJob WHERE (Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing') AND JobType = 'BatchApex'] < 5)
                {
                    SnP_MSRecalcBatch rb = new SnP_MSRecalcBatch();
                    rs.BatchID__c = Database.executeBatch(rb);
                    //rs.Testing__c = 'pasok';
                    update rs;
                }
                else{   
                    Datetime execTime = (System.now()).addMinutes(60); //define the execution time of the schedulable class
                    String cronExp = '' + execTime.second() + ' ' + execTime.minute() + ' ' + execTime.hour() + ' ' + execTime.day() + ' ' + execTime.month() + ' ? ' + execTime.year(); //assign the defined time to a string
                    String emailAd = [SELECT CreatedBy.Email FROM CronTrigger WHERE Id =:rs.CronID__c LIMIT 1].CreatedBy.Email;
                    
                    if([SELECT count() FROM CronTrigger WHERE Id =:rs.CronID__c LIMIT 1] > 0) //if the schedulable class exists, abort the previous one
                        System.abortJob(rs.CronID__c);
                    
                    SnP_MSRecalcSchedule rsNext = new SnP_MSRecalcSchedule();
                    
                    rs.CronID__c = System.schedule('SnPMSRecalculation', cronExp, rsNext); //schedule run
                
                    update rs;
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {emailAd};
                    mail.setToAddresses(toAddresses);
                    mail.setSubject('Microsoft Batch Recalculation Delayed');
                    mail.setPlainTextBody('Microsoft Batch Recalculation process has been delayed due to too many Batch Apex on queue in the organization. The batch will automatically run again in one(1) hour.\n\nThank you.');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    
                
                
                }
                    
                        
            }
                                                                                                                  
        }
    }
    
    public SnP_MSRecalcSchedule__c getOrCreateRecalcSchedule()
    {
        SnP_MSRecalcSchedule__c rsNew = SnP_MSRecalcSchedule__c.getInstance('SRECALCSCHEDULE'); //get the instance of a record with name 'SRECALCSCHEDULE'
            
        if(rsNew == null) //if there is no instance of such record mentioned above, create it
        {
            rsNew = new SnP_MSRecalcSchedule__c(Name = 'SRECALCSCHEDULE');
            insert rsNew;
        }
        
        return rsNew; //return it on the prior method, this is needed to track Batch ID
    }
}