global class FAP_SoqlUtils {

    global static String toLiteral(final Object value){
      return toLiteral(value,null);
    }
    
    global static String toLiteral(final Object value, FAP_SoqlOptions options){
        if(options == null){
            options = FAP_SoqlOptions.defaultOptions;
        }
      String literal = '';
        if(         value == null){
            literal += 'null'; 
        } else if(  value instanceof FAP_Soqlable ){
          return ((FAP_Soqlable)value).toSoql(options);
        } else if(  value instanceof String  ||
                    value instanceOf ID){
            String manipulated = (String) value;
            if(options.escapeSingleQuotes == true){
                manipulated = String.escapeSingleQuotes(manipulated);
            }
            literal += '\'' + manipulated + '\''; 
        } else if(  value instanceOf Boolean ||
                    value instanceOf Integer || 
                    value instanceOf Long    || 
                    value instanceOf Double  || 
                    value instanceOf Decimal){
            literal += value;
        } else if(  value instanceOf Date){
            literal += Datetime.newInstance(((Date)value).year(), ((Date)value).month(), ((Date)value).day()).format('yyyy-MM-dd');
        } else if(  value instanceOf Datetime){
            literal += ((Datetime) value).format('yyyy-MM-dd') + 'T' + ((Datetime) value).format('hh:mm:ss') + 'Z';
        } else {
            throw new FAP_IllegalArgumentException('invalid value; value must be null, a primitive type ' 
                + '(String|ID|Boolean|Integer|Long|Double|Decimal|Date|Datetime), or implement Soqlable interface');
        }
        return literal;
    }

    global static List<String> toLiteral(final List<Object> values){
      return toLiteral(values,FAP_SoqlOptions.defaultOptions);
    }
    
    global static List<String> toLiteral(final List<Object> values, final FAP_SoqlOptions options){
    final List<String> literals = new List<String>();
    if(values != null && values.size() > 0){
      for(Object obj : values){
        literals.add(toLiteral(obj,options));
      }
    }
    return literals;
  }

    global static void assertEquals(String expected, String actual){
        System.assert(
            equals(expected,actual),
            'Assertion failed, the following two SOQLs are not equal.  Expected: ' + expected + ', Actual: ' + actual);
    }

    /**
     * This equals is fairly simplistic.  It will account for unordered columns,
     * lower vs upper case (SELECT vs select) but it won't take into account anything else.  Different
     * order of where conditions for example.
     */
    global static Boolean equals(String soql1, String soql2){
        soql1 = FAP_StringUtils.trim(FAP_StringUtils.lowerCase(soql1));
        soql2 = FAP_StringUtils.trim(FAP_StringUtils.lowerCase(soql2));
        if(FAP_StringUtils.equals(soql1,soql2)){
            return true;
        }
        if(!FAP_StringUtils.startsWith(soql1, 'select') || !FAP_StringUtils.startsWith(soql2, 'select')){
          return false;
        }
        String afterSelect1 = FAP_StringUtils.trim(FAP_StringUtils.substringAfter(soql1,'select'));
        String afterSelect2 = FAP_StringUtils.trim(FAP_StringUtils.substringAfter(soql2,'select'));
        Set<String> columns1 = FAP_StringUtils.trimAll(FAP_SetUtils.listToSet(FAP_StringUtils.split(FAP_StringUtils.trim(FAP_StringUtils.substringBeforeLast(afterSelect1,' from ')),',')));
        Set<String> columns2 = FAP_StringUtils.trimAll(FAP_SetUtils.listToSet(FAP_StringUtils.split(FAP_StringUtils.trim(FAP_StringUtils.substringBeforeLast(afterSelect2,' from ')),',')));
        if(!FAP_SetUtils.equals(columns1,columns2)){
          return false;
        }
        String afterFrom1 = FAP_StringUtils.trim(FAP_StringUtils.substringAfterLast(soql1,' from '));
        String afterFrom2 = FAP_StringUtils.trim(FAP_StringUtils.substringAfterLast(soql2,' from '));
        return FAP_StringUtils.equals(afterFrom1,afterFrom2);
    }
    
    
}