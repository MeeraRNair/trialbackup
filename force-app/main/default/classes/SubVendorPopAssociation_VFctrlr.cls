/*
REVISION HISTORY
================
Version     Author        Date            Release#    	CR#     	Description
-------     ------        ----            --------    	---     	-----------
1.0                                                           		Initial draft
2.0      Krishnamoorthi  04-Dec-2012        14.2      	7732    	R14.2 Maintenance - Viper - Add POP Status to the POPV review Approval screen
3.0      Kishore         26-Sept-2018       FY19-1101   16597      	Giving access to "MDF Co-Marketing Manager" for associating vendor
3.1		 Shue			 05-Oct-2018		FY19-1101	16597		Fix violation pmd tool post scan
*/
public class SubVendorPopAssociation_VFctrlr {
    
    ID popID;
    Proof_of_Performance_POP__c popRec{get; set;}
    List<Associated_Programs_Vendors__c> assSubVendorList=new List<Associated_Programs_Vendors__c>(); 
    List <POP_Line_Item__c> popLineItemList=new List <POP_Line_Item__c>(); 
    //Wrapper Classes
    List<ASVWrapper> listofAvailableVendors{get; set;}	//3.1
    List<ASVWrapper> selectedListofAvailableVendors=new List<ASVWrapper>();
    set <ID> subVendorIDSet=new set <ID>();
    
    Boolean isSubVendor=true;	//3.1
    Boolean accessAvilable=True;
    ID userid;
    String profilename;
    //constructor
    public SubvendorPopAssociation_VFctrlr (ApexPages.StandardController controller) {
        popID=controller.getId();
        userid=userinfo.getUserId(); 
		
		//Profile check
        User userRec=[select id,profile.name from User where id=:userid];
        profilename=userRec.profile.name;
        system.debug('Profile'+profilename);
        if (profilename.contains('Marketing Operations')||profilename.contains('System Administrator')||profilename.contains('Contract Admin')||
                                                            profilename.contains('Program Owner')|| profilename.contains('MDF Product Managers')|| profilename.contains('MDF Co-Marketing  Manager')){ //3.0-Added 'MDF Co-Marketing  Manager' profile
            accessAvilable=False;    
        }

		//Associate Vendor process    
        popRec=[select id,Name,MDF_Program__c from Proof_of_Performance_POP__c where id=:popID];
        
        for (POP_Line_Item__c pop :[select Proof_of_Performance_POP__c,Vendor__c,Name from POP_Line_Item__c 
                                    where Proof_of_Performance_POP__c=:popID]){
            subVendorIDSet.add(pop.Vendor__c);                           
        } 
        for(Associated_Programs_Vendors__c asv:[select id,Name,MDF_Program__c,Status__c,Vendor__c,Vendor__r.name,POP_Status__c
                                                from Associated_Programs_Vendors__c where MDF_Program__c=:popRec.MDF_Program__c AND Status__c !='Declined']){
            if(!subVendorIDSet.contains(asv.Vendor__c)){            
                assSubVendorList.add(asv);
            } 
        }
        
        if(assSubVendorList.size()<=0){
            isSubVendor=False;    
        } 
    }

    public boolean getIsSubVendorAvailable(){
        return isSubVendor; 
    }
    
    public boolean getIsAccessAvilable(){
        return accessAvilable; 
    }
     
    public pagereference addSubVendor() {
        PageReference pageRef=new PageReference('/'+popID);	//3.1
        List <POP_Line_Item__c> insPopLineItemList=new List <POP_Line_Item__c>();	//3.1
        POP_Line_Item__c newPop;
        for ( ASVWrapper asv: listofAvailableVendors){
            if(asv.selected==true){
                //Rev2.0 -- Added POP_Status__c field
                newPop=new POP_Line_Item__c(Proof_of_Performance_POP__c=popID,Vendor__c=asv.asvpopElt.Vendor__c,POP_Status__c=asv.asvpopElt.POP_Status__c);
                insPopLineItemList.add(newPop);
            }
        }  
        if(insPopLineItemList.size()==0){
            ApexPages.Message msg;     
            msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select atleast one APV.');
            ApexPages.addMessage(msg);            
            return null;               
        }                   
        try{
            insert insPopLineItemList; 
        }catch(DmlException e){
            System.debug('##New pop line item##'+insPopLineItemList);
            System.debug('While Inserting POP line item'+e.getMessage());
        }            
    return pageRef;
    
    }
   
    //Wrapper class
    public class ASVWrapper{
        public Associated_Programs_Vendors__c asvpopElt {get; set;}
        public Boolean selected {get; set;}

        //Constructor for wrapper class
        public ASVWrapper(Associated_Programs_Vendors__c asvpopObj){
            asvpopElt = asvpopObj;
            selected = false;
        }
    } 
        
    public List<ASVWrapper> getListofAvailableVendors(){
        ASVWrapper asvWrapperElt;	//3.1
        listofAvailableVendors=new List<ASVWrapper>();            
        
        for(Associated_Programs_Vendors__c asv:assSubVendorList){          
            listofAvailableVendors.add(new ASVWrapper(asv));
        }
        System.debug('###listofAvailableVendors'+listofAvailableVendors); 
        return listofAvailableVendors;
    }
        
    public void setListofAvailableVendors(List<ASVWrapper> asvWrapperRecList){
        this.listofAvailableVendors=asvWrapperRecList;
    }
    
    //Rev 2.0 -- changes start
    public static void updatePOPLineItem(List<String> apvIdList){
        
        List<Associated_Programs_Vendors__c> popApvList = new List<Associated_Programs_Vendors__c>();
        List<POP_Line_Item__c> popLIList = new List<POP_Line_Item__c>();
        List<POP_Line_Item__c> popLIupdList = new List<POP_Line_Item__c>();
        List<String> mdfPrograms = new List<String>();
        List<String> vendors = new List<String>();
        Map<String, String> prgrmvendorMap = new Map<String, String>();
        
        for(Associated_Programs_Vendors__c popApv : [select Name,MDF_Program__r.Name,Status__c,Vendor__c,Vendor__r.name,POP_Status__c
                                                from Associated_Programs_Vendors__c where Id IN : apvIdList])  {
                  
           mdfPrograms.add(popApv.MDF_Program__r.Name);
           vendors.add(popApv.Vendor__c);
           prgrmvendorMap.put(popApv.MDF_Program__r.Name+':'+popApv.Vendor__c, popApv.POP_Status__c);
        }
        
        popLIList = [select POP_Status__c,Vendor__c,Program__c from POP_Line_Item__c where Program__c IN : mdfPrograms AND Vendor__c IN :vendors];
        
        if(!popLIList.isEmpty()){
            for(POP_Line_Item__c popli : popLIList){
                popli.POP_Status__c = prgrmvendorMap.get(popli.Program__c+':'+popli.Vendor__c);
                popLIupdList.add(popli);
            }
        }    
        
        if(!popLIupdList.isEmpty()){
            update popLIupdList;
        }
                
    }
    //Rev 2.0 -- changes End
    
}