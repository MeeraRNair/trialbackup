public class VFCntrlr_AddWishListPage {
    public MDF_Program__c myPGM{get;set;}
    public boolean noprogram {get;set;}
    public boolean programsrendered {get;set;}    
    public List<MDF_Program__c> availableprograms{get;set;}
    public List<ProgramWrapper> availableprogramsList{get;set;}
    public String recordId;
    public VFCntrlr_AddWishListPage(ApexPages.StandardController controller) {
        this.myPGM= (MDF_Program__c)controller.getRecord();  
        programsrendered = false;
        noprogram = false;
        recordId=ApexPages.currentPage().getParameters().get('FC');
    }
    
    public PageReference findPrograms(){ 
        Set <Id> existingpgmIdSet = new Set <Id> ();
        for(MDF_Program_Wish_List__c wl:[Select Id,MDF_Program__c,MDF_Forecast__c from MDF_Program_Wish_List__c where MDF_Forecast__c=:recordId]){
            system.debug('hiiiiiii--->'+wl);
            existingpgmIdSet.add(wl.MDF_Program__c);
        }
        availableprograms = [Select Id,Name,Region__c,Sub_Region__c,Fiscal_Quarter__C from MDF_Program__c where Region__c=:myPGM.Region__c and Sub_Region__c=:myPGM.Sub_Region__c and Country__c=:myPGM.Country__c and Business_Segment__c=:myPGM.Business_Segment__c and Fiscal_Quarter__c=:myPGM.Fiscal_Quarter__c and Program_Status__c='Approved' and Id NOT IN :existingpgmIdSet];
        //String recordId=ApexPages.currentPage().getParameters().get('FC');
        if(availableprograms.size()>0){
            programsrendered=true;
            noprogram = false;
            availableprogramsList = new List<ProgramWrapper>();
        for(MDF_Program__c pgm:availableprograms){
            
            availableprogramsList.add(new ProgramWrapper(pgm));
        }
        }
        else{ 
        noprogram = true;
        programsrendered=false;
        }
        
        return null;
    }
    
     public class ProgramWrapper{
        public MDF_Program__c apvMpElt {get; set;}
        public Boolean selected {get; set;}

        //Constructor for wrapper class
        public ProgramWrapper(MDF_Program__c apvMpObj){
            apvMpElt = apvMpObj;
            selected = false;
        }
    } 
    
    public pageReference saveWishList(){
        //String recordId=ApexPages.currentPage().getParameters().get('FC');
        List <MDF_Program_Wish_List__c> mdfWishList =  new List <MDF_Program_Wish_List__c>();
        MDF_Program_Wish_List__c wishlistrec;
        for(ProgramWrapper pgmW:availableprogramsList){
            if(pgmW.selected==true){
                wishlistrec = new MDF_Program_Wish_List__c(MDF_Forecast__c=recordId,MDF_Program__c=pgmW.apvMpElt.Id);
                mdfWishList.add(wishlistrec);
            }
        }
        insert mdfWishList;
        String urlString = '/'+recordId;
        return new PageReference(urlString);
    }   

}