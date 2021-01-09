global abstract class FAP_ConditionGroup implements FAP_NestableCondition{
    
    global List<FAP_Condition> conditions {get;private set;}
    
    private String separator {get;set;} 
    
    public FAP_ConditionGroup(String separator){
        this.separator = separator;
        this.Conditions = new List<FAP_Condition>();
    }
    
    global FAP_NestableCondition add(FAP_Condition c){
        if(c != null){
            this.conditions.add(c);
        }
        return this;
    }
    
    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(FAP_SoqlOptions options){
      if(options == null){
        options = FAP_SoqlOptions.defaultOptions;
      }
        String soql = '';
        if(conditions.size() == 1){
            return conditions.get(0).toSoql(options);
        } else if(conditions.size() > 1){
          Boolean hasOpenParenBeenAdded = false;
          String additionalSoql = null;
          for(FAP_Condition condition : conditions){
            additionalSoql = condition.toSoql(options);
            if(FAP_StringUtils.isBlank(additionalSoql)){
              continue;
            }
            if(hasOpenParenBeenAdded){
                    soql += ' ' + separator + ' ';
            } else {
                    soql = '(';
                    hasOpenParenBeenAdded = true;
            }
                soql += additionalSoql;
          }
            if(hasOpenParenBeenAdded){
                soql += ')';
            }
        }
        return soql;
    }
    
}