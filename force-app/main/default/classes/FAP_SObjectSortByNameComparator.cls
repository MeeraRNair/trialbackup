/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
global class FAP_SObjectSortByNameComparator implements FAP_ISObjectComparator {
    
    global Integer compare(SObject record1, SObject record2){
        if(record1 == null || record1.get('Name') == null){
            if(record2 == null || record2.get('Name') == null){
                return 0;
            } else {
                return -1;
            }
        }
        if(record2 == null || record2.get('Name') == null){
            return 1;
        }
        return (''+record1.get('Name')).compareTo(''+record2.get('Name'));
    }
    
}