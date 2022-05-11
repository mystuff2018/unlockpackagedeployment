/*
      Purpose:
            Facilitate the construction of valid SOQL strings based on parameters passed
            
      Initiative: Dell Thunderbolt PSA Implementation
      Author:     Alan Birchenough
      Company:    Icon Cloud Consulting
      Contact:    alan.birchenough@iconatg.com
      Created:    9/3/18
*/

public class SoqlQuery {
    private static final String LOG_PREFIX = 'SoqlQuery: ';
    private String objectName;
    private Set<String> selectSet;
    private List<SoqlQuery> privateSubQueries = new List<SoqlQuery>();
    private String whereCondition;
    private String orderClause;

    public SoqlQuery(String objectName, Set<String> selectSet) {
        this.objectName = objectName;
        this.selectSet = selectSet;
    }
    public SoqlQuery(String objectName, Set<String> selectSet, String whereCondition) {
        this.objectName = objectName;
        this.selectSet = selectSet;
        this.whereCondition = whereCondition;
    }
    public SoqlQuery(String objectName, Set<String> selectSet, String whereCondition, String orderClause) {
        this.objectName = objectName;
        this.selectSet = selectSet;
        this.whereCondition = whereCondition;
        this.orderClause = orderClause;
    }

    public List<SoqlQuery> SubQueries {get {return privateSubQueries;}}

    public String toSoql() {
        List<String> selectList = new List<String>();
        selectList.addAll(selectSet);
        String subQuerySoql = '';
        if (!privateSubQueries.isEmpty()) {
            subQuerySoql += ', ';
            Integer index = 0;
            for (SoqlQuery subQuery : privateSubQueries) {
                subQuerySoql += '(';
                subQuerySoql += subQuery.toSoql();
                subQuerySoql += ')';
                index++;
                if (index < privateSubQueries.size()) {
                    subQuerySoql += ', ';
                }
            }
        }
        String result =
                'select '+
                        delimitedStringFromArray(selectList, ', ') +
                        subQuerySoql +
                        ' from ' +
                        objectName +
                        ' '+
                        (whereCondition == null ? '':
                                'where '+
                                        whereCondition) +
                        (orderClause == null ? '':
                                ' order by '+
                                        orderClause)
        ;
        System.debug(LOG_PREFIX + 'generated query: ' + result);
        return result.trim();
    }
    public static String idCollectionLiteral(Set<Id> ids) {
        Set<String> stringsForIds = new Set<String>();
        for (Id id : ids) {
            stringsForIds.add(id);
        }
        return stringCollectionLiteral(stringsForIds);
    }
    public static String stringCollectionLiteral(Set<String> strings) {
        List<String> stringArray = new List<String>();
        stringArray.addAll(strings);
        return '(\''+delimitedStringFromArray(stringArray,'\',\'')+'\')';
    }
    private static String delimitedStringFromArray(String[] arr, String delimiter) {
        String result = '';
        if (!arr.isEmpty()) {
            for (Integer index=0; index < arr.size(); index++) {
                if (index > 0) {
                    result += delimiter;
                }
                result += arr[index];
            }
        }
        return result;
    }
}