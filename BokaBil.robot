*** Settings ***
Documentation   TestFile för att boka bil
Library     SeleniumLibrary
Resource    BokaBilResources.robot
Suite Setup     SetupBrowser    ${urlRental}




*** Test Cases ***
BookCarWhenLoggedIn
    Given I log in to rental    ${userEmail}    ${userPassword}
    And I select Dates
    When I attempt to book a car
    And I fill in booking
    Then Booked car should be added to my page
    And I Log Out


CancelBookingOfCar
    Given I make sure I am logged in
    When I cancel a booking
    Then Car should not be visible on My Page
    And I Log Out


Changing dates to rent a car
    Given I Make Sure I Am Logged In
    When I Select Dates
    Then Search for selected dates are visible
    And I Log Out


AttemptToBookCarWhenNotLoggedInGivesAlert
    Given I am at startpage
    When I attempt to book a car
    Then Alert Should be presented


Log in with wrong Email gives error
    When I Attempt login with wrong Email   ${WrongEmail}   ${userPassword}
    Then Login Error should be visible

