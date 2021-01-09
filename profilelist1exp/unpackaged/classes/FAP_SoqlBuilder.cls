global class FAP_SoqlBuilder implements FAP_Soqlable{
    
    private Set<Object>     selectx     = null;
    private Boolean         selectCount = false;
    private String          fromx       = null;
    private FAP_Condition       wherex      = null;
    private List<FAP_OrderBy>   orderByx    = null;
    private Integer         limitx      = null;
    
    global FAP_SoqlBuilder(){}
    
    global FAP_SoqlBuilder selectx(String field){ 
        return addToSelect(field);
    }
    
    global FAP_SoqlBuilder selectx(FAP_Field field){ 
        return addToSelect(field);
    }
    
    global FAP_SoqlBuilder selectx(FAP_SoqlBuilder field){ 
        return addToSelect(field);
    }
    
    global FAP_SoqlBuilder selectx(List<Object> fields){ 
        return selectx(FAP_SetUtils.listToSet(fields));
    }
    
    global FAP_SoqlBuilder selectx(Set<Object> fields){ 
        if(fields != null && fields.size() > 0){
            for(Object field : fields){
                addToSelect(field);
            }
        }
        return this;
    }
    
    private FAP_SoqlBuilder addToSelect(Object field){
        if(field == null){
            throw new FAP_IllegalArgumentException('null field');
        }
        if(field instanceof String || field instanceof FAP_Field || field instanceof FAP_SoqlBuilder ){
            if(selectx == null){
                selectx = new Set<Object>();
            }
            selectx.add(field);
        } else {
            throw new FAP_IllegalArgumentException('Invalid field type.  A field must be either a String, Field, or FAP_SoqlBuilder.');
        }
        this.selectCount = false;
        return this;
    }

    global FAP_SoqlBuilder selectCount(){ 
        return selectCountx();
    }

    global FAP_SoqlBuilder selectCountx(){ 
        this.selectCount = true;
        return this;
    }

    global FAP_SoqlBuilder fromx(String fromx){
        this.fromx = fromx; 
        return this;
    }

    global FAP_SoqlBuilder wherex(FAP_Condition wherex){ 
        this.wherex = wherex;
        return this;
    }
    
    global FAP_SoqlBuilder orderByx(FAP_OrderBy orderByx){ 
        if(this.orderByx == null){
            this.orderByx = new List<FAP_OrderBy>();
        }
        this.orderByx.add(orderByx);
        return this;
    }

    global FAP_SoqlBuilder orderByx(List<FAP_OrderBy> orderByx){ 
        if(orderByx != null && orderByx.size() > 0){
            for(FAP_OrderBy field : orderByx){
                orderByx(field);
            }
        }
        return this;
    }

    global FAP_SoqlBuilder limitx(Integer limitx){
        this.limitx = limitx; 
        return this;
    }
    
    global String toSoql(){ return this.toSoql(null); }
    
    global String toSoql(FAP_SoqlOptions options){
        if(options == null){
            options = FAP_SoqlOptions.defaultOptions;
        }
        if(FAP_StringUtils.isBlank(fromx)){
            throw new FAP_IllegalStateException('Illegal state!  You must invoke fromx() with valid object name before invoking toSoql().');
        }
        Boolean isFirst = true;
        String soql = 'SELECT ';
        if(selectx == null){
            selectx = new Set<Object>();
        }
        if(this.selectCount != null && this.selectCount){
            soql += 'count()';
        } else {
            if(selectx.size() <= 0){
                selectx.add('id');
            }
            String distinctField = null;
            Map<String,String> distinctFields = new Map<String,String>();
            for(Object value : selectx){
                if(value instanceof FAP_Field){
                    distinctField = ((FAP_Field)value).toSoql(options);
                } else if(value instanceof FAP_SoqlBuilder){
                    distinctField = '(' + ((FAP_SoqlBuilder)value).toSoql(options) + ')';
                } else {
                    distinctField = ''+value;
                }
                distinctField = FAP_StringUtils.trim(distinctField);
                distinctFields.put(FAP_StringUtils.lowerCase(distinctField),distinctField);
            }
            soql += FAP_StringUtils.joinStrings(distinctFields.values(),',');
        }
        soql += ' FROM ' + fromx;
        if(wherex != null){
            soql += ' WHERE ' + wherex.toSoql(options);
        }
        
        if(orderByx != null && orderByx.size() > 0){
            isFirst = true;
            for(FAP_OrderBy orderBy : orderByx){
                if(orderBy == null){
                    continue;
                }
                if(isFirst){
                    isFirst = false;
                    soql += ' ORDER BY ';
                } else {
                    soql += ', ';
                }
                soql += orderBy.toSoql(options);
            }
        }
        if(limitx != null){
            soql += ' LIMIT ' + limitx;
        }
        return soql;
    }
    
    
}