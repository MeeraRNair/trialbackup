@isTest
    private class AddVendorReimbursementFormCntrlrTest{
        
        static MDF_Program__c mdfProgram = new MDF_Program__c();
        static Vendor__c vendor = new Vendor__c();
        static Associated_Programs_Vendors__c assPrgmVendor = new Associated_Programs_Vendors__c();
        static Associated_Programs_Vendors__c assPrgmVendor1 = new Associated_Programs_Vendors__c();
        static Reimbursement_Form__c reqForm = new Reimbursement_Form__c();
        static List<Reimbursement_Form__c> reImburseList = new List<Reimbursement_Form__c>();
        static Vendor_Reimbursement__c parentVendorReImbursment = new Vendor_Reimbursement__c();
        static Profile profiles;
        static List<User> users = new List<User>();

        static Reimbursement_Form__c reqForm1 = new Reimbursement_Form__c();
        static List<Reimbursement_Form__c> reImburseList1 = new List<Reimbursement_Form__c>();

        public static testMethod void testAddVendorReimbursementFormCntrlrTest(){
            createData();
            
            ApexPages.StandardSetController stndCntrl = new ApexPages.StandardSetController(reImburseList);
            Apexpages.currentpage().getParameters().put('id', String.valueOf(reqForm.Id));
            
            AddVendorReimbursementFormCntrlr addVendReImburseCntrlr = new AddVendorReimbursementFormCntrlr(stndCntrl);
            for(AddVendorReimbursementFormCntrlr.APVWrapper wrp: addVendReImburseCntrlr.selectedAssociatedVendorsWrapper){
                wrp.selected = true;
            }
            addVendReImburseCntrlr.insertVendorReimbrsRecords();
            addVendReImburseCntrlr.getsearchAlphabet();
            addVendReImburseCntrlr.setsearchAlphabet('All');
            addVendReImburseCntrlr.setsearchAlphabet('test');
            addVendReImburseCntrlr.sortByAlphabet();
            
            UpdateVendorReimbrsementscontrlr updateVenderReImburse = new UpdateVendorReimbrsementscontrlr(stndCntrl);
            for(UpdateVendorReimbrsementscontrlr.wrapperClass wrp: updateVenderReImburse.wrapperList){
                wrp.selected = true;
            }
            updateVenderReImburse.updateVendorReimbRecords();
            updateVenderReImburse.sortByAlphabet();
            updateVenderReImburse.setsearchAlphabet('All');
            updateVenderReImburse.getsearchAlphabet();

            DeleteVendorReimbrsementscontrlr delVendorReImburse = new DeleteVendorReimbrsementscontrlr(stndCntrl);
            for(DeleteVendorReimbrsementscontrlr.wrapperClass wrp: delVendorReImburse.wrapperList){
                wrp.selected = true;
            }
            delVendorReImburse.deleteVendorReimbRecords();
            delVendorReImburse.sortByAlphabet();
            delVendorReImburse.setsearchAlphabet('All');
            delVendorReImburse.getsearchAlphabet();
            
        }

        public static testMethod void testAddVendorReimbursementFormCntrlrTest1(){
            
            createData1();

            ApexPages.StandardSetController stndCntrl1 = new ApexPages.StandardSetController(reImburseList1);
            Apexpages.currentpage().getParameters().put('id', String.valueOf(reqForm1.Id));
            
            AddVendorReimbursementFormCntrlr addVendReImburseCntrlr1 = new AddVendorReimbursementFormCntrlr(stndCntrl1);
            for(AddVendorReimbursementFormCntrlr.APVWrapper wrp: addVendReImburseCntrlr1.selectedAssociatedVendorsWrapper){
                wrp.selected = true;
            }
            addVendReImburseCntrlr1.insertVendorReimbrsRecords();
            addVendReImburseCntrlr1.insertVendorReimbrsRecords();
            addVendReImburseCntrlr1.getsearchAlphabet();
            addVendReImburseCntrlr1.setsearchAlphabet('All');
            addVendReImburseCntrlr1.setsearchAlphabet('test');
            addVendReImburseCntrlr1.sortByAlphabet();
            
            UpdateVendorReimbrsementscontrlr updateVenderReImburse = new UpdateVendorReimbrsementscontrlr(stndCntrl1);
            for(UpdateVendorReimbrsementscontrlr.wrapperClass wrp: updateVenderReImburse.wrapperList){
                wrp.selected = true;
            }
            updateVenderReImburse.updateVendorReimbRecords();
            updateVenderReImburse.sortByAlphabet();
            updateVenderReImburse.setsearchAlphabet('test');
            updateVenderReImburse.getsearchAlphabet();

            DeleteVendorReimbrsementscontrlr delVendorReImburse = new DeleteVendorReimbrsementscontrlr(stndCntrl1);
            for(DeleteVendorReimbrsementscontrlr.wrapperClass wrp: delVendorReImburse.wrapperList){
                wrp.selected = true;
            }
            delVendorReImburse.deleteVendorReimbRecords();
            delVendorReImburse.sortByAlphabet();
            delVendorReImburse.setsearchAlphabet('test');
            delVendorReImburse.getsearchAlphabet();
            
        }

        public static testMethod void testAddVendorReimbursementFormCntrlrTest2(){
            
            createData1();

            ApexPages.StandardSetController stndCntrl1 = new ApexPages.StandardSetController(reImburseList1);
            Apexpages.currentpage().getParameters().put('id', String.valueOf(reqForm1.Id));
            
            AddVendorReimbursementFormCntrlr addVendReImburseCntrlr1 = new AddVendorReimbursementFormCntrlr(stndCntrl1);
            for(AddVendorReimbursementFormCntrlr.APVWrapper wrp: addVendReImburseCntrlr1.selectedAssociatedVendorsWrapper){
                wrp.selected = true;
            }
            addVendReImburseCntrlr1.insertVendorReimbrsRecords();
            addVendReImburseCntrlr1.insertVendorReimbrsRecords();
            addVendReImburseCntrlr1.getsearchAlphabet();
            addVendReImburseCntrlr1.setsearchAlphabet('All');
            addVendReImburseCntrlr1.sortByAlphabet();
            
            UpdateVendorReimbrsementscontrlr updateVenderReImburse = new UpdateVendorReimbrsementscontrlr(stndCntrl1);
            for(UpdateVendorReimbrsementscontrlr.wrapperClass wrp: updateVenderReImburse.wrapperList){
                wrp.selected = true;
            }
            updateVenderReImburse.updateVendorReimbRecords();
            updateVenderReImburse.sortByAlphabet();
            updateVenderReImburse.setsearchAlphabet('test');
            updateVenderReImburse.getsearchAlphabet();

            DeleteVendorReimbrsementscontrlr delVendorReImburse = new DeleteVendorReimbrsementscontrlr(stndCntrl1);
            for(DeleteVendorReimbrsementscontrlr.wrapperClass wrp: delVendorReImburse.wrapperList){
                wrp.selected = true;
            }
            delVendorReImburse.deleteVendorReimbRecords();
            delVendorReImburse.sortByAlphabet();
            delVendorReImburse.setsearchAlphabet('test');
            delVendorReImburse.getsearchAlphabet();
        }

        
        public static testMethod void testAddVendorReimbursementFormCntrlrTest3(){
            
            createData1();

            ApexPages.StandardSetController stndCntrl3 = new ApexPages.StandardSetController(reImburseList1);
            Apexpages.currentpage().getParameters().put('id', String.valueOf(reqForm1.Id));
            
            AddVendorReimbursementFormCntrlr addVendReImburseCntrlr1 = new AddVendorReimbursementFormCntrlr(stndCntrl3);
            for(AddVendorReimbursementFormCntrlr.APVWrapper wrp: addVendReImburseCntrlr1.selectedAssociatedVendorsWrapper){
                wrp.selected = true;
            }
            addVendReImburseCntrlr1.insertVendorReimbrsRecords();
            addVendReImburseCntrlr1.insertVendorReimbrsRecords();
            addVendReImburseCntrlr1.getsearchAlphabet();
            addVendReImburseCntrlr1.setsearchAlphabet('All');
            addVendReImburseCntrlr1.sortByAlphabet();
            
            UpdateDeleteVendorReimbrsementscontrlr updelVendorReImburse = new UpdateDeleteVendorReimbrsementscontrlr(stndCntrl3);
            for(UpdateDeleteVendorReimbrsementscontrlr.wrapperClass wrp: updelVendorReImburse.wrapperList){
                wrp.selected = true;
            }
            updelVendorReImburse.deleteVendorReimbRecords();
            updelVendorReImburse.updateVendorReimbRecords();
            updelVendorReImburse.sortByAlphabet();
            updelVendorReImburse.setsearchAlphabet('test');
            updelVendorReImburse.getsearchAlphabet();
        }
        
        public static void createData(){

            profiles=[select id,name from Profile where name like 'MDF Program Owners' limit 1];

            for(Integer i = 0; i<3; i++){           
                users.add(
                    new User(
                        Username='testuser'+i+ System.currentTimeMillis()+'@dell.com',
                        Alias = 'test'+i, 
                        Email='testuser'+i+'@dell.com', 
                        FirstName='John', 
                        LastName='Doe'+i, 
                        ProfileId =profiles.Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='John.doe'+i
                   )
                );
            }
            insert users;

            mdfProgram.Name='testMDF Program';
            mdfProgram.Program_Owner__c=users[2].id;
            mdfProgram.POP_Owner__c=users[2].id;
            mdfProgram.Program_Status__c='Approved';
            mdfProgram.Pricing_Type__c='Variable';
            mdfProgram.Fiscal_Quarter__c='FY12Q3';
            mdfProgram.OwnerId=users[2].id;
            mdfProgram.Rate_Card_Price__c=12356;
            insert mdfProgram;

            vendor.Name = 'Test Vendor';
            insert vendor;

            assPrgmVendor.Vendor__c = vendor.Id;
            assPrgmVendor.MDF_Program__c = mdfProgram.Id;
            insert assPrgmVendor;

            reqForm.Name = 'Test ReImbursement';
            reqForm.MDF_Program__c = mdfProgram.Id;
            
            reImburseList.add(reqForm);
            insert reImburseList;

            parentVendorReImbursment.Reimbursement_Form__c = reqForm.Id;
            parentVendorReImbursment.APV__c = assPrgmVendor.Id;
            insert parentVendorReImbursment;

            reqForm1.Name = 'Test ReImbursement';
            reqForm1.MDF_Program__c = mdfProgram.Id;
            
            reImburseList1.add(reqForm1);

        }

        public static void createData1(){

            profiles=[select id,name from Profile where name like 'MDF Program Owners' limit 1];

            for(Integer i = 0; i<3; i++){           
                users.add(
                    new User(
                        Username='testuser'+i+ System.currentTimeMillis()+'@dell.com',
                        Alias = 'test'+i, 
                        Email='testuser'+i+'@dell.com', 
                        FirstName='John', 
                        LastName='Doe'+i, 
                        ProfileId =profiles.Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c='John.doe'+i
                   )
                );
            }
            insert users;

            mdfProgram.Name='testMDF Program';
            mdfProgram.Program_Owner__c=users[2].id;
            mdfProgram.POP_Owner__c=users[2].id;
            mdfProgram.Program_Status__c='Approved';
            mdfProgram.Pricing_Type__c='Variable';
            mdfProgram.Fiscal_Quarter__c='FY12Q3';
            mdfProgram.OwnerId=users[2].id;
            mdfProgram.Rate_Card_Price__c=12356;
            insert mdfProgram;

            vendor.Name = 'Test Vendor';
            insert vendor;

            assPrgmVendor.Vendor__c = vendor.Id;
            assPrgmVendor.MDF_Program__c = mdfProgram.Id;
            insert assPrgmVendor;

            reqForm1.Name = 'Test ReImbursement';
            reqForm1.MDF_Program__c = mdfProgram.Id;
            
            reImburseList1.add(reqForm1);

            insert reImburseList1;

        }

    }