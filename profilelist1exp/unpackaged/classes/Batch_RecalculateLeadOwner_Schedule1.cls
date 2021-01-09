/*
 * Author   : Ashok G
 * Purpose  : Schedule class for Batch Batch_RecalculateLeadOwner to process the leads from 2-30 days
 *        
 * Revision Ref Number  Release No  Date            Modified By        Description
 * -------- ----------  ----------  -----------     ------------       -----------
  1.0      CR 15143    FY19-0203   13-Nov-2017     Ashok              Spliting the batch job
      
 * 
 */


global class Batch_RecalculateLeadOwner_Schedule1 implements Schedulable {
   /*Note : Use this code for schedule this batch
            system.schedule('Recalculate Lead Owner', '0 0 8 * * ?', new Batch_RecalculateLeadOwner_Schedule ()); */
   global void execute(SchedulableContext ctx) {
      DateTime dtStartDate = System.now().date() - 30;
      DateTime dtEndDate = System.now().date() - 1;//2 days back
      Batch_RecalculateLeadOwner RLO = new Batch_RecalculateLeadOwner(dtStartDate,dtEndDate);
        database.executeBatch(RLO,200);
   }   
}