global class Batch_DeactiveInvalid_EndCust_Scheduler implements schedulable {

   global void execute(SchedulableContext sc){
       Batch_DeactivateInvalid_EndCustomers m = new Batch_DeactivateInvalid_EndCustomers();
       database.executebatch(m);
   }
     
   /* global static void executeBatch(Batch_DeactivateInvalid_EndCustomers batch) {       
    	database.executebatch(batch);        
    }*/
}
    
//  Batch_DeactiveInvalid_EndCust_Scheduler br = new Batch_DeactiveInvalid_EndCust_Scheduler(); 
    /*  String sch = '0 0 22 ? * SAT';
      System.schedule('Deactivate Invalid End Customers', sch, br);
       */