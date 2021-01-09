global class Schedular_10DaysExpirationNotification  implements Schedulable {
   global void execute(SchedulableContext SC) {
      Batch_10DaysExpirationNotification M = new Batch_10DaysExpirationNotification(); 
      database.executebatch(M,integer.ValueOf(Label.ExpiryMail_BatchSize));
   
   }
}