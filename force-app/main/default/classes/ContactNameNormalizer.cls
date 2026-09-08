/**
 * Normalizes editable Contact name fields before records are saved.
 */
public with sharing class ContactNameNormalizer {
    /**
     * Applies name casing to the first and last names of each Contact.
     *
     * @param contacts Contacts being inserted or updated.
     */
    public static void normalizeNames(List<Contact> contacts) {
        for (Contact contactRecord : contacts) {
            contactRecord.FirstName = toNameCase(contactRecord.FirstName);
            contactRecord.LastName = toNameCase(contactRecord.LastName);
        }
    }

    private static String toNameCase(String value) {
        if (String.isBlank(value)) {
            return value;
        }

        String normalizedValue = '';
        Boolean capitalizeNext = true;
        String lowercaseValue = value.toLowerCase();

        for (Integer index = 0; index < lowercaseValue.length(); index++) {
            String character = lowercaseValue.substring(index, index + 1);
            normalizedValue += capitalizeNext
                ? character.toUpperCase()
                : character;
            capitalizeNext =
                character == ' ' ||
                character == '-' ||
                character == '\'';
        }

        return normalizedValue;
    }
}
