public class TestDataGenerator {
    
    private static integer j=0; 
    private static List<SObject> UserList = new List<User>();
    private static List<SObject> AccList = new List<Account>();
    private static List<SObject> OppList = new List<Opportunity>();
        
    // Define Mandatory string field
    // add <cnt> if it is unique field
    private static Map<String, String> mapUser = new Map<String, String> {
                                                    'LastName'=>'dell', 
                                                    'UserName'=>'TestUser<time><cnt>@dell.com.test',
                                                    'ProfileId'=>'00e30000000nJ6KAAU',
                                                    'Email'=>'men_mee_how@dell.com',
                                                    'Alias'=>'dell<cnt>',
                                                    'Badge_Number__c'=>'B<cnt>'};
    private static Map<String, String> mapAcc = new Map<String, String> {'name' => 'Test Account'};        
    private static Map<String, String> mapSlsChnlGrp = new Map<String, String> {
                                                    'name'=>'TestSlsChnlGrp<cnt>',
                                                    'Group_ID__c'=>'G<cnt>'};
    private static Map<String, String> mapOpp = new Map<String, String> {
                                                    'RecordTypeId'=>'012300000004zf2',
                                                    'Name'=>'Test Opp<cnt>'};
  
    //Set methods
    public static  void setUserList(List<SObject> values) {
        UserList = values;
    }
       
    public static void setAccList(List<SObject> values) {
        AccList = values;
    }
    
    public static void setOppList(List<SObject> values) {
        OppList = values;
    }
    
    public static List<sObject> getObject(SObject prototype, Integer count) {
        return getObject(prototype, count, null, true);
    }
    
    public static List<SObject> getObject(SObject prototype, Integer count, Map<String, String> mString){
        return getObject(prototype, count, mString, true);
    }
        
    public static List<sObject> getObject(SObject prototype, Integer count, Map<String,String> mString, Boolean doInsert){
        final Integer MAX_COUNT = 250;
        
        if(prototype == null){
            return null;
        }
                
        //String objectName = StringUtils.split(''+prototype,':')[0];
        String objectName = (''+prototype).split(':')[0];
                
        List<SObject> objects = Database.query(
                    'select Id from '
                    + objectName
                    + ' where Id = \'0015000000Mrr40\' LIMIT 0'); // use dummy Id to ensure no return
                    
        if(count <= 0){
            return objects;
        }
        
        Schema.sObjectType prototypeToken = prototype.getSObjectType();
        
        sObject tmpObj = (sObject) prototypeToken.newSObject();
        
        if(mString != null && !mString.isEmpty()){          
            tmpObj = setValueTosObject(tmpObj, mString);            
        }           
        
        // Default mandatory picklist field
        Map<string, schema.sObjectField> m =  prototype.getSObjectType().getDescribe().Fields.getMap();     
        for (string key: m.keyset()) {          
            Schema.DescribeFieldResult f = m.get(key).getDescribe();
            if (!f.IsNillable() && !f.IsDefaultedOnCreate() && f.isFilterable() && f.isUpdateable()) {
                if (f.getType() == Schema.DisplayType.PICKLIST) {                          
                    if (tmpObj.get(key) == null) tmpObj.put(key, f.getPicklistvalues()[0].getValue());
                } else if (f.getType() == Schema.DisplayType.DATE) { 
                    if (tmpObj.get(key) == null) tmpObj.put(key, System.today());
                }
            }              
        }
           
        for(Integer i = 0; i < count && i < MAX_COUNT; i++){    
        
            sObject anObject = (SObject)prototypeToken.newSObject();            
            
            anObject = tmpObj.clone(); 
            
            // Check for mandatory fields
            anObject = defaultForMandatoryField(anObject, i, count);                
                
            objects.add(anObject);              
        }       
                
        if(doInsert){           
            insert objects;         
        }           
        
        return objects;     
    }  
    
    private static  sObject setValueTosObject(sObject sObj, Map<String, String> mString) {
        
        string sFieldName;
        string sDataType;
        
        for (String sk: mString.KeySet()) {
            sDataType = sk.subString(0,3);
            sFieldName = sk.subString(4);
            
            try {
                if (sDataType == 'int') 
                    sObj.put(sFieldName, integer.valueof(mString.get(sk)));
                else if (sDataType == 'dbl') 
                    sObj.put(sFieldName, double.valueof(mString.get(sk)));              
                else if (sDataType == 'dec') 
                    sObj.put(sFieldName, decimal.valueof(mString.get(sk)));
                //else if (sDataType == 'lng')
                //  sObj.put(sFieldName, long.valueof(mString.get(sk)));
                else if (sDataType == 'dat') 
                    sObj.put(sFieldName, date.valueOf(mString.get(sk)));
                else if (sDataType == 'dtm')                
                    sObj.put(sFieldName, datetime.valueOfGMT(mString.get(sk)));
                else if (sDataType == 'bln')            
                    sObj.put(sFieldName,  mString.get(sk).equals('true'));
                else //string
                    sObj.put(sFieldName, mString.get(sk));
            }
            catch (exception ex) {
                system.debug('Caught APEX exception(TestDataGenerator.setValueTosObject): ' + ex.getMessage());
            }
        }       
        return sObj;
    }
    /*
    private static sObject defaultForMandatoryField(sObject sObj, integer i, integer count) {
        Map<String, String> tmpMap = new Map<String, String> ();
                
        if (sObj.getSObjectType() == User.sObjectType){        
            tmpMap = mapUser.clone();
            j++;            
        } else if (sObj.getSObjectType() == Account.sObjectType){          
            tmpMap = mapAcc.clone();            
        } else if ((sObj.getSObjectType() == AccountTeamMember.sObjectType)){        
            if (AccList.isEmpty() && sObj.get('AccountId') == null) setAccList(getObject(new Account(), 1));            
            if (UserList.isEmpty() && sObj.get('UserId') == null) setUserList(getObject(new User(), count));
            
            if (sObj.get('AccountId') == null) sObj.put('AccountId',AccList[0].get('Id'));
            if (sObj.get('UserId') == null) sObj.put('UserId', UserList[i].get('Id'));                      
        } else if (sObj.getSObjectType() == AccountShare.sObjectType) {
            if (AccList.isEmpty() && sObj.get('AccountId') == null) setAccList(getObject(new Account(), 1));            
            if (UserList.isEmpty() && sObj.get('UserOrGroupId') == null) setUserList(getObject(new User(), count));
            
            if (sObj.get('AccountId') == null) sObj.put('AccountId',AccList[0].get('Id'));
            if (sObj.get('UserOrGroupId') == null) sObj.put('UserOrGroupId', UserList[i].get('Id'));  
            
            tmpMap = mapAccShare.clone();
        } else if (sObj.getSObjectType() == Sales_Channel_Group__c.sObjectType) {
            tmpMap = mapSlsChnlGrp.clone();
            j++;
        } else if(sObj.getSObjectType() == Opportunity.sObjectType){
            if (AccList.isEmpty() && sObj.get('AccountId') == null) setAccList(getObject(new Account(), 1));
            
            tmpMap = mapOpp.clone();
        } else if (sObj.getSObjectType() == OpportunityTeamMember.sObjectType) {
            if (OppList.isEmpty() && sObj.get('OpportunityId') == null) setOppList(getObject(new Opportunity(), 1));
            if (UserList.isEmpty() && sObj.get('UserId') == null) setUserList(getObject(new User(), count));
            
            if (sObj.get('OpportunityId') == null) sObj.put('OpportunityId', OppList[0].get('Id'));
            if (sObj.get('UserId') == null) sObj.put('UserId', UserList[i].get('Id'));  
        }
        
        for (string key: tmpMap.keySet()) {
            if (sObj.get(key) == null) sObj.put(key, tmpMap.get(key).replace('<cnt>', string.valueOf(j)));          
        }
        
        return sObj;
    }
    */
    
     private static sObject defaultForMandatoryField(sObject sObj, integer i, integer count) {
        Map<String, String> tmpMap = new Map<String, String> ();
        string mapValue;
        
        if (sObj.getSObjectType() == User.sObjectType){        
            tmpMap = mapUser.clone();
            j++;            
        } else if (sObj.getSObjectType() == Account.sObjectType){          
            tmpMap = mapAcc.clone();     
        } else if (sObj.getSObjectType() == Sales_Channel_Group__c.sObjectType) {
            tmpMap = mapSlsChnlGrp.clone();
            j++;    
        } else if (sObj.getSObjectType() == Opportunity.sObjectType) {
            tmpMap = mapOpp.clone();
        } 

        if ((sObj.getSObjectType() == AccountTeamMember.sObjectType) || (sObj.getSObjectType() == AccountShare.sObjectType) || (sObj.getSObjectType() == Opportunity.sObjectType)){        
            if (AccList.isEmpty() && sObj.get('AccountId') == null) setAccList(getObject(new Account(), 1));            
            if (sObj.get('AccountId') == null) sObj.put('AccountId',AccList[0].get('Id'));                             
        } 
        
        if ((sObj.getSObjectType() == AccountTeamMember.sObjectType) || (sObj.getSObjectType() == OpportunityTeamMember.sObjectType)) {
            if (UserList.isEmpty() && sObj.get('UserId') == null) setUserList(getObject(new User(), count));        
            if (sObj.get('UserId') == null) sObj.put('UserId', UserList[i].get('Id'));      
            
        }

        if ((sObj.getSObjectType() == AccountShare.sObjectType) || (sObj.getSObjectType() == OpportunityShare.sObjectType)) {  
            
            //Raymond 20090505: Added condition to set AccountAccessLevel for AccountShare only
            
            if(sObj.getSObjectType() == AccountShare.sObjectType)
            {
                if(sObj.get('AccountAccessLevel') == null) {
                    sObj.put('AccountAccessLevel','Read');
                }
            }
            
            if(sObj.get('OpportunityAccessLevel') == null) {
                sObj.put('OpportunityAccessLevel','None');
            }
                
            if (UserList.isEmpty() && sObj.get('UserOrGroupId') == null) setUserList(getObject(new User(), count));                        
            if (sObj.get('UserOrGroupId') == null) sObj.put('UserOrGroupId', UserList[i].get('Id'));            
        }   

        if ((sObj.getSObjectType() == OpportunityTeamMember.sObjectType) ||(sObj.getSObjectType() == OpportunityShare.sObjectType)) {
            if (OppList.isEmpty() && sObj.get('OpportunityId') == null) setOppList(getObject(new Opportunity(), 1));
            if (sObj.get('OpportunityId') == null) sObj.put('OpportunityId', OppList[0].get('Id'));
        }        
        
        for (string key: tmpMap.keySet()) {
            if (sObj.get(key) == null) {
                mapValue = tmpMap.get(key);
                mapValue = mapValue.replace('<cnt>', string.valueOf(j));
                mapValue = mapValue.replace('<time>', ''+System.currentTimeMillis());
                sObj.put(key, mapValue);
            }          
        }
        
        return sObj;
     }
}