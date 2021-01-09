@isTest
public class CC_exception_Pim_Dsa_Test {
  private static String action= '';
	private static String jsonData = '';
    //private static String jsonData1 = '';
	private static RestRequest req = new RestRequest();
    private static RestResponse res = new RestResponse();
    
   //Method exceptiondsa used to create a exception by calling  CC_exception_Pim_Dsa.CC_pim for Basemerge 
   static testMethod void exceptiondsa() {
        Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '';
            insert pid;
        action = 'BaseMerge';
		string itemClass = 'KC0031xx';
        string productlinedesc='LATITUDE 33001YYZ';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "'+productlinedesc+'",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFAIO", "offering_group": "", "offering_group_desc": "",'+
									   '"base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "",'+
									   '"product_offering_code_desc": "", "item_class": "'+itemClass+'",'+
									   '"item_class_desc": "LATITUDE 3300,NBK,PINEHILLSCTO1"'+
                                       '}  ]}';
        
        req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);
        RestContext.request = req;
        RestContext.response= res;
       
		Test.startTest();
        String jSONRequestBody=req.requestBody.toString().trim();
        CC_exception_Pim_Dsa.ccpim(res,'Any one or more filed values are missing in Post request,Field Names are - item_class,lob_desc,family_desc,type_desc,product_line_desc,group_desc or product_line_desc',jSONRequestBody,'BaseMerge');
        Test.stopTest();
        system.assertEquals(1, [select count() from Exception__c]);

        
   }
   //Method exceptiondsa1 used to create a exception by calling  CC_exception_Pim_Dsa.CC_pim for MonarchMerge  
    static testMethod void exceptiondsa1() {
        Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '';
            insert pid;
        action = 'MonarchMerge';
		string itemClass = 'KC0031xx';
        string productlinedesc='LATITUDE 33001YYZ';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "'+productlinedesc+'",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFAIO", "offering_group": "", "offering_group_desc": "",'+
									   '"base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "",'+
									   '"product_offering_code_desc": "", "item_class": "'+itemClass+'",'+
									   '"item_class_desc": "LATITUDE 3300,NBK,PINEHILLSCTO1"'+
                                       '}  ]}';
        
        req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);
        RestContext.request = req;
        RestContext.response= res;
       
		Test.startTest();
        String jSONRequestBody=req.requestBody.toString().trim();
        CC_exception_Pim_Dsa.ccpim(res ,'res',jSONRequestBody,'MonarchMerge'); 
        Test.stopTest();
        system.assertEquals(1, [select count() from Exception__c]);
        
   }
    //Method exceptiondsa2 used to create a exception by calling  CC_exception_Pim_Dsa.CC_pim for MonarchDelete  
    static testMethod void exceptiondsa2() {
        Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '';
            insert pid;
        action = 'MonarchDelete';
		string itemClass = 'KC0031xx';
        string productlinedesc='LATITUDE 33001YYZ';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "'+productlinedesc+'",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFAIO", "offering_group": "", "offering_group_desc": "",'+
									   '"base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "",'+
									   '"product_offering_code_desc": "", "item_class": "'+itemClass+'",'+
									   '"item_class_desc": "LATITUDE 3300,NBK,PINEHILLSCTO1"'+
                                       '}  ]}';
        
        req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);
        RestContext.request = req;
        RestContext.response= res;
       
		Test.startTest();
        String jSONRequestBody=req.requestBody.toString().trim();
        CC_exception_Pim_Dsa.ccpim(res,'Any one or more filed values are missing in Post request,Field Names are - item_class,lob_desc,family_desc,type_desc,product_line_desc,group_desc or product_line_desc',jSONRequestBody,'MonarchDelete'); 
         //CC_exception_Pim_Dsa.CC_pim(res,'Any one or more filed values are missing in Post request,Field Names are - item_class,lob_desc,family_desc,type_desc,product_line_desc,group_desc or product_line_desc',jSONRequestBody,'BaseDelete'); 
        Test.stopTest();
        system.assertEquals(1, [select count() from Exception__c]);
        
   }
    
  //Method exceptiondsa3 used to create a exception by calling  CC_exception_Pim_Dsa.CC_pim for BaseDelete   
  static testMethod void exceptiondsa3() {
        Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '';
            insert pid;
        action = 'MonarchDelete';
		string itemClass = 'KC0031xx';
        string productlinedesc='LATITUDE 33001YYZ';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "'+productlinedesc+'",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFAIO", "offering_group": "", "offering_group_desc": "",'+
									   '"base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "",'+
									   '"product_offering_code_desc": "", "item_class": "'+itemClass+'",'+
									   '"item_class_desc": "LATITUDE 3300,NBK,PINEHILLSCTO1"'+
                                       '}  ]}';
        
        req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);
        RestContext.request = req;
        RestContext.response= res;
       
		Test.startTest();
        String jSONRequestBody=req.requestBody.toString().trim();
        //CC_exception_Pim_Dsa.CC_pim(res,'Any one or more filed values are missing in Post request,Field Names are - item_class,lob_desc,family_desc,type_desc,product_line_desc,group_desc or product_line_desc',jSONRequestBody,'MonarchDelete'); 
        CC_exception_Pim_Dsa.ccpim(res,'Any one or more filed values are missing in Post request,Field Names are - item_class,lob_desc,family_desc,type_desc,product_line_desc,group_desc or product_line_desc',jSONRequestBody,'BaseDelete'); 
        Test.stopTest();
        system.assertEquals(1, [select count() from Exception__c]);
        
   } 
//Method exceptiondsa4 used to create a exception by calling  CC_exception_Pim_Dsa.CC_pim for insertPIM     
 static testMethod void exceptiondsa4() {
        Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '';
            insert pid;
        action = 'BaseMerge';
		string itemClass = 'KC0031xx';
        string productlinedesc='LATITUDE 33001YYZ';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "'+productlinedesc+'",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFAIO", "offering_group": "", "offering_group_desc": "",'+
									   '"base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "",'+
									   '"product_offering_code_desc": "", "item_class": "'+itemClass+'",'+
									   '"item_class_desc": "LATITUDE 3300,NBK,PINEHILLSCTO1"'+
                                       '}  ]}';
        
        req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);
        RestContext.request = req;
        RestContext.response= res;
     try{
		String jSONRequestBody=req.requestBody.toString().trim();
        Test.startTest();
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        system.assertEquals(0, [Select count() from Product2]);
     }catch(Exception ex){
         CC_exception_Pim_Dsa.ccpimex(res, ex,'Product2_PIM_Mapping__c','CC_PIM_ProductUpdates -> InsertPIM','InsertPIM');
     }     
   }
    
//Method exceptiondsa5 used to create a exception by calling  CC_exception_Pim_Dsa.CC_pim_dsa for DSA exception     
 static testMethod void exceptiondsa5() {
        Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '';
            insert pid;
        action = 'BaseMerge';
		string itemClass = 'KC0031xx';
        string productlinedesc='LATITUDE 33001YYZ';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "'+productlinedesc+'",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFAIO", "offering_group": "", "offering_group_desc": "",'+
									   '"base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "",'+
									   '"product_offering_code_desc": "", "item_class": "'+itemClass+'",'+
									   '"item_class_desc": "LATITUDE 3300,NBK,PINEHILLSCTO1"'+
                                       '}  ]}';
        
        req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);
        RestContext.request = req;
        RestContext.response= res;
       
		Test.startTest();
         CC_ProductDetails proddetail = (CC_ProductDetails)JSON.deserialize(jsonData,CC_ProductDetails.class);
         CC_exception_Pim_Dsa.ccpimdsa(proddetail);
        Test.stopTest();
        system.assertEquals(1, [select count() from Exception__c]);
   }   
}