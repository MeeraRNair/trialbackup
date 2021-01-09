/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
global class FAP_StringBuffer {

    private String theString;
    
    global FAP_StringBuffer(){
        this('');
    }
    
    global FAP_StringBuffer(String str){
        theString = str;
    }

    global FAP_StringBuffer(Decimal d){
        theString = '' + d;
    }
    
    global FAP_StringBuffer(Double d){
        theString = '' + d;
    }
    
    global FAP_StringBuffer(Long l){
        theString = '' + l;
    }
    
    global FAP_StringBuffer(Integer i){
        theString = '' + i;
    }
    
    global FAP_StringBuffer(Blob b){
        theString = '' + b;
    }
    
    global FAP_StringBuffer(Boolean b){
        theString = '' + b;
    }
    
    global FAP_StringBuffer(Date d){
        theString = '' + d;
    }
    
    global FAP_StringBuffer(Datetime d){
        theString = '' + d;
    }
    
    global FAP_StringBuffer(ID id){
        theString = '' + id;
    }
    
    global FAP_StringBuffer(Time t){
        theString = '' + t;
    }

    global FAP_StringBuffer append(String str){
        theString += str; return this;    
    }

    global FAP_StringBuffer append(Decimal d){
        theString += d;    return this;
    }
    
    global FAP_StringBuffer append(Double d){
        theString += d;    return this;
    }
    
    global FAP_StringBuffer append(Long l){
        theString += l;    return this;
    }
    
    global FAP_StringBuffer append(Integer i){
        theString += i;    return this;
    }
    
    global FAP_StringBuffer append(Blob b){
        theString += b;    return this;
    }
    
    global FAP_StringBuffer append(Boolean b){
        theString += b;    return this;
    }
    
    global FAP_StringBuffer append(Date d){
        theString += d;    return this;
    }
    
    global FAP_StringBuffer append(Datetime d){
        theString += d;    return this;
    }
    
    global FAP_StringBuffer append(ID id){
        theString += id; return this;
    }
    
    global FAP_StringBuffer append(Time t){
        theString += t;    return this;
    }

    global String toStr(){
        return theString;
    }
}