*** Settings ***
Documentation   TestFile för att boka bil
Library     SeleniumLibrary
Resource    BokaBilResources.robot
Suite Setup     SetupBrowser    ${urlRental}




*** Test Cases ***
Book Car When Logged In
    [Documentation]     Tests the process of booking a car. Covers several requirements.
    [Tags]      TestBookCar
    Given I log in to rental    ${userEmail}    ${userPassword}
    And I select dates
    When I attempt to book a car
    And I fill in booking
    Then Booked car should be added to my page
    And I Log Out


Cancel Booking Of Car
    [Documentation]     Tests Requirement from My Page that cancelation of booking is possible.
    [Tags]      TestCancelation
    Given I make sure I am logged in
    When I cancel a booking
    Then Car should not be visible on My Page
    And I Log Out


Changing dates to rent a car
    [Documentation]     Tests Requirement from Date Selection that valid dates take me to Car Selection.
    [Tags]      TestValidDates
    Given I Make Sure I Am Logged In
    When I Select Dates
    Then Search for selected dates are visible
    And I Log Out


Attempt To Book Car When Not Logged In Gives Alert
    [Documentation]     Tests Requirement from Car Selection that attempt to book when not logged in will produce a propmt.
    [Tags]      TestNotLoggedIn
    Given I am at startpage
    When I attempt to book a car
    Then Alert Should be presented


Log in with wrong Email gives error
    [Documentation]     Tests Requirement from Header that invalid input gives Error message.
    [Tags]      TestWrongLogin
    When I Attempt login with wrong Email   ${WrongEmail}   ${userPassword}
    Then Login Error should be visible

