public class RateCardImporter {

    public StaticResource[] csvFile = [SELECT Body from StaticResource WHERE Name = 'createRateCardsCSV' LIMIT 1];
    public static final String csvSeparator = ',|;';
    public static final Map<String,String> mapCSVtoObjFields = new Map<String,String>{
        'Country' => 'pse__Region__c',
        'Role' => 'pse__Role__c',
        'Rate' => 'pse__Average_Cost_Rate__c',
        'Currency' => 'CurrencyIsoCode',
        'Practice' => 'pse__Practice__c'
    };

    private Map<String, Id> mapRegionNameId;
    private pse__Rate_Card__c[] lstAllRateCards;
    private Map<String, Id> mapExistingRateCards;
    private Map<String, Id> mapPracticeId;

    public void run() {
        convertCSVToObj(csvFile[0]?.body.toString());
    }

    public RateCardImporter() {
        this.mapRegionNameId = new Map<String, Id>();
        this.mapPracticeId = new Map<String, Id>();
        pse__Region__c[] lstRegions = [SELECT Id, Name FROM pse__Region__c];
        pse__Practice__c[] lstPractices = [SELECT Id, Name FROM pse__Practice__c];

        for (pse__Region__c tempRegion : lstRegions) {
            this.mapRegionNameId.put(tempRegion.Name.toLowerCase(), tempRegion.Id);
        }
        for (pse__Practice__c tempPractice : lstPractices) {
            this.mapPracticeId.put(tempPractice.Name.toLowerCase(), tempPractice.Id);
        }

        this.lstAllRateCards = [SELECT Id, pse__Region__c, pse__Role__c,pse__Average_Cost_Rate__c,CurrencyIsoCode,pse__Practice__c
                                FROM pse__Rate_Card__c];
        this.mapExistingRateCards = new Map<String, Id>();
        for (pse__Rate_Card__c tempRate : lstAllRateCards) {
            String key = '' + tempRate.pse__Region__c + tempRate.pse__Role__c + tempRate.pse__Practice__c;
            mapExistingRateCards.put(key, tempRate.Id);
        }
    }

    public ExceptionLogger__c[] convertCSVToObj(String csvData) {

            String[] csvLines = csvData.split('\n');
            String[] csvHeader = csvLines[0].split(csvSeparator);
            pse__Rate_Card__c[] lstUpsertRateCards = new pse__Rate_Card__c[]{};

            ExceptionLogger__c exceptionLogger;
            List<ExceptionLogger__c> listaExceptionLogger = new List<ExceptionLogger__c>();

            Map<Id,pse__Rate_Card__c> mapRateCard = new Map<Id,pse__Rate_Card__c>();

            for (Integer i=1; i < csvLines.size(); i++) {

                try{
                    pse__Rate_Card__c newRateCard = new pse__Rate_Card__c();
                    String[] lstValues = csvLines[i].trim().split(csvSeparator);
                
                    newRateCard.pse__Region__c = this.mapRegionNameId.get(lstValues[0].toLowerCase());
                    newRateCard.pse__Role__c = lstValues[1];
                    newRateCard.pse__Average_Cost_Rate__c = Decimal.valueOf(lstValues[2]);
                    newRateCard.CurrencyIsoCode = lstValues[3];
                    newRateCard.pse__Practice__c = this.mapPracticeId.get(lstValues[4].toLowerCase());
                    if (newRateCard.pse__Practice__c == null) { throw new CardImporterException('Given Practice did not match any existing Practice records. Value given: "'+ lstValues[4] +'"'); }
                    newRateCard.pse__Suggested_Bill_Rate__c = newRateCard.pse__Average_Cost_Rate__c;
                    newRateCard.pse__Cascading_Role__c = true;

                    String key = '' + newRateCard.pse__Region__c + newRateCard.pse__Role__c + newRateCard.pse__Practice__c;
                    if (this.mapExistingRateCards.containsKey(key)) {
                        newRateCard.Id = this.mapExistingRateCards.get(key);
                        mapRateCard.put(newRateCard.Id, newRateCard);
                    }else{ lstUpsertRateCards.add(newRateCard); }

                }catch (Exception e){
                    System.debug('>>> ' + e.getMessage());
                    exceptionLogger = new ExceptionLogger__c(
                            Apex_Class__c = 'RateCardImporter',
                            Method_Name__c = 'convertCSVToObj()',
                            Description__c = 'Error importing createRateCardsCSV: \n' + e.getMessage() + '\n' + e.getStackTraceString() + '\n' +
                                    e.getCause() + '\n' + e.getLineNumber() + '\nCSV Line: ' + i,
                            Error_Code__c = e.getMessage(),
                            Object_Name__c = 'pse__Rate_Card__c',
                            User_Name__c = UserInfo.getName()
                    );

                    listaExceptionLogger.add(exceptionLogger);
			
                }
                
            }
 
            lstUpsertRateCards.addAll(mapRateCard.values());    
            Database.UpsertResult[] savedResults = Database.upsert(lstUpsertRateCards, false);
            
            for (Database.UpsertResult r : savedResults) {

                if (!r.isSuccess()) {
                    for (Database.Error e : r.getErrors()) {
                        exceptionLogger = new ExceptionLogger__c(
                            Apex_Class__c = 'RateCardImporter',
                            Method_Name__c = 'convertCSVToObj()',
                            Description__c = 'Error importing createRateCardsCSV: \n' + e.getMessage() + '\n' + e.getFields(),
                            Error_Code__c = e.getMessage(),
                            Object_Name__c = 'pse__Rate_Card__c',
                            User_Name__c = UserInfo.getName()
                        );
                        listaExceptionLogger.add(exceptionLogger);
                    }
                }
            }

            if(listaExceptionLogger.size() > 0) { upsert listaExceptionLogger; }
            return listaExceptionLogger;
    }

    @AuraEnabled
    public static ExceptionLogger__c[] upsertFromCSV(String csvData) {
        return new RateCardImporter().convertCSVToObj(csvData);
    }

    public class CardImporterException extends Exception { }
}