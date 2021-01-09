global class FAP_NumberUtils {
    global static final Integer MAX_INTEGER = 2147483647;
    global static final Integer MIN_INTEGER = -2147483647;
    global static final FAP_IntegerRange MAX_INTEGER_RANGE = new FAP_IntegerRange(FAP_NumberUtils.MIN_INTEGER,FAP_NumberUtils.MAX_INTEGER);
    
    global static final Long MAX_LONG = 9223372036854775807L;
    global static final Long MIN_LONG = -9223372036854775807L;
    global static final FAP_LongRange MAX_LONG_RANGE = new FAP_LongRange(FAP_NumberUtils.MIN_LONG,FAP_NumberUtils.MAX_LONG);
    
    global static Integer parseInt(String str, Integer radix){
        return parseLong(str,radix).intValue();
    }
    
    global static Long parseLong(String str, Integer radix){
        str = FAP_StringUtils.upperCase(FAP_StringUtils.trim(str));
        if(FAP_StringUtils.isBlank(str)){
            throw new FAP_NumberFormatException();
        }
        if(radix < 2 || radix > 36){
            throw new FAP_IllegalArgumentException('invalid radix parameter: ' + radix + '; radix must be >= 2 and <= 36');
        }
        Boolean isNegative = false;
        if(FAP_StringUtils.startsWith(str, '-')){
            isNegative = true;
            str = FAP_StringUtils.removeStart(str, '-');
        }
        String validChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.substring(0,radix);
        if(!FAP_StringUtils.containsOnly(str,validChars)){
            throw new FAP_NumberFormatException('Invalid characters found in number: ' + str + ', with radix = ' + radix);
        }
        final Integer LENGTH = FAP_StringUtils.length(str);
        Long returnValue = 0;
        for(Integer i = 0; i < LENGTH; i++){
            returnValue +=
                (validChars.indexOf(str.substring(LENGTH-i-1,LENGTH-i))
                * Math.pow(radix,i)).longValue();
        }
        if(isNegative){
            returnValue = -returnValue;
        }
        return returnValue;
    }
    
    
    
    global static String toBinaryString(Integer i){
        return toString(i,2);
    }

    global static String toOctalString(Integer i){
        return toString(i,8);
    }
    
    global static String toHexString(Integer i){
        return toString(i,16);
    }

    global static String toString(Integer i, Integer radix){
        if(i == null){
            return null;
        }
        return toString((Long)i,radix);
    }

    global static String toBinaryString(Long l){
        return toString(l,2);
    }

    global static String toOctalString(Long l){
        return toString(l,8);
    }

    global static String toHexString(Long l){
        return toString(l,16);
    }

    global static String toString(Long l, Integer radix){
        if(l == null){
            return null;
        }
        if(radix < 2 || radix > 36){
            throw new FAP_IllegalArgumentException('invalid radix parameter: ' + radix + '; radix must be >= 2 and <= 36');
        }
        return (l<0 ? '-' : '') + toStringPrivate(Math.abs(l),radix,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.substring(0,radix));
    }

    private static String toStringPrivate(Long l, Integer radix, String validChars){
        Integer r = Math.mod(l,radix).intValue();
        String result;
        if(l-r == 0){ 
            result = FAP_StringUtils.charAt(validChars,r);
        }else{ 
            result = toStringPrivate(((l-r)/radix),radix,validChars) + FAP_StringUtils.charAt(validChars,r);
        }
        return result;
        
    }

}