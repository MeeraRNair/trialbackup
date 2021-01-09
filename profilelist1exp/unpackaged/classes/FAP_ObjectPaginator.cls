global class FAP_ObjectPaginator {
    

    //================================================
    // CONSTRUCTORS    
    //================================================
    global FAP_ObjectPaginator(){
        this(DEFAULT_PAGE_SIZE, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, null);
    } 
    
    global FAP_ObjectPaginator(FAP_ObjectPaginatorListener listener ){
        this(DEFAULT_PAGE_SIZE, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, listener);
    }
     
    global FAP_ObjectPaginator(    List<Integer> pageSizeIntegerOptions ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, null);
    }
     
    global FAP_ObjectPaginator(    List<Integer> pageSizeIntegerOptions,
                            FAP_ObjectPaginatorListener listener ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, listener);
    } 
    
    global FAP_ObjectPaginator(    List<Integer> pageSizeIntegerOptions,
                            Integer skipSize ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, skipSize, null);
    } 
    
    global FAP_ObjectPaginator( List<Integer> pageSizeIntegerOptions,
                            Integer skipSize,
                             FAP_ObjectPaginatorListener listener ){
        this(DEFAULT_PAGE_SIZE, pageSizeIntegerOptions, skipSize, listener);
    } 
    
    global FAP_ObjectPaginator(    Integer pageSize ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, null);
    }
     
    global FAP_ObjectPaginator(    Integer pageSize,
                            FAP_ObjectPaginatorListener listener ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, DEFAULT_SKIP_SIZE, listener);
    } 
    
    global FAP_ObjectPaginator(    Integer pageSize,
                            Integer skipSize ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, skipSize, null);
    }
     
    global FAP_ObjectPaginator(    Integer pageSize,
                            Integer skipSize,
                            FAP_ObjectPaginatorListener listener ){
        this(pageSize, DEFAULT_PAGE_SIZE_OPTIONS, skipSize, listener);
    } 
    
    global FAP_ObjectPaginator(    Integer pageSize,
                            List<Integer> pageSizeIntegerOptions){
        this(pageSize, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, null);
    }
     
    global FAP_ObjectPaginator(    Integer pageSize,
                            List<Integer> pageSizeIntegerOptions,
                            FAP_ObjectPaginatorListener listener){
        this(pageSize, pageSizeIntegerOptions, DEFAULT_SKIP_SIZE, listener);
    }
     
    global FAP_ObjectPaginator(    Integer pageSize,
                            List<Integer> pageSizeIntegerOptions,
                            Integer skipSize){
        this(pageSize, pageSizeIntegerOptions, skipSize, null);
    }
     
    global FAP_ObjectPaginator(    Integer pageSize, 
                            List<Integer> pageSizeIntegerOptions, 
                            Integer skipSize, 
                            FAP_ObjectPaginatorListener listener){
        this.listeners = new List<FAP_ObjectPaginatorListener>();                                
        setPageSize(pageSize);
        setPageSizeOptions(pageSizeIntegerOptions);
        setSkipSize(skipSize);
        addListener(listener);
        config = config == null ? FAP_Configuration.getInstance() : config; // Ver 1.0
    }

    //================================================
    // CONSTANTS    
    //================================================
    global static final     Integer         DEFAULT_PAGE_SIZE             = 20;
    global static final     List<Integer>   DEFAULT_PAGE_SIZE_OPTIONS     = new List<Integer>{10,20,30,40,50};
    global static final     Integer         DEFAULT_SKIP_SIZE             = 4;
    global static final     Integer         MAX_SKIP_SIZE                 = 20;

    //================================================
    // PROPERTIES    
    //================================================
    global List<Object>                     all                     {get;private set;}
    global List<Object>                     page                    {get;private set;}
    global Integer                          pageSize                {get;private set;} 
    global List<Integer>                    pageSizeIntegerOptions  {get;private set;} 
    global List<SelectOption>               pageSizeSelectOptions   {get;private set;} 
    global Integer                          skipSize                {get;private set;}
    global Integer                          pageNumber              {get;set;}
    public FAP_SearchForm                       form                    {get; private set;}
    global List<FAP_ObjectPaginatorListener>    listeners               {get;private set;} 
    global Integer                          currentBlock            {get;private set;} 
    private FAP_Configuration config; // Ver 1.0

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
            //system.debug('????????????????????????????????????????    ' + this.pageNumber + '    ' + this.pageSize);
            return this.pageNumber * this.pageSize; 
           
        } 
    }
      
    global void setpageNumbertext(Integer pagenumber)
    {
        pagenumber = this.pageNumber + 1;
    }
    global Integer getpageNumbertext()
    {
       //pageNumber = this.pageNumber  + 1;
       
       return this.pagenumber;
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
    
    global void setPageNumberDisplayFriendly(Integer pgNum){
        this.pageNumber = pgNum - 1 ;
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
    global void setRecords(List<Object> all){
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
        this.pageSizeIntegerOptions = DEFAULT_PAGE_SIZE_OPTIONS;
        pageSizeSelectOptions=toSelectOption(this.pageSizeIntegerOptions);
        if(pageSizeSelectOptions == null){
            this.pageSizeSelectOptions = new List<SelectOption>();
         Map<Integer,String> pageSizeMap = new Map<Integer,String>();
            pageSizeMap.put(Integer.valueOf('10'),'10 items per page');
            pageSizeMap.put(Integer.valueOf('20'),'20 items per page');
            pageSizeMap.put(Integer.valueOf('30'),'30 items per page');
            pageSizeMap.put(Integer.valueOf('40'),'40 items per page');
            pageSizeMap.put(Integer.valueOf('50'),'50 items per page');
            for(string aSize:new List<string>{'10','20','30','40','50'})
            {
                this.pageSizeSelectOptions.add(new SelectOption(aSize,pageSizeMap.get(Integer.valueOf('aSize'))));
            }               
        }
    }
    
    public static List<SelectOption> toSelectOption(List<Integer> integers){
     Map<Integer,String> pageSizeMap = new Map<Integer,String>();
            pageSizeMap.put(Integer.valueOf('10'),'10 items per page');
            pageSizeMap.put(Integer.valueOf('20'),'20 items per page');
            pageSizeMap.put(Integer.valueOf('30'),'30 items per page');
            pageSizeMap.put(Integer.valueOf('40'),'40 items per page');
            pageSizeMap.put(Integer.valueOf('50'),'50 items per page');
            
              List<SelectOption> returnValue = new List<SelectOption>();
        if(integers != null && !integers.isEmpty()){
            for(Integer anInteger : integers){
                returnValue.add(new SelectOption(''+anInteger,pageSizeMap.get(anInteger)));
            }
        }
        return returnValue;
    
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
    
    global PageReference next(){
        try{
            if(!this.hasNext){
                throw new FAP_IllegalStateException();
            }
            this.pageNumber++;
            updatePage();
        }catch(FAP_FAPLimitException ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: FAP_PartnerSearchController | Method: skipToLocation]');          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                '[FAP_PartnerSearchController Line ' + ex.getLineNumber() + 
                ': [' + ex.getTypeName() + ']' +
                ': ' + ex.getMessage() + ']'));
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                '[FAP_PartnerSearchController Line ' + ex.getLineNumber() + 
                ': [' + ex.getTypeName() + ']' +
                ': ' + ex.getMessage() + ']'));
        }
        return null;
    }
    
    global PageReference previous(){
        try{
            if(!this.hasPrevious){
                throw new FAP_IllegalStateException();
            }
            this.pageNumber--;
            updatePage();
        }catch(FAP_FAPLimitException ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: FAP_PartnerSearchController | Method: skipToLocation]');          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                '[PartnerSearchController Line ' + ex.getLineNumber() + 
                ': [' + ex.getTypeName() + ']' +
                ': ' + ex.getMessage() + ']'));
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                '[FAP_PartnerSearchController Line ' + ex.getLineNumber() + 
                ': [' + ex.getTypeName() + ']' +
                ': ' + ex.getMessage() + ']'));
        }
            return null;
    }
    
    
    global PageReference first(){
        try{
            this.pageNumber = 0;
            updatePage();
        }catch(FAP_FAPLimitException ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: FAP_PartnerSearchController | Method: skipToLocation]');          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                '[PartnerSearchController Line ' + ex.getLineNumber() + 
                ': [' + ex.getTypeName() + ']' +
                ': ' + ex.getMessage() + ']'));
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                '[FAP_PartnerSearchController Line ' + ex.getLineNumber() + 
                ': [' + ex.getTypeName() + ']' +
                ': ' + ex.getMessage() + ']'));
        }
        return null;
    }
    
    global PageReference last(){
        try{
              
            this.pageNumber = pageCount - 1;
            updatePage();
        }catch(FAP_FAPLimitException ex){
            system.debug('## Caught APEX exception '+ex.getMessage()+' [Code: FAP_PartnerSearchController | Method: skipToLocation]');          
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                '[PartnerSearchController Line ' + ex.getLineNumber() + 
                ': [' + ex.getTypeName() + ']' +
                ': ' + ex.getMessage() + ']'));
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 
                'Find a Partner Tool is currently not able to search for partners. Please contact your administrator for assistance. ' + 
                '[FAP_PartnerSearchController Line ' + ex.getLineNumber() + 
                ': [' + ex.getTypeName() + ']' +
                ': ' + ex.getMessage() + ']'));
        }
            return null;
    }
    
    private void reset(List<Object> all, Integer pageSize){
        this.all = all;
        this.pageSize = pageSize < 1 ? DEFAULT_PAGE_SIZE : pageSize;        
        this.pageNumber = 0;
        updatePage();
        
    }

    private void updatePage() {
       
        this.page = null;
        if(this.all != null && this.all.size() > 0){
            this.page = new List<Object>();
                for (Integer i = this.pageStartPosition; i <= this.pageEndPosition; i++) {
                if(Limits.getScriptStatements() >= config.scriptStatementLimit) { 
                 throw new FAP_FAPLimitException();
                 } 
                this.page.add(this.all.get(i));
            }
        }
        firePageChangeEvent();
    }
    
    global void addListener(FAP_ObjectPaginatorListener listener){
        if(listener != null){
            listeners.add(listener);
        }
    }

    global void firePageChangeEvent(){
        for(FAP_ObjectPaginatorListener listener : listeners){
            listener.handlePageChange(this.page);
        }
    }
}