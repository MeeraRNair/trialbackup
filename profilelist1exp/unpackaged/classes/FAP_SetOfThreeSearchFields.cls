public class FAP_SetOfThreeSearchFields {

    public FAP_SearchField field1{get; set;}
    public FAP_SearchField field2{get; set;}
    public FAP_SearchField field3{get; set;}
    public FAP_SearchField field4{get; set;}
    
    public static List<FAP_SetOfThreeSearchFields> createFromList(List<FAP_SearchField> fields){
        final List<FAP_SetOfThreeSearchFields> returnValue = new List<FAP_SetOfThreeSearchFields>();
        if(fields != null && fields.size() > 0){
            final Integer rowCount = Math.ceil(fields.size() / 4.0).intValue();
            for(Integer i = 0; i < rowCount; i++){
                FAP_SetOfThreeSearchFields theSet = new FAP_SetOfThreeSearchFields();
                returnValue.add(theSet);
                theSet.field1=fields[i*4];
                if(i==(rowCount-1)){
                    if((i*4) + 1 >= fields.size()){
                        break;
                    } else {
                        theSet.field2=fields[i*4+1];
                        if(((i*4) + 2 >= fields.size())){
                            break;
                        } else {
                            theSet.field3=fields[i*4+2];
                            if(((i*4) + 3 >= fields.size())){
                            break;
                            } else{
                               theSet.field4=fields[i*4+3];  
                               }                       
                        }
                        
                    }
                } else {
                    theSet.field2=fields[(i*4) + 1];
                    theSet.field3=fields[(i*4) + 2];
                    theSet.field4=fields[(i*4) + 3];
                }
            }
           system.debug('Return value'+returnValue); 
        }
        return returnValue;
        
    }
}