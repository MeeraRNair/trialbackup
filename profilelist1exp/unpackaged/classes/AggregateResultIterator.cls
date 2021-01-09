/*
 * Author   : Ashok
 * Purpose  : The batch apex class implements AggregateResult.
 *        
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 14988    FY18-DCS-1101   03-OCT-2017     Ashok           Optimization of Aggregate query 
*/
global class AggregateResultIterator implements Iterator<AggregateResult> {
  AggregateResult [] results {get;set;}
  // tracks which result item is returned
  Integer index {get; set;} 
       
  global AggregateResultIterator(String query) {
    index = 0;
    results = Database.query(query);            
  } 

  global boolean hasNext(){ 
    return results != null && !results.isEmpty() && index < results.size(); 
  }    

  global AggregateResult next(){        
    return results[index++];            
  }       
}