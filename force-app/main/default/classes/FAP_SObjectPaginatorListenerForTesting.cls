/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
global class FAP_SObjectPaginatorListenerForTesting implements FAP_SObjectPaginatorListener{
    global Boolean handlePageChangeInvoked {get;set;}
    
    global FAP_SObjectPaginatorListenerForTesting(){
        handlePageChangeInvoked = false;
    }
    
    global void handlePageChange(List<SObject> newPage){
        handlePageChangeInvoked = true;
    }
    
}