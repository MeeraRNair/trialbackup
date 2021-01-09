/* 
Author: Jessie Tan

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     08-MAR-2010     Jessie Tan     Created to feed in data into AbortedApexJob component
2.0     06-JAN-2016     Jessie Tan     Modified for CR12515 to change the SOQL to get the aborted/failed apex job
3.0     22-June-2018    Rahul Mishra   Code Reduce!
*/

public class AbortedApexJobManager{
    
    private final List<AsyncApexJobWrapper> jobs = new List<AsyncApexJobWrapper>();
    
    //2.0 - start
    public class AsyncApexJobWrapper{
        public AsyncApexJob job {get;set;}
        public String getFormattedCompletedDate(){
            return ((this.job != null && this.job.CompletedDate !=null)? this.job.CompletedDate.format() : '');
        } 
        public String getFormattedCreatedDate(){
            return ((this.job != null && this.job.CreatedDate !=null)? this.job.CreatedDate.format() : '');
        } 
        public AsyncApexJobWrapper( AsyncApexJob job){
            this.job = job;
        }
           
    }
    //2.0 - end 
    
    
    public AbortedApexJobManager() {
        
         DateTime endDate = DateTime.now();                
         DateTime startDate = endDate.addDays(-1);
         
         //2.0 - start
         DateTime startDate2dayAgo = endDate.addDays(-2);
       
         List<AsyncApexJob> retrievedJobs = [Select ApexClass.Name, CreatedDate, CompletedDate, ExtendedStatus, 
                    JobItemsProcessed, JobType, MethodName, NumberOfErrors, Status, TotalJobItems 
                    From AsyncApexJob
                    where JobType IN ('BatchApex', 'ScheduledApex')
                    and ApexClass.Name != 'AbortedApexJobReporter'
                    and (
                        Status IN ('Aborted', 'Failed') 
                              OR
                        (Status = 'Completed' and NumberOfErrors > 0)
                    ) 
                    and (
                            (CompletedDate  != null and CompletedDate >:startDate and CompletedDate <:endDate )
                             OR
                            (CompletedDate  = null and CreatedDate >:startDate2dayAgo and CreatedDate <:endDate )
                    )  
                    order by CompletedDate, CreatedDate desc 
            ];
     
         
         for (AsyncApexJob job : retrievedJobs){
             jobs.add(new AsyncApexJobWrapper(job));
         }
    
    }
    
    public String getSalesforceServerURL(){
       
        return System.URL.getSalesforceBaseUrl().getHost().remove('-api' );
    }
            
    public List<AsyncApexJobWrapper> getAbortedApexJobs() {
        return jobs;
    }
}