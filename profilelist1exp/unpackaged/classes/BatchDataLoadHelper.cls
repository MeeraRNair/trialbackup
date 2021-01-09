/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      13668       FY17-DCS-0103   15-Dec-2016     Fenny           Schedule a batch job to data loading Opportunity records
 * 2.0      13796       FY17-DCS-0103   15-Dec-2016     Fenny           Schedule a batch job to data loading Account records
*/

public class BatchDataLoadHelper{
    public static void getHelper(Schema.DescribeSObjectResult result, Map<Id, sObject> objMap){
        //try{
            if(result != null && objMap != null){
                // 1.0
                if(result.getName().equals('Opportunity')){
                    OpportunityDataLoadHelper.execute((List<Opportunity>)objMap.values());
                    
                // 2.0    
                }else if(result.getName().equals('Account')){
                    AccountDataLoadHelper.execute((List<Account>)objMap.values());
                }
            }
        //}catch(Exception ex){
            //throw ex;
        //}
    }
}