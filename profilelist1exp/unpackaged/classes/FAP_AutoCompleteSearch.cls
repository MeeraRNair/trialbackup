/**
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Fenny       19-Jul-2012     13.7        7110    CRQ 0417
**/
global virtual class FAP_AutoCompleteSearch{
    
    global String searchString {get;private set;}

    public FAP_AutoCompleteSearch(String searchString){
        if(FAP_StringUtils.length(FAP_StringUtils.trim(searchString)) < 2){
            throw new FAP_IllegalArgumentException('Search string parameter must be two characters or more!');
        }
        this.searchString = searchString;
    }

    // Ver 1.0
    public virtual List<String> internalExecute(){
        return new List<String>();
    }

    global List<String> execute(){
        // Ver 1.0
        final List<String> aSet = internalExecute(); 
        return aSet; 
    }
    
}