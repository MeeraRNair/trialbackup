global class FAP_NotCondition implements FAP_NestableCondition{
    
    global FAP_Condition condition {get;private set;}
    
    //private String FAP_NotCondition {get;set;} 
    
    global FAP_NotCondition(){
        this(null);
    }
    
    global FAP_NotCondition(FAP_Condition c){
        add(c);
    }
    
    global FAP_NestableCondition add(FAP_Condition c){
      this.condition = c;
        return this;
    }
    
    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(FAP_SoqlOptions options){
        if(options == null){
            options = FAP_SoqlOptions.defaultOptions;
        }
        String soql = '';
        if(condition != null){
          soql += 'NOT(' + condition.toSoql(options) + ')';
        }
        return soql;
    }
    
}