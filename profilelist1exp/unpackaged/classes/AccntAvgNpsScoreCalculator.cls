/***********************************************************
    * Name          : AccntAvgNpsScoreCalculator 
    * Description   : An Abstract class to calculate the average of NPS score for a given Account
    * ---------------------------------------------------------
    * Revision  Name             Date         Description
    * 1.0       Jessie Tan       24-Apr-2014  CR 9548  - An Abstract class to calculate the average of NPS score for a given Account
************************************************************/

global abstract class AccntAvgNpsScoreCalculator implements TempDataHolderAndCalculator{

    protected Map<String, List<Double>> accountScoreMap;
    
    global abstract AggregateResult[] querySourceData(Set<Id> accountIdSet);
    
    public void storeSourceData(Set<Id> accountIdSet){
        
        accountScoreMap = new Map<String, List<Double>>();
        
        AggregateResult[] contactScoreArray = querySourceData(accountIdSet);
        
        System.debug('### Total average NPS Score records of all the accounts : ' + contactScoreArray.size());
        
        for (integer i=0; i<=contactScoreArray.size()-1; i++){                 
            if(!accountScoreMap.containsKey((String)contactScoreArray[i].get('accountId'))){
                accountScoreMap.put((String)contactScoreArray[i].get('accountId'), new List<Double>());
            }    
            accountScoreMap.get(((String)contactScoreArray[i].get('accountId'))).add(((Decimal)contactScoreArray[i].get('avgScore')).doubleValue());                
            System.debug('### Storing average NPS Score records for account ' + contactScoreArray[i].get('accountId') + ' : ' + contactScoreArray[i].get('avgScore'));
        }
        
    }
    
    public Double calculateResult(String accountId){
        
        if(accountScoreMap ==null || accountScoreMap.size() <=0)
            return 0;
            
        if(!accountScoreMap.containsKey(accountId))
            return 0;
               
        if(accountScoreMap.get(accountId)==null || accountScoreMap.get(accountId).size() <=0)
            return 0;
        
        List<Double> contactNpsList = accountScoreMap.get(accountId);
            
        Double sum = 0;
        Integer count = 0;
                                 
        for(Double contactNps : contactNpsList ){
            sum += contactNps;
            ++count;
        }
        
        System.debug('### Account : ' + accountId + ', Overall Sum : ' + sum + ', Overall Count : ' + count + ', Average NPS Result : ' + sum/count);
        
        return sum/count;     
                               
    }
    
}