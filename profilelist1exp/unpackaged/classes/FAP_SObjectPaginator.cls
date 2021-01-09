global class FAP_SObjectPaginator {
    //================================================
    // CONSTRUCTORS    
    //================================================
    global FAP_SObjectPaginator(){
        this(DEFAULT_PAGE_SIZE, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, null);
    } 
    
    global FAP_SObjectPaginator(    FAP_SObjectPaginatorListener listener ){
        this(DEFAULT_PAGE_SIZE, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, listener);
    }
     
    global FAP_SObjectPaginator(    List<Integer> pageSizeIntegerOptions ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, null);
    }
     
    global FAP_SObjectPaginator(    List<Integer> pageSizeIntegerOptions,
                            FAP_SObjectPaginatorListener listener ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, listener);
    } 
    
    global FAP_SObjectPaginator(    List<Integer> pageSizeIntegerOptions,
                                Integer skipSize ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, skipSize, null);
    } 
    
    global FAP_SObjectPaginator(     List<Integer> pageSizeIntegerOptions,
                                Integer skipSize,
                                 FAP_SObjectPaginatorListener listener ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, skipSize, listener);
    } 
    
    global FAP_SObjectPaginator(    Integer pageSize ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, null);
    }
     
    global FAP_SObjectPaginator(    Integer pageSize,
                                FAP_SObjectPaginatorListener listener ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, listener);
    } 
    
    global FAP_SObjectPaginator(    Integer pageSize,
                                Integer skipSize ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, skipSize, null);
    }
     
    global FAP_SObjectPaginator(    Integer pageSize,
                                Integer skipSize,
                                FAP_SObjectPaginatorListener listener ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, skipSize, listener);
    } 
    
    global FAP_SObjectPaginator(    Integer pageSize,
                                List<Integer> pageSizeIntegerOptions){
        this(pageSize, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, null);
    }
     
    global FAP_SObjectPaginator(    Integer pageSize,
                                List<Integer> pageSizeIntegerOptions,
                                FAP_SObjectPaginatorListener listener){
        this(pageSize, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, listener);
    }
     
    global FAP_SObjectPaginator(    Integer pageSize,
                                List<Integer> pageSizeIntegerOptions,
                                Integer skipSize){
        this(pageSize, pageSizeIntegerOptions, skipSize, null);
    }
     
    global FAP_SObjectPaginator(    Integer pageSize, 
                                List<Integer> pageSizeIntegerOptions, 
                                Integer skipSize, 
                                FAP_SObjectPaginatorListener listener){
        this.listeners = new List<FAP_SObjectPaginatorListener>();                                
        setPageSize(pageSize);
        setPageSizeOptions(pageSizeIntegerOptions);
        setSkipSize(skipSize);
        addListener(listener);
    }

    //================================================
    // CONSTANTS    
    //================================================
    global static final     Integer         DEFAULT_PAGE_SIZE             = 20;
    global static final     List<Integer>   DEFAULT_PAGE_SIZE_OPTIONS     = new List<Integer>{10,20,50,100,200};
    global static final     Integer         DEFAULT_SKIP_SIZE             = 3;
    global static final     Integer         MAX_SKIP_SIZE                 = 20;

    //================================================
    // PROPERTIES    
    //================================================
    global List<SObject>                    all                     {get;private set;}
    global List<SObject>                    page                    {get;private set;}
    global Integer                          pageSize                {get;private set;} 
    global List<Integer>                    pageSizeIntegerOptions  {get;private set;} 
    global List<SelectOption>               pageSizeSelectOptions   {get;private set;} 
    global Integer                          skipSize                {get;private set;}
    global Integer                          pageNumber              {get;private set;}
    global List<FAP_SObjectPaginatorListener>   listeners               {get;private set;}    

    //================================================
    // DERIVED PROPERTIES    
    //================================================
    global Integer pageCount { 
        get{ 
            Double allSize = this.all == null ? 0 : this.all.size(); 
            Double pageSize = this.pageSize; 
            return this.all == null ? 0 : Math.ceil(allSize/pageSize).intValue(); 
        } 
    }
    
    global Integer recordCount {
        get{ 
            return this.all == null ? 0 : this.all.size(); 
        } 
    }
    
    global Boolean hasNext{
        get{ 
            return pageNumber >= 0 && pageNumber < this.pageCount-1;
        }
    }
    
    global Boolean hasPrevious{
        get{
            return pageNumber > 0 && pageNumber <= this.pageCount-1;
        }
    }
    
    global Integer pageStartPosition {
        get{ 
            return this.pageNumber * this.pageSize; 
        } 
    }
    
    global Integer pageEndPosition {
        get{ 
            Integer endPosition = (this.pageNumber + 1) * this.pageSize - 1;
            endPosition = endPosition < recordCount ? endPosition : recordCount-1;
            return endPosition; 
        } 
    }
    global List<Integer> previousSkipPageNumbers {
        get{
            List<Integer> returnValues = new List<Integer>();
            for(Integer i = skipSize; i > 0; i--){
                if(pageNumber-i < 0){
                    continue;
                }
                returnValues.add(pageNumber-i);
            }
            return returnValues;
        }
    }
    
    global List<Integer> nextSkipPageNumbers {
        get{
            List<Integer> returnValues = new List<Integer>();
            for(Integer i = 1; i <= skipSize; i++){
                if(pageNumber+i >= pageCount){
                    break;
                }
                returnValues.add(pageNumber+i);
            }
            return returnValues;
        }
    }

    global Integer pageNumberDisplayFriendly {
        get{ 
            return this.pageNumber + 1; 
        } 
    }
    
    global Integer pageStartPositionDisplayFriendly {
        get{ 
            return this.pageStartPosition + 1; 
        } 
    }
    
    global Integer pageEndPositionDisplayFriendly {
        get{ 
            return this.pageEndPosition + 1; 
        } 
    }

    //================================================
    // METHODS    
    //================================================
    global void setRecords(List<SObject> all){
        reset(all,this.pageSize);
    }
    
    global void setPageSize(Integer pageSize){
        if(this.pageSize!=pageSize){
            reset(this.all,pageSize);
        }
    }
    
    global Integer getPageSize(){
        return this.pageSize;
    }

    global void setPageSizeOptions(List<Integer> pageSizeIntegerOptions){
        this.pageSizeIntegerOptions = pageSizeIntegerOptions;
        if(this.pageSizeSelectOptions == null){
            this.pageSizeSelectOptions = new List<SelectOption>();
        }
        this.pageSizeSelectOptions.clear();
        if(pageSizeIntegerOptions != null && pageSizeIntegerOptions.size() > 0){
            for(Integer pageSizeOption : pageSizeIntegerOptions){
                if(pageSizeOption < 1){
                    continue;
                }
                this.pageSizeSelectOptions.add(new SelectOption(''+pageSizeOption,''+pageSizeOption));
            }
        }
    }
    
    global List<SelectOption> getPageSizeOptions(){
        return this.pageSizeSelectOptions;
    }

    global void setSkipSize(Integer skipSize){
        this.skipSize = skipSize < 0 || skipSize > MAX_SKIP_SIZE ? this.skipSize : skipSize;
    }
    
    global PageReference skipToPage(Integer pageNumber){
        if(pageNumber < 0 || pageNumber > this.pageCount-1){
            throw new FAP_IllegalArgumentException();
        }
        this.pageNumber = pageNumber;
        updatePage();
        return null;
    }
    
    global pagereference  next(){
        if(!this.hasNext){
            throw new FAP_IllegalStateException();
        }
        this.pageNumber++;
        updatePage();
        return null;
    }
    
    global PageReference previous(){
        if(!this.hasPrevious){
            throw new FAP_IllegalStateException();
        }
        this.pageNumber--;
        updatePage();
        return null;
    }
    
    global PageReference first(){
        this.pageNumber = 0;
        updatePage();
        return null;
    }
    
    global PageReference last(){
        this.pageNumber = pageCount - 1;
        updatePage();
        return null;
    }
    
    private void reset(List<SObject> all, Integer pageSize){
        this.all = all;
        this.pageSize = pageSize < 1 ? DEFAULT_PAGE_SIZE : pageSize;
        this.pageNumber = 0;
        updatePage();
    }

    private void updatePage() {
        this.page = null;
        if(this.all != null && this.all.size() > 0){
            this.page = FAP_ArrayUtils.createEmptySObjectList(this.all.get(0));
            for (Integer i = this.pageStartPosition; i <= this.pageEndPosition; i++) {
                this.page.add(this.all.get(i));
            }
        }
        firePageChangeEvent();
    }
     
    global void addListener(FAP_SObjectPaginatorListener listener){
        if(listener != null){
            listeners.add(listener);
        }
    }

    global void firePageChangeEvent(){
        for(FAP_SObjectPaginatorListener listener : listeners){
            listener.handlePageChange(this.page);
        }
    }
}