public class ViperProgramManagement{
        
        Boolean pendingErrorMsgBol=false;
        Boolean displaySubVendorListBol=false;
        Boolean displaySelectedSubVendorList=false;
        Boolean authErrorMsgBol=false;
        Boolean variablePgm=false;
        Boolean programOwner=false;
        Id currentUserId;
        String mdfPgm2BDeletedId;
        String mdfPgmId;
        Id[] idArr = new Id[]{};
        MDF_Program__c mdfProgram=new MDF_Program__c();
        Marketing_Plan__c marketingPlan;
        Map<Id,vendor__c> subVendorMap=new Map<Id,vendor__c>();        
        List<removeSubVendorWrapper> listOfSubVendorRecords=new List<removeSubVendorWrapper>();
        List<removeSubVendorWrapper> wrapperRecs=new List<removeSubVendorWrapper>();
        List<Vendor__c> subVendorList=new List<Vendor__c>();
        List<Associated_Programs_Vendors__c> associatedPgmVendorList=new List<Associated_Programs_Vendors__c>();        
        List<APVWrapper> listOfAPVWrapperRecs=new List<APVWrapper>();
        List<APVWrapper> APVWrapperRecs=new List<APVWrapper>();
        List<APVWrapper> apvShowList=new List<APVWrapper>(); 
        Headcount__c HC = new Headcount__c();
        //List<Profile> userProfile;  
        //Def 72000
        Boolean noDeleteApv=False;
        Boolean listapv=True;
        Boolean DelApvAuth=False;
        //Def 72000
        
        //Wrapper class 1
        public class removeSubVendorWrapper{
            public Associated_Programs_Vendors__c apvElt {get;set;}
            public Vendor__c subVendorElt {get;set;}
            public Boolean selected {get;set;}
            //Constructor for wrapper class
            public removeSubVendorWrapper(Associated_Programs_Vendors__c apvObj,Vendor__c subVendorObj){
                apvElt = apvObj;
                subVendorElt = subVendorObj;
                selected = false;
            }
        }
        
        public class APVWrapper{
            public Associated_Programs_Vendors__c apvElt{get;set;}            
            public Boolean selected {get;set;}
            //Constructor for wrapper class
            public APVWrapper(Associated_Programs_Vendors__c apvObj){
                apvElt = apvObj;                
                selected = false;
            }
        }
     
                
       
        //CONSTRUCTOR  

        public ViperProgramManagement(){
            try{
                String currentURL=ApexPages.currentPage().getUrl();
                currentUserId=UserInfo.getUserId();
                Associated_Programs_Vendors__c apvObj;
                List<Profile> userProfile;
                Id mdf_program_id=ApexPages.currentPage().getParameters().get('id');
                
                mdfProgram=[select Name,Id,Program_Owner__c,POP_Owner__c,Program_Status__c,HCID__c,HCID__r.Manager_s_Name__r.Name,HCID__r.Employee_Name__c,Business_Segment__c,fiscal_quarter__c,OwnerId,Rate_Card_Price__c,Pricing_Type__c,Program_Type__c, RecordType.Name from 
                            MDF_Program__c where id=:mdf_program_id];
                userProfile=[select Name from profile where id = :userinfo.getProfileId()]; 
                                
                if(currentURL.contains('AutoApproveProgram')){
                    mdfPgmId=mdf_program_id;
                    
                    /* mdfProgram=[select Id,Program_Status__c,Program_Owner__c,Business_Segment__c,OwnerId,
                    Rate_Card_Price__c,Pricing_Type__c from MDF_Program__c where id=:mdfPgmId];*/
                                 
                }            
                if(currentURL.contains('DeleteMDFProgram')){
                    mdfPgm2BDeletedId=mdf_program_id;
                    /* mdfProgram=[select Id,Program_Status__c,OwnerId,Rate_Card_Price__c,Pricing_Type__c from 
                    MDF_Program__c where id=:mdfPgm2BDeletedId]; */
                }            
                if(currentURL.contains('ProgramVendorAssociation')){
                    
                    String mdfProgramId=mdf_program_id;
                    Set<Id> subVendorIdSet=new Set<Id>();
                    String adminMgr='XXX'; 
                    
                    if(userinfo.getUserId()==mdfProgram.Program_Owner__c||userinfo.getUserId()==mdfProgram.POP_Owner__c|| userProfile[0].name=='System Administrator'||userProfile[0].name.contains('MDF Co-Marketing')||userProfile[0].name=='MDF Marketing Operations / Contract Admin'){
                        adminMgr='no';
                    }else if(userProfile[0].name=='MDF Finance Users'||userProfile[0].name=='MDF Product Managers'){
                        adminMgr='yes';
                    }else{
                        adminMgr='yes';
                    }
                    /*
                    for(Profile profileElt:userProfile){
                        if(profileElt!=null && (profileElt.name.contains('MDF Reporting Admin')||profileElt.name.contains('MDF Product Managers'))){
                            adminMgr='yes';
                        }
                    }
                    
                    mdfProgram=[select Name,Id,Program_Owner__c,POP_Owner__c,Program_Status__c,Business_Segment__c,fiscal_quarter__c,OwnerId,Rate_Card_Price__c,Pricing_Type__c,Program_Type__c from 
                    MDF_Program__c where id=:mdfProgramId];*/
                    
                    for(Associated_Programs_Vendors__c apvListElt:[select id,name,vendor__c,MDF_Program__c
                        from Associated_Programs_Vendors__c where MDF_Program__c=:mdfProgram.id]){                    
                        subVendorIdSet.add(apvListElt.vendor__c);                    
                    }
                    
                    if(mdfProgram.Program_Status__c=='Approved' && adminMgr=='no'){
                        RecordType apvRT=[Select Name, Id From RecordType where  sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association' limit 1];
                           
                        for(Vendor__c subVendorElt:[select Id,Is_this_a_Parent_Vendor__c,Budgeted_Discount__c,Name,Partner_Status__c,Parent_Vendor__c,Partner_Type__c  from Vendor__c  where Is_this_a_Parent_Vendor__c=false and Partner_Status__c='Active'  and id not in:subVendorIdSet order by Name ASC]){            
                                
                                subVendorMap.put(subVendorElt.Id,subVendorElt);
                                
                                apvObj=new Associated_Programs_Vendors__c(
                                    Vendor__c=subVendorElt.Id,
                                    MDF_Program__c=mdfProgram.Id,
                                    recordtypeId=apvRT.Id,
                                    Status__c='Pending',
                                    Rate_Card_Price__c=mdfProgram.Rate_Card_Price__c,
                                    Headcount__c=mdfProgram.HCID__c,
                                    Manager_Name__c=mdfProgram.HCID__r.Manager_s_Name__r.Name,                                    
                                    Employee_Name__c=mdfProgram.HCID__r.Employee_Name__c
                                );
                                if((mdfProgram.Pricing_Type__c=='Variable' && mdfProgram.Rate_Card_Price__c!=null)||(mdfProgram.Pricing_Type__c=='Non-Variable' && subVendorElt.Budgeted_Discount__c==null && mdfProgram.Rate_Card_Price__c!=null)){
                                    apvObj.Budgeted_Price__c=mdfProgram.Rate_Card_Price__c;
                                }
                                if(mdfProgram.Pricing_Type__c=='Non-Variable' && mdfProgram.Rate_Card_Price__c!=null && subVendorElt.Budgeted_Discount__c!=null){                                
                                     apvObj.Budgeted_Price__c=mdfProgram.Rate_Card_Price__c*((100 -subVendorElt.Budgeted_Discount__c)/100);                                
                                }
                                associatedPgmVendorList.add(apvObj); 
                                listOfSubVendorRecords.add(new removeSubVendorWrapper(apvObj,subVendorElt));
                                wrapperRecs.add(new removeSubVendorWrapper(apvObj,subVendorElt));                           
                                
                            }
                            displaySubVendorListBol=true;
                            pendingErrorMsgBol=false;
                            displaySelectedSubVendorList=true;
                            authErrorMsgBol=false; 
                    }
                    
                    //displaySelectedSubVendorList=true;
                    
                    if(mdfProgram.Program_Status__c!='Approved'){
                        pendingErrorMsgBol=true; 
                        displaySubVendorListBol=false;
                        displaySelectedSubVendorList=false;
                        authErrorMsgBol=false;                   
                    }  
                    if(adminMgr=='yes'){
                        authErrorMsgBol=true;
                        pendingErrorMsgBol=false; 
                        displaySubVendorListBol=false;
                        displaySelectedSubVendorList=false;                   
                    }
                    if(mdfProgram.Pricing_Type__c!='Variable'){
                        variablePgm=true;
                    }
                    // Story 3603803:VIPER: Grant Product Manager to edit Budgeted Price Variable
                    Set<String> invalidRTNames = new Set<String>{'Field Event', 'Seed Units', 'Web'};
                    Id userProfileId = userinfo.getProfileId();
                    String userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId].Name;
                    if(userProfileName == 'MDF Product Managers' && invalidRTNames.contains(mdfProgram.RecordType.Name)) {
                        variablePgm=true;
                    }
                    // Story 3603803:VIPER: Grant Product Manager to edit Budgeted Price Variable
                    if(currentUserId==mdfProgram.program_owner__c){
                        programOwner=true;
                    }    
                }
                
                
                if(currentURL.contains('DeleteAPVFromMDFProgram')){
                    mdfPgmId=mdf_program_id;             
                                    
                    for(Associated_Programs_Vendors__c apvListElt:[select id,name,vendor__c,MDF_Program__c,Budgeted_Price__c,
                    Rate_Card_Price__c,Marketing_Plan__c from Associated_Programs_Vendors__c where MDF_Program__c=:mdfPgmId AND status__c='Pending']){                    
                            listOfAPVWrapperRecs.add(new APVWrapper(apvListElt));                    
                    }
                    //Def Fix 72000
                    if(userinfo.getUserId()!=mdfProgram.Program_Owner__c && userinfo.getUserId()!=mdfProgram.POP_Owner__c && userProfile[0].name !='System Administrator' &&
                                !(userProfile[0].Name.contains('MDF Marketing Operations / Contract Admin')) &&  !(userProfile[0].Name.contains('MDF Co-Marketing  Manager')) ){
                        noDeleteApv= True;
                        listapv=False;
                        DelApvAuth=False;
                    }   

                    if(userProfile.size()>0 && (userProfile[0].name.contains('MDF Dell Management Executive')|| userProfile[0].name.contains('MDF Finance Users'))){
                        DelApvAuth= True;
                        listapv=False;
                        noDeleteApv=False;
                    }
                    //Def Fix 72000                      
                }
                if(currentURL.contains('DeleteAPVFromMarketingPlan')){
                    String marketingPlanId=ApexPages.currentPage().getParameters().get('MPlanId');             
                                    
                    for(Associated_Programs_Vendors__c apvListElt:[select id,name,vendor__c,MDF_Program__c,Budgeted_Price__c,Rate_Card_Price__c,Invoice_Amount__c,
                            Contract_Status_Reason__c,LE__c,PUB__c,SMB__c,CSMR__c,Package__c,Accounting_Treatment__c,POP_Status__c,
                            POP_Status_Reason__c,Marketing_Plan__c from Associated_Programs_Vendors__c where Marketing_Plan__c=:marketingPlanId AND status__c='Pending']){                    
                            listOfAPVWrapperRecs.add(new APVWrapper(apvListElt));                    
                    }
                }
               
                if(currentURL.contains('updateAllAPV')){
                    mdfPgmId=mdf_program_id;
                    /* mdfProgram=[select Name,Id,Business_Segment__c,fiscal_quarter__c,Program_Type__c,Program_Status__c,OwnerId,Rate_Card_Price__c,Pricing_Type__c,program_owner__c 
                                from MDF_Program__c where id=:mdfPgmId]; */
                    if(mdfProgram.Pricing_Type__c!='Variable'){
                        System.debug('Not eligible for mass update of budgeted price');
                    } 
                    if(mdfProgram.Pricing_Type__c=='Variable'){
                        variablePgm=false;
                       for(Associated_Programs_Vendors__c apvElt:[select id,name,
                           vendor__c,Vendor__r.Name, MDF_Program__c,Rate_Card_Price__c,budgeted_price__c
                           from Associated_Programs_Vendors__c where MDF_Program__c=:mdfProgram.id 
                           and marketing_Plan__c=null]){                    
                            apvShowList.add(new APVWrapper(apvElt));                    
                        }
                    }                    
                    if(mdfProgram.Pricing_Type__c!='Variable'){
                        variablePgm=true;
                    }
                     if((currentUserId==mdfProgram.program_owner__c || userProfile[0].name=='System Administrator')&& mdfProgram.Pricing_Type__c=='Variable'){
                        programOwner=true;
                    }                       
                }
             //System.debug('###VPM mdfProgram.Pricing_Type__c'+mdfProgram.Pricing_Type__c);   
             //System.debug('###VPM variablePgm'+variablePgm);   
            }Catch(Exception e){
                System.debug('###VPM exception'+e);
            }
            
            
       }

        //.............. ASSOCIATE PROGRAM VENDOR........................
        
        public Boolean getPendingErrorMsg(){
            return pendingErrorMsgBol;   
        }
        public Boolean getAuthErrorMsg(){
            return authErrorMsgBol;   
        } 

        public Boolean getDisplaySubVendorList(){
            return displaySubVendorListBol;   
        }

        //DELETE MDF PROGRAMS
        public PageReference deleteProgram(){
            PageReference pageRef=new PageReference('/a1R/o'); 
            PageReference currentPageRef=new PageReference('/'+mdfProgram.Id); 
            if(mdfProgram.Program_Status__c=='Pending'
                && UserInfo.getUserId()==mdfProgram.OwnerId){
                delete mdfProgram;
                return pageRef;
            }else
            return currentPageRef;
        }
        
        public Boolean getDisplaySelectedSubVendors(){
            return displaySelectedSubVendorList;
        }

        public List<removeSubVendorWrapper> getAssociatedProgramsVendorsList(){         
            return listOfSubVendorRecords;
        }
        
        public void setAssociatedProgramsVendorsList(List<removeSubVendorWrapper> wList){            
            this.listOfSubVendorRecords=wList;
        }



        
        public PageReference insertProgramVendorAssociation(){
            Database.SaveResult[] insertResult;
            String errors;
            PageReference currentPageRef=new PageReference('/'+mdfProgram.Id);
            List<Associated_Programs_Vendors__c> apvInsertList=new List<Associated_Programs_Vendors__c>(); 
            for(removeSubVendorWrapper rsvw:listOfSubVendorRecords){
                if(rsvw.selected==true){
                    apvInsertList.add(rsvW.apvElt);
                }
                        
            }
          
            if(associatedPgmVendorList.size()>0){
                try{                   
                   insertResult= Database.insert(apvInsertList,false);
                }catch(exception e){
                }
            
            
            }
            return currentPageRef;    
        }

        public Pagereference sortByAlphabet(){
            try{
                //String currentURL=ApexPages.currentPage().getUrl();
                //Pagereference pageRef=new Pagereference(currentURL);
                
                String selection=ApexPages.currentPage().getParameters().get('selected');
                String lbl;  
                //System.debug('###selection'+selection);          
                listOfSubVendorRecords=new List<removeSubVendorWrapper>();            
                if(selection!='All'){
                    for(removeSubVendorWrapper rsvw:wrapperRecs){
                        lbl=subVendorMap.get(rsvW.apvElt.vendor__c).name;
                        if(selection!='Other' && lbl.startsWith(selection)){
                            listOfSubVendorRecords.add(rsvw);
                        }
                        if(selection=='Other'){                    
                            if(!((lbl.substring(0,1)>='A' && lbl.substring(0,1)<='z') || lbl.substring(0,1)==' ')){
                                listOfSubVendorRecords.add(rsvw);
                            }
                        }                
                    }
                }
                if(selection=='All'){           
                    listOfSubVendorRecords=wrapperRecs;
                }
                //System.debug('###listOfSubVendorRecords'+listOfSubVendorRecords);  
            }Catch(Exception e){
                System.debug('###Exception in VPM'+e);  
            }
            return null;         
        }
        
         //Auto approve mdf program
          public PageReference autoApproveAPVRecord(){
              PageReference currentPageRef;             
                
            try{
                if(mdfProgram.Program_Status__c=='Pending'&& mdfProgram.Business_Segment__c!=null){
                    idArr.add(mdfProgram.Program_Owner__c);
                    idArr.add(mdfProgram.OwnerId); 
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Submitting request for Auto-approval.');
                    req1.setObjectId(mdfPgmId); 
                    req1.setNextApproverIds(idArr); 
                    
                    Approval.ProcessResult result = Approval.process(req1);  
                                
                    //System.assert(result.isSuccess());
                    //System.assertEquals('Pending', result.getInstanceStatus(), 'Instance status'+result.getInstanceStatus());
                    if(result.isSuccess()==true){
                        List<Id> newWorkItemIds = result.getNewWorkitemIds();                    
                        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();                                     
                        
                        req2.setNextApproverIds(idArr);
                        
                        req2.setWorkitemId(newWorkItemIds.get(0));
                        req2.setComments('Auto-approved');
                        req2.setAction('Approve');                     
                        Approval.ProcessResult result2 = Approval.process(req2);
                         
                        //System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
                        //System.assertEquals('Approved', result2.getInstanceStatus(), 'Instance Status'+result2.getInstanceStatus());
                          
                    }                    
                    currentPageRef=new PageReference('/'+mdfProgram.Id);
                    
                }else{
                    currentPageRef=null;
                }
                
            }catch(Exception e){
                
            }
            return currentPageRef;
        }
    

        //...........END APV.................  
        
        //..........PackagePrice Update...........
        
        public static void updateBudgetedPrice( Set<Id> packageIdSet,Map<Id,Associated_Programs_Vendors__c> apvMap){
            try{
                Package__c packageObj;
                Decimal pkgPrice=0;
                Decimal apvBudgetedPrice=0;
                List<Package__c> packageUpdateList=new List<Package__c>();
                
                
                List<Package__c> packageList=[Select id,Fiscal_Quarter__c,Marketing_Plan__c,Package_Price_del__c,Status__c
                from Package__c where id in:packageIdSet];
                List<Associated_Programs_Vendors__c> apvlistNew=new List<Associated_Programs_Vendors__c>();
                apvlistNew=[select Budgeted_Price__c,package__c from Associated_Programs_Vendors__c where package__c in:packageIdSet];  
                            
                for(integer j=0;j<packageList.size();j++){
                    packageObj=new Package__c(Id=packageList[j].Id);
                     
                    for(integer i=0;i<apvlistNew.size();i++){
                        if(apvlistNew[i].package__c==packageList[j].id && apvlistNew[i].Budgeted_Price__c!=null){                        
                            if(apvMap.get(apvlistNew[i].Id)!=null){
                                apvBudgetedPrice=apvMap.get(apvlistNew[i].Id).Budgeted_Price__c;
                            }else{
                                apvBudgetedPrice=apvlistNew[i].Budgeted_Price__c;
                            }
                            pkgPrice=pkgPrice+apvBudgetedPrice;
                        }
                    }
                    packageObj.Package_Price_del__c=pkgPrice;                  
                    packageUpdateList.add(packageObj);
                } 
                
                if(packageUpdateList.size()>0){
                    update packageUpdateList;
                } 
            }Catch(Exception e){
            }          
            
        }
        
        public static void updateInvoiceAmount( Set<Id> mPlanIdSet,Map<Id,Associated_Programs_Vendors__c> apvMap){
        try{
                Marketing_Plan__c mPlanObj;
                Decimal InvAmount=0;
                Decimal apvInvAmount=0;
                List<Marketing_Plan__c> mPlanUpdateList=new List<Marketing_Plan__c>();            
                List<Marketing_Plan__c> mPlanList=[Select id,Invoice_Amount__c,Invoice__c from Marketing_Plan__c where id in:mPlanIdSet];  
                
                List<Associated_Programs_Vendors__c> apvlistNew=new List<Associated_Programs_Vendors__c>();
                apvlistNew=[select Invoice_Amount__c,Marketing_Plan__c from Associated_Programs_Vendors__c where Marketing_Plan__c in:mPlanIdSet];  
                        
               
                for(integer j=0;j<mPlanList.size();j++){
                    mPlanObj=new Marketing_Plan__c(Id=mPlanList[j].Id); 
                    for(integer i=0;i<apvlistNew.size();i++){
                        if(apvlistNew[i].Marketing_Plan__c==mPlanList[j].id && apvlistNew[i].Invoice_Amount__c!=null){                        
                            
                            if(apvMap.get(apvlistNew[i].Id)!=null){
                                
                                apvInvAmount=apvMap.get(apvlistNew[i].Id).Invoice_Amount__c;
                            }else{
                                apvInvAmount=apvlistNew[i].Invoice_Amount__c;
                            }                       
                            
                            InvAmount=InvAmount+apvInvAmount;
                        }
                    }               
                    mPlanObj.Invoice_Amount__c=InvAmount;
                    mPlanUpdateList.add(mPlanObj);
                }             
                if(mPlanUpdateList.size()>0){
                    update mPlanUpdateList;
                } 
            }Catch(Exception e){
            }
        }
        
        //********************Delete Associated program vendor records*************//
        
        public List<APVWrapper> getAPVWrapperRecs(){
            return listOfAPVWrapperRecs; 
        } 
        
        public void setAPVWrapperRecs(List<APVWrapper> lstRecs){
            this.listOfAPVWrapperRecs=lstRecs; 
        }
        
        public PageReference deleteSelectedAPVRecordsFromProgram(){
            Profile profileName=[select Name from profile where id = :userinfo.getProfileId()];
            PageReference pageRef=new PageReference('/'+mdfPgmId);
            Associated_Programs_Vendors__c apvObj;
            List<Associated_Programs_Vendors__c> apvDeleteList=new List<Associated_Programs_Vendors__c>();
            for(APVWrapper apvWrapperElt:listOfAPVWrapperRecs){
                if(apvWrapperElt.selected==true){
                    apvObj=new Associated_Programs_Vendors__c();
                    apvObj=apvWrapperElt.apvElt;
                    if(apvObj.Marketing_Plan__c !=null && !(profileName.Name.contains('MDF Marketing Operations / Contract Admin')) &&  !(profileName.Name.contains('MDF Co-Marketing  Manager')) ){
                        ApexPages.Message msg;     
                        msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: Only Marketing Operations / Contract Admin or MDF Co-Marketing Manager are allowed to delete APVs which are added to a Marketing Plan.');
                        ApexPages.addMessage(msg);            
                        pageRef=null; 
                        return null;                     
                    }else{
                        apvDeleteList.add(apvObj); 
                    }     
                }
            }
            if(apvDeleteList.size()==0){
                ApexPages.Message msg;     
                msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select atleast one APV.');
                ApexPages.addMessage(msg);            
                pageRef=null; 
                return null;  
                 
            } 
            if(apvDeleteList.size()>0){
                try{
                    delete apvDeleteList;
                }Catch(Exception e){
                    system.debug('##del action##'+e);
                }
                
                pageRef=new PageReference('/'+mdfPgmId);  
            }
            return pageRef;
             
        }
        
        public PageReference deleteSelectedAPVRecsFromMarketingPlan(){
            PageReference pageRef;
            String marketingPlanId;
            Associated_Programs_Vendors__c apvObj;
            List<Associated_Programs_Vendors__c> apvUpdateList=new List<Associated_Programs_Vendors__c>();
            RecordType apvRT=[Select Name, Id From RecordType where sObjectType='Associated_Programs_Vendors__c' and name='Vendor Association' limit 1];
            for(APVWrapper apvWrapperElt:listOfAPVWrapperRecs){
                if(apvWrapperElt.selected==true){
                        apvObj=new Associated_Programs_Vendors__c(); 
                        marketingPlanId=apvWrapperElt.apvElt.Marketing_Plan__c;
                        apvWrapperElt.apvElt.Marketing_Plan__c=null;
                        apvWrapperElt.apvElt.Invoice_Amount__c=0;
                        apvWrapperElt.apvElt.Contract_Status_Reason__c=null;
                        apvWrapperElt.apvElt.LE__c=0;
                        apvWrapperElt.apvElt.PUB__c=0;
                        apvWrapperElt.apvElt.SMB__c=0;
                        apvWrapperElt.apvElt.CSMR__c=0;
                        apvWrapperElt.apvElt.Package__c=null;
                        apvWrapperElt.apvElt.Accounting_Treatment__c=null;
    //                    apvWrapperElt.apvElt.POP_Status__c=null;
    //                    apvWrapperElt.apvElt.POP_Status_Reason__c=null;
                        apvWrapperElt.apvElt.recordTypeId=apvRT.Id;
                        apvWrapperElt.apvElt.Status__c='Pending';
                        apvObj=apvWrapperElt.apvElt;
                        apvUpdateList.add(apvObj);    
                }
            }
            if(apvUpdateList.size()==0){
                ApexPages.Message msg;     
                msg = new ApexPages.Message(ApexPages.severity.FATAL,'Error: To continue, please select atleast one APV.');
                ApexPages.addMessage(msg);            
                pageRef=null; 
                return null;  
                 
            } 
            if(apvUpdateList.size()>0){
                try{
                    update apvUpdateList;
                }Catch(Exception e){
                }
                  
            }
            pageRef=new PageReference('/'+marketingPlanId);            
            return pageRef;
             
        }
        
        public boolean getdeleteApv(){
            return noDeleteApv;
        }
        public boolean getDelApvAuth(){
            return DelApvAuth;
        }
        public boolean getlistapv(){
            return listapv;
        }         
                
         //********************Mass Update Associated program vendor records*************//
         
        public List<APVWrapper> getAPVShowList(){
            return apvShowList; 
        } 
        
        public void setAPVShowList(List<APVWrapper> lstRecs){
            this.apvShowList=lstRecs; 
        }
        public Boolean getVariablePgm(){
            return variablePgm; 
        } 
        
        public void setVariablePgm(Boolean bol){
            this.variablePgm=bol; 
        }
        public Boolean getProgramOwner(){
            return programOwner; 
        } 
        
        public void setProgramOwner(Boolean bol){
            this.programOwner=bol; 
        }
        
        public PageReference massUpdateAPVRecrods(){
            PageReference pageRef=new PageReference('/'+mdfProgram.Id);
            List<Associated_Programs_Vendors__c> apvUpdateList=new List<Associated_Programs_Vendors__c>();
            for(APVWrapper apv:apvShowList){
                if(apv.selected==true){
                    apvUpdateList.add(apv.apvElt);
                }    
            }
            if(apvUpdateList.size()>0){
                update apvUpdateList;
            }
            return pageRef;
        }
        
        public PageReference CancelAction(){
            String marketingPlanId=ApexPages.currentPage().getParameters().get('MPlanId');
            PageReference pageRef;
            if(marketingPlanId!=null){
                pageRef=new PageReference('/'+marketingPlanId);
            }else{
                pageRef=new PageReference('/'+mdfProgram.Id);
            }
            return pageRef;
        }
        public MDF_Program__c getMDFProgram(){
            return mdfProgram; 
        } 

    }