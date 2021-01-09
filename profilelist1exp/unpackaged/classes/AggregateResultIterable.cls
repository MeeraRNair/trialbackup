/*
 * Author   : Ashok
 * Purpose  : The batch apex class implements AggregateResult.
 *        
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 14988    FY18-DCS-1101   03-OCT-2017     Ashok           Optimization of Aggregate query 
*/
global class AggregateResultIterable implements Iterable<AggregateResult> {
  private String query;

  global AggregateResultIterable(String soql){
    query = soql;
  }

  global Iterator<AggregateResult> Iterator(){
    return new AggregateResultIterator(query);
  }
}