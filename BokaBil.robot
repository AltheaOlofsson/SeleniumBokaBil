*** Settings ***
Documentation   TestFile för att boka bil
Library     SeleniumLibrary
Resource    BokaBilResources.robot
Suite Setup     SetupBrowser    ${urlRental}




*** Test Cases ***
BookCarWhenLoggedIn
    Given I log in to rental    ${userEmail}    ${userPassword}
    When I attempt to book car
    And I fill in booking
    Then Booked car should be added to my page
    And I Log Out


CancelBookingOfCar
    Given I make sure I am logged in
    When I cancel a booking
    Then Car should not be visible on My Page


BookCarWhenNotLoggedIn
    When I attempt to book car
    Then Alert Should be presented
