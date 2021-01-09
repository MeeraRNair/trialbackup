/***********************************************************
* Name          : SolutionCertificationUtils
* Description   : Solution Certificate Insert functionality
* ---------------------------------------------------------
* Revision  Name     Date        Description
* 1.0       Hanan    30.04.2010  CR 2590 Solution Certificate Insert functionality
* 2.0       Hanan    04.07.2010  CR 3314
* 3.0       Hanan    22.10.2010  SAR 1099
* 4.0       Shue     19.05.2014  CR 9467 - picklist value updated.
* 5.0       Ramesh   21.08.2017  CR 14815 Class is fully commented, this class is related to services.
************************************************************/
    public class SolutionCertificationUtils{
        /* v 5.0- start
        public static final Decimal ServicesOpportunityRevenue=2000000;
        //static Set<Id> opportunityIdSet=new Set<Id>(); 
        //Static Map<Id,Id> opptyIdsolnCertIdMap=new Map<Id,Id>();     
        static Map<String,String> servicesOpptyMap=new Map<String,String>();     
        static Map<Id,Opportunity> opportunityMap=new Map<Id,Opportunity>();
        static Map<String,decimal> opptyIdRevenueMap=new Map<String,decimal>(); */ //v 5.0- End
         
        public SolutionCertificationUtils(){
        
        } 
         
      //v 5.0- start
      /* // the opptyMapFromTgr contains opportunities which have no solution cert records 
        public static void processOpportunityListFromTrigger(Map<Id,Opportunity> opptyMapFromTgr,Set<Id> opptyIdSetFromTgr,
                                                            Map<Id,Id> oppIdSolnIdMap){
            //Boolean setChanged=false;                                                
            Boolean byPassAllLOTOceanCalValue=GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION;
            Set<Id> opportunityIdSet=new Set<Id>(); 
            System.debug('###oppIdSolnIdMap.keySet()###'+oppIdSolnIdMap.keySet());   
            if(oppIdSolnIdMap.size()>0){
                if(opptyIdSetFromTgr.removeAll(oppIdSolnIdMap.keySet())){
                    opportunityIdSet=opptyIdSetFromTgr;
                    System.debug('###opportunityIdSet after removal###'+opportunityIdSet);
                }
            
            }
            if(oppIdSolnIdMap.isEmpty()){
                opportunityIdSet=opptyIdSetFromTgr;                
            }
            
            if(opportunityIdSet.size()>0){
                 GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION=true;              
                 opportunityMap=opptyMapFromTgr; 
                 System.debug('###opportunityIdSet###'+opportunityIdSet);             
                 processOpportunityLineItems(opportunityIdSet);
                 GlobalVariables.BYPASS_ALL_LOT_OCEAN_CALCULATION=byPassAllLOTOceanCalValue;
            }else{
                    return;
            }
            
            

        }
        */ //v 5.0- End
        
        /*process the opptyLineItems to get total revenue of & to get  id of opportunities 
            which has atleast 1 product whose type ='services'*/
       /* //v 5.0- Start     
        public static void processOpportunityLineItems(Set<Id> noSolnCertOpptyIdSet){
            decimal revenue=0;      
            String opportunityId;           
            Set<Id> servicesOptyIdSet=new Set<Id>();            

            for(OpportunityLineItem  oli:[Select Id,PricebookEntry.Product2Id,UnitPrice, 
                                            quantity,PricebookEntry.Product2.Family,
                                            opportunityId from OpportunityLineItem where 
                                            opportunityId in:noSolnCertOpptyIdSet  and
                                            PricebookEntry.Product2.Family='Services'
                                             order by opportunityId ]){
                System.debug('###OLI###'+oli);          
                
                if(oli!=null){
                    
                    //if(oli.PricebookEntry.Product2.Family=='Services'){
                        servicesOpptyMap.put(oli.opportunityId,oli.PricebookEntry.Product2.Family);
                        servicesOptyIdSet.add(oli.opportunityId);
                    //}
                   
                }
            }
            
            //opptyIdRevenueMap.put(opportunityId, revenue);
           System.debug('###servicesOptyIdSetp###'+servicesOptyIdSet);
           
           if(servicesOptyIdSet.size()>0){
               insertSolutionCertificationRecords(servicesOptyIdSet);
           }
            
        }
        */ //v 5.0- End
        /* //v 5.0- Start
        //the idSet contains ids of opportunities which has atleast 1 product whose type ='services' 
        public static void insertSolutionCertificationRecords(Set<Id> servicesOpptyIdSet){
            
            Decimal revenue;            
            String solnCertOpptyId;     
            String productType; 
            String opptyId; 
            String strId;   
            Opportunity opptyElt;           
            Solution_Certification__c solutionCert;         
            List<Solution_Certification__c> solutionCertList=new List<Solution_Certification__c>();
            
            for(Id sElt:servicesOpptyIdSet){

                opptyId=sElt;
                strId=''+sElt;              
                opptyElt=new Opportunity(); 
                opptyElt=opportunityMap.get(opptyId);
                //productType=servicesOpptyMap.get(strId);
                productType=servicesOpptyMap.get(sElt); 
               // revenue=opptyIdRevenueMap.get(strId);
                
               
              
                //if((revenue>=ServicesOpportunityRevenue)&&(productType!=null)){
                //added for CR:-3314 checking Unweighted_Rev_USD__c field also  */ //v 5.0- End
                /*  commented on 07-Oct-2010
                if((revenue==opptyElt.amount)&&(productType!=null)
                 &&(opptyElt.Unweighted_Rev_USD__c>=ServicesOpportunityRevenue)){*/ 
  /* //v 5.0- Start System.debug('###opptyElt.Unweighted_Rev_USD__c###'+opptyElt.Unweighted_Rev_USD__c);
                 if((productType!=null)&&(opptyElt.Unweighted_Rev_USD__c>=ServicesOpportunityRevenue)){                 
                    solnCertOpptyId=String.valueOf(strId);
                    solutionCert=new Solution_Certification__c(Opportunity__c=solnCertOpptyId,
                    //Status__c='SolCert Not Yet Engaged'); 
                    Status__c='Deal Cert Not Yet Engaged');// CR 9467
                    solutionCertList.add(solutionCert);             
                }
                

            }

            if(solutionCertList.size()>0){
                insert solutionCertList;
            }

        } */ //v 5.0- End
        
         static testMethod void callingSCUcconst(){
       SolutionCertificationUtils scu= new SolutionCertificationUtils(); 
    } 

    }