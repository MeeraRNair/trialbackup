@isTest
public class CC_PIM_ProductUpdatesTest {
	private static String action= '';
	private static String jsonData = '';
    //private static String jsonData1 = '';
	private static RestRequest req = new RestRequest();
    private static RestResponse res = new RestResponse();
        
    @testSetup
    static void setup(){
            Product2 product = new Product2(
            Product_ID__c = '1',
			PIM_Product__c = True ,
            IsActive=true,
			Name = 'LATITUDE 33001',
			Description = 'LOB222501',
			Brand_Category_code__c ='23296',
			Detailed_Description__c = 'Test',
			Family = 'PINEHILLSFCTO12-IN-1',
			ProductCode ='Commercial1',
			Product_Line_Desc__c ='LATITUDE 33001',
			Product_Offering_Description__c = 'OFFICE 365 APPLICATIONS-T',
			Family_Code__c =''
        );
		insert product;    
   
		Product2_PIM_Mapping__c prdpim = new Product2_PIM_Mapping__c(
			Brand_Category_Code__c='23296',
			Product_Offering_Description__c ='Abc1',
			Classcode_Prod_Offer_Code__c='KC0031',
            IsActive__c=True,
			SFDC_Prod_ID__C = product.Id);
            insert prdpim;
        
        Product2_PIM_Mapping__c prdpim2 = new Product2_PIM_Mapping__c(
			Brand_Category_Code__c='23296',
			Product_Offering_Description__c ='OFFICE 365 APPLICATIONS-T',
			Classcode_Prod_Offer_Code__c='SV-PC-20023-T',
            IsActive__c=True,
			SFDC_Prod_ID__C = product.Id
        );
        insert prdpim2;
        
        Product2 product1 = new Product2(
            Product_ID__c = '11',
			PIM_Product__c = True ,
            IsActive=true,
			Name = 'LATITUDE 33001 AIO',
			Description = 'LOB222501',
			Brand_Category_code__c ='23296',
			Detailed_Description__c = 'Test',
			Family = 'PINEHILLSFCTO12-IN-1',
			ProductCode ='Commercial1',
			Product_Line_Desc__c ='LATITUDE 33001',
			Product_Offering_Description__c = 'OFFICE 365 APPLICATIONS-T',
			Family_Code__c =''
        );
		insert product1; 
        Product2_PIM_Mapping__c prdpim1 = new Product2_PIM_Mapping__c(
			Brand_Category_Code__c='23296',
			Product_Offering_Description__c ='Abc1',
			Classcode_Prod_Offer_Code__c='KC0031',
            IsActive__c=True,
			SFDC_Prod_ID__C = product1.Id);
            insert prdpim1;
        
            Product2 product2 = new Product2(
            Product_ID__c = '111',
			PIM_Product__c = True ,
            IsActive=true,
			Name = 'LATITUDE 33001 AIO',
			Description = 'Latitude1',
			Brand_Category_code__c ='23296',
			Detailed_Description__c = 'Test',
			Family = 'Client Solutions PBU1',
			ProductCode ='Commercial1',
			Product_Line_Desc__c ='LATITUDE 33001',
			Product_Offering_Description__c = 'OFFICE 365 APPLICATIONS-T',
			Family_Code__c ='',
            EMC_Product_ID__c='01t'
        );
		insert product2;
        
        Product2 product3 = new Product2(
            Product_ID__c = '1213',
			PIM_Product__c = True ,
            IsActive=true,
			Name = 'LATITUDE 33001',
			Description = 'LOB222501',
			Brand_Category_code__c ='23296',
			Detailed_Description__c = 'Test',
			Family = 'PINEHILLSFCTO12-IN-1',
			ProductCode ='Commercial1',
			Product_Line_Desc__c ='LATITUDE 33001',
			Product_Offering_Description__c = 'ABCD',
			Family_Code__c =''
        );
		insert product3;  
        //KC00311
        Product2 product4 = new Product2(
            Product_ID__c = '19999',
			PIM_Product__c = True ,
            IsActive=true,
			Name = 'LATITUDE 33001',
			Description = 'LOB222501',
			Brand_Category_code__c ='23296',
			Detailed_Description__c = 'Test',
			Family = 'PINEHILLSFCTO12-IN-1',
			ProductCode ='Commercial1',
			Product_Line_Desc__c ='LATITUDE 33001',
			Product_Offering_Description__c = 'OFFICE 365 APPLICATIONS-T',
			Family_Code__c =''
        );
		insert product4;    
   
		Product2_PIM_Mapping__c prdpim4 = new Product2_PIM_Mapping__c(
			Brand_Category_Code__c='23296',
			Product_Offering_Description__c ='Abc1',
			Classcode_Prod_Offer_Code__c='KC00311',
            IsActive__c=True,
			SFDC_Prod_ID__C = product4.Id);
            insert prdpim4;
        ////SV-PC-20023-TTTT
       Product2 product5 = new Product2(
            Product_ID__c = '19998',
			PIM_Product__c = True ,
            IsActive=true,
			Name = 'LATITUDE 33001',
			Description = 'LOB222501',
			Brand_Category_code__c ='23296',
			Detailed_Description__c = 'Test',
			Family = 'PINEHILLSFCTO12-IN-1',
			ProductCode ='Commercial1',
			Product_Line_Desc__c ='LATITUDE 33001',
			Product_Offering_Description__c = 'OFFICE 365 APPLICATIONS-T',
			Family_Code__c =''
        );
		insert product5;    
   
		Product2_PIM_Mapping__c prdpim5 = new Product2_PIM_Mapping__c(
			Brand_Category_Code__c='23296',
			Product_Offering_Description__c ='Abc1',
			Classcode_Prod_Offer_Code__c='SV-PC-20023-TTTT',
            IsActive__c=True,
			SFDC_Prod_ID__C = product5.Id);
            insert prdpim5;
    
		Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Standard Price Book';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';      	
        insert pb1;
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'Common Catalog';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='MXN';
      	insert pb2;
        
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
         Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '1';
            insert pid;
    }
    
    public static PricebookEntry createPricebookEntry (Id standardId, Pricebook2 newPricebook, Product2 prod, Decimal value) {
        System.debug('***** starting one');
        PricebookEntry one = new PricebookEntry();
        one.pricebook2Id = standardId;
        one.product2id = prod.id;
        one.unitprice = value;
        one.isactive = true;
        insert one;
        System.debug('***** one complete, ret next');
        PricebookEntry ret = new PricebookEntry();
        ret.pricebook2Id = newPricebook.id;
        ret.product2id = prod.id;
        ret.unitprice = value;
        ret.isactive = true;
        insert ret;
        return ret;
    }
    // Method testPositiveBaseMerge will pass the Json to doPost() method and insert one Product.
	static testmethod void testPositiveBaseMerge(){
            Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '1111';
            insert pid;
        action = 'BaseMerge';
		string itemClass = 'KC003131';
        string productlinedesc='LATITUDE 33001YY';
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
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        // New Product should inserted and increase the Product count to 7.
        system.assertEquals(7, [Select count() from Product2]);
     }
    // Method testPositiveBaseMerge1 will pass the Json to doPost() method and Update the Product & PIM as product already available.
    static testmethod void testPositiveBaseMerge1(){
        action = 'BaseMerge';
		string itemClass = 'KC0031';
        string productlinedesc='LATITUDE 33001';
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
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        
        // Since the same Item class already available , it will perform update and count will remain 6.
        system.assertEquals(6, [Select count() from Product2]);
        
     }
 // Method testPositiveBaseMerge2 will pass the Json to doPost() method and Update the Product and insert pim.
  static testmethod void testPositiveBaseMerge2(){
        action = 'BaseMerge';
		string itemClass = 'KC0031xx';
        string productlinedesc='LATITUDE 33001';
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
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
       // Since the same product_line_desc already available , it will perform update Product and insert PIM.
       // Product Count should remain 6.
        system.assertEquals(6, [Select count() from Product2]);
      
     } 
    //EMC validation 
   // Method testPositiveBaseMerge3 will pass the Json to doPost() method to cover the EMC Product id.
    static testmethod void testPositiveBaseMerge3(){
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
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        // New ItemClass and product_line_desc, it will Perform an insert of Product.
        // So Product count will increase to 7.
         system.assertEquals(7, [Select count() from Product2]);
     }
    // Method testBaseMergeNegative will pass the Json to doPost() .This method to validate the exception.
    static testmethod void testBaseMergeNegative(){
        action = 'BaseMerge';
		string itemClass = '';
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
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        
        // We are passing Null itemclass, So No Product will insert.
        // Product count will remain 6.
        
         system.assertEquals(6, [Select count() from Product2]);
     }  
    // Method testPositiveBaseMergeNegativeDSA will pass the Json to doPost() .This method to validate the exception.
    //Test Negative for DSA
    static testmethod void testPositiveBaseMergeNegativeDSA(){
        action = 'BaseMerge';
		string itemClass = '';
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
        CC_PIM_ProductUpdates.ccpimprod(proddetail);
        Test.stopTest();
        
         system.assertEquals(6, [Select count() from Product2]);
     }
    // Test Negative Exception
    // This testPositiveBaseMergeNegativeDSA will validate the exception for the insert Product. 
    static testmethod void testNegativeBaseMergeEXP(){
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
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        
        // We are passing Null Product_Id, So it will give exception and no Product will be inseted. 
       
         system.assertEquals(6, [Select count() from Product2]);
     }
    // This testNegativeBaseMergeEXPDSA will validate the exception for the insert Product.
    static testmethod void testNegativeBaseMergeEXPDSA(){
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
		Test.startTest();
        CC_ProductDetails proddetail = (CC_ProductDetails)JSON.deserialize(jsonData,CC_ProductDetails.class);
        CC_PIM_ProductUpdates.ccpimprod(proddetail);
        Test.stopTest();
        //Passing Null Itemclass, it should give validation exception and no product will be inserted.
        //Product count will remain 6
        }catch(Exception ex){
            
        }
        system.assertEquals(6, [Select count() from Product2]);
     }
    // This testPositiveMonarchMerge will insert new product for Snp
    
    static testmethod void testPositiveMonarchMerge(){
        Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '222';
            insert pid;
        action = 'MonarchMerge';
            jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "LATITUDE 33001",'+
                '"product_type": "", "product_type_desc": "Delltest", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1", "portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "offering_group": "", "offering_group_desc": "", "base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "SV-PC-20023-TTY", "product_offering_code_desc": "ABC", "item_class": "", "item_class_desc": ""'+
                '}  ]}';							   
       
            req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
            req.httpMethod = 'POST';
            req.requestBody = blob.valueOf(jsonData);
            RestContext.request = req;
            RestContext.response= res;
            Test.startTest();
            CC_PIM_ProductUpdates.doPost();
            Test.stopTest();
        //New Snp product should inseted and product count will increase to 7
        system.assertEquals(7, [Select count() from Product2]);
        
        }
    
    // This testPositiveMonarchMerge will perform update of  product for Snp
      static testmethod void testPositiveMonarchMerge1(){
        action = 'MonarchMerge';
            jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "LATITUDE 33001",'+
                '"product_type": "", "product_type_desc": "Delltest", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1", "portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "offering_group": "", "offering_group_desc": "", "base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "SV-PC-20023-T", "product_offering_code_desc": "ABC", "item_class": "", "item_class_desc": ""'+
                '}  ]}';							   
       
            req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
            req.httpMethod = 'POST';
            req.requestBody = blob.valueOf(jsonData);
            RestContext.request = req;
            RestContext.response= res;
            Test.startTest();
            CC_PIM_ProductUpdates.doPost();
            Test.stopTest();
          system.assertEquals(6, [Select count() from Product2]);
        }
    
    // This testPositiveMonarchMerge2 will perform update of  product for Snp
    static testmethod void testPositiveMonarchMerge2(){
        action = 'MonarchMerge';
            jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "LATITUDE 33001",'+
                '"product_type": "", "product_type_desc": "Delltest", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1", "portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "offering_group": "", "offering_group_desc": "", "base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "SV-PC-20023-TTTY", "product_offering_code_desc": "ABCD", "item_class": "", "item_class_desc": ""'+
                '}  ]}';							   
       
            req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
            req.httpMethod = 'POST';
            req.requestBody = blob.valueOf(jsonData);
            RestContext.request = req;
            RestContext.response= res;
            Test.startTest();
            CC_PIM_ProductUpdates.doPost();
            Test.stopTest();
        
        system.assertEquals(6, [Select count() from Product2]);
        }
     // This testNegativeMonarchMerge will perform exception validateion for snp
    static testmethod void testNegativeMonarchMerge(){
        action = 'MonarchMerge';
            jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "LATITUDE 33001",'+
                '"product_type": "", "product_type_desc": "Delltest", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1", "portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "offering_group": "", "offering_group_desc": "", "base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "", "product_offering_code_desc": "ABCD", "item_class": "", "item_class_desc": ""'+
                '}  ]}';							   
       
            req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
            req.httpMethod = 'POST';
            req.requestBody = blob.valueOf(jsonData);
            RestContext.request = req;
            RestContext.response= res;
            Test.startTest();
            CC_PIM_ProductUpdates.doPost();
            Test.stopTest();
        system.assertEquals(6, [Select count() from Product2]);
        }
    
    // This testNegativeMonarchMerge will perform exception validateion for snp
    static testmethod void testNegativeMonarchMergeDSA(){
        action = 'MonarchMerge';
            jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "LATITUDE 33001",'+
                '"product_type": "", "product_type_desc": "Delltest", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1", "portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "offering_group": "", "offering_group_desc": "", "base_code": "PINEHILLSCTO123", "base_code_desc": "LATITUDE 3300,KABYLAKE,NOTEBOOK,PINEHILLSCTO1", "product_offering_code": "", "product_offering_code_desc": "ABCD", "item_class": "", "item_class_desc": ""'+
                '}  ]}';							   
       
            req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
            req.httpMethod = 'POST';
            req.requestBody = blob.valueOf(jsonData);
            RestContext.request = req;
            RestContext.response= res;
            Test.startTest();
           CC_ProductDetails proddetail = (CC_ProductDetails)JSON.deserialize(jsonData,CC_ProductDetails.class);
           CC_PIM_ProductUpdates.ccpimprod(proddetail);
            Test.stopTest();
        system.assertEquals(6, [Select count() from Product2]);
        }
    
    // This testPositiveBaseDelete will perform update for BaseDelete
     public static testmethod void testPositiveBaseDelete(){
        action = 'BaseDelete';
        string itemClass = 'KC0031';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "LATITUDE 33001",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "offering_group": "", "offering_group_desc": "",'+
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
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
         system.assertEquals(6, [Select count() from Product2]);
        
	}
    // This testNegativeBaseDelete will perform exception  for BaseDelete
    public static testmethod void testNegativeBaseDelete(){
        action = 'BaseDelete';
        string itemClass = '';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "LATITUDE 33001",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "offering_group": "", "offering_group_desc": "",'+
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
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        system.assertEquals(6, [Select count() from Product2]);
    }
    
    // This testNegativeBaseDeleteDSA will perform exception  for BaseDelete
    public static testmethod void testNegativeBaseDeleteDSA(){
        action = 'BaseDelete';
        string itemClass = '';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "LATITUDE 33001",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "offering_group": "", "offering_group_desc": "",'+
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
       CC_PIM_ProductUpdates.ccpimprod(proddetail);
        Test.stopTest();
        system.assertEquals(6, [Select count() from Product2]);
    }
    // This testPositiveMonarchDelete will perform update for  MonarchDelete 
    public static testmethod void testPositiveMonarchDelete(){
        string productofferingcode = 'SV-PC-20023-T';
		action = 'MonarchDelete';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    { "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "product_line_desc": "LATITUDE 33001", "product_offering_code": "'+productofferingcode+'", "product_offering_code_desc": "OFFICE 365 APPLICATIONS-T"'+
                                       '}  ]}';
		
		req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);

        RestContext.request = req;
        RestContext.response= res;
        
		Test.startTest();
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        system.assertEquals(6, [Select count() from Product2]);
    }
    // This method  testNegativeMonarchDelete will perform exception for  MonarchDelete 
    public static testmethod void testNegativeMonarchDelete(){
        string productofferingcode = '';
		action = 'MonarchDelete';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    { "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "product_line_desc": "LATITUDE 33001", "product_offering_code": "'+productofferingcode+'", "product_offering_code_desc": "OFFICE 365 APPLICATIONS-T"'+
                                       '}  ]}';
		
		req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);

        RestContext.request = req;
        RestContext.response= res;
        
		Test.startTest();
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        system.assertEquals(6, [Select count() from Product2]);
    }
    // This method  testNegativeMonarchDeleteDSA will perform exception for  MonarchDelete 
    public static testmethod void testNegativeMonarchDeleteDSA(){
        string productofferingcode = '';
		action = 'MonarchDelete';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    { "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "product_line_desc": "LATITUDE 33001", "product_offering_code": "'+productofferingcode+'", "product_offering_code_desc": "OFFICE 365 APPLICATIONS-T"'+
                                       '}  ]}';
		
		req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);

        RestContext.request = req;
        RestContext.response= res;
        
		Test.startTest();
       CC_ProductDetails proddetail = (CC_ProductDetails)JSON.deserialize(jsonData,CC_ProductDetails.class);
       CC_PIM_ProductUpdates.ccpimprod(proddetail);
        Test.stopTest();
        system.assertEquals(6, [Select count() from Product2]);
    }
    
      // This method  testPositiveBaseDeletemethod will perform exception for  MonarchDelete 
    public static testmethod void testPositiveBaseDeletemethod(){
        action = 'BaseDelete';
        string itemClass = 'KC00311';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    {      "type_code": "TYP21",  "type_desc": "Client Solutions PBU1",'+
                                       '"group_code": "GRP221",      "group_desc": "Commercial1",      "lob_code": "LOB222501",      "lob_desc": "Latitude1",'+
                                       '"category": "",      "category_desc": "",      "product_line": "232961",      "product_line_desc": "LATITUDE 33001",'+
                                       '"product_type": "", "product_type_desc": "", "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1",'+
									   '"portfolio": "", "portfolio_desc": "", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "offering_group": "", "offering_group_desc": "",'+
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
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        system.assertEquals(6, [Select count() from Product2]);
        
	}
    public static testmethod void testPositiveMonarchDeletemethod(){
        string productofferingcode = 'SV-PC-20023-TTTT';
		action = 'MonarchDelete';
        jsonData ='{ "Id": "044ea1bda9144af180e2106dcbfcc14c",'+
                                       '"Attempt": 1,  "Action": "'+action+'",  "Data": [    { "family_parent": "1312361", "family_parent_desc": "PINEHILLSCTO12-IN-1", "family": "1312371", "family_desc": "PINEHILLSFCTO1", "product_line_desc": "LATITUDE 33001", "product_offering_code": "'+productofferingcode+'", "product_offering_code_desc": "OFFICE 365 APPLICATIONS-T"'+
                                       '}  ]}';
		
		req.requestURI = '/services/apexrest/ProductUpdate'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = blob.valueOf(jsonData);

        RestContext.request = req;
        RestContext.response= res;
        
		Test.startTest();
        CC_PIM_ProductUpdates.doPost();
        Test.stopTest();
        system.assertEquals(6, [Select count() from Product2]);
    }
    
    static testmethod void testPositiveBaseMergeDSAinsert(){
            Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '11';
            insert pid;
        action = 'BaseMerge';
		string itemClass = 'KC003131';
        string productlinedesc='LATITUDE 33001YY';
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
        CC_PIM_ProductUpdates.ccpimprod(proddetail);
        Test.stopTest();
        // New Product should inserted and increase will Product count to 7, from DSA.
        system.assertEquals(7, [Select count() from Product2]);
     }
 
  }