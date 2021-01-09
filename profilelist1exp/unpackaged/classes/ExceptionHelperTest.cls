@isTest
public class ExceptionHelperTest {
    private static String straction= '';
    private static String strjsonData = '';
    //private static String strjsonData1 = '';
    private static RestRequest req = new RestRequest();
    private static RestResponse res = new RestResponse();
    @testSetup 
    static void setup(){
        List<Group> listgrp=[SELECT (select userOrGroupId from groupMembers) FROM group WHERE name ='CC_Exception_Emailgroup'];
        Profile prf=[select id from profile where name='IT TA User'];        
        User user = new User(FirstName = 'Test', LastName='User2', ProfileId = prf.id, Username ='Testcommoncatalog@dell.com', Email= 'Testcommoncatalog@dell.com', Alias ='teste', EmailEncodingKey='UTF-8', LocaleSidKey='en_US', LanguageLocaleKey='en_US', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='CommonCatexceptin');
        insert user;
        if(listgrp.size()==0){
            Group gp = new Group(Name ='CC_Exception_Emailgroup');
            insert gp;
            GroupMember gpm = new GroupMember();
            gpm.GroupId = gp.Id;
            gpm.UserOrGroupId = user.Id;
            Database.insert(gpm);
        }else{
           GroupMember gpm = new GroupMember();
            gpm.GroupId = listgrp[0].Id;
            gpm.UserOrGroupId = user.Id;
            Database.insert(gpm); 
        }
    }  
  
    static testMethod void newexception() {
        Product_ID__c pid = new Product_ID__c();
        pid.name = 'default1';
        pid.Id__c = '';
        insert pid;
        straction = 'BaseMerge';
        string stritemClass = 'KC0031xx';
        string strproductlinedesc='LATITUDE 33001YYZ';
        strjsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
            '"Attempt": 1,  "Action": "'+straction+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
            '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
            '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "'+strproductlinedesc+'",'+
            '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
            '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFAIO", "offering_group": "", "offering_group_desc": "",'+
            '"base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "",'+
            '"product_offering_code_desc": "", "item_class": "'+stritemClass+'",'+
            '"item_class_desc": "LATITUDE 3300,NBK,PINEHILLSCTO1"'+
            '}  ]}';
        
        req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(strjsonData);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        String strjSONRequestBody=req.requestBody.toString().trim();
        ExceptionHelper.logException('Product2','Something went wrong in BaseMerge if Condition',strjSONRequestBody, 'IF Condition BaseMerge','BaseMerge');
        Test.stopTest();
        system.assertEquals(1,[select count() from Exception__c]);
        
    }
    
    static testmethod void testPositiveBaseMerge1(){
        Product_ID__c pid = new Product_ID__c();
        pid.name = 'default';
        pid.Id__c = '';
        insert pid;
        straction = 'BaseMerge';
        string stritemClass = 'KC0031';
        string strproductlinedesc='LATITUDE 33001';
        strjsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
            '"Attempt": 1,  "Action": "'+straction+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
            '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
            '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "'+strproductlinedesc+'",'+
            '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
            '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFAIO", "offering_group": "", "offering_group_desc": "",'+
            '"base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "",'+
            '"product_offering_code_desc": "", "item_class": "'+stritemClass+'",'+
            '"item_class_desc": "LATITUDE 3300,NBK,PINEHILLSCTO1"'+
            '}  ]}';
        
        req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(strjsonData);
        RestContext.request = req;
        RestContext.response= res;
        try{
            Test.startTest();
            CC_PIM_ProductUpdates.doPost();
            Test.stopTest();
            system.assertEquals(1,[select count() from Exception__c]);
            
        }catch(Exception ex){
            ExceptionHelper.logException('Product2_PIM_Mapping__c', ex,'req', 'CC_PIM_ProductUpdates -> InsertPIM','Insert');
        }
        
    }
    static testMethod void insertNewUser2() {
        Test.startTest();
        ExceptionHelper.insertLog('uuu','ttt','ggg','kkk','rrr','yyy');
        Test.stopTest();
        system.assertEquals(1,[select count() from Exception__c]); 
    }
}