@isTest
private class TestPropertyController {
    private final static String MOCK_PICTURE_NAME = 'MockPictureName';

    public static void createProperties(Integer amount) {
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 0; i < amount; i++) {
            properties.add(
                new Property__c(
                    Name = 'Name ' + i,
                    Price__c = 20000,
                    Beds__c = 3,
                    Baths__c = 3
                )
            );
        }
        insert properties;
    }

    @isTest
    static void testGetPagedPropertyList() {
        Profile standardUserProfile = [
            SELECT Name, Id
            FROM Profile
            WHERE
                UserType = 'Standard'
                AND PermissionsPrivacyDataAccess = FALSE
                AND PermissionsSubmitMacrosAllowed = TRUE
                AND PermissionsMassInlineEdit = TRUE
            LIMIT 1
        ];
        User testUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser@dreamhouse-testorg.com'
        );
        insert testUser;
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'dreamhouse'
        ];
        insert new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = ps.Id
        );

        // Insert test properties as admin
        System.runAs(new User(Id = UserInfo.getUserId())) {
            TestPropertyController.createProperties(5);
        }
        // Read properties as test user
        System.runAs(testUser) {
            Test.startTest();
            PagedResult result = PropertyController.getPagedPropertyList(
                '',
                999999,
                0,
                0,
                10,
                1
            );
            Test.stopTest();
            Assert.areEqual(5, result.records.size());
        }
    }

    @isTest
    static void testGetPagedPropertyListDefaultPageSize() {
        TestPropertyController.createProperties(15);

        Test.startTest();
        PagedResult result = PropertyController.getPagedPropertyList(
            '',
            999999,
            0,
            0,
            null,
            1
        );
        Test.stopTest();

        Assert.areEqual(12, result.pageSize);
        Assert.areEqual(12, result.records.size());
        Assert.areEqual(15, result.totalItemCount);

        PagedResult page2 = PropertyController.getPagedPropertyList(
            '',
            999999,
            0,
            0,
            null,
            2
        );
        Assert.areEqual(12, page2.pageSize);
        Assert.areEqual(3, page2.records.size());
        Assert.areEqual(15, page2.totalItemCount);
    }

    @isTest
    static void testGetSimilarProperties() {
        // Setup: create a base property and several candidate properties
        Property__c baseProperty = new Property__c(
            Name = 'Base Property',
            City__c = 'San Francisco',
            Price__c = 500000,
            Beds__c = 3,
            Baths__c = 2
        );
        insert baseProperty;

        // Within range: same city, prices within 20% (400000 - 600000)
        List<Property__c> similarOnes = new List<Property__c>{
            new Property__c(
                Name = 'Similar 1',
                City__c = 'San Francisco',
                Price__c = 480000,
                Beds__c = 2,
                Baths__c = 1
            ),
            new Property__c(
                Name = 'Similar 2',
                City__c = 'San Francisco',
                Price__c = 550000,
                Beds__c = 4,
                Baths__c = 3
            )
        };

        // Out of range: different city or price outside 20% band
        List<Property__c> excludedOnes = new List<Property__c>{
            new Property__c(
                Name = 'Other City',
                City__c = 'Los Angeles',
                Price__c = 500000,
                Beds__c = 3,
                Baths__c = 2
            ),
            new Property__c(
                Name = 'Too Expensive',
                City__c = 'San Francisco',
                Price__c = 700000,
                Beds__c = 5,
                Baths__c = 4
            ),
            new Property__c(
                Name = 'Too Cheap',
                City__c = 'San Francisco',
                Price__c = 200000,
                Beds__c = 1,
                Baths__c = 1
            )
        };

        insert similarOnes;
        insert excludedOnes;

        Test.startTest();
        List<Property__c> results = PropertyController.getSimilarProperties(
            baseProperty.Id
        );
        Test.stopTest();

        // Only the 2 in-range, same-city properties should be returned
        Assert.areEqual(2, results.size(), 'Expected 2 similar properties');

        // Collect returned names for assertion
        Set<String> returnedNames = new Set<String>();
        for (Property__c p : results) {
            returnedNames.add(p.Name);
        }
        Assert.isTrue(
            returnedNames.contains('Similar 1'),
            'Similar 1 should be included'
        );
        Assert.isTrue(
            returnedNames.contains('Similar 2'),
            'Similar 2 should be included'
        );

        // The base property itself must not be returned
        for (Property__c p : results) {
            Assert.areNotEqual(
                baseProperty.Id,
                p.Id,
                'Base property must be excluded from results'
            );
        }
    }

    @isTest
    static void testGetSimilarPropertiesMaxFive() {
        // Verify the result is capped at 5 even when more matches exist
        Property__c baseProperty = new Property__c(
            Name = 'Base Property',
            City__c = 'Austin',
            Price__c = 300000,
            Beds__c = 2,
            Baths__c = 1
        );
        insert baseProperty;

        List<Property__c> candidates = new List<Property__c>();
        for (Integer i = 0; i < 7; i++) {
            candidates.add(
                new Property__c(
                    Name = 'Candidate ' + i,
                    City__c = 'Austin',
                    Price__c = 300000,
                    Beds__c = 2,
                    Baths__c = 1
                )
            );
        }
        insert candidates;

        Test.startTest();
        List<Property__c> results = PropertyController.getSimilarProperties(
            baseProperty.Id
        );
        Test.stopTest();

        Assert.isTrue(
            results.size() <= 5,
            'Result must be capped at 5 properties'
        );
    }

    @isTest
    static void testGetPicturesNoResults() {
        Property__c property = new Property__c(Name = 'Name');
        insert property;

        Test.startTest();
        List<ContentVersion> items = PropertyController.getPictures(
            property.Id
        );
        Test.stopTest();

        Assert.isNull(items);
    }

    @isTest
    static void testGetPicturesWithResults() {
        Property__c property = new Property__c(Name = 'Name');
        insert property;

        // Insert mock picture
        ContentVersion picture = new Contentversion();
        picture.Title = MOCK_PICTURE_NAME;
        picture.PathOnClient = 'picture.png';
        picture.Versiondata = EncodingUtil.base64Decode('MockValue');
        insert picture;

        // Link picture to property record
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument
            LIMIT 1
        ];
        ContentDocumentLink link = new ContentDocumentLink();
        link.LinkedEntityId = property.Id;
        link.ContentDocumentId = documents[0].Id;
        link.shareType = 'V';
        insert link;

        Test.startTest();
        List<ContentVersion> items = PropertyController.getPictures(
            property.Id
        );
        Test.stopTest();

        Assert.areEqual(1, items.size());
        Assert.areEqual(MOCK_PICTURE_NAME, items[0].Title);
    }

    @isTest
    static void testGetSimilarProperties() {
        Property__c currentProperty = new Property__c(
            Name = 'Current',
            City__c = 'Boston',
            Price__c = 100000,
            Beds__c = 3,
            Baths__c = 2
        );
        List<Property__c> properties = new List<Property__c>{
            currentProperty,
            new Property__c(
                Name = 'Low Bound',
                City__c = 'Boston',
                Price__c = 80000,
                Beds__c = 2,
                Baths__c = 1
            ),
            new Property__c(
                Name = 'Mid Range',
                City__c = 'Boston',
                Price__c = 110000,
                Beds__c = 3,
                Baths__c = 2
            ),
            new Property__c(
                Name = 'High Bound',
                City__c = 'Boston',
                Price__c = 120000,
                Beds__c = 4,
                Baths__c = 2
            ),
            new Property__c(
                Name = 'Fourth Match',
                City__c = 'Boston',
                Price__c = 90000,
                Beds__c = 2,
                Baths__c = 1
            ),
            new Property__c(
                Name = 'Fifth Match',
                City__c = 'Boston',
                Price__c = 95000,
                Beds__c = 2,
                Baths__c = 2
            ),
            new Property__c(
                Name = 'Too Cheap',
                City__c = 'Boston',
                Price__c = 79999,
                Beds__c = 1,
                Baths__c = 1
            ),
            new Property__c(
                Name = 'Too Expensive',
                City__c = 'Boston',
                Price__c = 120001,
                Beds__c = 5,
                Baths__c = 3
            ),
            new Property__c(
                Name = 'Other City',
                City__c = 'Chicago',
                Price__c = 100000,
                Beds__c = 3,
                Baths__c = 2
            )
        };
        insert properties;

        Test.startTest();
        List<Property__c> similar = PropertyController.getSimilarProperties(
            currentProperty.Id
        );
        List<Property__c> missing = PropertyController.getSimilarProperties(
            null
        );
        Test.stopTest();

        Assert.isTrue(
            missing.isEmpty(),
            'A null property should return no rows'
        );
        Assert.areEqual(
            5,
            similar.size(),
            'Only five similar properties are returned'
        );

        Set<String> names = new Set<String>();
        Decimal previousPrice = 0;
        for (Property__c property : similar) {
            names.add(property.Name);
            Assert.areNotEqual(
                currentProperty.Id,
                property.Id,
                'The current property is excluded'
            );
            Assert.areEqual(
                'Boston',
                property.City__c,
                'Similar properties stay in the same city'
            );
            Assert.isTrue(
                property.Price__c >= previousPrice,
                'Results are ordered by price'
            );
            previousPrice = property.Price__c;
        }
        Assert.isTrue(
            names.contains('Low Bound'),
            'The low price boundary is included'
        );
        Assert.isTrue(
            names.contains('Fourth Match'),
            'An in-range property is included'
        );
        Assert.isTrue(
            names.contains('Fifth Match'),
            'An in-range property is included'
        );
        Assert.isTrue(
            names.contains('Mid Range'),
            'An in-range property is included'
        );
        Assert.isTrue(
            names.contains('High Bound'),
            'The high price boundary is included'
        );
        Assert.isFalse(
            names.contains('Too Cheap'),
            'A price below the range is excluded'
        );
        Assert.isFalse(
            names.contains('Too Expensive'),
            'A price above the range is excluded'
        );
        Assert.isFalse(
            names.contains('Other City'),
            'A different city is excluded'
        );
        Assert.isFalse(
            names.contains('Current'),
            'The current property is excluded'
        );
    }
}
