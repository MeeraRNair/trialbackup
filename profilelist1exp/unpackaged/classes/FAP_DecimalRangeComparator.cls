/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
global class FAP_DecimalRangeComparator implements FAP_ObjectComparator{

    global Integer compare(Object object1, Object object2){
        if(object1==null || !(object1 instanceof FAP_DecimalRange)
        || object2==null || !(object2 instanceof FAP_DecimalRange)){
            throw new FAP_IllegalArgumentException();
        }
        Decimal dr1 = ((FAP_DecimalRange) object1).min();
        Decimal dr2 = ((FAP_DecimalRange) object2).min();
        if(dr1 < dr2){
            return -1;
        } else if(dr1 == dr2){
            return 0;
        }else{
            return 1;
        }
    }

}