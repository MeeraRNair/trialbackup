/*
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      13796       FY17-DCS-0103   15-Dec-2016     Fenny           Schedule a batch job to data loading account records
*/

public class AccountDataLoadHelper{
    public static void execute(List<Account> accounts){
        try{
            if(accounts != null && accounts.size() > 0){
                for(Account acc : accounts){
                    acc.Count_of_Trip_Reports_Temp__c            = acc.Count_of_Trip_Reports__c;
                    acc.Competitive_Information_Count_Temp__c    = acc.Competitive_Information_Count__c;
                    acc.Account_Plan_Count_Temp__c               = acc.Account_Plan_Count__c;
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}