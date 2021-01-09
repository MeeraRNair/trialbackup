global class FAP_SoqlOptions {

    global static FAP_SoqlOptions defaultOptions = new FAP_SoqlOptions();
    
    global Boolean escapeSingleQuotes {get;set;}
    global Boolean wildcardStringsInLikeOperators {get;set;}
  
    global FAP_SoqlOptions(){
      escapeSingleQuotes();
      doNotWildcardStringsInLikeOperators();
    }
    
    global FAP_SoqlOptions wildcardStringsInLikeOperators(){
        this.wildcardStringsInLikeOperators = true;
        return this;
    }
    
    global FAP_SoqlOptions doNotWildcardStringsInLikeOperators(){
        this.wildcardStringsInLikeOperators = false;
        return this;
    }
    
    global FAP_SoqlOptions escapeSingleQuotes(){
        this.escapeSingleQuotes = true;
        return this;
    }
    
    global FAP_SoqlOptions doNotEscapeSingleQuotes(){
        this.escapeSingleQuotes = false;
        return this;
    }
    

}