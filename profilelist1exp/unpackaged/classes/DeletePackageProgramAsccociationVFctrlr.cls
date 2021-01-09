public class DeletePackageProgramAsccociationVFctrlr {

    ID packageID;
    ID marketpalnID;
    Decimal budgetprice=0;
    Decimal pkgprice=0;
    Package__c packagerec {get; set;}
    Marketing_Plan__c marketplanerec {get; set;}
    
    //Wrapper Classes
    List<APVWrapper> ListofAvailableApvs{get; set;}
    List<APVWrapper> selectedListofAvailableApvs=new List<APVWrapper>();
    
    List <Associated_Programs_Vendors__c> availableAPVList=new List<Associated_Programs_Vendors__c>();
    Public Boolean noApv=True;

    //constructor
    public DeletePackageProgramAsccociationVFctrlr (ApexPages.StandardController controller) {
        packageID=controller.getId();
        packagerec=[select Name,Marketing_Plan__c,Package_Price_del__c from Package__c where id=:packageID];
        availableAPVList=[select id,Name,Marketing_Plan__c,Package__c,MDF_Program__c,Status__c,Business_Segment__c,Budgeted_Price__c 
                            from Associated_Programs_Vendors__c where Marketing_Plan__c=:packagerec.Marketing_Plan__c AND Package__c=:packagerec.Id];
        if(availableAPVList.size()>0){
            noApv=False;    
        }
        
    }

    public boolean getIsApvavailable(){
        return noApv; 
    }
    

    public pageReference deleteAPVFromPackage(){
        List <Associated_Programs_Vendors__c> upd_apvs=new List<Associated_Programs_Vendors__c>();
        PageReference currPageRef=new PageReference('/'+packageID);
        Associated_Programs_Vendors__c apvObj;
        
        List <Associated_Programs_Vendors__c> selectedAPVList=new List<Associated_Programs_Vendors__c>();
        
        for ( APVWrapper apv: ListofAvailableApvs){
            if(apv.selected==true){
                apvObj=new Associated_Programs_Vendors__c(id=apv.apvPkgElt.Id);
                if(apv.apvPkgElt.Budgeted_Price__c==null){
                    apvObj.Budgeted_Price__c=0.00;
                }
                apvObj.Package__c=NULL;
                upd_apvs.add(apvObj);
                if(apv.apvPkgElt.Budgeted_Price__c!=null){
                    budgetprice=budgetprice+apv.apvPkgElt.Budgeted_Price__c;
                }
            }        
        }  
        if(upd_apvs.size()==0){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select atleast one APV.');
            ApexPages.addMessage(msg);            
            return null;  
             
        }        
        if(upd_apvs.size()>0){
            pkgprice=packagerec.Package_Price_del__c;
            if(packagerec.Package_Price_del__c==Null){
                pkgprice=0.00;
            }
            packagerec.Package_Price_del__c=pkgprice-budgetprice;
            try {
                update upd_apvs;
                update packagerec;
            } catch (DmlException e){
                System.debug('From Delete Package Program Association updating package/APV record '+e.getMessage());
            }
        }  

    return currPageRef;
    
    }

         //Wrapper class
    public class APVWrapper{
        public Associated_Programs_Vendors__c apvPkgElt {get; set;}
        public Boolean selected {get; set;}

        //Constructor for wrapper class
        public APVWrapper(Associated_Programs_Vendors__c apvAPVObj){
            apvPkgElt = apvAPVObj;
            selected = false;
        }
    } 


    public List<APVWrapper> getListofAvailableApvs(){
        APVWrapper apvWrapperElt;
        ListofAvailableApvs=new List<APVWrapper>();            
        
        for(Associated_Programs_Vendors__c apv:availableAPVList){                
            ListofAvailableApvs.add(new APVWrapper(apv));
        }
        System.debug('###AvailableAPVs'+ListofAvailableApvs); 
        return ListofAvailableApvs;
    }
        
    public void setListofAvailableApvs(List<APVWrapper> apvWrapperRecList){
        this.ListofAvailableApvs=apvWrapperRecList;
    }

}