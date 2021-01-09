/*
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0      Fenny    04-Jul-2012    13.7        Defect#: 36898, 37042, 37241: Too many script statements: 200001
*/
global class FAP_FieldIndex {

    global final Map<String,Schema.DescribeFieldResult> index = new Map<String,Schema.DescribeFieldResult>(); 

    global FAP_FieldIndex(){}
    
    /*
    global FieldIndex indexAllTypes(){
        final Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        if(globalDescribe != null){
            for(Schema.SObjectType aType : globalDescribe.values()){
                indexType(aType.getDescribe());
            }
        }
        return this;
    }
    */
    
    global FAP_FieldIndex indexType(List<Schema.DescribeSObjectResult> types){
        if(types != null && types.size() > 0){
            for(Schema.DescribeSObjectResult aType : types){
                indexType(aType);
            }
        }
        return this;
    }
    
    global FAP_FieldIndex indexType(Schema.DescribeSObjectResult aType){
        if(aType != null){
            final Map<String, Schema.SObjectField> fieldMap = aType.fields.getMap();
            if(fieldMap != null && fieldMap.size() > 0){
                Schema.DescribeFieldResult current = null;
                for(Schema.SObjectField field : fieldMap.values()){
                    current = field.getDescribe();
                    index.put(aType.getLocalName() + '.' + current.getLocalName(),current);
                }
            }
        }
        
        List<Object> fieldNameList = new List<String>();
        for(String key : index.keySet()){
            fieldNameList.add(key);
        }
        return this;
    }
    
    global Boolean isValidField(String qualifiedName){
        //return getDescribeForField(qualifiedName) != null; // Ver 1.0: To fix 'Too many script statements'
        return index.get(qualifiedName) != null;
    }
    
    global Boolean isValidField(String objectName, String fieldName){
        //return getDescribeForField(objectName,fieldName) != null; // Ver 1.0: To fix 'Too many script statements'
       
        return index.get(objectName + '.' + fieldName) != null;
    }

    global Schema.DescribeFieldResult getDescribeForField(String qualifiedName){
        return index.get(qualifiedName);
    }

    global Schema.DescribeFieldResult getDescribeForField(String objectName, String fieldName){
        //return getDescribeForField(objectName + '.' + fieldName); // Ver 1.0: To fix 'Too many script statements'
        return index.get(objectName + '.' + fieldName);
    }
    
}