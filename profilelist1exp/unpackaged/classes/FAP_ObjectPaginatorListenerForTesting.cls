global class FAP_ObjectPaginatorListenerForTesting implements FAP_ObjectPaginatorListener{

    global Boolean handlePageChangeInvoked {get;set;}
    
    global FAP_ObjectPaginatorListenerForTesting(){
        handlePageChangeInvoked = false;
    }
    
    global void handlePageChange(List<Object> newPage){
        handlePageChangeInvoked = true;
    }
    
}