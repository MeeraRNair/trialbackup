/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
global class FAP_ArrayUtils {
    
    global static String[] emptyStringArray = new String[]{};
    global static Integer maxNumberOfEmelentsInList {get{return 1000;}}
    
     global static Object[] reverse(Object[] anArray) {
        if (anArray == null) {
            return null;
        }
        Integer i = 0;
        Integer j = anArray.size() - 1;
        Object tmp;
        while (j > i) {
            tmp = anArray[j];
            anArray[j] = anArray[i];
            anArray[i] = tmp;
            j--;
            i++;
        }
        return anArray;
    }
    
    global static SObject[] reverse(SObject[] anArray) {
        if (anArray == null) {
            return null;
        }
        Integer i = 0;
        Integer j = anArray.size() - 1;
        SObject tmp;
        while (j > i) {
            tmp = anArray[j];
            anArray[j] = anArray[i];
            anArray[i] = tmp;
            j--;
            i++;
        }
        return anArray;
    }
    
    global static Object[] mergex(Object[] array1, Object[] array2){
        if(array1 == null){ return array2; }
        if(array2 == null){ return array1; }
        Object[] merged = new Object[array1.size() + array2.size()];
        for(Integer i = 0; i < array1.size(); i++){
            merged[i] = array1[i];
        }
        for(Integer i = 0; i < array2.size(); i++){
            merged[i+array1.size()] = array2[i];
        }
        return merged;
    }   
     
    global static SObject[] mergex(SObject[] array1, SObject[] array2){
        if(array1 == null){ return array2; }
        if(array2 == null){ return array1; }
        if(array1.size() <= 0){ return array2; }
        List<SObject> merged = createEmptySObjectList(array1[0]);
        for(SObject sObj : array1){ merged.add(sObj); }
        for(SObject sObj : array2){ merged.add(sObj); }
        return merged;
    }   
    
    global static Boolean isEmpty(Object[] objectArray){
        if(objectArray == null){
            return true;
        }
        return objectArray.size() == 0;
    }
    
    global static Boolean isEmpty(SObject[] objectArray){
        if(objectArray == null){
            return true;
        }
        return objectArray.size() == 0;
    }
     global static Object[] pluck(SObject[] objectArray, String fieldName){
        if(isEmpty(objectArray) || StringUtils.isBlank(fieldName)){
            return new Object[]{};
        }
        Object[] plucked = new Object[objectArray.size()];
        for(Integer i = 0; i < objectArray.size(); i++){
            plucked[i] = objectArray[i].get(fieldName);
        }
        return plucked;
    }
    global static Boolean isNotEmpty(Object[] objectArray){
        return !isEmpty(objectArray);
    }
    
    global static Boolean isNotEmpty(SObject[] objectArray){
        return !isEmpty(objectArray);
    }
    
    global static String toString(Object[] objectArray){
        if(objectArray == null){
            return 'null';    
        }
        String returnValue = '{';
        for(Integer i = 0; i < objectArray.size(); i++){
            if(i!=0){ returnValue += ','; }
            returnValue += '\'' + objectArray[i] + '\'';
        }
        returnValue += '}';
        return returnValue; 
    }
    
    global static String toString(SObject[] objectArray){
        if(objectArray == null){
            return 'null';    
        }
        String returnValue = '{';
        for(Integer i = 0; i < objectArray.size(); i++){
            if(i!=0){ returnValue += ','; }
            returnValue += '\'' + objectArray[i] + '\'';
        }
        returnValue += '}';
        return returnValue; 
    }
    
    global static void assertArraysAreEqual(Object[] expected, Object[] actual){
        //check to see if one param is null but the other is not
        System.assert((expected == null && actual == null)|| (expected != null && actual != null),
            'Assertion failed, the following two arrays are not equal.  Expected: ' 
                    + FAP_ArrayUtils.toString(expected) + ', Actual: ' + FAP_ArrayUtils.toString(actual));
        if(expected != null && actual != null){
            System.assert(expected.size() == actual.size(), 'Assertion failed, the following two arrays are not equal.  Expected: ' 
                    + FAP_ArrayUtils.toString(expected) + ', Actual: ' + FAP_ArrayUtils.toString(actual));
            for(Integer i = 0; i < expected.size(); i++){
                System.assert(expected[i] == actual[i], 'Assertion failed, the following two arrays are not equal.  Expected: ' 
                    + FAP_ArrayUtils.toString(expected) + ', Actual: ' + FAP_ArrayUtils.toString(actual));
            }
        }
    }
    
    global static void assertArraysAreEqual(SObject[] expected, SObject[] actual){
        //check to see if one param is null but the other is not
        System.assert((expected == null && actual == null)|| (expected != null && actual != null),
            'Assertion failed, the following two arrays are not equal.  Expected: ' 
                    + FAP_ArrayUtils.toString(expected) + ', Actual: ' + FAP_ArrayUtils.toString(actual));
        if(expected != null && actual != null){
            System.assert(expected.size() == actual.size(), 'Assertion failed, the following two arrays are not equal.  Expected: ' 
                    + FAP_ArrayUtils.toString(expected) + ', Actual: ' + FAP_ArrayUtils.toString(actual));
            for(Integer i = 0; i < expected.size(); i++){
                System.assert(expected[i] == actual[i], 'Assertion failed, the following two arrays are not equal.  Expected: ' 
                    + FAP_ArrayUtils.toString(expected) + ', Actual: ' + FAP_ArrayUtils.toString(actual));
            }
        }
    }
    
    /**
     * This method is no longer needed as in Spring '10, you can created
     * generic SObject lists.
     * 
     * @deprecated
     */
    global static List<SObject> createEmptySObjectList(SObject prototype){
        if(prototype == null){
            return null;
        }
        return Database.query(
            'select Id from ' 
            + FAP_StringUtils.split(''+prototype,':')[0] 
            + ' where Id = \'0015000000Mrr40\' LIMIT 0'); // use dummy Id to ensure no return
    }

    global static List<Object> merg(List<Object> list1, List<Object> list2) {
        List<Object> returnList = new List<Object>();
        if(list1 != null && list2 != null && (list1.size()+list2.size()) > maxNumberOfEmelentsInList){
            throw new FAP_IllegalArgumentException('Lists cannot be merged because new list would be greater than maximum number of elements in a list: ' + maxNumberOfEmelentsInList);
        }
        if(isNotEmpty(list1)){
            for(Object elmt : list1){
                returnList.add(elmt);
            }
        }
        if(isNotEmpty(list2)){
            for(Object elmt : list2){
                returnList.add(elmt);
            }
        }
        return returnList;
    }

    
    global static List<SObject> merg(List<SObject> list1, List<SObject> list2) {
        if(list1 != null && list2 != null && (list1.size()+list2.size()) > maxNumberOfEmelentsInList){
            throw new FAP_IllegalArgumentException('Lists cannot be merged because new list would be greater than maximum number of elements in a list: ' + maxNumberOfEmelentsInList);
        }
        if(isEmpty(list1) && isEmpty(list2)){
            return null;
        }
        List<SObject> returnList = createEmptySObjectList(isNotEmpty(list1) ? list1.get(0) : list2.get(0));
        if(list1 != null){
            for(SObject elmt : list1){
                returnList.add(elmt);
            }
        }
        if(list2 != null){
            for(SObject elmt : list2){
                returnList.add(elmt);
            }
        }
        return returnList;
    }
    
    global static List<Object> subset(List<Object> aList, Integer count) {
        return subset(aList,0,count);
    }

    global static List<Object> subset(List<Object> list1, Integer startIndex, Integer count) {
        List<Object> returnList = new List<Object>();
        if(list1 != null && list1.size() > 0 && startIndex >= 0 && startIndex <= list1.size()-1 && count > 0){
            for(Integer i = startIndex; i < list1.size() && i - startIndex < count; i++){
                returnList.add(list1.get(i));
            }
        }
        return returnList;
    }

    
    global static List<SObject> subset(List<SObject> aList, Integer count) {
        return subset(aList,0,count);
    }

    global static List<SObject> subset(List<SObject> list1, Integer startIndex, Integer count) {
        List<SObject> returnList = null;
        if(list1 != null && list1.size() > 0 && startIndex <= list1.size()-1 && count > 0){
            returnList = createEmptySObjectList(list1.get(0));
            for(Integer i = startIndex; i < list1.size() && i - startIndex < count; i++){
                returnList.add(list1.get(i));
            }
        }
        return returnList;
    }
    
    //===============================================
    //LIST/ARRAY SORTING
    //===============================================

    //FOR FORCE.COM PRIMITIVES (Double,Integer,ID,etc.):
    global static List<Object> qsort(List<Object> theList) {
        return qsort(theList,new FAP_PrimitiveComparator());
    }

    global static List<Object> qsort(List<Object> theList, Boolean sortAsc) {
        return qsort(theList,new FAP_PrimitiveComparator(),sortAsc);
    }
    
    global static List<Object> qsort(List<Object> theList, FAP_ObjectComparator comparator) {
        return qsort(theList,comparator,true);
    }
    
    global static List<Object> qsort(List<Object> theList, FAP_ObjectComparator comparator, Boolean sortAsc) {
        return qsort(theList, 0, (theList == null ? 0 : theList.size()-1),comparator,sortAsc);
    }
    

    
    //FOR SALESFORCE OBJECTS (sObjects):
    global static List<SObject> qsort(List<SObject> theList, FAP_ISObjectComparator comparator) {
        return qsort(theList,comparator,true);
    }
    
    global static List<SObject> qsort(List<SObject> theList, FAP_ISObjectComparator comparator,Boolean sortAsc ) {
        return qsort(theList,  0, (theList == null ? 0 : theList.size()-1),comparator,sortAsc);
    }

    private static List<Object> qsort(List<Object> theList,
                                Integer lo0, 
                                Integer hi0, 
                                FAP_ObjectComparator comparator,
                                Boolean sortAsc){
        Integer lo = lo0;
        Integer hi = hi0;
     
        if (lo >= hi) {
            return theList;
        } else if( lo == hi - 1 ) {
        
            if (( comparator.compare(theList[lo],theList[hi])>0 && sortAsc) || 
                  (comparator.compare(theList[lo],theList[hi])<0 && !sortAsc)    
                ) {
                 Object prs = theList[lo];
                 theList[lo]         = theList[hi];
                 theList[hi]         = prs;
            }
            return theList;
        }

        Object pivot = theList[(lo + hi) / 2];
        theList[(lo + hi) / 2] = theList[hi];
        theList[hi] = pivot;

        while( lo < hi ) {
            while ((comparator.compare(theList[lo], pivot)<=0 && lo < hi && sortAsc) || 
                   (comparator.compare(theList[lo], pivot)>=0 && lo < hi && !sortAsc)
                  ) { lo++; }
            while (( comparator.compare(pivot,theList[hi])<=0 && lo < hi && sortAsc) ||
                   ( comparator.compare(pivot,theList[hi])>=0 && lo < hi && !sortAsc)
                  ) { hi--; }
            
            if( lo < hi ){
                 Object prs = theList[lo];
                 theList[lo]   = theList[hi];
                 theList[hi]    = prs;
            }
        }

        theList[hi0] = theList[hi];
        theList[hi] = pivot;
        
        qsort(theList, lo0, lo-1,comparator,sortAsc);
        qsort(theList, hi+1, hi0,comparator,sortAsc);
        return theList;
    }    
        
    
    private static List<SObject> qsort(List<SObject> theList,
                                Integer lo0, 
                                Integer hi0, 
                                FAP_ISObjectComparator comparator,
                                Boolean sortAsc){
        Integer lo = lo0;
        Integer hi = hi0;
     
        if (lo >= hi) {
            return theList;
        } else if( lo == hi - 1 ) {
        
            if (( comparator.compare(theList[lo],theList[hi])>0 && sortAsc) || 
                  (comparator.compare(theList[lo],theList[hi])<0 && !sortAsc)    
                ) {
                 SObject prs = theList[lo];
                 theList[lo]         = theList[hi];
                 theList[hi]         = prs;
            }
            return theList;
        }

        SObject pivot = theList[(lo + hi) / 2];
        theList[(lo + hi) / 2] = theList[hi];
        theList[hi] = pivot;

        while( lo < hi ) {
            while ((comparator.compare(theList[lo], pivot)<=0 && lo < hi && sortAsc) || 
                   (comparator.compare(theList[lo], pivot)>=0 && lo < hi && !sortAsc)
                  ) { lo++; }
            while (( comparator.compare(pivot,theList[hi])<=0 && lo < hi && sortAsc) ||
                   ( comparator.compare(pivot,theList[hi])>=0 && lo < hi && !sortAsc)
                  ) { hi--; }
            
            if( lo < hi ){
                 SObject prs = theList[lo];
                 theList[lo]   = theList[hi];
                 theList[hi]    = prs;
            }
        }

        theList[hi0] = theList[hi];
        theList[hi] = pivot;
        
        qsort(theList, lo0, lo-1,comparator,sortAsc);
        qsort(theList, hi+1, hi0,comparator,sortAsc);
        return theList;
    }
}