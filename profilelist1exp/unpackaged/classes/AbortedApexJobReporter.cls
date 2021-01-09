/* 
Author: Jessie Tan

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     08-MAR-2010     Jessie Tan     Created to Report Aborted/Failed Apex Job 
2.0     06-JAN-2016     Jessie Tan     Modified for CR12515 to change the SOQL to get the correct count of aborted/failed apex job
3.0     22-June-2018    Rahul          Code Reduce! 
*/
global class AbortedApexJobReporter implements Schedulable{    

  public static boolean isTest = false;
  
  global static void execute(SchedulableContext sc){
      
      try{
      
          if (!isTest && isInTestingEnvironment()){
              return;
          }
          
          if(isAnyFailedApexJob())
              sendReportingEmail();
              
      }catch(Exception e){
          sendFailureEmail();          
      }
      
  }

  public static Boolean isAnyFailedApexJob() {
    
        DateTime endDate = DateTime.now();                
        DateTime startDate = endDate.addDays(-1);
        
        //2.0 - start
        DateTime startDate2dayAgo = endDate.addDays(-2);
        
        Integer count = 0;
        
        if (isTest){
            //for testing purpose
            count = [Select count() From AsyncApexJob
                         where JobType IN ('BatchApex', 'ScheduledApex')
                            and (Status IN ('Aborted', 'Failed') 
                                OR NumberOfErrors > 0) limit 1                            
            ];
        
        }else{        

            count = [Select count() From AsyncApexJob
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
            ];
            
        }

        return (count>0);
  }
  
  public static void sendReportingEmail() {    
        sendTextEmail(System.Label.ApexJobReporterEmailTemplateId);        
  }
  
  public static void sendFailureEmail() {    
        sendTextEmail(System.Label.ApexJobReporterFailureEmailTemplateId);        
  }
  
  public static boolean isInTestingEnvironment(){
      return (System.Label.ApexJobReporterInTesting.equalsIgnoreCase('true'));
  }
  
  private static List<String> getEmailRecipient(){
      String recipient = System.Label.ApexJobReporterRecipient;      
      String[] recipientList = recipient.split(',');      
      return recipientList ;
      
    }
  
    public static void sendTextEmail(String templateId) { 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setTemplateId(templateId); 
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setToAddresses(getEmailRecipient());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}