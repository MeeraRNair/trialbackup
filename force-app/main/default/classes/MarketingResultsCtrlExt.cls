/**********************************************************************************************
History:
Version Date           Modified By     Description
--------------------------------------------------------------------------------------
1.0     05-Apr-2012    Krishnamoorthi  CR7042 & CR7043: For R13.4 Maintenance Project - Ala Carte and Volume Based Template Modification
2.0     11-Dec-2012    Sheeba          CR7734 - Viper - Marketing results only showing Programs with an APV contract status of signed
3.0     08-Aug-2017    Ismail          CR14754-VIPER: Update Marketing Results generation to include 100% "Not Executed" Marketing Plans
************************************************************************************************/
/*
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Saurabh     12-Apr-2013       14.5     8180  Viper - Marketing results showing Invoice MDF field as blank 
                                                         and sub-total and grand-total for Headcount plans  
*/
 

public class MarketingResultsCtrlExt{

    public List<Marketing_Plan__c> marketingPlanList = New List<Marketing_Plan__c>();
    List<MarketingPlanWrapperCls> marketingPlanIteratedList = new List<MarketingPlanWrapperCls>();
    Invoice__c curInvoice = new Invoice__c();
    String ID = ApexPages.currentPage().getParameters().get('id');
    public boolean nullMP {get; set;}
    public List<Marketing_Plan__c> marketingplnlst;
    public List<Marketing_Plan__c> updateList = new List<Marketing_Plan__c>();
    static set<id> MPIDset = new set<id>();
    Public Invoice__c InvoicePackage;
    Id invoiceId;
    List<Marketing_Plan__c> marketingPlanList1 = new List<Marketing_Plan__c>();
    List<Associated_Programs_Vendors__c> volumeBasedAPVPgmList = new List<Associated_Programs_Vendors__c>();
    Map<string,List<Associated_Programs_Vendors__c>>  volumeBasedAPVPgmMap = new Map<string,List<Associated_Programs_Vendors__c>>();
    List<VolumeBasedMP> volumeBasedMPList = new List<VolumeBasedMP>();
    Map<string,List<Associated_Programs_Vendors__c>>  alaCarteAPVPgmMap = new Map<string,List<Associated_Programs_Vendors__c>>();
    List<VolumeBasedMP> alaCarteMPList = new List<VolumeBasedMP>();
    Map<string,List<Associated_Programs_Vendors__c>>  headCountAPVPgmMap = new Map<string,List<Associated_Programs_Vendors__c>>();
    List<VolumeBasedMP> headCountMPList = new List<VolumeBasedMP>();

    List<Associated_Programs_Vendors__c> headCountAPVPgmList = new List<Associated_Programs_Vendors__c>();
    Public List<Associated_Programs_Vendors__c> alaCarteAPVPgmList = new List<Associated_Programs_Vendors__c>();
    MDF_Associated_Contact__c MDFAssociatedContact = new MDF_Associated_Contact__c();
    Double alaCarteBudgetedPrice = 0;
    Double alaCarteInvoiceAmnt = 0;
    Double headCountBudgetedPrice = 0;
    Double headCountInvoiceAmount = 0;
    PageReference wordDoc;
    Integer interval=0;
    Boolean generateBtn=false;
    Boolean attachBtn=false;

    public MarketingResultsCtrlExt(ApexPages.StandardController controller) {

        curInvoice = [select Vendor__c,Vendor__r.name,Fiscal_Quarter__c,Region__c,Contract_Type__c from Invoice__c where ID =:controller.getId()];

        marketingPlanList = new List<Marketing_Plan__c>();
        marketingPlanIteratedList = new List<MarketingPlanWrapperCls>();

        Set<String> invcnttypeset  = new Set<String>{'Volume Based', 'Ala Carte','Headcount','rebates'};

        if(curInvoice.Region__c != 'Global'){
        // Rev 3.0 - CR14754 Changes Start
        marketingPlanList = [Select Name,Contract_Status__c, Contract_Type__c, Fiscal_Quarter__c, Invoice_Amount__c, Purchase_Order__c, Rebate_Rule_Header__c, Region__c, Term__c, Vendor__c, Volume_Based_Rule_Header__c, Invoice__c
                                From Marketing_Plan__c
                                where
                                Contract_Status__c =: 'Signed' and
                                //Invoice_Amount__c != NULL and
                                Contract_Type__c in: invcnttypeset and
                                Vendor__c =: curInvoice.Vendor__c and
                                Fiscal_Quarter__c =: curInvoice.Fiscal_Quarter__c and
                                Id IN (select Marketing_Plan__c from Associated_Programs_Vendors__c where POP_Status__c = 'Executed' OR POP_Status__c = 'Not Executed') and
                                Region__c =: curInvoice.Region__c
                                ];
        }
        else{
        marketingPlanList = [Select Name,Contract_Status__c, Contract_Type__c, Fiscal_Quarter__c, Invoice_Amount__c, Purchase_Order__c, Rebate_Rule_Header__c, Region__c, Term__c, Vendor__c, Volume_Based_Rule_Header__c, Invoice__c
                                From Marketing_Plan__c
                                where
                                Contract_Status__c =: 'Signed' and
                                //Invoice_Amount__c != NULL and
                                Contract_Type__c in: invcnttypeset and
                                Vendor__c =: curInvoice.Vendor__c and
                                Fiscal_Quarter__c =: curInvoice.Fiscal_Quarter__c and
                                Id IN (select Marketing_Plan__c from Associated_Programs_Vendors__c where POP_Status__c = 'Executed' OR POP_Status__c = 'Not Executed')
                                ];
           // Rev 3.0 - CR14754 Changes End
        }
        system.debug('marketingPlanList' +marketingPlanList);

        for(Marketing_Plan__c mprcd : marketingPlanList){
            marketingPlanIteratedList.add(new MarketingPlanWrapperCls(mprcd));
        }
        nullMP = false;

        RecordType MDFContactRT=[Select Name, Id From RecordType where
                                    sObjectType='MDF_Contact__c' and name='Product Manager Contact' limit 1];

        try{
            MDFAssociatedContact = [Select Id,Name,MDF_Contact__r.Name,Vendor__c,MDF_Contact__r.phone__c
                                from MDF_Associated_Contact__c
                                where
                                Vendor__c =: curInvoice.Vendor__c
                                and MDF_Contact__r.Region__c =: curInvoice.Region__c
                                and MDF_Contact__r.recordTypeId =: MDFContactRT.Id
                                and MDF_Contact__r.Primary_Secondary__c = 'Primary'
                                ];
        } catch (QueryException e) {
            MDFAssociatedContact = null;
        }
        generateBtn=true;
        attachBtn=false;

    }

    public class MarketingPlanWrapperCls{
        public Marketing_Plan__c mpRecord{get;set;}
        public boolean selected{get;set;}
        public MarketingPlanWrapperCls(Marketing_Plan__c mprcd){
           mpRecord = mprcd;
           selected = false;
        }
    }

    public PageReference insertSelectedMarketingPlans() {
        updateList = New List<Marketing_Plan__c>();
         Map<String, List<Associated_Programs_Vendors__c>> contractTypeToAPVListMap= new Map<String, List<Associated_Programs_Vendors__c>> ();
        for(MarketingPlanWrapperCls selectedlist : marketingPlanIteratedList){
            if(selectedlist.selected==true){
                system.debug('inside selected List true');
                MPIDset.add(selectedlist.mpRecord.Id);
                
                selectedlist.mpRecord.Invoice__c = curInvoice.ID;
                updateList.add(selectedlist.mpRecord);
            }
        }
        system.debug('MPIDset' +MPIDset);
        update updateList;

        if(updateList.size() == 0){
            nullMP = true;
            return null;
        }
         //Rev 2.0 -- CR7734 Changes Start
         for(Associated_Programs_Vendors__c assoProgVendor : [SELECT Id,Name,Budgeted_Price__c,POP_Status__c,POP_Status_Reason__c,Invoice_Amount__c,
                            MDF_Program__c,Vendor__c,Business_Segment__c,Program_Notes__c,MDF_Program__r.Name,
                            MDF_Program__r.Program_Detail__c,MDF_Program__r.Business_Segment__c, Fiscal_Quarter_New__c,
                            Marketing_Plan__r.Contract_Type__c,
                            MDF_Program__r.Fiscal_Quarter__c,MDF_Program__r.Region__c,MDF_Program__r.Sub_Region__c
                            FROM Associated_Programs_Vendors__c
                            WHERE Marketing_Plan__c IN:MPIDset AND
                            Status__c = 'Signed'                               
                            //AND (POP_Status__c = 'Executed' OR POP_Status__c = 'Not Executed')
                            ORDER BY Region__c]){

            if(contractTypeToAPVListMap.get(assoProgVendor.Marketing_Plan__r.Contract_Type__c) == null){
                contractTypeToAPVListMap.put(assoProgVendor.Marketing_Plan__r.Contract_Type__c, new List<Associated_Programs_Vendors__c>{assoProgVendor});
            }else{
                contractTypeToAPVListMap.get(assoProgVendor.Marketing_Plan__r.Contract_Type__c).add(assoProgVendor);
            }
        }
         system.debug('contractTypeToAPVListMap' +contractTypeToAPVListMap);
        //Rev 2.0 -- CR7734 Changes End
        
        volumeBasedAPVPgmList = contractTypeToAPVListMap.get('Volume Based');
        //Rev 1.0 -- CR 7043 Changes Start
            if (volumeBasedAPVPgmList != null) {
                for(Associated_Programs_Vendors__c vend : volumeBasedAPVPgmList ){
                    string header = '';
                    if(vend.MDF_Program__r.Region__c == 'Global'){
                        header = vend.MDF_Program__r.Region__c+' - ' +vend.MDF_Program__r.Business_Segment__c;
                    }
                    else{
                        header = vend.MDF_Program__r.Region__c+' - '+vend.MDF_Program__r.Sub_Region__c+ '- '+vend.MDF_Program__r.Business_Segment__c;
                    }
                    if(volumeBasedAPVPgmMap.get(header) == null)
                        volumeBasedAPVPgmMap.put(header, null);
        
                    if(volumeBasedAPVPgmMap.get(header) == null){
                        List<Associated_Programs_Vendors__c> tmpList = new List<Associated_Programs_Vendors__c>();
                        tmpList.add(vend);
                        volumeBasedAPVPgmMap.put(header,tmpList);
                    } else {
                        List<Associated_Programs_Vendors__c> tmpList = volumeBasedAPVPgmMap.get(header);
                        tmpList.add(vend);
                        volumeBasedAPVPgmMap.put(header,tmpList);
                    }
    
    
            }
        }

        for (String header : volumeBasedAPVPgmMap.keySet()){
             volumeBasedMPList.add(new VolumeBasedMP(header , volumeBasedAPVPgmMap.get(header)));
        }

       //Rev 1.0 -- CR 7043 Changes End
        
        alaCarteAPVPgmList = contractTypeToAPVListMap.get('Ala Carte');
        
        //Rev 1.0 -- CR 7042 Changes Start
            if (alaCarteAPVPgmList != null) {
                for(Associated_Programs_Vendors__c alavend : alaCarteAPVPgmList){
                    string alaheader = '';
                    if(alavend.MDF_Program__r.Region__c == 'Global'){
                        alaheader = alavend.MDF_Program__r.Region__c+' - '+alavend.MDF_Program__r.Business_Segment__c;
                    }
                    else{
                        alaheader = alavend.MDF_Program__r.Region__c+' - ' +alavend.MDF_Program__r.Sub_Region__c+' - '+alavend.MDF_Program__r.Business_Segment__c;
                    }
                    if(alaCarteAPVPgmMap.get(alaheader) == null)
                        alaCarteAPVPgmMap.put(alaheader, null);
        
                    if(alaCarteAPVPgmMap.get(alaheader) == null){
                        List<Associated_Programs_Vendors__c> alatmpList = new List<Associated_Programs_Vendors__c>();
                        alatmpList.add(alavend);
                        alaCarteAPVPgmMap.put(alaheader,alatmpList);
                    } else {
                        List<Associated_Programs_Vendors__c> alatmpList = alaCarteAPVPgmMap.get(alaheader);
                        alatmpList.add(alavend);
                        alaCarteAPVPgmMap.put(alaheader,alatmpList);
                    }
    
    
            }
        }

          for (String alaheader : alaCarteAPVPgmMap.keySet()){
                alaCarteMPList.add(new VolumeBasedMP(alaheader , alaCarteAPVPgmMap.get(alaheader)));
        }
        System.Debug('alaCarteMPList###'+alaCarteMPList);

        //Rev 1.0 -- CR 7042 Changes End

        
        headCountAPVPgmList = contractTypeToAPVListMap.get('Headcount');
        string HCount = '';
         if (headCountAPVPgmList != null) {
            for(Associated_Programs_Vendors__c headCount : headCountAPVPgmList){
                if(headCount.MDF_Program__r.Region__c == 'Global'){
                    HCount = headCount.MDF_Program__r.Region__c+' - '+headCount.MDF_Program__r.Business_Segment__c;
                }
                else{
                    HCount = headCount.MDF_Program__r.Region__c+' - '+headCount.MDF_Program__r.Sub_Region__c+' - '+headCount.MDF_Program__r.Business_Segment__c;
                }
                  if(headCount.Fiscal_Quarter_New__c == curInvoice.Fiscal_Quarter__c){
                    if(headCountAPVPgmMap.get(HCount) == null)
                        headCountAPVPgmMap.put(HCount, null);
        
                    if(headCountAPVPgmMap.get(HCount) == null){
                        List<Associated_Programs_Vendors__c> HCtmpList = new List<Associated_Programs_Vendors__c>();
                        HCtmpList.add(headCount);
                        headCountAPVPgmMap.put(HCount,HCtmpList);
                    } else {
                        List<Associated_Programs_Vendors__c> HCtmpList = headCountAPVPgmMap.get(HCount);
                        HCtmpList.add(headCount);
                        headCountAPVPgmMap.put(HCount,HCtmpList);
                    }
                }
          }
    
        }
        for (String HC : headCountAPVPgmMap.keySet()){
                headCountMPList.add(new VolumeBasedMP(HC , headCountAPVPgmMap.get(HC)));
        }
        
        
        try{
            for(Associated_Programs_Vendors__c iterateAlaCarteAPVPgmList : alaCarteAPVPgmList){
                if(iterateAlaCarteAPVPgmList.Budgeted_Price__c != null){
                    alaCarteBudgetedPrice = alaCarteBudgetedPrice + iterateAlaCarteAPVPgmList.Budgeted_Price__c;
                }
            }
        }catch(NullPointerException e){
            alaCarteBudgetedPrice = null;
        }
        //Rev 1.0 -- Changes Start
        try{
            for(Associated_Programs_Vendors__c iterateAlaCarteAPVPgmInvList : alaCarteAPVPgmList){
                if(iterateAlaCarteAPVPgmInvList.Invoice_Amount__c != null && ((iterateAlaCarteAPVPgmInvList.POP_Status__c == 'Executed' && iterateAlaCarteAPVPgmInvList.POP_Status_Reason__c != 'Vendor Dissatisfied with Program') || (iterateAlaCarteAPVPgmInvList.POP_Status__c == 'Not Executed' && iterateAlaCarteAPVPgmInvList.POP_Status_Reason__c == 'Vendor Absent – Charge'))){
                    alaCarteInvoiceAmnt  = alaCarteInvoiceAmnt  + iterateAlaCarteAPVPgmInvList.Invoice_Amount__c;                    
                }
            }
        }catch(NullPointerException e){
            alaCarteInvoiceAmnt = null;
        }
        //Rev 1.0 -- Changes End
        
        //Modified  for CR 8180,BR 019 in Release 14.5
        
        /*try{
            for(Associated_Programs_Vendors__c iterateHeadCountAPVPgmList : headCountAPVPgmList){
                if(iterateHeadCountAPVPgmList.Budgeted_Price__c != null){
                    headCountBudgetedPrice = headCountBudgetedPrice + iterateHeadCountAPVPgmList.Budgeted_Price__c;
                }
            }
        }catch(NullPointerException e){
            headCountBudgetedPrice = null;
        }*/
        
       
        
     
      
      system.debug('headCountAPVPgmList ' +headCountAPVPgmList );
      //apply null pointer check by mayank : 12/06/2013 for CR 8180
      if(headCountAPVPgmList!=Null && headCountAPVPgmList.Size()>0)
      {
           for(Associated_Programs_Vendors__c iterateHeadCountAPVPgmList : headCountAPVPgmList){
            if(iterateHeadCountAPVPgmList.Fiscal_Quarter_New__c == curInvoice.Fiscal_Quarter__c){
            
            system.debug('iterateHeadCountAPVPgmList ' +iterateHeadCountAPVPgmList );
            
            try{
               if(iterateHeadCountAPVPgmList.Budgeted_Price__c != null){
                        headCountBudgetedPrice = headCountBudgetedPrice + iterateHeadCountAPVPgmList.Budgeted_Price__c;
                    }
                }
                catch(NullPointerException e){
                headCountBudgetedPrice = null;
                }
            try{
    
                    if(iterateHeadCountAPVPgmList.Invoice_Amount__c != null && ((iterateHeadCountAPVPgmList.POP_Status__c == 'Executed' && iterateHeadCountAPVPgmList.POP_Status_Reason__c != 'Vendor Dissatisfied with Program') || (iterateHeadCountAPVPgmList.POP_Status__c == 'Not Executed' && iterateHeadCountAPVPgmList.POP_Status_Reason__c == 'Vendor Absent – Charge'))){
                        headCountInvoiceAmount = headCountInvoiceAmount + iterateHeadCountAPVPgmList.Invoice_Amount__c;
                    }
                }
              
                catch(NullPointerException e){
                headCountInvoiceAmount = null;
                }
              } 
           }
     }  
                
        
        // End CR 8180,BR 019 in Release 14.5
        generateBtn=false;
        attachBtn=true;

        return null;
    
    
    }
    public PageReference insertAttachment() {

        PageReference wordDoc =new PageReference('/apex/MarketingResultsTemplate?id='+curInvoice.ID);

        wordDoc.getParameters().put('id',curInvoice.ID);

        Attachment attach = new Attachment();

        Blob body;

        try {
            body = wordDoc.getContent();
        } catch (VisualforceException e) {
            body = Blob.valueOf('VisualForceException occured while creating the word document');
        }

        attach.Body = body;
        attach.Name = 'Marketing Results'+'.doc';
        attach.IsPrivate = false;
        attach.ParentId = curInvoice.ID;
        insert attach;

        return new PageReference('/'+curInvoice.ID);
    }

    public List<MarketingPlanWrapperCls> getmarketingPlanIteratedList() {
        return marketingPlanIteratedList;
    }
    
    
    
     public  void setmarketingPlanIteratedList(List<MarketingPlanWrapperCls> mPlanList) {
        this.marketingPlanIteratedList=mPlanList;
    }
    public set<id> getMPIDset(){
        return MPIDset;
    }
     public Invoice__c getInvoicePackage() {
         InvoicePackage=curInvoice;
        return InvoicePackage;
    }

    public List<Marketing_Plan__c> getmarketingPlanList() {
        for(MarketingPlanWrapperCls selectedlist : marketingPlanIteratedList){
            if(selectedlist.selected==true){
                marketingPlanList.add(selectedlist.mpRecord);
            }
        }
        return marketingPlanList;
    }

    public MDF_Associated_Contact__c getMDFAssociatedContact(){
        return MDFAssociatedContact;
    }

    public List<Associated_Programs_Vendors__c> getvolumeBasedAPVPgmList () {
        return volumeBasedAPVPgmList;
    }

       public List<Associated_Programs_Vendors__c> getheadCountAPVPgmList () {
        return headCountAPVPgmList;
    }
    public List<Associated_Programs_Vendors__c> getalaCarteAPVPgmList () {
        return alaCarteAPVPgmList;
    }
    public Double getalaCarteBudgetedPrice (){
        return alaCarteBudgetedPrice;
    }
    //Rev 1.0 -- Changes Start
    public Double getalaCarteInvoiceAmnt (){
        return alaCarteInvoiceAmnt;
    }
     public List<VolumeBasedMP> getVolumeBasedMPList(){
        return  volumeBasedMPList;
    }
    
    public List<VolumeBasedMP> getalaCarteMPList(){
        return  alaCarteMPList;
    }
    
    public List<VolumeBasedMP> getheadCountMPList(){
        return  headCountMPList;
    }

    //Rev 1.0 -- Changes End
    
    public Double getheadCountInvoiceAmount  (){
        return  headCountInvoiceAmount ;
    }


    public Double getheadCountBudgetedPrice (){
        return headCountBudgetedPrice;
    }
    public Boolean getGenerateBtn(){
        return generateBtn;
    }
    public Boolean getAttachBtn(){
        return attachBtn;
    }

}