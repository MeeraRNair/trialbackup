/* 
REVISION HISTORY
================
Version    Author    Date            Release#    CR#     Description
-------    ------    ----            --------    ---     -----------
1.0        Rap   21-Feb-2013           14.2      ---     Test class for SnP_MSAdditionalInfoController
1.1        Rap   29-Mar-2013           14.3      ---     Added test for 14.3 CR's
*/
/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
private class SnP_MSAdditionalInfoControllerTest {
    @testSetup static void setup() {
        // Create common test OWD settings
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
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        listOppTdf[0].Name = 'test';
        listOppTdf[0].CloseDate = System.today();
        //listOppTdf[0].StageName = 'Plan - 1%';
        listOppTdf[0].CurrencyIsoCode = 'USD';
        insert listOppTdf;
        List<S_P_Vendor_Product_Threshold__c> listthresh1 = new List<S_P_Vendor_Product_Threshold__c>();
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(Agreement_Level__c = 'A1', Level__c = 'EA', /*Minimum_Revenue__c = 10000,*/ 
                                                            Percentage__c = 10, /*Product_Description__c = '', Product_Family__c = '',*/ Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'Enterprise Desktop w MDOP', Product_Family__c = 'Windows', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'Lync', Product_Family__c = 'Lync', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'SQL Server EAP', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'SQL Azure Web', Product_Family__c = 'Product Not Eligible for SIP', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'CIS Ste DataCntr', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'CIS Ste Ent', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'Lync Mac', Product_Family__c = 'Lync', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'Visual Studio UltPrem EAP', Product_Family__c = 'Product Not Eligible for SIP', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'CIS Ste Ent - Security', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'SQL Svr Enterprise Core', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'SQL Server Datacenter', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));
        listthresh1.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',*/ Level__c = 'Product', Minimum_Revenue__c = 10000, 
                                                            Percentage__c = 10, Product_Description__c = 'CIS Ste Std - Syst Ctr', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));
        Database.insert(listthresh1);
    }
    static testMethod void testEaDetail() {
        //Account acc = new Account(Name = 'Test Account');
        //Database.insert(acc);
        TriggerExecutionController.setSkipAllTriggers(true);
        List<S_P_Vendor_Product_Threshold__c> listthresh = [select id from S_P_Vendor_Product_Threshold__c limit 13];
        
        /*  thresh.add(new S_P_Vendor_Product_Threshold__c(Agreement_Level__c = 'A1', Level__c = 'EA', /*Minimum_Revenue__c = 10000,
Percentage__c = 10, /*Product_Description__c = '', Product_Family__c = '', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Enterprise Desktop w MDOP', Product_Family__c = 'Windows', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Lync', Product_Family__c = 'Lync', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Server EAP', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Azure Web', Product_Family__c = 'Product Not Eligible for SIP', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste DataCntr', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste Ent', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Lync Mac', Product_Family__c = 'Lync', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Visual Studio UltPrem EAP', Product_Family__c = 'Product Not Eligible for SIP', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste Ent - Security', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Svr Enterprise Core', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Server Datacenter', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste Std - Syst Ctr', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

Database.insert(thresh);
*/
        
        /************************************************************************
*                 This part tests if EAP = Yes                         *
************************************************************************/
        /*Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%', 
CurrencyIsoCode = 'USD');
Database.insert(opp);
*/
        list<Opportunity> listOpp=[select id,CurrencyIsoCode from Opportunity Limit 1];
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id, How_did_you_uncover_this_opportunity__c = 'sample',
                                                   Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
                                                   One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
                                                   Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
                                                   Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
                                                   Software_Licensing_Specialist__c = 'sample',    Is_this_an_Enterprise_Agreement__c = 'Yes');
        Database.insert(mainSV);
        // S_P_Vendors__c mainSV=[select id,Opportunity.CurrencyIsoCode,Opportunity__c,Ship_to_Address__c,Is_this_an_Enterprise_Agreement__c,Software_Licensing_Specialist__c,Role__c,Contact_Name__c,Customer_Name__c,Software_Account_Executive__c,One_sentence_desc_of_Oppty_strategy__c,Has_a_customer_contact_been_identified__c,Sales_Activities_to_Date__c,How_did_you_uncover_this_opportunity__c,Country__c from S_P_Vendors__c limit 1];
        ApexPages.StandardController ms = new ApexPages.StandardController(mainSV);
        SnP_MSAdditionalInfoController sc = new SnP_MSAdditionalInfoController(ms);
        Integer intmoreProd = 2;
        //Add EA Types
        PageReference addEaTypes = Page.SnPMSAdditionalInfo;
        Test.setCurrentPageReference(addEaTypes);
        List<S_P_Vendor_Additional_Information__c> listaddlInfoQueryMain = sc.getAddlInfoQuery();
        listaddlInfoQueryMain[0].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[0].EA_Type__c = 'EA';
        listaddlInfoQueryMain[0].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[0].Total__c = 100000;
        listaddlInfoQueryMain[1].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[1].EA_Type__c = 'EAP';
        listaddlInfoQueryMain[1].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[1].Total__c = 100000;
        listaddlInfoQueryMain[2].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[2].EA_Type__c = 'ECI';
        listaddlInfoQueryMain[2].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[2].Total__c = 100000;
        listaddlInfoQueryMain[3].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[3].EA_Type__c = 'SCE';
        listaddlInfoQueryMain[3].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[3].Total__c = 100000;
        listaddlInfoQueryMain.add(new S_P_Vendor_Additional_Information__c());
        listaddlInfoQueryMain[4].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[4].EA_Type__c = 'EAS';
        listaddlInfoQueryMain[4].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[4].Total__c = 100000;
        sc.wizardStart();
        
        Integer intDeleteCheck = sc.getDeleteCheck();
        //Add EA Products
        sc.previousPage();
        sc.wizardStart();
        List<S_P_Vendor_Product_Selection__c> listeaProducts = sc.getEaProducts();
        List<S_P_Vendor_Product_Selection__c> listeaAddlProducts = sc.getEaAddlProducts();
        List<S_P_Vendor_Product_Selection__c> listeaAddlProductsToDisplay = sc.getEaAddlProductsToDisplay();
        sc.nextPage();
        listeaProducts[0].EA_Enterprise_Product__c = 'Enterprise Desktop w MDOP';
        listeaProducts[0].Quantity__c = 3;
        listeaProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsText();
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.nextPage();
        listeaAddlProducts[0].Additional_Product_Type__c = 'Lync';
        listeaAddlProducts[0].New_Products_Only__c = 'Lync';
        listeaAddlProducts[0].Quantity__c = 3;
        listeaAddlProducts[0].Unit_Price__c = 10000;
        listeaAddlProducts[1].Additional_Product_Type__c = 'Lync';
        listeaAddlProducts[1].New_Products_Only__c = 'Lync';
        listeaAddlProducts[1].Quantity__c = 3;
        listeaAddlProducts[1].Unit_Price__c = 10000;
        listeaAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listeaAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listeaAddlProductsToDisplay[0].Additional_Product_Type__c = 'Lync';
        listeaAddlProductsToDisplay[0].New_Products_Only__c = 'Lync';
        listeaAddlProductsToDisplay[0].Quantity__c = 3;
        listeaAddlProductsToDisplay[0].Unit_Price__c = 10000;
        listeaAddlProductsToDisplay[1].Additional_Product_Type__c = 'Lync';
        listeaAddlProductsToDisplay[1].New_Products_Only__c = 'Lync';
        listeaAddlProductsToDisplay[1].Quantity__c = 3;
        listeaAddlProductsToDisplay[1].Unit_Price__c = 10000;
        sc.nextPage();
        listeaAddlProducts[1].New_Products_Only__c = 'Lync Mac';
        listeaAddlProducts[1].Remove__c = TRUE;
        sc.checkDeleteAddlProducts();
        sc.deleteAddlProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        
        //Add EAP Products
        List<S_P_Vendor_Product_Selection__c> listEapProducts = sc.getEapProducts();
        List<S_P_Vendor_Product_Selection__c> listEapAddlProducts = sc.getEapAddlProducts();
        List<S_P_Vendor_Product_Selection__c> listEapAddlProductsToDisplay = sc.getEapAddlProductsToDisplay();
        sc.nextPage();
        listEapProducts[0].EA_Enterprise_Product__c = 'SQL Server EAP';
        sc.openAddProductsText();
        listEapProducts[0].Quantity__c = 3;
        listEapProducts[0].Unit_Price__c = 10000;
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.nextPage();
        listEapAddlProducts[0].Additional_Product_Type__c = 'SQL';
        listEapAddlProducts[0].New_Products_Only__c = 'SQL Azure Web';
        listEapAddlProducts[0].Quantity__c = 3;
        listEapAddlProducts[0].Unit_Price__c = 10000;
        listEapAddlProducts[1].Additional_Product_Type__c = 'SQL';
        listEapAddlProducts[1].New_Products_Only__c = 'SQL Azure Web';
        listEapAddlProducts[1].Quantity__c = 3;
        listEapAddlProducts[1].Unit_Price__c = 10000;
        listEapAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listEapAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listEapAddlProductsToDisplay[0].Additional_Product_Type__c = 'SQL';
        listEapAddlProductsToDisplay[0].New_Products_Only__c = 'SQL Azure Web';
        listEapAddlProductsToDisplay[0].Quantity__c = 3;
        listEapAddlProductsToDisplay[0].Unit_Price__c = 10000;
        listEapAddlProductsToDisplay[1].Additional_Product_Type__c = 'SQL';
        listEapAddlProductsToDisplay[1].New_Products_Only__c = 'SQL Azure Web';
        listEapAddlProductsToDisplay[1].Quantity__c = 3;
        listEapAddlProductsToDisplay[1].Unit_Price__c = 10000;
        sc.nextPage();
        listEapAddlProducts[1].Additional_Product_Type__c = 'SQL';
        listEapAddlProducts[1].New_Products_Only__c = 'SQL Server Datacenter';
        listEapAddlProducts[1].Remove__c = TRUE;
        sc.checkDeleteAddlProducts();
        sc.deleteAddlProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        
        //Add ECI Products
        List<S_P_Vendor_Product_Selection__c> listEciProducts = sc.getEciProducts();
        List<S_P_Vendor_Product_Selection__c> listEciAddlProducts = sc.getEciAddlProducts();
        List<S_P_Vendor_Product_Selection__c> listEciAddlProductsToDisplay = sc.getEciAddlProductsToDisplay();
        sc.nextPage();
        listEciProducts[0].EA_Enterprise_Product__c = 'CIS Ste DataCntr';
        listEciProducts[0].Quantity__c = 3;
        listEciProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsText();
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.nextPage();
        listEciAddlProducts[0].Additional_Product_Type__c = 'CIS';
        listEciAddlProducts[0].New_Products_Only__c = 'CIS Ste Ent';
        listEciAddlProducts[0].Quantity__c = 3;
        listEciAddlProducts[0].Unit_Price__c = 10000;
        listEciAddlProducts[1].Additional_Product_Type__c = 'CIS';
        listEciAddlProducts[1].New_Products_Only__c = 'CIS Ste Ent';
        listEciAddlProducts[1].Quantity__c = 3;
        listEciAddlProducts[1].Unit_Price__c = 10000;
        listEciAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listEciAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listEciAddlProductsToDisplay[0].Additional_Product_Type__c = 'CIS';
        listEciAddlProductsToDisplay[0].New_Products_Only__c = 'CIS Ste Ent';
        listEciAddlProductsToDisplay[0].Quantity__c = 3;
        listEciAddlProductsToDisplay[0].Unit_Price__c = 10000;
        listEciAddlProductsToDisplay[1].Additional_Product_Type__c = 'CIS';
        listEciAddlProductsToDisplay[1].New_Products_Only__c = 'CIS Ste Ent';
        listEciAddlProductsToDisplay[1].Quantity__c = 3;
        listEciAddlProductsToDisplay[1].Unit_Price__c = 10000;
        sc.nextPage();
        listEciAddlProducts[1].New_Products_Only__c = 'CIS Ste Ent - Security';
        listEciAddlProducts[1].Remove__c = TRUE;
        sc.checkDeleteAddlProducts();
        sc.deleteAddlProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        
        //Add SCE Products
        List<S_P_Vendor_Product_Selection__c> listsceProducts = sc.getSceProducts();
        List<S_P_Vendor_Product_Selection__c> listsceAddlProducts = sc.getSceAddlProducts();
        List<S_P_Vendor_Product_Selection__c> listsceAddlProductsToDisplay = sc.getSceAddlProductsToDisplay();
        sc.nextPage();
        listsceProducts[0].EA_Enterprise_Product__c = 'SQL Server EAP';
        sc.openAddProductsText();
        listsceProducts[0].Quantity__c = 3;
        listsceProducts[0].Unit_Price__c = 10000;
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.nextPage();
        listsceAddlProducts[0].Additional_Product_Type__c = 'SQL';
        listsceAddlProducts[0].New_Products_Only__c = 'SQL Azure Web';
        listsceAddlProducts[0].Quantity__c = 3;
        listsceAddlProducts[0].Unit_Price__c = 10000;
        listsceAddlProducts[1].Additional_Product_Type__c = 'SQL';
        listsceAddlProducts[1].New_Products_Only__c = 'SQL Azure Web';
        listsceAddlProducts[1].Quantity__c = 3;
        listsceAddlProducts[1].Unit_Price__c = 10000;
        listsceAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listsceAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listsceAddlProductsToDisplay[0].Additional_Product_Type__c = 'SQL';
        listsceAddlProductsToDisplay[0].New_Products_Only__c = 'SQL Azure Web';
        listsceAddlProductsToDisplay[0].Quantity__c = 3;
        listsceAddlProductsToDisplay[0].Unit_Price__c = 10000;
        listsceAddlProductsToDisplay[1].Additional_Product_Type__c = 'SQL';
        listsceAddlProductsToDisplay[1].New_Products_Only__c = 'SQL Azure Web';
        listsceAddlProductsToDisplay[1].Quantity__c = 3;
        listsceAddlProductsToDisplay[1].Unit_Price__c = 10000;
        sc.nextPage();
        listsceAddlProducts[1].Additional_Product_Type__c = 'SQL';
        listsceAddlProducts[1].New_Products_Only__c = 'SQL Server Datacenter';
        listsceAddlProducts[1].Remove__c = TRUE;
        sc.checkDeleteAddlProducts();
        sc.deleteAddlProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        
        //Add EAS Products
        sc.previousPage();
        sc.wizardStart();
        List<S_P_Vendor_Product_Selection__c> listeasProducts = sc.getEasProducts();
        List<S_P_Vendor_Product_Selection__c> listeasAddlProducts = sc.getEasAddlProducts();
        List<S_P_Vendor_Product_Selection__c> listeasAddlProductsToDisplay = sc.getEasAddlProductsToDisplay();
        sc.nextPage();
        listeasProducts[0].EA_Enterprise_Product__c = 'Enterprise Desktop w MDOP';
        listeasProducts[0].Quantity__c = 3;
        listeasProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsText();
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.nextPage();
        listeasAddlProducts[0].Additional_Product_Type__c = 'Lync';
        listeasAddlProducts[0].New_Products_Only__c = 'Lync';
        listeasAddlProducts[0].Quantity__c = 3;
        listeasAddlProducts[0].Unit_Price__c = 10000;
        listeasAddlProducts[1].Additional_Product_Type__c = 'Lync';
        listeasAddlProducts[1].New_Products_Only__c = 'Lync';
        listeasAddlProducts[1].Quantity__c = 3;
        listeasAddlProducts[1].Unit_Price__c = 10000;
        listeasAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listeasAddlProductsToDisplay.add(new S_P_Vendor_Product_Selection__c());
        listeasAddlProductsToDisplay[0].Additional_Product_Type__c = 'Lync';
        listeasAddlProductsToDisplay[0].New_Products_Only__c = 'Lync';
        listeasAddlProductsToDisplay[0].Quantity__c = 3;
        listeasAddlProductsToDisplay[0].Unit_Price__c = 10000;
        listeasAddlProductsToDisplay[1].Additional_Product_Type__c = 'Lync';
        listeasAddlProductsToDisplay[1].New_Products_Only__c = 'Lync';
        listeasAddlProductsToDisplay[1].Quantity__c = 3;
        listeasAddlProductsToDisplay[1].Unit_Price__c = 10000;
        sc.nextPage();
        listeasAddlProducts[1].New_Products_Only__c = 'Lync Mac';
        listeasAddlProducts[1].Remove__c = TRUE;
        sc.checkDeleteAddlProducts();
        sc.deleteAddlProducts();
        sc.currentPage();
        //sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        //Insert all
        sc.finishWizard();
        sc.getEaAddlProductsToDisplay();
        sc.getEapAddlProductsToDisplay();
        sc.getEciAddlProductsToDisplay();
        sc.getAddlInfoProdEa();
        sc.getAddlInfoProdEap();
        sc.getAddlInfoProdEci();
        sc.getCheckEaProductsEmpty();
        sc.getCheckEaProductsEmptyEdit();
        sc.getCheckSipProductsEmpty();
        sc.getCheckSipProductsEmptyEdit();
        sc.getCurrentProfile();
        sc.getEaAddlProductsNotEmpty();
        sc.getEapAddlProductsNotEmpty();
        sc.getEaDisplaySV();
        sc.getEapProductsNotEmpty();
        sc.getEaProductsNotEmpty();
        sc.getEapThreshNotEmpty();
        sc.getEaThreshNotEmpty();
        sc.getEciAddlProductsNotEmpty();
        sc.getEciProductsNotEmpty();
        sc.getEciThreshNotEmpty();
        sc.getIsProdManagerEa();
        sc.getIsThisEa();
        sc.getIsThisEaNotBlank();
        sc.getIsThisNotEa();
        sc.getProdSelQuery();
        sc.getShowNoIncentiveMsg();
        sc.getShowNoIncentiveMsgSIP();
        sc.getSipDisplaySV();
        sc.getSipSumDisplay();
        sc.getSipThreshNotEmpty();
        sc.getSipThresholdSummary();
        sc.getTotalAll();
        sc.getTotalEa();
        sc.getTotalProd();
        sc.showEditSVPage();
        sc.saveEaSV();
        sc.saveSipSV();
        sc.closePopup();
        sc.showPopup();
        sc.getEasProductsNotEmpty();
        sc.getEasAddlProductsNotEmpty();
        sc.getEasThreshNotEmpty();
        sc.getSipAddlProductsToDisplay();
        sc.getAddlInfoProdEas();
        sc.getUserCurrency();
        sc.getConvertedTotalProd();
        sc.getConvertedTotalEa();
        sc.getconvertedTotalAll();
        sc.getCurrencyCheck();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testEaUpdateProducts(){
        // Account acc = new Account(Name = 'Test Account');
        //Database.insert(acc);
        TriggerExecutionController.setSkipAllTriggers(true);
        List<S_P_Vendor_Product_Threshold__c> listthresh = [select id from S_P_Vendor_Product_Threshold__c limit 4];
        
        /* List<S_P_Vendor_Product_Threshold__c> thresh = new List<S_P_Vendor_Product_Threshold__c>();

thresh.add(new S_P_Vendor_Product_Threshold__c(Agreement_Level__c = 'A1', Level__c = 'EA', /*Minimum_Revenue__c = 10000,
Percentage__c = 10, /*Product_Description__c = '', Product_Family__c = '', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Enterprise Desktop w MDOP', Product_Family__c = 'Windows', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Lync', Product_Family__c = 'Lync', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Svr Enterprise Core', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

insert thresh;
*/
        /* Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%', 
CurrencyIsoCode = 'USD');
Database.insert(opp);
*/
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        listOpp[0].Name = 'test';
        listOpp[0].CloseDate = System.today();
        listOpp[0].StageName = 'Plan - 1%';
        listOpp[0].CurrencyIsoCode = 'USD';
        update listOpp;
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id, How_did_you_uncover_this_opportunity__c = 'sample',
                                                   Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
                                                   One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
                                                   Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
                                                   Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
                                                   Software_Licensing_Specialist__c = 'sample',    Is_this_an_Enterprise_Agreement__c = 'Yes');
        Database.insert(mainSV);
        S_P_Vendor_Additional_Information__c ea = new S_P_Vendor_Additional_Information__c(S_P_Vendors_Id__c = mainSV.Id, EA_Type__c = 'EA',
                                                                                           Agreement_Level__c = 'A1', Total__c = 100000, Opportunity_Name__c = 'test - NNEA', Deal_Reg_Status__c = 'Pending',
                                                                                           Products_Included__c = 'EA', Level__c = 'EA');
        S_P_Vendor_Additional_Information__c win = new S_P_Vendor_Additional_Information__c(S_P_Vendors_Id__c = mainSV.Id, EA_Type__c = 'EA',
                                                                                            Agreement_Level__c = 'A1', Total__c = 30000, Opportunity_Name__c = 'test - Windows', Deal_Reg_Status__c = 'Pending',
                                                                                            Products_Included__c = 'Windows ', Level__c = 'Product', SIP_Incentive__c = 'Windows', SIP_Threshold_Met__c = 'Yes');
        S_P_Vendor_Additional_Information__c lync = new S_P_Vendor_Additional_Information__c(S_P_Vendors_Id__c = mainSV.Id, EA_Type__c = 'EA',
                                                                                             Agreement_Level__c = 'A1', Total__c = 30000, Opportunity_Name__c = 'test - Lync', Deal_Reg_Status__c = 'Pending',
                                                                                             Products_Included__c = 'Lync', Level__c = 'Product', SIP_Incentive__c = 'Lync', SIP_Threshold_Met__c = 'Yes');
        insert ea;
        insert win;
        insert lync;
        S_P_Vendor_Product_Selection__c winProd = new S_P_Vendor_Product_Selection__c(S_P_Vendor_Additional_Information_ID__c = win.Id,
                                                                                      Type__c = 'EA', EA_Enterprise_Product__c = 'Enterprise Desktop w MDOP', Additional_Product_Type__c = 'Windows',
                                                                                      Quantity__c = 3, Unit_Price__c = 10000, Total__c = 30000, SIP_Incentive__c = 'Windows 7', SIP_Threshold_Met__c = 'Yes',
                                                                                      SIP_Fees__c = 3000);
        S_P_Vendor_Product_Selection__c lyncProd = new S_P_Vendor_Product_Selection__c(S_P_Vendor_Additional_Information_ID__c = lync.Id,
                                                                                       Type__c = 'EA', New_Products_Only__c = 'Lync Mac', Additional_Product_Type__c = 'Lync',
                                                                                       Quantity__c = 3, Unit_Price__c = 10000, Total__c = 30000, SIP_Incentive__c = 'Lync', SIP_Threshold_Met__c = 'Yes',
                                                                                       SIP_Fees__c = 3000);
        insert winProd;
        insert lyncProd;
        ApexPages.StandardController ms = new ApexPages.StandardController(mainSV);
        SnP_MSAdditionalInfoController sc = new SnP_MSAdditionalInfoController(ms);
        Integer intmoreProd = 1;
        sc.showNewSipPage();
        PageReference editEaType = Page.SnPMSAdditionalInfoNewEditEA;
        Test.setCurrentPageReference(editEaType);
        
        sc.wizardStart();
        sc.previousPage();
        sc.wizardStart();
        List<S_P_Vendor_Product_Selection__c> listeaProducts = sc.getEaProducts();
        List<S_P_Vendor_Product_Selection__c> listeaAddlProducts = sc.getEaAddlProducts();
        listeaProducts[0].EA_Enterprise_Product__c = 'Enterprise Desktop w MDOP';
        listeaProducts[0].Quantity__c = 3;
        listeaProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsText();
        listeaAddlProducts[0].Additional_Product_Type__c = 'Lync';
        listeaAddlProducts[0].New_Products_Only__c = 'Lync Mac';
        listeaAddlProducts[0].Quantity__c = 3;
        listeaAddlProducts[0].Unit_Price__c = 20000;
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        //sc.openMoreProducts();
        //eaAddlProducts[1].Additional_Product_Type__c = 'SQL';
        //eaAddlProducts[1].New_Products_Only__c = 'SQL Svr Enterprise Core';
        //eaAddlProducts[1].Quantity__c = 3;
        //eaAddlProducts[1].Unit_Price__c = 10000;
        sc.currentPage();
        //sc.nextPage();
        //Insert all
        sc.finishWizard();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void testEaUpdateProductsNew(){
        //Account acc = new Account(Name = 'Test Account');
        //Database.insert(acc);
        TriggerExecutionController.setSkipAllTriggers(true);
        List<S_P_Vendor_Product_Threshold__c> listthresh = [select id from S_P_Vendor_Product_Threshold__c limit 4];
        
        /*  List<S_P_Vendor_Product_Threshold__c> thresh = new List<S_P_Vendor_Product_Threshold__c>();

thresh.add(new S_P_Vendor_Product_Threshold__c(Agreement_Level__c = 'A1', Level__c = 'EA', /*Minimum_Revenue__c = 10000,
Percentage__c = 10, /*Product_Description__c = '', Product_Family__c = '', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Enterprise Desktop w MDOP', Product_Family__c = 'Windows', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Lync', Product_Family__c = 'Lync', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Svr Enterprise Core', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

insert thresh;
*/
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        /* Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%', 
CurrencyIsoCode = 'USD');
Database.insert(opp);
*/
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id, How_did_you_uncover_this_opportunity__c = 'sample',
                                                   Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
                                                   One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
                                                   Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
                                                   Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
                                                   Software_Licensing_Specialist__c = 'sample',    Is_this_an_Enterprise_Agreement__c = 'Yes');
        Database.insert(mainSV);
        S_P_Vendor_Additional_Information__c ea = new S_P_Vendor_Additional_Information__c(S_P_Vendors_Id__c = mainSV.Id, EA_Type__c = 'EA',
                                                                                           Agreement_Level__c = 'A1', Total__c = 100000, Opportunity_Name__c = 'test - NNEA', Deal_Reg_Status__c = 'Pending',
                                                                                           Products_Included__c = 'EA', Level__c = 'EA');
        S_P_Vendor_Additional_Information__c win = new S_P_Vendor_Additional_Information__c(S_P_Vendors_Id__c = mainSV.Id, EA_Type__c = 'EA',
                                                                                            Agreement_Level__c = 'A1', Total__c = 30000, Opportunity_Name__c = 'test - Windows', Deal_Reg_Status__c = 'Pending',
                                                                                            Products_Included__c = 'Windows ', Level__c = 'Product', SIP_Incentive__c = 'Windows', SIP_Threshold_Met__c = 'Yes');
        S_P_Vendor_Additional_Information__c lync = new S_P_Vendor_Additional_Information__c(S_P_Vendors_Id__c = mainSV.Id, EA_Type__c = 'EA',
                                                                                             Agreement_Level__c = 'A1', Total__c = 30000, Opportunity_Name__c = 'test - Lync', Deal_Reg_Status__c = 'Pending',
                                                                                             Products_Included__c = 'Lync', Level__c = 'Product', SIP_Incentive__c = 'Lync', SIP_Threshold_Met__c = 'Yes');
        insert ea;
        insert win;
        insert lync;
        S_P_Vendor_Product_Selection__c winProd = new S_P_Vendor_Product_Selection__c(S_P_Vendor_Additional_Information_ID__c = win.Id,
                                                                                      Type__c = 'EA', EA_Enterprise_Product__c = 'Enterprise Desktop w MDOP', Additional_Product_Type__c = 'Windows',
                                                                                      Quantity__c = 3, Unit_Price__c = 10000, Total__c = 30000, SIP_Incentive__c = 'Windows 7', SIP_Threshold_Met__c = 'Yes',
                                                                                      SIP_Fees__c = 3000);
        S_P_Vendor_Product_Selection__c lyncProd = new S_P_Vendor_Product_Selection__c(S_P_Vendor_Additional_Information_ID__c = lync.Id,
                                                                                       Type__c = 'EA', New_Products_Only__c = 'Lync Mac', Additional_Product_Type__c = 'Lync',
                                                                                       Quantity__c = 3, Unit_Price__c = 10000, Total__c = 30000, SIP_Incentive__c = 'Lync', SIP_Threshold_Met__c = 'Yes',
                                                                                       SIP_Fees__c = 3000);
        insert winProd;
        insert lyncProd;
        ApexPages.StandardController ms = new ApexPages.StandardController(mainSV);
        SnP_MSAdditionalInfoController sc = new SnP_MSAdditionalInfoController(ms);
        Integer intmoreProd = 1;
        sc.showNewSipPage();
        PageReference editEaType = Page.SnPMSAdditionalInfoNewEditEA;
        Test.setCurrentPageReference(editEaType);
        sc.wizardStart();
        //Add EA Products
        sc.previousPage();
        sc.wizardStart();
        List<S_P_Vendor_Product_Selection__c> listeaProducts = sc.getEaProducts();
        List<S_P_Vendor_Product_Selection__c> listeaAddlProducts = sc.getEaAddlProducts();
        listeaProducts[0].EA_Enterprise_Product__c = 'Enterprise Desktop w MDOP';
        listeaProducts[0].Quantity__c = 3;
        listeaProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsText();
        listeaAddlProducts[0].Additional_Product_Type__c = 'SQL';
        listeaAddlProducts[0].New_Products_Only__c = 'SQL Svr Enterprise Core';
        listeaAddlProducts[0].Quantity__c = 3;
        listeaAddlProducts[0].Unit_Price__c = 20000;
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        //sc.openMoreProducts();
        //eaAddlProducts[1].Additional_Product_Type__c = 'SQL';
        //eaAddlProducts[1].New_Products_Only__c = 'SQL Svr Enterprise Core';
        //eaAddlProducts[1].Quantity__c = 3;
        //eaAddlProducts[1].Unit_Price__c = 10000;
        sc.currentPage();
        //sc.nextPage();
        //Insert all
        sc.finishWizard();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void testProductDetail() {
        
        /************************************************************************
*                 This part tests if EAP = No                         *
************************************************************************/
        //Account acc = new Account(Name = 'Test Account');
        
        //Database.insert(acc);
        TriggerExecutionController.setSkipAllTriggers(true);
        List<S_P_Vendor_Product_Threshold__c> listthresh = [select id from S_P_Vendor_Product_Threshold__c limit 3];
        
        /*  List<S_P_Vendor_Product_Threshold__c> thresh = new List<S_P_Vendor_Product_Threshold__c>();

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Lync', Product_Family__c = 'Lync', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste Ent', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Svr Enterprise Core', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

Database.insert(thresh);
*/
        /*        Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%', 
CurrencyIsoCode = 'USD');
Database.insert(opp);
*/
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id, How_did_you_uncover_this_opportunity__c = 'sample',
                                                   Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
                                                   One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
                                                   Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
                                                   Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
                                                   Software_Licensing_Specialist__c = 'sample',    Is_this_an_Enterprise_Agreement__c = 'No', Licensing_Program__c = 'Open');
        Database.insert(mainSV);
        ApexPages.StandardController ms = new ApexPages.StandardController(mainSV);
        SnP_MSAdditionalInfoController sc = new SnP_MSAdditionalInfoController(ms);
        Integer intmoreProd = 2;
        //Add SIP Products
        PageReference addSip = Page.SnPMSAdditionalInfo;
        Test.setCurrentPageReference(addSip);
        List<S_P_Vendor_Product_Selection__c> listsipProducts = sc.getSipProducts();
        List<S_P_Vendor_Product_Selection__c> listsipAddlProducts = sc.getSipAddlProducts();
        listsipProducts[0].Additional_Product_Type__c = 'CIS';
        listsipProducts[0].New_Products_Only__c = 'CIS Ste Ent';
        listsipProducts[0].Quantity__c = 3;
        listsipProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsTextSip();
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProductSip();
        listsipAddlProducts[0].Additional_Product_Type__c = 'Lync';
        listsipAddlProducts[0].New_Products_Only__c = 'Lync';
        listsipAddlProducts[0].Quantity__c = 3;
        listsipAddlProducts[0].Unit_Price__c = 10000;
        listsipAddlProducts[1].Additional_Product_Type__c = 'SQL';
        listsipAddlProducts[1].New_Products_Only__c = 'SQL Svr Enterprise Core';
        listsipAddlProducts[1].Quantity__c = 3;
        listsipAddlProducts[1].Unit_Price__c = 10000;
        sc.showFinalSIP();
        sc.previousPageSIP();
        sc.showFinalSIP();
        sc.finishWizardSIP();
        
        PageReference addSipFin = Page.SnPMSAdditionalInfo;
        Test.setCurrentPageReference(addSipFin);
        //sc.assignEaProducts();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testMethod void testEaDetailOneProduct() {
        // Account acc = new Account(Name = 'Test Account');
        //Database.insert(acc);
        TriggerExecutionController.setSkipAllTriggers(true);
        List<S_P_Vendor_Product_Threshold__c> listthresh = [select id from S_P_Vendor_Product_Threshold__c limit 4];
        
        /* List<S_P_Vendor_Product_Threshold__c> thresh = new List<S_P_Vendor_Product_Threshold__c>();

thresh.add(new S_P_Vendor_Product_Threshold__c(Agreement_Level__c = 'A1', Level__c = 'EA', /*Minimum_Revenue__c = 10000,
Percentage__c = 10, /*Product_Description__c = '', Product_Family__c = '', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Enterprise Desktop w MDOP', Product_Family__c = 'Windows', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Server EAP', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste DataCntr', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

Database.insert(thresh);
*/
        /************************************************************************
*                 This part tests if EAP = Yes                         *
************************************************************************/
        /*Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%', 
CurrencyIsoCode = 'USD');
Database.insert(opp);
*/
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id, How_did_you_uncover_this_opportunity__c = 'sample',
                                                   Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
                                                   One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
                                                   Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
                                                   Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
                                                   Software_Licensing_Specialist__c = 'sample',    Is_this_an_Enterprise_Agreement__c = 'Yes');
        Database.insert(mainSV);
        ApexPages.StandardController ms = new ApexPages.StandardController(mainSV);
        SnP_MSAdditionalInfoController sc = new SnP_MSAdditionalInfoController(ms);
        Integer intmoreProd = 0;
        //Add EA Types
        PageReference addEaTypes = Page.SnPMSAdditionalInfo;
        Test.setCurrentPageReference(addEaTypes);
        List<S_P_Vendor_Additional_Information__c> listaddlInfoQueryMain = sc.getAddlInfoQuery();
        listaddlInfoQueryMain[0].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[0].EA_Type__c = 'EA';
        listaddlInfoQueryMain[0].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[0].Total__c = 100000;
        listaddlInfoQueryMain[1].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[1].EA_Type__c = 'EAP';
        listaddlInfoQueryMain[1].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[1].Total__c = 100000;
        listaddlInfoQueryMain[2].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[2].EA_Type__c = 'ECI';
        listaddlInfoQueryMain[2].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[2].Total__c = 100000;
        sc.wizardStart();
        //Add EA Products
        sc.previousPage();
        sc.wizardStart();
        List<S_P_Vendor_Product_Selection__c> listeaProducts = sc.getEaProducts();
        List<S_P_Vendor_Product_Selection__c> listeaAddlProducts = sc.getEaAddlProducts();
        listeaProducts[0].EA_Enterprise_Product__c = 'Enterprise Desktop w MDOP';
        listeaProducts[0].Quantity__c = 3;
        listeaProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsText();
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        
        //Add EAP Products
        List<S_P_Vendor_Product_Selection__c> listeapProducts = sc.getEapProducts();
        List<S_P_Vendor_Product_Selection__c> listeapAddlProducts = sc.getEapAddlProducts();
        listeapProducts[0].EA_Enterprise_Product__c = 'SQL Server EAP';
        sc.openAddProductsText();
        listeapProducts[0].Quantity__c = 3;
        listeapProducts[0].Unit_Price__c = 10000;
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        
        //Add ECI Products
        List<S_P_Vendor_Product_Selection__c> listeciProducts = sc.getEciProducts();
        List<S_P_Vendor_Product_Selection__c> listeciAddlProducts = sc.getEciAddlProducts();
        listeciProducts[0].EA_Enterprise_Product__c = 'CIS Ste DataCntr';
        listeciProducts[0].Quantity__c = 3;
        listeciProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsText();
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        
        //Insert all
        sc.finishWizard();
        
        PageReference addEaTypesFin = Page.SnPMSAdditionalInfo;
        Test.setCurrentPageReference(addEaTypesFin);
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    
    static testMethod void testEaDetailEaTypeValidations() {
        //Account acc = new Account(Name = 'Test Account');
        //Database.insert(acc);
        TriggerExecutionController.setSkipAllTriggers(true);
        
        /************************************************************************
*                 This part tests if EAP = Yes                         *
************************************************************************/
        /* Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%', 
CurrencyIsoCode = 'USD');
Database.insert(opp);
*/ 
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        system.assertNotEquals(listOpp[0].id, null);
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id, How_did_you_uncover_this_opportunity__c = 'sample',
                                                   Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
                                                   One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
                                                   Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
                                                   Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
                                                   Software_Licensing_Specialist__c = 'sample',    Is_this_an_Enterprise_Agreement__c = 'Yes');
        Database.insert(mainSV);
        ApexPages.StandardController ms = new ApexPages.StandardController(mainSV);
        SnP_MSAdditionalInfoController sc = new SnP_MSAdditionalInfoController(ms);
        Integer intmoreProd = 0;
        //Add EA Types
        PageReference addEaTypes = Page.SnPMSAdditionalInfo;
        Test.setCurrentPageReference(addEaTypes);
        List<S_P_Vendor_Additional_Information__c> listaddlInfoQueryMain = sc.getAddlInfoQuery();
        sc.wizardStart();
        listaddlInfoQuerymain[0].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[0].EA_Type__c = 'EA';
        listaddlInfoQuerymain[0].Agreement_Level__c = '';
        listaddlInfoQuerymain[0].Total__c = 100000;
        sc.wizardStart();
        listaddlInfoQuerymain[0].Agreement_Level__c = 'A1';
        listaddlInfoQuerymain[0].EA_Type__c = null;
        sc.wizardStart();
        listaddlInfoQuerymain[0].EA_Type__c = 'EA';
        listaddlInfoQuerymain[0].Agreement_Level__c = null;
        listaddlInfoQuerymain[0].Total__c = null;
        sc.wizardStart();
        listaddlInfoQuerymain[0].EA_Type__c = 'EAP';
        listaddlInfoQuerymain[0].Agreement_Level__c = '';
        listaddlInfoQuerymain[0].Total__c = 100000;
        listaddlInfoQuerymain[1].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[1].EA_Type__c = 'EAP';
        listaddlInfoQuerymain[1].Agreement_Level__c = 'A1';
        listaddlInfoQuerymain[1].Total__c = 100000;
        sc.wizardStart();
        listaddlInfoQuerymain[0].EA_Type__c = 'EA';
        listaddlInfoQuerymain[2].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[2].EA_Type__c = 'ECI';
        listaddlInfoQuerymain[2].Agreement_Level__c = 'A1';
        listaddlInfoQuerymain[2].Total__c = 100000;
        sc.wizardStart();
        listaddlInfoQuerymain[0].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[0].EA_Type__c = 'EAP';
        listaddlInfoQuerymain[0].Agreement_Level__c = 'A1';
        listaddlInfoQuerymain[0].Total__c = 100000;
        listaddlInfoQuerymain[1].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[1].EA_Type__c = 'EA';
        listaddlInfoQuerymain[1].Agreement_Level__c = 'A1';
        listaddlInfoQuerymain[1].Total__c = 100000;
        listaddlInfoQuerymain[2].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[2].EA_Type__c = 'ECI';
        listaddlInfoQuerymain[2].Agreement_Level__c = 'A1';
        listaddlInfoQuerymain[2].Total__c = 100000;
        sc.wizardStart();
        listaddlInfoQuerymain[0].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[0].EA_Type__c = 'ECI';
        listaddlInfoQuerymain[0].Agreement_Level__c = 'A1';
        listaddlInfoQuerymain[0].Total__c = 100000;
        listaddlInfoQuerymain[1].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[1].EA_Type__c = 'EAP';
        listaddlInfoQuerymain[1].Agreement_Level__c = 'A1';
        listaddlInfoQuerymain[1].Total__c = 100000;
        listaddlInfoQuerymain[2].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[2].EA_Type__c = 'EA';
        listaddlInfoQuerymain[2].Agreement_Level__c = 'A1';
        listaddlInfoQuerymain[2].Total__c = 100000;
        sc.wizardStart();
        listaddlInfoQuerymain[0].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQuerymain[0].EA_Type__c = 'EAS';
        listaddlInfoQuerymain[0].Agreement_Level__c = '';
        listaddlInfoQuerymain[0].Total__c = 100000;
        sc.wizardStart();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void testEaProductsValidation() {
        //Account acc = new Account(Name = 'Test Account');
        //Database.insert(acc);
        TriggerExecutionController.setSkipAllTriggers(true);
        List<S_P_Vendor_Product_Threshold__c> listthresh = [select id from S_P_Vendor_Product_Threshold__c limit 13];
        
        /*  List<S_P_Vendor_Product_Threshold__c> thresh = new List<S_P_Vendor_Product_Threshold__c>();

thresh.add(new S_P_Vendor_Product_Threshold__c(Agreement_Level__c = 'A1', Level__c = 'EA', /*Minimum_Revenue__c = 10000, 
Percentage__c = 10, /*Product_Description__c = '', Product_Family__c = '', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1',Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Enterprise Desktop w MDOP', Product_Family__c = 'Windows', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Lync', Product_Family__c = 'Lync', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Server EAP', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Azure Web', Product_Family__c = 'Product Not Eligible for SIP', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste DataCntr', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste Ent', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Lync Mac', Product_Family__c = 'Lync', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Server Datacenter', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste Ent - Security', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'SQL Svr Enterprise Core', Product_Family__c = 'Application Platform', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'Expression StudioWeb EAP', Product_Family__c = 'Product Not Eligible for SIP', Threshold_Required__c = TRUE));

thresh.add(new S_P_Vendor_Product_Threshold__c(/*Agreement_Level__c = 'A1', Level__c = 'Product', Minimum_Revenue__c = 10000, 
Percentage__c = 10, Product_Description__c = 'CIS Ste Std - Syst Ctr', Product_Family__c = 'Management & Virtualization', Threshold_Required__c = TRUE));

Database.insert(thresh);
*/
        /************************************************************************
*                 This part tests if EAP = Yes                         *
************************************************************************/
        /* Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%', 
CurrencyIsoCode = 'USD');
Database.insert(opp);
*/
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = listOpp[0].Id, How_did_you_uncover_this_opportunity__c = 'sample',
                                                   Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
                                                   One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
                                                   Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
                                                   Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
                                                   Software_Licensing_Specialist__c = 'sample',Is_this_an_Enterprise_Agreement__c = 'Yes');
        Database.insert(mainSV);
        ApexPages.StandardController ms = new ApexPages.StandardController(mainSV);
        SnP_MSAdditionalInfoController sc = new SnP_MSAdditionalInfoController(ms);
        Integer intmoreProd = 2;
        
        //Add EA Types
        PageReference addEaTypes = Page.SnPMSAdditionalInfo;
        Test.setCurrentPageReference(addEaTypes);
        List<S_P_Vendor_Additional_Information__c> listaddlInfoQueryMain = sc.getAddlInfoQuery();
        listaddlInfoQueryMain[0].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[0].EA_Type__c = 'EA';
        listaddlInfoQueryMain[0].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[0].Total__c = 100000;
        listaddlInfoQueryMain[1].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[1].EA_Type__c = 'EAP';
        listaddlInfoQueryMain[1].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[1].Total__c = 100000;
        listaddlInfoQueryMain[2].S_P_Vendors_ID__c = mainSV.Id;
        listaddlInfoQueryMain[2].EA_Type__c = 'ECI';
        listaddlInfoQueryMain[2].Agreement_Level__c = 'A1';
        listaddlInfoQueryMain[2].Total__c = 100000;
        sc.wizardStart();
        
        Integer intdeleteCheck = sc.getDeleteCheck();
        
        //Add EA Products
        sc.previousPage();
        sc.wizardStart();
        List<S_P_Vendor_Product_Selection__c> listeaProducts = sc.getEaProducts();
        List<S_P_Vendor_Product_Selection__c> listeaAddlProducts = sc.getEaAddlProducts();
        sc.nextPage();
        listeaProducts[0].EA_Enterprise_Product__c = 'Enterprise Desktop w MDOP';
        listeaProducts[0].Quantity__c = 3;
        listeaProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsText();
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.nextPage();
        listeaAddlProducts[0].Additional_Product_Type__c = 'Lync';
        listeaAddlProducts[0].New_Products_Only__c = 'Lync';
        listeaAddlProducts[0].Quantity__c = 3;
        listeaAddlProducts[0].Unit_Price__c = 10000;
        listeaAddlProducts[1].Additional_Product_Type__c = 'Lync';
        listeaAddlProducts[1].New_Products_Only__c = 'Lync';
        listeaAddlProducts[1].Quantity__c = 3;
        listeaAddlProducts[1].Unit_Price__c = 10000;
        sc.nextPage();
        listeaAddlProducts[1].New_Products_Only__c = 'Lync Mac';
        listeaAddlProducts[1].Remove__c = TRUE;
        sc.checkDeleteAddlProducts();
        sc.deleteAddlProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        
        //Add EAP Products
        List<S_P_Vendor_Product_Selection__c> listeapProducts = sc.getEapProducts();
        List<S_P_Vendor_Product_Selection__c> listeapAddlProducts = sc.getEapAddlProducts();
        sc.nextPage();
        listeapProducts[0].EA_Enterprise_Product__c = 'SQL Server EAP';
        sc.openAddProductsText();
        listeapProducts[0].Quantity__c = 3;
        listeapProducts[0].Unit_Price__c = 10000;
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.nextPage();
        listeapAddlProducts[0].Additional_Product_Type__c = 'SQL';
        listeapAddlProducts[0].New_Products_Only__c = 'SQL Azure Web';
        listeapAddlProducts[0].Quantity__c = 3;
        listeapAddlProducts[0].Unit_Price__c = 10000;
        listeapAddlProducts[1].Additional_Product_Type__c = 'SQL';
        listeapAddlProducts[1].New_Products_Only__c = 'SQL Azure Web';
        listeapAddlProducts[1].Quantity__c = 3;
        listeapAddlProducts[1].Unit_Price__c = 10000;
        sc.nextPage();
        listeapAddlProducts[1].Additional_Product_Type__c = 'SQL';
        listeapAddlProducts[1].New_Products_Only__c = 'SQL Server Datacenter';
        listeapAddlProducts[1].Remove__c = TRUE;
        sc.checkDeleteAddlProducts();
        sc.deleteAddlProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        
        //Add ECI Products
        List<S_P_Vendor_Product_Selection__c> listeciProducts = sc.getEciProducts();
        List<S_P_Vendor_Product_Selection__c> listeciAddlProducts = sc.getEciAddlProducts();
        sc.nextPage();
        listeciProducts[0].EA_Enterprise_Product__c = 'CIS Ste DataCntr';
        listeciProducts[0].Quantity__c = 3;
        listeciProducts[0].Unit_Price__c = 10000;
        sc.openAddProductsText();
        sc.setMoreProd(intmoreProd);
        sc.getMoreProd();
        system.assertEquals(intmoreProd, sc.getMoreProd());
        sc.openMoreProducts();
        sc.nextPage();
        listeciAddlProducts[0].Additional_Product_Type__c = 'CIS';
        listeciAddlProducts[0].New_Products_Only__c = 'CIS Ste Ent';
        listeciAddlProducts[0].Quantity__c = 3;
        listeciAddlProducts[0].Unit_Price__c = 10000;
        listeciAddlProducts[1].Additional_Product_Type__c = 'CIS';
        listeciAddlProducts[1].New_Products_Only__c = 'CIS Ste Ent';
        listeciAddlProducts[1].Quantity__c = 3;
        listeciAddlProducts[1].Unit_Price__c = 10000;
        sc.nextPage();
        listeciAddlProducts[1].New_Products_Only__c = 'CIS Ste Ent - Security';
        listeciAddlProducts[1].Remove__c = TRUE;
        sc.checkDeleteAddlProducts();
        sc.deleteAddlProducts();
        sc.currentPage();
        sc.nextPage();
        sc.previousPage();
        sc.nextPage();
        //Insert all
        sc.finishWizard();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}