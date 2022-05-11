// /*
//       Purpose:
//             Test the simple SOQL query builder class
            
//       Initiative: Dell Thunderbolt PSA Implementation
//       Author:     Alan Birchenough
//       Company:    Icon Cloud Consulting
//       Contact:    alan.birchenough@iconatg.com
//       Created:    9/19/18
// */

 @IsTest
 private class SoqlQueryTest {
//     @IsTest
//     static void testTwoArgumentConstructor() {
//         String expected = 'select Id, Name, WhatNot__c from Thing__c';
//         SoqlQuery testQuery = new SoqlQuery('Thing__c', new Set<String>{'Id','Name','WhatNot__c'});
//         System.assertEquals(expected, testQuery.toSoql());
//     }
//     @IsTest
//     static void testSubQueryFormatting() {
//         String expected = 'select Id, Name, WhatNot__c, (select Id, Name, Doodab__c from Gadgets__r) from Thing__c';
//         SoqlQuery testQuery = new SoqlQuery('Thing__c', new Set<String>{'Id','Name','WhatNot__c'});
//         SoqlQuery testSubQuery = new SoqlQuery('Gadgets__r', new Set<String>{'Id','Name','Doodab__c'});
//         testQuery.SubQueries.add(testSubQuery);
//         System.assertEquals(expected, testQuery.toSoql());
//     }
//     @IsTest
//     static void testThreeArgumentConstructor() {
//         String expected = 'select Id, Name, WhatNot__c from Thing__c where Thing__c <> null';
//         SoqlQuery testQuery =
//             new SoqlQuery(
//                 'Thing__c',
//                 new Set<String>{'Id','Name','WhatNot__c'},
//                 'Thing__c <> null'
//             );
//         System.assertEquals(expected, testQuery.toSoql());
//     }
//     @IsTest
//     static void testFourArgumentConstructor() {
//         String expected = 'select Id, Name, WhatNot__c from Thing__c where Thing__c <> null order by Name desc';
//         SoqlQuery testQuery =
//                 new SoqlQuery(
//                         'Thing__c',
//                         new Set<String>{'Id','Name','WhatNot__c'},
//                         'Thing__c <> null',
//                         'Name desc'
//                 );
//         System.assertEquals(expected, testQuery.toSoql());
//     }
//     @IsTest
//     static void testIdCollectionLiteral() {
//         Set<Id> testIdSet = new Set<Id>{'a2A3D000000QNHtUAO','a2A3D000000ND4BUAW'};
//         String actual = SoqlQuery.idCollectionLiteral(testIdSet);
//         System.assertEquals('(\'a2A3D000000QNHtUAO\',\'a2A3D000000ND4BUAW\')',actual);
//     }
//     @IsTest
//     static void testStringCollectionLiteral() {
//         Set<String> testStringSet = new Set<String>{'The','quick','brown','fox'};
//         String actual = SoqlQuery.stringCollectionLiteral(testStringSet);
//         System.assertEquals('(\'The\',\'quick\',\'brown\',\'fox\')',actual);
//     }
 }