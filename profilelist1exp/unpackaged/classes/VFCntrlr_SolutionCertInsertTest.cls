/* 
 * History:
 * Version     Date  			Modified By					Description
-------------------------------------------------------------------------------
	  2.0	 04-12-2019			VIKAS KH					Implemeted TDF		

 */

@isTest
private class VFCntrlr_SolutionCertInsertTest{
    Static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static Date dCloseDate; 
    static List<string> listid=new List<string>();
    static Map<String,String> mapcountOpptyId=new Map<String,String>();
    static list<OpportunityLineItem> listOplineitem;
    static List<Solution_Certification__c> listsolnCert=new List<Solution_Certification__c>();
    @testsetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
        list<Opportunity> listoppTDF = TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        insert listoppTDF;
        list<OpportunitylineItem> listOpplTDF = TestDataFactory.createNOpportunityLineItem(1);
        listOpplTDF[0].Opportunityid=listoppTDF[0].id; 
        insert listOpplTDF;
        
    }           
    static testMethod void testinitializeController(){
        listAcc = [select id from Account limit 1];
        dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: To fulfill new VR OpptyBookDateValidation
        listOpp = [select name,id,AccountId from Opportunity limit 1];
        listOpp[0].Type='Deal/Bid Direct';
        listOpp[0].CloseDate=dCloseDate;
        listOpp[0].StageName='Plan - 1%';
        try{
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            update listOpp;   
        } catch(exception e){}
        listOplineitem = [Select id, UnitPrice, quantity from OpportunityLineItem ];
        listOplineitem[0].UnitPrice=1000;
        listOplineitem[0].quantity=2000;
        try{
            update listOplineitem;
        }catch (exception e){}
        system.assertEquals(1000, listOplineitem[0].UnitPrice);
        PageReference  pr=new PageReference('/apex/solutioncertinsert?id=listOpp[0].id');
        Test.setCurrentPage(pr);
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());
        VFCntrlr_SolutionCertInsert controller= new VFCntrlr_SolutionCertInsert(new ApexPages.StandardController(listOpp[0]) );
    }
    static testMethod void testactionMethod(){
        listAcc = [select id,name from Account limit 1];
        dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: To fulfill new VR OpptyBookDateValidation
        listOpp = [select id, AccountId,name,RecordTypeID from Opportunity limit 1];
        listOpp[0].Type='Deal/Bid Direct';
        listOpp[0].CloseDate=dCloseDate;
        listOpp[0].StageName='Plan - 1%';
        try{ 
            Update ListOpp;
        }catch(exception e){}
        listOplineitem = [Select id, UnitPrice, quantity from OpportunityLineItem ];
        listOplineitem[0].UnitPrice=1000;
        listOplineitem[0].quantity=20;
        try{
            update listOplineitem;
        }catch (exception e){}
        system.assertEquals(1000, listOplineitem[0].UnitPrice);
        PageReference  pr=new PageReference('/apex/solutioncertinsert?id=listOpp[0].id');
        Test.setCurrentPage(pr);            
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());
        String stropptyId15Char=listOpp[0].Id;
        stropptyId15Char=stropptyId15Char.substring(0,15);
        String stroppName=listAcc[0].name+' '+'-'+' '+listOpp[0].name;
        VFCntrlr_SolutionCertInsert controller= new VFCntrlr_SolutionCertInsert(new ApexPages.StandardController(listOpp[0]) );
        PageReference  pageRefExpected=new PageReference('/a0h/e?CF00NA00000034C5V='+listAcc[0].name+' '+'-'+' '+listOpp[0].name+'&CF00NA00000034C5V_lkid='+stropptyId15Char+'&retURL=%2F'+stropptyId15Char);
    }
    static testMethod void testnonServicePdt(){
        listAcc = [select id,name from Account limit 1]; 
        dCloseDate = Date.TODAY(); // Fenny added [18-July-2014]: To fulfill new VR OpptyBookDateValidation
        listOpp = [select id, AccountId,name from Opportunity limit 1];
        listOpp[0].Type='Deal/Bid Direct';
        listOpp[0].CloseDate=dCloseDate;
        listOpp[0].StageName='Plan - 1%';
        try{
            Update ListOpp;
        }catch(exception e){}
        listOplineitem = [Select id, UnitPrice, quantity from OpportunityLineItem ];
        listOplineitem[0].UnitPrice=100;
        listOplineitem[0].quantity=20;
        try{
            insert listOplineitem;
        }catch(exception e){}
        system.assertEquals(100, listOplineitem[0].UnitPrice);
        PageReference  pr=new PageReference('/apex/solutioncertinsert?id=listOpp[0].id');
        Test.setCurrentPage(pr);            
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());
        String stropptyId15Char=listOpp[0].Id;
        stropptyId15Char=stropptyId15Char.substring(0,15);
        String stroppName=listAcc[0].name+' '+'-'+' '+listOpp[0].name;
        VFCntrlr_SolutionCertInsert controller= new VFCntrlr_SolutionCertInsert(new ApexPages.StandardController(listOpp[0]) );
    }
    static testMethod void testNoProducts(){
        listAcc = [select name, id from Account limit 1];
        listOpp = [select id, AccountId,name from Opportunity limit 1];
        listOpp[0].AccountID = listAcc[0].id;
        listOpp[0].Type='Deal/Bid Direct';
        listOpp[0].CloseDate=system.today();
        listOpp[0].StageName='Plan - 1%';
        try{
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            update listOpp;
        }
        catch(exception e){}
        system.assertNotEquals(null, listOpp[0].StageName);
        PageReference  pr=new PageReference('/apex/solutioncertinsert?id=listOpp[0].id');
        Test.setCurrentPage(pr);            
        System.debug('DEBUG: Current Page URL: ' + ApexPages.currentPage().getUrl());
        String stropptyId15Char=listOpp[0].Id;
        stropptyId15Char=stropptyId15Char.substring(0,15);
        String stroppName=listAcc[0].name+' '+'-'+' '+listOpp[0].name;
        VFCntrlr_SolutionCertInsert controller= new VFCntrlr_SolutionCertInsert(new ApexPages.StandardController(listOpp[0]) );
    }
}