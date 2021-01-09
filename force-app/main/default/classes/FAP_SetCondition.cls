global class FAP_SetCondition implements FAP_Condition{
    
    private static final FAP_Operator INCLUDES  = FAP_Operator.INCLUDES;
    private static final FAP_Operator EXCLUDES  = FAP_Operator.EXCLUDES;
    private static final FAP_Operator INX       = FAP_Operator.INX;
    private static final FAP_Operator NOT_IN    = FAP_Operator.NOT_IN;
    private static final FAP_Operator LIKEX      = FAP_Operator.LIKEX;
    

    global String       field    {get; private set;}
    global FAP_Operator     operator {get; private set;}
    global List<Object> values   {get; private set;}
    global FAP_SoqlBuilder  builder  {get; private set;}
    
    global FAP_SetCondition(){}
    
    global FAP_SetCondition(String field){
        this.field(field);
    }
    
    global FAP_SetCondition(String field, FAP_Operator operator, List<Object> values){
        this.field(field);
        this.setOperation(operator,values);
    }
    
    global FAP_SetCondition(String field, FAP_Operator operator, FAP_SoqlBuilder builder){
        this.field(field);
        this.setOperation(operator,builder);
    }
    
    global FAP_SetCondition field(String field){
        if(FAP_StringUtils.isBlank(field)){
            throw new FAP_IllegalArgumentException('illegal argument:  field is empty');
        }
        this.field = FAP_StringUtils.trim(field);
        return this;
    }
    
    global FAP_SetCondition includes(List<Object> values){ return setOperation(INCLUDES,values); }
    global FAP_SetCondition excludes(List<Object> values){ return setOperation(EXCLUDES,values); }
    global FAP_SetCondition inx     (List<Object> values){ return setOperation(INX,     values); }
    global FAP_SetCondition notIn   (List<Object> values){ return setOperation(NOT_IN,  values); }
    global FAP_SetCondition likex   (List<Object> values){ return setOperation(LIKEX,  values); }

    global FAP_SetCondition includes(FAP_SoqlBuilder builder){ return setOperation(INCLUDES,builder); }
    global FAP_SetCondition excludes(FAP_SoqlBuilder builder){ return setOperation(EXCLUDES,builder); }
    global FAP_SetCondition inx     (FAP_SoqlBuilder builder){ return setOperation(INX,     builder); }
    global FAP_SetCondition notIn   (FAP_SoqlBuilder builder){ return setOperation(NOT_IN,  builder); }

    private FAP_SetCondition setOperation(FAP_Operator operator, List<Object> values){
        if(values == null || values.size() <= 0){
            throw new FAP_IllegalArgumentException('illegal argument:  values is empty');
        }
        this.values = values;
        return setOperator(operator);
    }

    private FAP_SetCondition setOperation(FAP_Operator operator, FAP_SoqlBuilder builder){
        if(builder == null){
            throw new FAP_IllegalArgumentException('illegal argument:  builder is null');
        }
        this.builder = builder;
        return setOperator(operator);
    }
    
    private FAP_SetCondition setOperator(FAP_Operator operator){
        if(operatorToString(operator) == null){
            throw new FAP_IllegalArgumentException('illegal operator: ' + operator);
        }
        this.operator = operator;
        return this;
    }

    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(FAP_SoqlOptions options){
        if(options == null){
            options = FAP_SoqlOptions.defaultOptions;
        }
        if(this.operator== null){
            throw new FAP_IllegalStateException(
               'Illegal state!  One of the following operations must be invoked on SetCondition prior to invoke toSoql(): (includes|excludes|inn|notIn)');
        }
        return field 
            + ' ' 
            + operatorToString(operator) 
            + ' (' 
            + (builder == null ? FAP_StringUtils.joinArray(FAP_SoqlUtils.toLiteral(this.values),',') : builder.toSoql(options)) 
            + ')'; 
    }

    global static String operatorToString(FAP_Operator operator){
        String returnValue = null;
        if(operator == INCLUDES){ returnValue = 'INCLUDES'; }       
        else if(operator == EXCLUDES){ returnValue = 'EXCLUDES'; }       
        else if(operator == INX){ returnValue = 'IN'; }       
        else if(operator == NOT_IN){ returnValue = 'NOT IN'; }
        else if (operator == LIKEX) { returnValue = 'like'; }
        return returnValue;
    }

}