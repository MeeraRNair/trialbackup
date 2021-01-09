@IsTest
public class TranslationParser_Test {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{\"from\":\"kor\",\"to\":\"en\",\"trans_result\":[{\"src\":\"\\ub378 \\uad6d\\uc81c\",\"dst\":\"on the international\"},{\"src\":\"\\ub9c8\\ub4dc \\ud574\\uba38\",\"dst\":\"please hammer, don\'t\"},{\"src\":\"null\",\"dst\":\"null\"},{\"src\":\"\\ud558\\uc774\\ub370\\ub77c\\ubc14\\ub4dc\",\"dst\":\"the lava).\"},{\"src\":\"\\ud154\\ub780\\uac00\\ub098\",\"dst\":\"the hotel is now\"},{\"src\":\"505001\",\"dst\":\"505001\"}]}';
        Translation_Parser.TranslationParser  r = Translation_Parser.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        Translation_Parser.TranslationParser objTrans_result = new Translation_Parser.TranslationParser(System.JSON.createParser(json));
     

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        Translation_Parser.TranslationParser objTranslationParser = new Translation_Parser.TranslationParser(System.JSON.createParser(json));
       
    }
}