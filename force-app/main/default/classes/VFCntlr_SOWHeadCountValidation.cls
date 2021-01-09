public class VFCntlr_SOWHeadCountValidation {

  Marketing_Plan__c marketingPlanRec;
  RecordType headCountRT;
  List<Associated_Programs_Vendors__c> associatedPgmVendorList=new List<Associated_Programs_Vendors__c>();

  public VFCntlr_SOWHeadCountValidation(ApexPages.StandardController controller) {
  }

  Public PageReference redirectToSowHeadCount(){
    headCountRT=[select id,name,SobjectType  from RecordType 
        where SobjectType='Marketing_Plan__c' and name='Headcount Marketing Plan' limit 1];
       
        VfCtrl_ViperSOQLMethod_Utility ViperSOQLMethod= new VfCtrl_ViperSOQLMethod_Utility();
        
        marketingPlanRec= database.query(ViperSOQLMethod.getQueryMethod1(new Marketing_Plan__c(),'VFCntlr_SOWHeadCountValidation') + ' where id=\''+ApexPages.currentPage().getParameters().get('id')+'\'');
        
        System.debug('###marketingPlanRec'+marketingPlanRec);
        
        If(marketingPlanRec.recordTypeId==headCountRT.id && marketingPlanRec.Contract_Type__c=='Headcount'){
            for(Associated_Programs_Vendors__c apvListElt: database.query(ViperSOQLMethod.getQueryMethod2(new Associated_Programs_Vendors__c(),'VFCntlr_SOWHeadCountValidation') +' where vendor__c=\''+marketingPlanRec.vendor__c+'\' and Marketing_Plan__c=\''+marketingPlanRec.Id+
                                                                        '\' and status__c=\'Accepted\' and Fiscal_Quarter__c=\''+marketingPlanRec.Fiscal_Quarter__c+'\'') ){
                                                           

                associatedPgmVendorList.add(apvListElt);
                System.debug('###associatedPgmVendorList'+associatedPgmVendorList);    
                    
            }
            If(associatedPgmVendorList.size() > 0){
              // Redirect to SOWHeadCount Page to download the Doc
              PageReference page = new PageReference('/apex/selectSOWTemplate?id='+ marketingPlanRec.id);
              return page;
            }else{
              // Display an error message
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'No matching APV record found for Marketing Plan’s starting Fiscal Quarter'));
            return null;
            } 
        }else{
            // Redirect to SOWHeadCount Page to download the Doc
            PageReference page = new PageReference('/apex/selectSOWTemplate?id='+ marketingPlanRec.id);
            return page;
        }
        return null;
    }
  }