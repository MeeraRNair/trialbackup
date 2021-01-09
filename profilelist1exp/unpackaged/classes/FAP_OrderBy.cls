/*
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0      Fenny    13-Jul-2012    13.7        Initialize boolean properties to prevent NullPointerException
*/
global class FAP_OrderBy implements FAP_Soqlable{

    global String field {get;set;}
    global Boolean ascending {get;set;}
    global Boolean descending {get{return !ascending;}}
    global Boolean nullsFirst {get;set;}
    global Boolean nullsLast {get{return !nullsFirst;}}
    private Boolean sortSet = false;
    private Boolean nullsSet = false;
  
    global FAP_OrderBy(String field){
        if(StringUtils.isBlank(field)){
          throw new IllegalArgumentException('field is empty');
        }
        this.field = field;
        this.ascending(); // Ver 1.0: If require to remove this line, please initialize those boolean properties
        this.sortSet = false;
    }
    
    global FAP_OrderBy ascending (){ return setAscending(true); }
    global FAP_OrderBy descending(){ return setAscending(false);}
    global FAP_OrderBy nullsFirst(){ return setNullsFirst(true);}
    global FAP_OrderBy nullsLast (){ return setNullsFirst(false);}
    
    private FAP_OrderBy setAscending(Boolean ascending){
        this.ascending = ascending;
        this.sortSet = true;
        if(!this.nullsSet){
          this.nullsFirst = this.descending;
        }
        return this;
    }
    
    private FAP_OrderBy setNullsFirst(Boolean nullsFirst){
        this.nullsFirst = nullsFirst;
        this.nullsSet = true;
        return this;
    }

    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(FAP_SoqlOptions options){
        if(options == null){
            options = FAP_SoqlOptions.defaultOptions;
        }
        return this.field 
           + (sortSet ? (ascending ? ' ASC' : ' DESC'): '')
           + (nullsSet ? (nullsFirst ? ' NULLS FIRST' : ' NULLS LAST') : '')
        ;
    }
    

}