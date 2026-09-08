trigger ContactNameNormalization on Contact(before insert, before update) {
    ContactNameNormalizer.normalizeNames(Trigger.new);
}
