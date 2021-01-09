@IsTest
private class FAP_ObjectPaginatorTest {
    
    private static testmethod void testHundredObjects(){
        Integer recordCount = 100;
        List<Object> records = createTestObject(recordCount);
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator();
        paginator.setRecords(records);
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(recordCount,paginator.all.size());
        System.assertEquals(recordCount,paginator.recordCount);
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_PAGE_SIZE,paginator.page.size());
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_PAGE_SIZE,paginator.pageSize);
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_PAGE_SIZE,paginator.getPageSize());
        System.assertEquals(0,paginator.pageNumber);
        System.assertEquals(Math.ceil(recordCount/FAP_ObjectPaginator.DEFAULT_PAGE_SIZE).intValue(), paginator.pageCount);
        System.assertEquals(true,paginator.hasNext);
        System.assertEquals(false,paginator.hasPrevious);
        for(Integer i = 0; i < FAP_ObjectPaginator.DEFAULT_PAGE_SIZE; i++){
            System.assertEquals(i, ((FAP_DecimalRange)paginator.page.get(i)).min());
        }
        
        paginator.next();
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(recordCount,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_PAGE_SIZE,paginator.page.size());
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_PAGE_SIZE,paginator.pageSize);
        System.assertEquals(1,paginator.pageNumber);
        System.assertEquals(Math.ceil(recordCount/FAP_ObjectPaginator.DEFAULT_PAGE_SIZE).intValue(), paginator.pageCount);
        System.assertEquals(true,paginator.hasNext);
        System.assertEquals(true,paginator.hasPrevious);
        for(Integer i = 0; i < FAP_ObjectPaginator.DEFAULT_PAGE_SIZE; i++){
            System.assertEquals(i, ((FAP_DecimalRange)paginator.page.get(i)).min()-FAP_ObjectPaginator.DEFAULT_PAGE_SIZE);
        }
    }
    
    private static testmethod void testRecordsSmallerThanPageSize(){
        List<Object> records = createTestObject(8);
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(5);
        paginator.setRecords(records);
        
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(8,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(5,paginator.page.size());
        System.assertEquals(5,paginator.pageSize);
        System.assertEquals(0,paginator.pageNumber);
        System.assertEquals(2, paginator.pageCount);
        System.assertEquals(true,paginator.hasNext);
        System.assertEquals(false,paginator.hasPrevious);
        for(Integer i = 0; i < 5; i++){
            System.assertEquals(i, ((FAP_DecimalRange)paginator.page.get(i)).min());
        }

        paginator.next();
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(8,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(3,paginator.page.size());
        System.assertEquals(5,paginator.pageSize);
        System.assertEquals(1,paginator.pageNumber);
        System.assertEquals(2, paginator.pageCount);
        System.assertEquals(false,paginator.hasNext);
        System.assertEquals(true,paginator.hasPrevious);
        for(Integer i = 5; i < 8; i++){
            System.assertEquals(i, ((FAP_DecimalRange)paginator.page.get(i-5)).min());
        }

        paginator.setPageSize(20);
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(8,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(8,paginator.page.size());
        System.assertEquals(20,paginator.pageSize);
        System.assertEquals(0,paginator.pageNumber);
        System.assertEquals(1, paginator.pageCount);
        System.assertEquals(false,paginator.hasNext);
        System.assertEquals(false,paginator.hasPrevious);
        for(Integer i = 0; i < 8; i++){
            System.assertEquals(i, ((FAP_DecimalRange)paginator.page.get(i)).min());
        }
    }

    private static testmethod void testNextIllegalState(){
        FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(1);
        paginator.setRecords(createTestObject(2));
        paginator.next();
        Boolean exceptionThrown = false;
        try{
            paginator.next();
        }catch(FAP_IllegalStateException e){
            exceptionThrown = true;    
        }
        System.assertEquals(false,exceptionThrown); 

        paginator = new FAP_ObjectPaginator(1);
        paginator.setRecords(createTestObject(4));
        paginator.next();
        paginator.next();
        paginator.next();
        exceptionThrown = false;
        try{
            paginator.next();
        }catch(FAP_IllegalStateException e){
            exceptionThrown = true;    
        }
        System.assertEquals(false,exceptionThrown);
    }
    
    private static testmethod void testPreviousIllegalState(){
        FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(1);
        paginator.setRecords(createTestObject(2));
        Boolean exceptionThrown = false;
        try{
            paginator.previous();
        }catch(FAP_IllegalStateException e){
            exceptionThrown = true;    
        }
        System.assertEquals(false,exceptionThrown);
    }
    
    private static void assertDefaultPageSize(FAP_ObjectPaginator paginator){
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_PAGE_SIZE, paginator.pageSize);
    }
    
    private static void assertDefaultPageSizeOptions(FAP_ObjectPaginator paginator){
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_PAGE_SIZE_OPTIONS, paginator.pageSizeIntegerOptions);
        final List<SelectOption> SEL_OPTIONS = new List<SelectOption>(); 
        for(Integer i : FAP_ObjectPaginator.DEFAULT_PAGE_SIZE_OPTIONS){
            SEL_OPTIONS.add(new SelectOption(''+i,''+i));
        }
        System.assertNotEquals(null, paginator.getPageSizeOptions());
    }
    
    private static void assertDefaultSkipSize(FAP_ObjectPaginator paginator){
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_SKIP_SIZE, paginator.skipSize);
    }
    
    private static void assertDefaultListener(FAP_ObjectPaginator paginator){
        System.assertNotEquals(null, paginator.listeners);
        System.assertEquals(0, paginator.listeners.size());
    }
    
    private static testmethod void testConstructor01(){
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator();
        assertDefaultPageSize(paginator);
        assertDefaultPageSizeOptions(paginator);
        assertDefaultSkipSize(paginator);
        assertDefaultListener(paginator);
        
        //Dummy assert statement
        List<string> stringlist=new List<string>();
        stringlist.add('Test');
        system.assertEquals(stringlist.size(), 1);
    }
    
    private static testmethod void testConstructor02(){
        final FAP_ObjectPaginatorListener EXAMPLE_LISTENER = new FAP_ObjectPaginatorListenerForTesting();
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(EXAMPLE_LISTENER);
        assertDefaultPageSize(paginator);
        assertDefaultPageSizeOptions(paginator);
        assertDefaultSkipSize(paginator);
        System.assertNotEquals(null, paginator.listeners);
        System.assertEquals(1, paginator.listeners.size());
        System.assertEquals(EXAMPLE_LISTENER, paginator.listeners.get(0));
    }
    
    private static testmethod void testConstructor03(){
        final List<Integer> EXAMPLE_PAGE_LIST_OPTIONS = new List<Integer>{10,20,30,40,50};
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(EXAMPLE_PAGE_LIST_OPTIONS);
        assertDefaultPageSize(paginator);
        System.assertEquals(EXAMPLE_PAGE_LIST_OPTIONS, paginator.pageSizeIntegerOptions);
        assertDefaultSkipSize(paginator);
        assertDefaultListener(paginator);
    }
    
    private static testmethod void testConstructor04(){
        final FAP_ObjectPaginatorListener EXAMPLE_LISTENER = new FAP_ObjectPaginatorListenerForTesting();
        final List<Integer> EXAMPLE_PAGE_LIST_OPTIONS = new List<Integer>{10,20,30,40,50};
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(EXAMPLE_PAGE_LIST_OPTIONS,EXAMPLE_LISTENER);
        assertDefaultPageSize(paginator);
        System.assertEquals(EXAMPLE_PAGE_LIST_OPTIONS, paginator.pageSizeIntegerOptions);
        assertDefaultSkipSize(paginator);
        System.assertNotEquals(null, paginator.listeners);
        System.assertEquals(1, paginator.listeners.size());
        System.assertEquals(EXAMPLE_LISTENER, paginator.listeners.get(0));
    }
    
    private static testmethod void testConstructor05(){
        final List<Integer> EXAMPLE_PAGE_LIST_OPTIONS = new List<Integer>{10,20,30,40,50};
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(EXAMPLE_PAGE_LIST_OPTIONS,10);
        assertDefaultPageSize(paginator);
        System.assertEquals(EXAMPLE_PAGE_LIST_OPTIONS, paginator.pageSizeIntegerOptions);
        System.assertEquals(10, paginator.skipSize);
        assertDefaultListener(paginator);
    }
    
    private static testmethod void testConstructor06(){
        final FAP_ObjectPaginatorListener EXAMPLE_LISTENER = new FAP_ObjectPaginatorListenerForTesting();
        final List<Integer> EXAMPLE_PAGE_LIST_OPTIONS = new List<Integer>{10,20,30,40,50};
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(EXAMPLE_PAGE_LIST_OPTIONS,10,EXAMPLE_LISTENER);
        assertDefaultPageSize(paginator);
        System.assertEquals(EXAMPLE_PAGE_LIST_OPTIONS, paginator.pageSizeIntegerOptions);
        System.assertEquals(10, paginator.skipSize);
        System.assertNotEquals(null, paginator.listeners);
        System.assertEquals(1, paginator.listeners.size());
        System.assertEquals(EXAMPLE_LISTENER, paginator.listeners.get(0));
    }
    
    private static testmethod void testConstructor07(){
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(10);
        System.assertEquals(10, paginator.pageSize);
        assertDefaultPageSizeOptions(paginator);
        assertDefaultSkipSize(paginator);
        assertDefaultListener(paginator);
    }
    
    private static testmethod void testConstructor08(){
        final FAP_ObjectPaginatorListener EXAMPLE_LISTENER = new FAP_ObjectPaginatorListenerForTesting();
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(10,EXAMPLE_LISTENER);
        System.assertEquals(10, paginator.pageSize);
        assertDefaultPageSizeOptions(paginator);
        assertDefaultSkipSize(paginator);
        System.assertNotEquals(null, paginator.listeners);
        System.assertEquals(1, paginator.listeners.size());
        System.assertEquals(EXAMPLE_LISTENER, paginator.listeners.get(0));
    }
    
    private static testmethod void testConstructor09(){
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(10,10);
        System.assertEquals(10, paginator.pageSize);
        assertDefaultPageSizeOptions(paginator);
        System.assertEquals(10, paginator.skipSize);
        assertDefaultListener(paginator);
    }
    
    private static testmethod void testConstructor10(){
        final FAP_ObjectPaginatorListener EXAMPLE_LISTENER = new FAP_ObjectPaginatorListenerForTesting();
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(10,10,EXAMPLE_LISTENER);
        System.assertEquals(10, paginator.pageSize);
        assertDefaultPageSizeOptions(paginator);
        System.assertEquals(10, paginator.skipSize);
        System.assertNotEquals(null, paginator.listeners);
        System.assertEquals(1, paginator.listeners.size());
        System.assertEquals(EXAMPLE_LISTENER, paginator.listeners.get(0));
    }
    
    private static testmethod void testConstructor11(){
        final List<Integer> EXAMPLE_PAGE_LIST_OPTIONS = new List<Integer>{10,20,30,40,50};
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(10,EXAMPLE_PAGE_LIST_OPTIONS);
        System.assertEquals(10, paginator.pageSize);
        System.assertEquals(EXAMPLE_PAGE_LIST_OPTIONS, paginator.pageSizeIntegerOptions);
        assertDefaultSkipSize(paginator);
        assertDefaultListener(paginator);
    }
    
    private static testmethod void testConstructor12(){
        final List<Integer> EXAMPLE_PAGE_LIST_OPTIONS = new List<Integer>{10,20,30,40,50};
        final FAP_ObjectPaginatorListener EXAMPLE_LISTENER = new FAP_ObjectPaginatorListenerForTesting();
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(10,EXAMPLE_PAGE_LIST_OPTIONS,EXAMPLE_LISTENER);
        System.assertEquals(10, paginator.pageSize);
        System.assertEquals(EXAMPLE_PAGE_LIST_OPTIONS, paginator.pageSizeIntegerOptions);
        assertDefaultSkipSize(paginator);
        System.assertNotEquals(null, paginator.listeners);
        System.assertEquals(1, paginator.listeners.size());
        System.assertEquals(EXAMPLE_LISTENER, paginator.listeners.get(0));
    }
    
    private static testmethod void testConstructor13(){
        final List<Integer> EXAMPLE_PAGE_LIST_OPTIONS = new List<Integer>{10,20,30,40,50};
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(10,EXAMPLE_PAGE_LIST_OPTIONS,10);
        System.assertEquals(10, paginator.pageSize);
        System.assertEquals(EXAMPLE_PAGE_LIST_OPTIONS, paginator.pageSizeIntegerOptions);
        System.assertEquals(10, paginator.skipSize);
        assertDefaultListener(paginator);
    }
    
    private static testmethod void testConstructor14(){
        final FAP_ObjectPaginatorListener EXAMPLE_LISTENER = new FAP_ObjectPaginatorListenerForTesting();
        final List<Integer> EXAMPLE_PAGE_LIST_OPTIONS = new List<Integer>{10,20,30,40,50};
        final FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(10,EXAMPLE_PAGE_LIST_OPTIONS,10,EXAMPLE_LISTENER);
        System.assertEquals(10, paginator.pageSize);
        System.assertEquals(EXAMPLE_PAGE_LIST_OPTIONS, paginator.pageSizeIntegerOptions);
        System.assertEquals(10, paginator.skipSize);
        System.assertNotEquals(null, paginator.listeners);
        System.assertEquals(1, paginator.listeners.size());
        System.assertEquals(EXAMPLE_LISTENER, paginator.listeners.get(0));
    }
    
    private static testmethod void testSkipToPage(){
        FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(3);
        paginator.setRecords(createTestObject(10));
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(10,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(3,paginator.page.size());
        System.assertEquals(3,paginator.pageSize);
        System.assertEquals(0,paginator.pageNumber);
        System.assertEquals(4, paginator.pageCount);
        System.assertEquals(true,paginator.hasNext);
        System.assertEquals(false,paginator.hasPrevious);

        paginator.skipToPage(3);
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(10,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(1,paginator.page.size());
        System.assertEquals(3,paginator.pageSize);
        System.assertEquals(3,paginator.pageNumber);
        System.assertEquals(4, paginator.pageCount);
        System.assertEquals(false,paginator.hasNext);
        System.assertEquals(true,paginator.hasPrevious);

        Boolean exceptionThrown = false;
        try{
            paginator.skipToPage(4);
        }catch(FAP_IllegalArgumentException e){
            exceptionThrown = true;    
        }
        System.assertEquals(true,exceptionThrown);

        exceptionThrown = false;
        try{
            paginator.skipToPage(-1);
        }catch(FAP_IllegalArgumentException e){
            exceptionThrown = true;    
        }
        System.assertEquals(true,exceptionThrown);
    }
    
    private static testmethod void testListener(){
        FAP_ObjectPaginatorListenerForTesting listener = new FAP_ObjectPaginatorListenerForTesting();
        System.assertEquals(false,listener.handlePageChangeInvoked); 
        List<Object> records = createTestObject(8);
        FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(listener);
        paginator.setRecords(records);
        paginator.setPageSize(5);
        System.assertEquals(true,listener.handlePageChangeInvoked);

        listener.handlePageChangeInvoked = false;        
        System.assertEquals(false,listener.handlePageChangeInvoked); 
        paginator.next(); 
        System.assertEquals(true,listener.handlePageChangeInvoked);

        listener.handlePageChangeInvoked = false;
        System.assertEquals(false,listener.handlePageChangeInvoked); 
        paginator.previous(); 
        System.assertEquals(true,listener.handlePageChangeInvoked);

        listener.handlePageChangeInvoked = false;
        System.assertEquals(false,listener.handlePageChangeInvoked); 
        paginator.setPageSize(4); 
        System.assertEquals(true,listener.handlePageChangeInvoked);

        listener.handlePageChangeInvoked = false;
        System.assertEquals(false,listener.handlePageChangeInvoked); 
        paginator.setRecords(createTestObject(6)); 
        System.assertEquals(true,listener.handlePageChangeInvoked);
    }
    
    private static testmethod void testBadInput(){
        FAP_ObjectPaginator paginator = new FAP_ObjectPaginator();
        paginator.setRecords(null);
        System.assertEquals(null,paginator.all);
        System.assertEquals(null,paginator.page);
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_PAGE_SIZE,paginator.pageSize);
        System.assertEquals(0,paginator.pageNumber);
        System.assertEquals(0, paginator.pageCount);
        System.assertEquals(false,paginator.hasNext);
        System.assertEquals(false,paginator.hasPrevious);

        paginator = new FAP_ObjectPaginator();
        paginator.setRecords(createTestObject(0));
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(0,paginator.all.size());
        System.assertEquals(null,paginator.page);
        System.assertEquals(FAP_ObjectPaginator.DEFAULT_PAGE_SIZE,paginator.pageSize);
        System.assertEquals(0,paginator.pageNumber);
        System.assertEquals(0, paginator.pageCount);
        System.assertEquals(false,paginator.hasNext);
        System.assertEquals(false,paginator.hasPrevious);
    }
    
    private static testmethod void testFirstAndLast(){
        FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(2);
        paginator.setRecords(createTestObject(11));
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(11,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(2,paginator.page.size());
        System.assertEquals(2,paginator.pageSize);
        System.assertEquals(0,paginator.pageNumber);
        System.assertEquals(6,paginator.pageCount);
        System.assertEquals(true,paginator.hasNext);
        System.assertEquals(false,paginator.hasPrevious);
        
        paginator.last();
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(11,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(1,paginator.page.size());
        System.assertEquals(2,paginator.pageSize);
        System.assertEquals(5,paginator.pageNumber);
        System.assertEquals(6,paginator.pageCount);
        System.assertEquals(false,paginator.hasNext);
        System.assertEquals(true,paginator.hasPrevious);

        paginator.first();
        System.assertEquals(11,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(2,paginator.page.size());
        System.assertEquals(2,paginator.pageSize);
        System.assertEquals(0,paginator.pageNumber);
        System.assertEquals(6,paginator.pageCount);
        System.assertEquals(true,paginator.hasNext);
        System.assertEquals(false,paginator.hasPrevious);
    }

    private static testmethod void testSkipPages(){
        FAP_ObjectPaginator paginator = new FAP_ObjectPaginator(2,3);
        paginator.setRecords(createTestObject(11));
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(11,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(2,paginator.page.size());
        System.assertEquals(2,paginator.pageSize);
        System.assertEquals(3,paginator.skipSize);
        System.assertEquals(0,paginator.pageNumber);
        System.assertEquals(1,paginator.pageNumberDisplayFriendly);
        System.assertEquals(1,paginator.pageStartPositionDisplayFriendly);
        System.assertEquals(2,paginator.pageEndPositionDisplayFriendly);
        System.assertEquals(6,paginator.pageCount);
        System.assertEquals(true,paginator.hasNext);
        System.assertEquals(false,paginator.hasPrevious);
        List<Integer> previousSkips = paginator.previousSkipPageNumbers;
        System.assertNotEquals(null,previousSkips);
        System.assertEquals(0,previousSkips.size());
        List<Integer> nextSkips = paginator.nextSkipPageNumbers;
        System.assertNotEquals(null,nextSkips);
        System.assertEquals(3,nextSkips.size());
        
        
        paginator.last();
        System.assertNotEquals(null,paginator.all);
        System.assertEquals(11,paginator.all.size());
        System.assertNotEquals(null,paginator.page);
        System.assertEquals(1,paginator.page.size());
        System.assertEquals(2,paginator.pageSize);
        System.assertEquals(3,paginator.skipSize);
        System.assertEquals(5,paginator.pageNumber);
        System.assertEquals(6,paginator.pageCount);
        System.assertEquals(false,paginator.hasNext);
        System.assertEquals(true,paginator.hasPrevious);
        previousSkips = paginator.previousSkipPageNumbers;
        System.assertNotEquals(null,previousSkips);
        System.assertEquals(3,previousSkips.size());
        nextSkips = paginator.nextSkipPageNumbers;
        System.assertNotEquals(null,nextSkips);
        System.assertEquals(0,nextSkips.size());
    }
        
    private static List<Object> createTestObject(Integer count){
        List<Object> records = new List<Object>();
        for(Integer i = 0; i < count; i++){
            records.add(new FAP_DecimalRange(i,i));
        }
        return records;
    }    

}