/***********************************************************
* Name          : SolutionCertificationUtilsTest
* Description   : Solution Certificate Insert functionality Test Class
* ---------------------------------------------------------
* Revision  Name           Date        Description
* 1.0       Hanan       22 Apr 2010  CR 2590 Solution Certificate Insert functionality
* 2.0       Shue        09 Mar 2015  Fix test class: Add Solution_Certification__c test data
* 3.0		Venugopal   04-Dec 2019	 Implemented TDF

************************************************************/
@isTest
private class SolutionCertificationUtilsTest{
    
    static Opportunity testOpportunity;
    static Account testAccount; 
    static Date dCloseDate; 
    static Product2 pdt1;       
    static Pricebook2 pb;
    static PricebookEntry pbe;       
    static Opportunity o ; 
    static OpportunityLineItem oli ;
    static RecordType rectype;
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    static list<OpportunityLineItem> listOppLineItem;
    @testSetup static void setup(){
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert oWDsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        listOppTdf[1].AccountId=listAccTdf[0].id;
        listOppTdf[0].Type='Deal/Bid Direct';
        insert listOppTdf;
        
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(2);
        listOppLineItemTdf[0].OpportunityID=listOppTdf[0].id;
        listOppLineItemTdf[1].OpportunityID=listOppTdf[1].id;
        
        insert listOppLineItemTdf;
    }
    
    static testMethod void testmethod1(){
        GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION = true;
        List<string> listid;
        List<Opportunity> listoppty;
        List<Opportunity> listoppty2BUpdated;
        List<Opportunity> listopptyUpdate;
        List<OpportunityLineItem> listopptyLineItem;
        List<OpportunityLineItem> listopptyLineItem2BUpdated;
        Map<String,String> mapcountOpptyId;
        List<Solution_Certification__c> listsolnCert;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        listAcc=[SELECT ID FROM Account LIMIT 1];
        listOpp=[SELECT ID FROM Opportunity LIMIT 2];
        List<string> listId2=new List<string>{listOpp[0].id,listOpp[1].id};
            listoppty=new List<Opportunity>();
        listopptyLineItem=new List<OpportunityLineItem>();
        listoppty2BUpdated=new List<Opportunity>();
        
        Test.startTest();
        listOppLineItem=[SELECT ID FROM OpportunityLineItem LIMIT 2];
        
        for(Integer intj=0;intj<listoppty.size();intj++){            
            oli = new OpportunityLineItem(opportunityid=listoppty[intj].id,
                                          UnitPrice=1000, quantity=2000, pricebookentryid=pbe.Id);
            listopptyLineItem.add(oli);
            listid.add(listoppty[intj].id);
        }    
        Test.stopTest();
        
        mapcountOpptyId=new Map<String,String>();
        
        //2.0 Starts
        listsolnCert = new List <Solution_Certification__c>();
        for(Integer intj=0;intj<listOpp.size();intj++){
            Solution_Certification__c solCert = new Solution_Certification__c();
            solCert.Comments__c = 'Comments test';
            solCert.DealCert_done_prior_proposal_submission__c = 'Deal Cert';
            solCert.Disengage_Reason__c = 'Design Test';
            solCert.Opportunity__c = listOpp[intj].id;
            solCert.Status__c = 'Status Test';
            listsolnCert.add(solCert);
        }
        insert listsolnCert;
        //2.0 Ends
        
        for(Solution_Certification__c solnElt:[select Id,Opportunity__c from Solution_Certification__c where Opportunity__c in:listId2]){
            mapcountOpptyId.put(solnElt.Opportunity__c,solnElt.Opportunity__c);
        }
        
        System.debug('###Test method 1 mapcountOpptyId.size() before update'+mapcountOpptyId.size());
        for(Integer intj=0;intj<listOpp.size();intj++){
            system.assertEquals(listOpp[intj].id,mapcountOpptyId.get(listOpp[intj].id));     
        }
        
        for(Integer intj=0;intj<listOpp.size();intj++){            
            listOpp[intj].name='test oppty'+intj;
            listoppty2BUpdated.add(listOpp[intj]); 
            
        }
        update listoppty2BUpdated;
        for(Solution_Certification__c solnElt:[select Id,Opportunity__c 
                                               from Solution_Certification__c where Opportunity__c in:listId2]){
                                                   //system.assertEquals(1,solnElt.count);   
                                               }
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    
}