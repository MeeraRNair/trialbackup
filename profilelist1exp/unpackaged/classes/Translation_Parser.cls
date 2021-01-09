public class Translation_Parser {
    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || 
                curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT ||
                curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    public class Trans_result {
        public String src {get;set;} 
        public String dst {get;set;} 

        public Trans_result(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'src') {
                            src = parser.getText();
                        } else if (text == 'dst') {
                            dst = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Trans_result consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class TranslationParser {
        public String from_Z {get;set;} // in json: from
        public String to {get;set;} 
        public List<Trans_result> trans_result {get;set;} 

        public TranslationParser(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'from') {
                            from_Z = parser.getText();
                        } else if (text == 'to') {
                            to = parser.getText();
                        } else if (text == 'trans_result') {
                            trans_result = new List<Trans_result>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                trans_result.add(new Trans_result(parser));
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'TranslationParser consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static TranslationParser parse(String json) {
        return new TranslationParser(System.JSON.createParser(json));
    }
}