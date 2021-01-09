/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13171       FY18-DCS-0502   13-April-2017   Azwanti         LM2_Fix missing Campaign Member - Reset triggers flag in batch processing
2.0         14654       FY18-DCS-11-1   21-Sept-2017    Shue            Reset triggers flag in batch processing (Oppty, OLI, Account)  
3.0         15056	    FY18-DCS-0102   30-Oct-2017     Sajith          Reset triggers flag in batch processing for User Object   
4.0         15781       FY19-DCE-0703   30-May-2018     Fenny           Skip Case triggers by Process flow
*/    

@isTest(SeeAllData=false)
public class ResetProcessFlowTriggerControllerTest{
    private static testMethod void testResetSkipTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
        
        ResetProcessFlowTriggerController.processFlowClass rp = new ResetProcessFlowTriggerController.processFlowClass();
        rp.strObjectName = 'Lead,Case'; // 4.0: added Case
        rp.isSkip = false;
        listAddedPFC.add(rp);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.debug('in testResetSkipTriggers: '+TriggerExecutionController.skipLeadTriggers());
        system.assert(!TriggerExecutionController.skipLeadTriggers()); 
        system.debug('in testResetSkipTriggers: '+TriggerExecutionController.skipCaseTriggers()); // 4.0
        system.assert(!TriggerExecutionController.skipCaseTriggers());  // 4.0
    }
    
    private static testMethod void testSkipTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
                
        ResetProcessFlowTriggerController.processFlowClass param= new ResetProcessFlowTriggerController.processFlowClass();
        param.strObjectName = 'Lead,Case'; // 4.0: added Case
        param.isSkip = true;
        listAddedPFC.add(param);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.assert(TriggerExecutionController.skipLeadTriggers()); 
        system.assert(TriggerExecutionController.skipCaseTriggers());  // 4.0
    }
    
    
    //---------------------- v2 test START ---------------------------------------------
    //Account
    private static testMethod void testAccResetSkipTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
        
        ResetProcessFlowTriggerController.processFlowClass rp = new ResetProcessFlowTriggerController.processFlowClass();
        rp.strObjectName = 'Account'; 
        rp.isSkip = false;
        listAddedPFC.add(rp);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.debug('in Account testResetSkipTriggers: '+TriggerExecutionController.skipAccountTriggers());
        system.assert(!TriggerExecutionController.skipAccountTriggers()); 
    }
    
    private static testMethod void testAccSkipTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
                
        ResetProcessFlowTriggerController.processFlowClass param= new ResetProcessFlowTriggerController.processFlowClass();
        param.strObjectName = 'Account'; 
        param.isSkip = true;
        listAddedPFC.add(param);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.assert(TriggerExecutionController.skipAccountTriggers()); 
    }
    //Oppty
    private static testMethod void testOpptyResetSkipTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
        
        ResetProcessFlowTriggerController.processFlowClass rp = new ResetProcessFlowTriggerController.processFlowClass();
        rp.strObjectName = 'Opportunity'; 
        rp.isSkip = false;
        listAddedPFC.add(rp);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.debug('in Oppty testResetSkipTriggers: '+TriggerExecutionController.skipOpportunityTriggers());
        system.assert(!TriggerExecutionController.skipOpportunityTriggers()); 
    }
    
    private static testMethod void testOpptySkipTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
                
        ResetProcessFlowTriggerController.processFlowClass param= new ResetProcessFlowTriggerController.processFlowClass();
        param.strObjectName = 'Opportunity'; 
        param.isSkip = true;
        listAddedPFC.add(param);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.assert(TriggerExecutionController.skipOpportunityTriggers()); 
    }
    //OLI
    private static testMethod void testOLIResetSkipTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
        
        ResetProcessFlowTriggerController.processFlowClass rp = new ResetProcessFlowTriggerController.processFlowClass();
        rp.strObjectName = 'OpportunityLineItem'; 
        rp.isSkip = false;
        listAddedPFC.add(rp);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.debug('in testResetSkipTriggers: '+TriggerExecutionController.skipOpportunityLineItemTriggers());
        system.assert(!TriggerExecutionController.skipOpportunityLineItemTriggers()); 
    }
    
    private static testMethod void testOLISkipTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
                
        ResetProcessFlowTriggerController.processFlowClass param= new ResetProcessFlowTriggerController.processFlowClass();
        param.strObjectName = 'OpportunityLineItem'; 
        param.isSkip = true;
        listAddedPFC.add(param);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.assert(TriggerExecutionController.skipOpportunityLineItemTriggers()); 
    }
    //---------------------- v2 test END------------------------------------------
    //---------------------- v3 test Start------------------------------------------
    private static testMethod void testResetUserSkipTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
        
        ResetProcessFlowTriggerController.processFlowClass rp = new ResetProcessFlowTriggerController.processFlowClass();
        rp.strObjectName = 'User'; 
        rp.isSkip = false;
        listAddedPFC.add(rp);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.debug('in testResetSkipTriggers: '+TriggerExecutionController.skipUserTriggers());
        system.assert(!TriggerExecutionController.skipUserTriggers()); 
    }
    
    private static testMethod void testSkipUserTriggers(){
        
        List<ResetProcessFlowTriggerController.processFlowClass> listAddedPFC = new List<ResetProcessFlowTriggerController.processFlowClass>();  
        
        ResetProcessFlowTriggerController.processFlowClass param= new ResetProcessFlowTriggerController.processFlowClass();
        param.strObjectName = 'User'; 
        param.isSkip = true;
        listAddedPFC.add(param);
        
        ResetProcessFlowTriggerController.isTest = true;  
        ResetProcessFlowTriggerController.skipOrResetObjTrigger(listAddedPFC); 
        
        system.assert(TriggerExecutionController.skipUserTriggers()); 
    }  
    //---------------------- v3 test END------------------------------------------
}