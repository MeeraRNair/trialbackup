/*
 * Author   : Nagendra Singh
 * Purpose  : Schedule class for Batch Batch_RecalculateLeadOwner.
 *        
 * Revision Ref Number  Release No  Date            Modified By        Description
 * -------- ----------  ----------  -----------     ------------       -----------
 * 1.0      CR 12316    17.02       13-N0v-2015     Nagendra Singh     LM2_1_34-Account transition for Lead2.0
 * 2.0      CR 15143    FY19-0203   13-Nov-2017     Ashok              Spliting the batch job
 * 
 */


global class Batch_RecalculateLeadOwner_Schedule implements Schedulable {
   /*Note : Use this code for schedule this batch
            system.schedule('Recalculate Lead Owner', '0 0 8 * * ?', new Batch_RecalculateLeadOwner_Schedule ()); */
   global void execute(SchedulableContext ctx) {
      DateTime dtStartDate = System.now().date() - 90; // V2.0
      DateTime dtEndDate = System.now().date() - 30;//31 days back
      Batch_RecalculateLeadOwner RLO = new Batch_RecalculateLeadOwner(dtStartDate,dtEndDate);
        database.executeBatch(RLO,200);
   }   
}