@isTest(seeAllData=False)
public class CC_DSAProductProcessWebserviceTest {
    
    public static PricebookEntry createPricebookEntry (Id standardId, Pricebook2 newPricebook, Product2 prod, Decimal value) {
        System.debug('***** starting one');
        PricebookEntry one = new PricebookEntry();
        one.pricebook2Id = standardId;
        one.product2id = prod.id;
        one.unitprice = value;
        one.isactive = true;
        one.CurrencyIsoCode='MXN';
        insert one;
        System.debug('***** one complete, ret next');
        PricebookEntry ret = new PricebookEntry();
        ret.pricebook2Id = newPricebook.id;
        ret.product2id = prod.id;
        ret.unitprice = value;
        ret.isactive = true;
        ret.CurrencyIsoCode='MXN';
        insert ret;
        return ret;
    }     
   //Creating Test Setup for Testing
    @testSetup
    static void testSetup(){
         OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        
        Product_ID__c pid = new Product_ID__c();
			pid.name = 'default';
			pid.Id__c = '1111';
            insert pid;
        
    }
    
    // Create CC_ProductDetails for product insert by passing valida Request
    //  from CC_DSAProductProcessWebservice.addOppLineItem
    
    Public static testMethod void testNewWebService(){
       
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
        
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common Catalog';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'Common Catalog';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='MXN';
        insert pb2;
      
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);
        List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem LIMIT 1];
        system.debug('listoptt'+listoptt);
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
        
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180),
			Primary_Competitor_Product_Type__c = 'Object'
        );
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where id=:opt.Id limit 1];
        
       Test.startTest();
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='ABC002';
        dsareq.ProductType='Ordercode';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId='yur';
        dsareq.dealId=op.Deal_ID__c;
        CC_PIMBaseProdHierarchy item = new CC_PIMBaseProdHierarchy();
        List<CC_PIMBaseProdHierarchy.ITEM_LIST> listitem = new List<CC_PIMBaseProdHierarchy.ITEM_LIST>{};
            
        CC_PIMBaseProdHierarchy.ITEM_LIST dsares = new CC_PIMBaseProdHierarchy.ITEM_LIST();
        dsares.TYPE_CODE='2CP';
		dsares.TYPE_DESC='Client Solutions PBU';
		dsares.GROUP_CODE='3CN';
		dsares.GROUP_DESC='Consumer';
		dsares.LOB_CODE='4XN';
		dsares.LOB_DESC='XPS Notebooks';		
		dsares.FAMILY_PARENT='6GL1';
		dsares.BASE_CODE_DESC='ccq';
		dsares.FAMILY='7GL1AB';
		dsares.FAMILY_DESC='GREENLAND';
		dsares.FAMILY_PARENT_DESC='GREENLAND';
		dsares.ITEM_CLASS_DESC='KC0031';
        dsares.ITEM_CLASS_ID='12345';
        dsares.ITEM_NUM='KC0031';
        dsares.BASE_CODE='GRNBRCOM2330';
        dsares.PRODUCT_LINE='716';
        dsares.PRODUCT_LINE_DESC='XPS M2010';
		
        
        item.ITEM_LIST = new List<CC_PIMBaseProdHierarchy.ITEM_LIST>{ dsares };
        
        //CC_PIMBaseProdHierarchy.ITEM_LIST[0] = dsares;
        String strjsonRespo = Json.serialize(item); 
        CC_DSAProductMock fakeResponse = new CC_DSAProductMock(200,
                                                               'Complete',
                                                               strjsonRespo,
                                                               null);
        
        
        
        
        Test.setMock(HttpCalloutMock.class, fakeResponse); 
       
        dsareq.BaseSKUNumber='ABC002';      
        CC_DSAProductProcessWebservice.addOppLineItem(dsareq);
        
        test.stopTest();
        system.assert([select count() from Product2]>0);
        
    }
    // Passing Null value in ProductDescription & dealId to create the exception.
    
    Public static testMethod void testNegativeWebService(){
      
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC009';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='Ordercode';
        dsareq.ProductDescription='';
        dsareq.SfdclineItemId='yur';
        dsareq.dealId='';
        Test.startTest();
        CC_DSAProductProcessWebservice.addOppLineItem(dsareq);
        Test.stopTest();
        system.assertEquals(1, [select count() from Exception__c]);
        
    }
    
    // Test method to check for addOppLineItem for Snp.
    Public static testMethod void testNewWebServiceSnp(){
       
         Product2 product = new Product2(
            Product_ID__c = '33',
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
        
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common Catalog';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
      
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);
        List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem LIMIT 1];
        system.debug('listoptt'+listoptt);
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
        
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180),
			Primary_Competitor_Product_Type__c = 'Object'
        );
        
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where id=:opt.Id limit 1];
         
       
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='ABC002';
        dsareq.ProductType='Snp';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId='yur';
        dsareq.dealId=op.Deal_ID__c;
        CC_PIMProdHierarchy item = new CC_PIMProdHierarchy();
        List<CC_PIMProdHierarchy.ITEM_LIST> listitem = new List<CC_PIMProdHierarchy.ITEM_LIST>{};
        Test.startTest();    
        CC_PIMProdHierarchy.ITEM_LIST dsares = new CC_PIMProdHierarchy.ITEM_LIST();
        dsares.TYPE_CODE='abcd';
		dsares.TYPE_DESC='ddd';
		dsares.GROUP_CODE='eee';
		dsares.GROUP_DESC='bbd';
		dsares.LOB_CODE='wreq';
		dsares.LOB_DESC='mmg';		
		dsares.CATEGORY='ggd';
		dsares.CATEGORY_DESC='ccq';
		dsares.PRODUCT_TYPE='trq';
		dsares.PRODUCT_TYPE_DESC='qwer';
		dsares.PORTFOLIO='qwer';
		dsares.PORTFOLIO_DESC='wertyu';
        dsares.OFFERING_GROUP='12345';
        dsares.OFFERING_GROUP_DESC='12we3';
        dsares.PRODUCT_OFFERING_CODE='KC0031';
        dsares.PRODUCT_OFFERING_CODE_DESC='werty';
        dsares.ERROR_INFO='';
		
        
        item.ITEM_LIST = new List<CC_PIMProdHierarchy.ITEM_LIST>{ dsares };
        
        //CC_PIMBaseProdHierarchy.ITEM_LIST[0] = dsares;
        String strjsonRespo = Json.serialize(item); 
        CC_DSAProductMock fakeResponse = new CC_DSAProductMock(200,
                                                               'Complete',
                                                               strjsonRespo,
                                                               null);
        
        
        
        
        Test.setMock(HttpCalloutMock.class, fakeResponse); 
        CC_DSAProductProcessWebservice.addOppLineItem(dsareq);
		dsares.PRODUCT_OFFERING_CODE='KC00322';
		CC_DSAProductProcessWebservice.addOppLineItem(dsareq);
        test.stopTest();
		List<OpportunityLineItem> listpinew = [select id from OpportunityLineItem where opportunityid=:op.id];
		System.assert(listpinew.size()>0);
    }
    /*Public static testMethod void testNewWebServiceSnpEls(){
        
         Product2 product = new Product2(
            Product_ID__c = '333',
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
        
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common Catalog';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
      
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);
        List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem LIMIT 1];
        system.debug('listoptt'+listoptt);
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
        
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180)
        );
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where id=:opt.Id limit 1];
         
       
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='ABC002';
        dsareq.ProductType='SnP';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId='yur';
        dsareq.dealId=op.Deal_ID__c;
        CC_PIMProdHierarchy item = new CC_PIMProdHierarchy();
        List<CC_PIMProdHierarchy.ITEM_LIST> listitem = new List<CC_PIMProdHierarchy.ITEM_LIST>{};
        Test.startTest();    
        CC_PIMProdHierarchy.ITEM_LIST dsares = new CC_PIMProdHierarchy.ITEM_LIST();
        dsares.TYPE_CODE='abcd';
		dsares.TYPE_DESC='ddd';
		dsares.GROUP_CODE='eee';
		dsares.GROUP_DESC='bbd';
		dsares.LOB_CODE='wreq';
		dsares.LOB_DESC='mmg';		
		dsares.CATEGORY='ggd';
		dsares.CATEGORY_DESC='ccq';
		dsares.PRODUCT_TYPE='trq';
		dsares.PRODUCT_TYPE_DESC='qwer';
		dsares.PORTFOLIO='qwer';
		dsares.PORTFOLIO_DESC='wertyu';
        dsares.OFFERING_GROUP='12345';
        dsares.OFFERING_GROUP_DESC='12we3';
        dsares.PRODUCT_OFFERING_CODE='KCC23';
        dsares.PRODUCT_OFFERING_CODE_DESC='werty';
        dsares.ERROR_INFO='';
		
        
        item.ITEM_LIST = new List<CC_PIMProdHierarchy.ITEM_LIST>{ dsares };
        
        //CC_PIMBaseProdHierarchy.ITEM_LIST[0] = dsares;
        String strjsonRespo = Json.serialize(item); 
        CC_DSAProductMock fakeResponse = new CC_DSAProductMock(200,
                                                               'Complete',
                                                               strjsonRespo,
                                                               null);
        
        
        
        
        Test.setMock(HttpCalloutMock.class, fakeResponse); 
        CC_DSAProductProcessWebservice.addOppLineItem(dsareq);
        test.stopTest();
		List<OpportunityLineItem> listpinew = [select id from OpportunityLineItem where opportunityid=:op.id];
		System.assert(listpinew.size()>0);
    }*/
    
    //This test method will insert one OppotunitylineItem , using DSA request.
     Public static testMethod void testNewWebService12(){
       Product2 product = new Product2(
            Product_ID__c = '333',
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
        
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common Catalog';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
      
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);
        //List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem LIMIT 1];
        //system.debug('listoptt'+listoptt);
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
        
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180),
			Primary_Competitor_Product_Type__c = 'Object'
        );
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where id=:opt.Id limit 1];
        
        Test.startTest();
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='Ordercode';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId='yur';
        dsareq.dealId=op.Deal_ID__c;
         
        CC_DSAProductProcessWebservice.addOppLineItem(dsareq);
        test.stopTest();
        system.assertEquals(1,[select count() from OpportunityLineItem where opportunityid=:op.id]);
         
    }
    
   // This test method will check the negative condition in replace() method by passing Null.
    Public static testMethod void testNewWebServiceReplaceNegative(){
    CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='Snp';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId='';
        dsareq.dealId='AW123';
        test.startTest();
        CC_DSAProductProcessWebservice.replace(dsareq); 
        test.stopTest();
        system.assertEquals(1,[select count() from Exception__c]);
 }
  
    // This test method will check the negative condition in replace() method for Else Part.
Public static testMethod void testNewWebService5ReplaceNegative(){
      
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='Snp';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId='ZZZ';
        dsareq.dealId='AW123';
        test.startTest();
        CC_DSAProductProcessWebservice.replace(dsareq); 
        test.stopTest();
      system.assertEquals(0,[select count() from OpportunityLineItem]);
    }
    //Validate 
    //This test method will response for Success in Validate method.
    //This test method will response for Success in Validate method.
    Public static testMethod void testPositiveWebServiceValidateSnP(){
       
            Product2 product = new Product2(
            Product_ID__c = '33',
            PIM_Product__c = True ,
            IsActive=true,
            Name ='LATITUDE 33001',
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
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common Catalog';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'Common Catalog';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='MXN';
        insert pb2;
        
        
        
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);	
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
		TriggerExecutionController.setSkipOpportunityTriggers(true);
		Test.startTest();
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180),
			Primary_Competitor_Product_Type__c = 'Object'
        );
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where Id=:opt.id];
        System.debug('op:'+op);
        
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = op.Id,
            Quantity = 5,
            PricebookEntryId = listpbe[0].Id,
            TotalPrice = 20
        );
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        insert oli;
        
        
        List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem where id=:oli.id Limit 1];
        system.debug('listoptt'+listoptt);
        
       // Test.startTest();
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='validate';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='Ordercode';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId=listoptt[0].Product_Line_ID__c;
        dsareq.dealId=op.Deal_Id__c;
       
        CC_DSAProductProcessWebservice.validate(dsareq); 
       Test.stopTest();
	   TriggerExecutionController.setSkipOpportunityTriggers(false);
        system.assertEquals(1,[select count() from Product2_PIM_Mapping__c]);
        
    } 
    
    //This test method , will check for the Else condition , When productType - Snp
     Public static testMethod void testPositiveWebServiceSnPElse(){
        
        Product2 product = new Product2(
            Product_ID__c = '33',
            PIM_Product__c = True ,
            IsActive=true,
            Name ='LATITUDE 33001',
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
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common Catalog';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'Common Catalog';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='MXN';
        insert pb2;
        
        
        
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);	
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
       
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180),
			Primary_Competitor_Product_Type__c = 'Object'
        );
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where Id=:opt.id];
        
        
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = op.Id,
            Quantity = 5,
            PricebookEntryId = listpbe[0].Id,
            TotalPrice = 20
        );
        
        insert oli;
        
        
        List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem where id=:oli.id Limit 1];
        system.debug('listoptt'+listoptt);
        
        Test.startTest();
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='SnP';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId=listoptt[0].Product_Line_ID__c;
        dsareq.dealId='AW123';
        
         CC_PIMProdHierarchy item = new CC_PIMProdHierarchy(); 
        CC_PIMProdHierarchy.ITEM_LIST dsares = new CC_PIMProdHierarchy.ITEM_LIST();
        dsares.TYPE_CODE='abcd';
		dsares.TYPE_DESC='ddd';
		dsares.GROUP_CODE='eee';
		dsares.GROUP_DESC='bbd';
		dsares.LOB_CODE='wreq';
		dsares.LOB_DESC='mmg';		
		dsares.CATEGORY='ggd';
		dsares.CATEGORY_DESC='ccq';
		dsares.PRODUCT_TYPE='trq';
		dsares.PRODUCT_TYPE_DESC='qwer';
		dsares.PORTFOLIO='qwer';
		dsares.PORTFOLIO_DESC='wertyu';
        dsares.OFFERING_GROUP='12345';
        dsares.OFFERING_GROUP_DESC='12we3';
        dsares.PRODUCT_OFFERING_CODE='KC0031';
        dsares.PRODUCT_OFFERING_CODE_DESC='werty';
        dsares.ERROR_INFO='';
        item.ITEM_LIST = new List<CC_PIMProdHierarchy.ITEM_LIST>{ dsares };
        
        //CC_PIMBaseProdHierarchy.ITEM_LIST[0] = dsares;
        String strjsonRespo = Json.serialize(item); 
         CC_DSAProductMock fakeResponse = new CC_DSAProductMock(200,
                                                               'Complete',
                                                               strjsonRespo,
                                                               null);
        
        
        
        
        Test.setMock(HttpCalloutMock.class, fakeResponse); 
       
        CC_DSAProductProcessWebservice.validate(dsareq); 
       Test.stopTest();
         system.assertEquals(1,[select count() from Product2]);
        
    } 
    
    Public static testMethod void testNegativeWebServiceSnP(){
        
        
        Product2 product = new Product2(
            Product_ID__c = '33',
            PIM_Product__c = True ,
            IsActive=true,
            Name ='LATITUDE 33001',
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
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common Catalog';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'Common Catalog';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='MXN';
        insert pb2;
        
        
        
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);	
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
       
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180),
			Primary_Competitor_Product_Type__c = 'Object'
        );
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where Id=:opt.id];
        
        
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = op.Id,
            Quantity = 5,
            PricebookEntryId = listpbe[0].Id,
            TotalPrice = 20
        );
        
        insert oli;
        
        
        List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem where id=:oli.id Limit 1];
        system.debug('listoptt'+listoptt);
        
        Test.startTest();
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='KC003123';
        dsareq.ProductType='Ordercode';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId=listoptt[0].Product_Line_ID__c;
        dsareq.dealId='AW123';
       
        CC_DSAProductProcessWebservice.validate(dsareq); 
       Test.stopTest();
         system.assertEquals(1,[select count() from Product2_PIM_Mapping__c]);
    }
    
    Public static testmethod void negativeValidate(){
        Test.startTest();
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId='';
        dsareq.dealId='';
        CC_DSAProductProcessWebservice.validate(dsareq); 
        Test.stopTest();
         system.assertEquals(0,[select count() from Product2_PIM_Mapping__c]);
    }
	 //This test method will insert one OppotunitylineItem , using DSA request.
     Public static testMethod void testvalidatecatalog(){
       Product2 product = new Product2(
            Product_ID__c = '333',
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
        
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
      
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);
        //List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem LIMIT 1];
        //system.debug('listoptt'+listoptt);
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
        
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            //pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180),
			Primary_Competitor_Product_Type__c = 'Object'
        );
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where id=:opt.Id limit 1];
        
        Test.startTest();
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='Addlineitem';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='Ordercode';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId='yur';
        dsareq.dealId=op.Deal_ID__c;
        CC_DSAProductProcessWebservice.addOppLineItem(dsareq);
        test.stopTest();
        system.assertEquals(0,[select count() from OpportunityLineItem where opportunityid=:op.id]);
        op.pricebook2Id=listpbe[0].pricebook2Id;
		update op;
		CC_DSAProductProcessWebservice.addOppLineItem(dsareq);
    }
    //This test method will insert one OppotunitylineItem , using DSA request.
     Public static testMethod void testreplacecatalog(){
       Product2 product = new Product2(
            Product_ID__c = '333',
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
        
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common Catalog';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
      
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);
        //List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem LIMIT 1];
        //system.debug('listoptt'+listoptt);
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
        
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180),
			Primary_Competitor_Product_Type__c = 'Object'
        );
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where id=:opt.Id limit 1];
        
        Test.startTest();
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='replace';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='Ordercode';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId='yur';
        dsareq.dealId=op.Deal_ID__c;
        CC_DSAProductProcessWebservice.replace(dsareq);
        test.stopTest();
        system.assertEquals(1,[select count() from OpportunityLineItem where opportunityid=:op.id]);
        
    }
    Public static testMethod void testPositiveWebServiceValidateSnPnew(){
       
            Product2 product = new Product2(
            Product_ID__c = '33',
            PIM_Product__c = True ,
            IsActive=true,
            Name ='LATITUDE 33001',
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
        Id standardPBId= Test.getStandardPricebookId();
        PriceBook2 pb1=new PriceBook2();
        pb1.Name = 'Common Catalog';
        pb1.IsActive = true;
        pb1.CurrencyIsoCode='MXN';          
        insert pb1;
        
        PriceBook2 pb2=new PriceBook2();
        pb2.Name = 'Common Catalog';
        pb2.IsActive = true;
        pb2.CurrencyIsoCode='MXN';
        insert pb2;
        
        
        
        PricebookEntry pbe = createPricebookEntry(standardPBId,pb1,product, 120.0);
        
        List<PricebookEntry> listpbe = [ Select Product2Id,Product2.Name,Pricebook2Id,CurrencyIsoCode From PricebookEntry Where Product2Id = :pbe.Product2Id AND PriceBook2Id = :pbe.pricebook2Id  AND CurrencyIsoCode = :pbe.CurrencyIsoCode AND PriceBook2.isActive=true AND ISActive = true limit 1];
        system.debug('inside pb'+listpbe);	
        //Creating one account 
        Account acc=new Account();
        acc.Name='bbc';
        insert acc;
		TriggerExecutionController.setSkipOpportunityTriggers(true);
		Test.startTest();
        //Creating one Opportunity 
        Opportunity opt=new Opportunity(
            Name='AHB',
            pricebook2Id=listpbe[0].pricebook2Id,
            RecordTypeId= '012A0000000Vjtg',
            Override_Probability__c='99',
            CurrencyIsoCode='MXN',
            Domain__c='Business Solutions',
            StageName='Qualify - 30%',
            //Dell_Asset_RMA__Opportunity_Type__c='Deal/Bid - Direct',
            AccountId=acc.Id,
            //CreatedDate=system.now(),
            Request_Status__c='New', 
            Primary_Competitor__c='Unknown',
            Forecast_Category_Override__c ='Pipeline',
            Competitor_Lost_To__c='Unknown',
            CloseDate= System.Now().Date().addDays(180),
			Primary_Competitor_Product_Type__c = 'Object'
        );
        insert opt;
        Opportunity op =[select Deal_Id__c from Opportunity where Id=:opt.id];
        System.debug('op:'+op);
        
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = op.Id,
            Quantity = 5,
            PricebookEntryId = listpbe[0].Id,
            TotalPrice = 20
        );
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        insert oli;
        
        
        List<OpportunityLineItem> listoptt=[select id, Product_Line_ID__c from OpportunityLineItem where id=:oli.id Limit 1];
        system.debug('listoptt'+listoptt);
        
       // Test.startTest();
        CC_DSAProductProcessWebservice.DSARequest dsareq=new CC_DSAProductProcessWebservice.DSARequest();
        dsareq.Operation='validate';
        dsareq.Quantity=1.1;
        dsareq.Listprice=12.0;
        dsareq.Margin=1.2;
        dsareq.Discount_off=5;
        dsareq.Quotenumber='CCD';
        dsareq.Ordercode_SKU='bbc';
        dsareq.BaseSKUNumber='ABC';
        dsareq.BaseSKUClass='KC0031';
        dsareq.ProductType='SnP';
        dsareq.ProductDescription='TTR';
        dsareq.SfdclineItemId=listoptt[0].Product_Line_ID__c;
        dsareq.dealId=op.Deal_Id__c;
       
        CC_DSAProductProcessWebservice.validate(dsareq); 
       Test.stopTest();
	   TriggerExecutionController.setSkipOpportunityTriggers(false);
        system.assertEquals(1,[select count() from Product2_PIM_Mapping__c]);
        
    } 
}