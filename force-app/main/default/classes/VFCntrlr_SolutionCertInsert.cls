/*---------------------------------------------
    Description: Visualforce controller to check whether a solution certification
    record has to be inserted for the opportunity .    
    Version: 1.0 

    Author: Hanan Justin

    History:
    1.0 - 09-April-2010: Creation.
    Revision  Name     Date        Description
    1.0       Ramesh  21.08.2017   CR 14815 Class is fully commented, this class is related to services.
    ---------------------------------------------*/
    public class VFCntrlr_SolutionCertInsert {
    /* // v 1.0 - start
        Pagereference pageLink;
        Pagereference backBtnLink;
        String opportunityId;
        String opptyId15Char;               
        Integer solutionCertCount=0; */ // v 1.0 - end
              
       
        public VFCntrlr_SolutionCertInsert(ApexPages.StandardController controller){
           /* // v 1.0 - start try{
                //opportunityId=ApexPages.currentPage().getParameters().get('id');
                opportunityId=controller.getId();
                System.debug('DEBUG: VFCntrlr_SolutionCertInsert In controller ' +opportunityId);
            }
            catch(Exception e){                
                System.debug(e);
            } */ // v 1.0 - end
        }
/* // v 1.0 - start
        public PageReference actionReturnUrl(){
            try{

                Opportunity opp=[Select name from Opportunity where Id =:opportunityId];
                solutionCertCount=[select count() from Solution_Certification__c where Opportunity__c=:opportunityId];      
                //opportunityId=ApexPages.currentPage().getParameters().get('id');
                if(solutionCertCount==0){                
                     //errormsg=null;
                      pageLink=new PageReference('/a0h/e?CF00NA00000034C5V='+opp.name+'&CF00NA00000034C5V_lkid='+opportunityId+'&retURL=%2F'+opportunityId);
                      System.debug('DEBUG: VFCntrlr_SolutionCertInsert In actionReturnUrl pageLink '+pageLink);
                      
                }
                else{                  
                    pageLink=null;
                    backBtnLink=new PageReference('/'+opportunityId);
                }
            }
            catch(exception e){                
                System.debug(e);
            }
            return pageLink;        
        } */ // v 1.0 - end
        /*
        public  String getSolnCertCountAndPdtType(){
            System.debug('DEBUG: VFCntrlr_SolutionCertInsert In actionReturnUrl errormsg '+errormsg);            
            return errormsg;
        }
        */
        /* // v 1.0 - start
        public  PageReference backBtnURL(){
            backBtnLink=new PageReference('/'+opportunityId);           
            return backBtnLink;
        } */ // v 1.0 - end
        
      static testMethod void callingvfscconst(){
       Solution_Certification__c sc = new Solution_Certification__c (); 
       ApexPages.StandardController con = new ApexPages.StandardController(sc);
       VFCntrlr_SolutionCertInsert  vfsc = new VFCntrlr_SolutionCertInsert (con);
       
    } 
    }