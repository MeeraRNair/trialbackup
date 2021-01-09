global class FAP_FieldCondition implements FAP_Condition{
    
    private static final FAP_Operator EQUALS                    = FAP_Operator.EQUALS;
    private static final FAP_Operator NOT_EQUALS                = FAP_Operator.NOT_EQUALS;
    private static final FAP_Operator LESS_THAN                 = FAP_Operator.LESS_THAN;
    private static final FAP_Operator LESS_THAN_OR_EQUAL_TO     = FAP_Operator.LESS_THAN_OR_EQUAL_TO;
    private static final FAP_Operator GREATER_THAN              = FAP_Operator.GREATER_THAN;
    private static final FAP_Operator GREATER_THAN_OR_EQUAL_TO  = FAP_Operator.GREATER_THAN_OR_EQUAL_TO;
    private static final FAP_Operator LIKEX                     = FAP_Operator.LIKEX;
    private static final FAP_Operator DEFAULT_OPERATOR          = EQUALS;
    
    global String   field        {get;private set;}
    global Integer   field1        {get;private set;} //CSP Change
    global Integer   field2        {get;private set;} //CSP Change
    global FAP_Operator operator    {get;private set;}
    global Object   value       {get;private set;}
    
    global FAP_FieldCondition(){}    
    
    global FAP_FieldCondition(String field){
        this.field(field);
    }
    
    global FAP_FieldCondition(String field, Object value){
        this(field, DEFAULT_OPERATOR, value);
    }
    
    global FAP_FieldCondition(Integer field1, FAP_Operator operator, Integer field2){ //CSP Change
        this(field1, EQUALS, field2);
    }
    
    global FAP_FieldCondition(String field, FAP_Operator operator, Object value){
        this.field(field);
        if(operator!= null){
            this.setOperation(operator,value);
        }
    }

    global FAP_FieldCondition field(String field){
        if(FAP_StringUtils.isBlank(field)){
            throw new FAP_IllegalArgumentException('illegal argument:  field is empty');
        }
        this.field = FAP_StringUtils.trim(field);
        return this;
    }

    global FAP_FieldCondition equals              (Object value){ return setOperation(EQUALS                  ,value); }
    global FAP_FieldCondition notEquals           (Object value){ return setOperation(NOT_EQUALS              ,value); }
    global FAP_FieldCondition lessThan            (Object value){ return setOperation(LESS_THAN               ,value); }
    global FAP_FieldCondition lessThanOrEqualTo   (Object value){ return setOperation(LESS_THAN_OR_EQUAL_TO   ,value); }
    global FAP_FieldCondition greaterThan         (Object value){ return setOperation(GREATER_THAN            ,value); }
    global FAP_FieldCondition greaterThanOrEqualTo(Object value){ return setOperation(GREATER_THAN_OR_EQUAL_TO,value); }
    global FAP_FieldCondition likex               (Object value){ return setOperation(LIKEX                   ,value); }
    
    private FAP_FieldCondition setOperation(FAP_Operator operator, Object value){
        if( operatorToString(operator) == null){
            throw new FAP_IllegalArgumentException('illegal operator: ' + operator);
        }
        this.operator = operator;
        this.value = value;
        return this;
    }

    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(FAP_SoqlOptions options){
        if(options == null){
            options = FAP_SoqlOptions.defaultOptions;
        }
        Object manipulated = value;
        if(    manipulated != null 
               && manipulated instanceof String 
               && operator == LIKEX
               && options.wildcardStringsInLikeOperators){ 
            manipulated = FAP_StringUtils.ensureStringStartsEndsWithChar( ((String)manipulated),'%');
        }
        return field + ' ' + operatorToString(operator) + ' ' + FAP_SoqlUtils.toLiteral(manipulated,options);
    }
    
    global static String operatorToString(FAP_Operator op){
        String returnValue = null;
        if(     op == EQUALS)                   { returnValue = '='; }       
        else if(op == NOT_EQUALS)               { returnValue = '!='; }       
        else if(op == LESS_THAN)                { returnValue = '<'; }       
        else if(op == LESS_THAN_OR_EQUAL_TO)    { returnValue = '<='; }       
        else if(op == GREATER_THAN)             { returnValue = '>'; }       
        else if(op == GREATER_THAN_OR_EQUAL_TO) { returnValue = '>='; }       
        else if(op == LIKEX)                    { returnValue = 'like'; }
        return returnValue;
    }
    
}