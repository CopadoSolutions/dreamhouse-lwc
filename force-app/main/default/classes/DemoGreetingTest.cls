@IsTest
private class DemoGreetingTest {
    @IsTest
    static void greetReturnsHelloWithName() {
        System.assertEquals('Hello, Ada', DemoGreeting.greet('Ada'));
    }

    @IsTest
    static void greetFallsBackWhenNameIsBlank() {
        System.assertEquals('Hello, there', DemoGreeting.greet('  '));
    }
}