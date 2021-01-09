@IsTest
private class FAP_SoqlBuilderTest {
    
    private static testmethod void testLimit(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM account LIMIT 1000',
            new FAP_SoqlBuilder().selectx('id').fromx('account').limitx(1000).toSoql()); 
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testNoObjectName(){
        Boolean exceptionCaught = false;
        try{
            new FAP_SoqlBuilder().toSoql();
        }catch(FAP_IllegalStateException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalStateException not thrown');
    }
    
    private static testmethod void testBadField1(){
        Boolean exceptionCaught = false;
        try{
            String aNull = null;
            new FAP_SoqlBuilder().selectx(aNull);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalArgumentException not thrown');
    }
    
    private static testmethod void testBadField2(){
        Boolean exceptionCaught = false;
        try{
            List<Object> anObjectList = new List<Object>{new DecimalRange(0,1)};
                new FAP_SoqlBuilder().selectx(anObjectList);
        }catch(FAP_IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'FAP_IllegalArgumentException not thrown');
    }
    
    private static testmethod void testBasicSelect(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id,name FROM account WHERE name like \'%acme%\'',
            new FAP_SoqlBuilder()
            .selectx(new List<String>{'id','name'})
            .fromx('account')
            .wherex(new FAP_FieldCondition('name',FAP_Operator.LIKEX,'%acme%'))
            .toSoql());   
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testOptionWildcardStringsInLikeFAPOperators(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM account WHERE name like \'%acme%\'',
            new FAP_SoqlBuilder()
            .fromx('account')
            .wherex(new FAP_FieldCondition('name',FAP_Operator.LIKEX,'acme'))
            .toSoql(new FAP_SoqlOptions().wildcardStringsInLikeOperators())); 
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testOptionWildcardStringsInLikeFAPOperatorsAlreadyWildcarded(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM account WHERE name like \'%acme%\'',
            new FAP_SoqlBuilder()
            .fromx('account')
            .wherex(new FAP_FieldCondition('name',FAP_Operator.LIKEX,'%acme%'))
            .toSoql(new FAP_SoqlOptions().wildcardStringsInLikeOperators()));   
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testOptionDoNotWildcardStringsInLikeFAPOperators(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM account WHERE name like \'acme\'',
            new FAP_SoqlBuilder()
            .fromx('account')
            .wherex(new FAP_FieldCondition('name',FAP_Operator.LIKEX,'acme'))
            .toSoql(new FAP_SoqlOptions().doNotWildcardStringsInLikeOperators()));
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testOptionEscapeSingleQuotes(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM account WHERE name like \'Bill\\\'s Chop Shop\'',
            new FAP_SoqlBuilder()
            .fromx('account')
            .wherex(new FAP_FieldCondition('name',FAP_Operator.LIKEX,'Bill\'s Chop Shop'))
            .toSoql(new FAP_SoqlOptions().escapeSingleQuotes()));  
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testOptionDoNotEscapeSingleQuotes(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM account WHERE name like \'Bill\'s Chop Shop\'',
            new FAP_SoqlBuilder()
            .fromx('account')
            .wherex(new FAP_FieldCondition('name',FAP_Operator.LIKEX,'Bill\'s Chop Shop'))
            .toSoql(new FAP_SoqlOptions().doNotEscapeSingleQuotes()));   
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');             
    }
    
    private static testmethod void testNestedConditions(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id,name FROM account WHERE ((name like \'%acme%\' OR description = \'yo\') AND ispartner = true) ORDER BY name DESC LIMIT 500',
            new FAP_SoqlBuilder()
            .selectx(new List<String>{'id','name'})
            .fromx('account')
            .wherex(
                new FAP_AndCondition()
                .add(
                    new FAP_OrCondition()
                    .add(new FAP_FieldCondition('name',FAP_Operator.LIKEX,'%acme%'))
                    .add(new FAP_FieldCondition('description',FAP_Operator.EQUALS,'yo'))
                )
                .add(new FAP_FieldCondition('ispartner',FAP_Operator.EQUALS,true))
            ).orderByx(new FAP_OrderBy('name').descending())
            .limitx(500)
            .toSoql());  
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testOrderBy1(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM account ORDER BY name',
            new FAP_SoqlBuilder()
            .fromx('account')
            .orderByx(new List<FAP_OrderBy>{new FAP_OrderBy('name')})
            .toSoql());  
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testOrderBy2(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM account ORDER BY name ASC NULLS LAST, rating DESC, industry DESC NULLS FIRST',
            new FAP_SoqlBuilder()
            .fromx('account')
            .orderByx(new List<FAP_OrderBy>{
                new FAP_OrderBy('name').ascending().nullsLast()
                    ,new FAP_OrderBy('rating').descending()
                    ,new FAP_OrderBy('industry').descending().nullsFirst()})
            .toSoql());   
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testANullOrderBy(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM account ORDER BY name',
            new FAP_SoqlBuilder()
            .fromx('account')
            .orderByx(new List<FAP_OrderBy>{
                new FAP_OrderBy('name')
                    ,null})
            .toSoql());   
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testParentToChildQuery1(){
        FAP_SoqlUtils.assertEquals(
            'SELECT ID, Name, toLabel(Rating), (SELECT FirstName, LastName FROM Contacts) FROM Account',
            new FAP_SoqlBuilder()
            .selectx('ID')
            .selectx('Name')
            .selectx(new FAP_Field('Rating').toLabelx())
            .selectx(
                new FAP_SoqlBuilder()
                .selectx('FirstName')
                .selectx('LastName')
                .fromx('Contacts'))
            .fromx('Account')
            .toSoql());   
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');        
    }
    
    private static testmethod void testParentToChildQuery2(){
        FAP_SoqlUtils.assertEquals(
            'SELECT    ID, Name,    toLabel(Rating), (SELECT FirstName, LastName FROM Contacts) FROM Account',
            new FAP_SoqlBuilder()
            .selectx(new List<Object>
                     {
                         'ID'
                             ,'Name'
                             ,new FAP_Field('Rating').toLabelx()
                             ,new FAP_SoqlBuilder()
                             .selectx('FirstName')
                             .selectx('LastName')
                             .fromx('Contacts')
                             }
                    )
            .fromx('Account')
            .toSoql()); 
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testSelectCount1(){
        FAP_SoqlUtils.assertEquals(
            'SELECT count() from Contact c, c.Account a WHERE a.name = \'MyriadPubs\'',
            new FAP_SoqlBuilder()
            .selectCount()
            .fromx('Contact c, c.Account a')
            .wherex(new FAP_FieldCondition('a.name','MyriadPubs'))
            .toSoql());  
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account'); 
    }
    
    private static testmethod void testSelectCount2(){
        FAP_SoqlUtils.assertEquals(
            'SELECT count() FROM Account WHERE Name LIKE \'a%\'',
            new FAP_SoqlBuilder()
            .selectCount()
            .fromx('Account')
            .wherex(new FAP_FieldCondition('Name',FAP_Operator.LIKEX,'a%'))
            .toSoql());   
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');             
    }
    
    
    
    private static testmethod void testSelectNullCondition(){
        FAP_SoqlUtils.assertEquals(
            'SELECT Id FROM Case WHERE Contact.Lastname = null',
            new FAP_SoqlBuilder()
            .fromx('Case')
            .wherex(new FAP_FieldCondition('Contact.Lastname',null))
            .toSoql()); 
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');        
    }
    
    private static testmethod void testIncludes(){
        FAP_SoqlUtils.assertEquals(
            'SELECT Id, MSP1__c from CustObj__c WHERE MSP1__c INCLUDES (\'AAA;BBB\',\'CCC\')',
            new FAP_SoqlBuilder()
            .selectx(new List<String>{'id','MSP1__c'})
            .fromx('CustObj__c')
            .wherex(new FAP_SetCondition('MSP1__c').includes(new List<String>{'AAA;BBB','CCC'}))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testExcludes(){
        FAP_SoqlUtils.assertEquals(
            'SELECT Id, MSP1__c from CustObj__c WHERE MSP1__c EXCLUDES (\'AAA;BBB\',\'CCC\')',
            new FAP_SoqlBuilder()
            .selectx(new List<String>{'id','MSP1__c'})
            .fromx('CustObj__c')
            .wherex(new FAP_SetCondition('MSP1__c').excludes(new List<String>{'AAA;BBB','CCC'}))
            .toSoql());   
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testIn(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM ACCOUNT WHERE BillingState IN (\'California\',\'New York\')',
            new FAP_SoqlBuilder()
            .fromx('ACCOUNT')
            .wherex(new FAP_SetCondition('BillingState').inx(new List<String>{'California','New York'}))
            .toSoql()); 
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testNotIn(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id FROM ACCOUNT WHERE BillingState NOT IN (\'California\',\'New York\')',
            new FAP_SoqlBuilder()
            .fromx('ACCOUNT')
            .wherex(new FAP_SetCondition('BillingState').notIn(new List<String>{'California','New York'}))
            .toSoql());  
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');        
    }
    
    private static testmethod void testDateFormulaNextNFiscalQuarters(){
        FAP_SoqlUtils.assertEquals(
            'SELECT Id FROM Account WHERE CreatedDate < NEXT_N_FISCAL_QUARTERS:6',
            new FAP_SoqlBuilder()
            .fromx('Account')
            .wherex(new FAP_FieldCondition('CreatedDate', FAP_Operator.LESS_THAN, new FAP_DateFormula().next(6,FAP_UnitOfTime.FiscalQuarter)))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testDateFormulaTomorrow(){
        FAP_SoqlUtils.assertEquals(
            'SELECT Id FROM Opportunity WHERE CloseDate = TOMORROW',
            new FAP_SoqlBuilder()
            .fromx('Opportunity')
            .wherex(new FAP_FieldCondition('CloseDate', new FAP_DateFormula().tomorrowx()))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testEquals1(){
        FAP_SoqlUtils.assertEquals(
            'SELECT name,employees FROM account WHERE employees = 10',
            new FAP_SoqlBuilder()
            .selectx('name')
            .selectx(new Set<Object>{'employees'})
            .fromx('account')
            .wherex(new FAP_FieldCondition('employees', 10))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testEquals2(){
        FAP_SoqlUtils.assertEquals(
            'SELECT name,employees FROM account WHERE employees = 10',
            new FAP_SoqlBuilder()
            .selectx('name')
            .selectx('employees')
            .fromx('account')
            .wherex(new FAP_FieldCondition('employees').equals(10))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');        
    }
    
    private static testmethod void testEquals3(){
        FAP_SoqlUtils.assertEquals(
            'SELECT name,employees FROM account WHERE employees = 10',
            new FAP_SoqlBuilder()
            .selectx(new Set<Object>{'name','employees'})
            .fromx('account')
            .wherex(new FAP_FieldCondition().field('employees').equals(10))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testInx1(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id,industry FROM account WHERE industry in (\'Agriculture\',\'Apparel\')',
            new FAP_SoqlBuilder()
            .selectx(new List<Object>{'industry','id'})
            .fromx('account')
            .wherex(new FAP_SetCondition('industry', FAP_Operator.INX, new List<Object>{'Agriculture','Apparel'}))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testInx2(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id,industry FROM account WHERE industry in (\'Agriculture\',\'Apparel\')',
            new FAP_SoqlBuilder()
            .selectx(new List<Object>{'industry','id'})
            .fromx('account')
            .wherex(new FAP_SetCondition('industry').inx(new List<Object>{'Agriculture','Apparel'}))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }
    
    private static testmethod void testInx3(){
        FAP_SoqlUtils.assertEquals(
            'SELECT id,industry FROM account WHERE industry in (\'Agriculture\',\'Apparel\')',
            new FAP_SoqlBuilder()
            .selectx(new List<Object>{'industry','id'})
            .fromx('account')
            .wherex(new FAP_SetCondition().field('industry').inx(new List<Object>{'Agriculture','Apparel'}))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');        
        
    }
    
    private static testmethod void testBasicSemiJoin(){
        System.assertEquals(
            'SELECT id FROM Account WHERE ID IN '
            +'(SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
            new FAP_SoqlBuilder()
            .fromx('Account')
            .wherex(new FAP_SetCondition('ID').inx(
                new FAP_SoqlBuilder()
                .selectx('AccountId')
                .fromx('Opportunity')
                .wherex(new FAP_FieldCondition('StageName','Closed Lost'))))
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');        
    }
    
    private static testmethod void testDuplicateFields(){
        System.assertEquals(
            'SELECT name FROM Account',
            new FAP_SoqlBuilder()
            .selectx('name')
            .selectx(new FAP_Field('name'))
            .fromx('Account')
            .toSoql());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');        
    }
    
    
    
}