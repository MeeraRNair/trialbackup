/*
 * Revision CR Number   Release No  Date            Created/Modified By         Description
 * -------- ---------   ----------  -----------     --------------------        -----------
 * 1.0      CR#14155    FY18-0602   19-Apr-2017     Venkateswarlu Chirala      LOBi_AutoAccSchDispatcher is implemented through Design pattern to bypass the error 
 *                                                                             while changing Schedulable class already schduled (or) class has batch or future jobs 
 *                                                                             pending or in progress (or) this schedulable class has jobs pending or in progress
 *                                                                          ** Test Class for this class is: LOBi_SchDispatcher_Batch_RulesTest
 * 
 *                                                                                                          
 */
 
  global class LOBi_AutoAccSchDispatcher Implements Schedulable {

     /** 
      * @author Venkateswarlu Chirala
      * @date  19-Apr-2017
      * @description IScheduleDispatched Interface used in "LOBi_AutoAccSchDispatcherHandler" Apex class to overrride execute method.
      * 
      */
     public Interface IScheduleDispatched {
         void execute(SchedulableContext sc);
     }
     
     /** 
      * @author Venkateswarlu Chirala
      * @date  19-Apr-2017
      * @description Using the Type.NewInstance method to create the class "LOBi_AutoAccSchDispatcherHandler" dynamically prevents the platform 
      *              from seeing it as a dependent class
      * 
      *@param SchedulableContext Interface a class that implements the Schedulable interface and contains the scheduled job ID.
      */
     global void execute(SchedulableContext sc) {
         Type targettype = Type.forName('LOBi_AutoAccSchDispatcherHandler');
         if (targettype != NULL) {
             IScheduleDispatched obj = (IScheduleDispatched) targettype.NewInstance();
             obj.execute(sc);
         }
     }
 }