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
