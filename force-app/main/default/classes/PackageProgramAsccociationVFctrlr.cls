public class PackageProgramAsccociationVFctrlr {

    ID packageID;
    ID marketpalnID;
    Decimal budgetprice=0;
    Decimal pkgprice=0;
    Package__c packagerec {get; set;}
    Marketing_Plan__c marketplanerec {get; set;}
    
    //Wrapper Classes
    List<MPWrapper> ListofAvailableApvs{get; set;}
    List<MPWrapper> selectedListofAvailableApvs=new List<MPWrapper>();
    
    List <Associated_Programs_Vendors__c> availableAPVList=new List<Associated_Programs_Vendors__c>();
    Public Boolean noApv=True;

    //constructor
    public PackageProgramAsccociationVFctrlr (ApexPages.StandardController controller) {
        packageID=controller.getId();
        packagerec=[select Name,Marketing_Plan__c,Package_Price_del__c,Business_Segment__c from Package__c where id=:packageID];
        availableAPVList=[select id,Name,Marketing_Plan__c,Package__c,MDF_Program__c,Status__c,Business_Segment__c,Budgeted_Price__c from Associated_Programs_Vendors__c where
                         Marketing_Plan__c=:packagerec.Marketing_Plan__c AND Package__c=Null AND Associated_Programs_Vendors__c.MDF_Program__r.Preferred_Program__c=False AND Business_Segment__c=:packagerec.Business_Segment__c ];
        if(availableAPVList.size()<=0){
            noApv=False;    
        }
        
    }

    public boolean getIsApvavailable(){
        return noApv; 
    }
    

    public pageReference updatefields(){
        List <Associated_Programs_Vendors__c> upd_apvs=new List<Associated_Programs_Vendors__c>();
        PageReference currPageRef=new PageReference('/'+packageID);
        Associated_Programs_Vendors__c apvObj;
        
        List <Associated_Programs_Vendors__c> selectedAPVList=new List<Associated_Programs_Vendors__c>();
        
        for ( MPWrapper apv: ListofAvailableApvs){
            if(apv.selected==true){
                apvObj=new Associated_Programs_Vendors__c(id=apv.apvMpElt.Id);
                if(apv.apvMpElt.Budgeted_Price__c==null){
                    apvObj.Budgeted_Price__c=0.00;
                }
                apvObj.Package__c=packageID;
                upd_apvs.add(apvObj);
                if(apv.apvMpElt.Budgeted_Price__c!=null){
                    budgetprice=budgetprice+apv.apvMpElt.Budgeted_Price__c;
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
            packagerec.Package_Price_del__c=pkgprice+budgetprice;
            try {
                update upd_apvs;
                update packagerec;
            } catch (DmlException e){
                System.debug('While updating package record/APV '+e.getMessage());
            }
        }  

    return currPageRef;
    
    }

         //Wrapper class
    public class MPWrapper{
        public Associated_Programs_Vendors__c apvMpElt {get; set;}
        public Boolean selected {get; set;}

        //Constructor for wrapper class
        public MPWrapper(Associated_Programs_Vendors__c apvMpObj){
            apvMpElt = apvMpObj;
            selected = false;
        }
    } 


    public List<MPWrapper> getListofAvailableApvs(){
        MPWrapper mpWrapperElt;
        ListofAvailableApvs=new List<MPWrapper>();            
        
        for(Associated_Programs_Vendors__c apv:availableAPVList){                
            ListofAvailableApvs.add(new MPWrapper(apv));
        }
        System.debug('###AvailableAPVs'+ListofAvailableApvs); 
        return ListofAvailableApvs;
    }
        
    public void setListofAvailableApvs(List<MPWrapper> mpWrapperRecList){
        this.ListofAvailableApvs=mpWrapperRecList;
    }

}