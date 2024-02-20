*** Settings ***
Documentation   resource fil för test av boka bil
Library     SeleniumLibrary
Resource    BokaBilResources.robot
Suite Setup     SetupBrowser    ${urlRental}




*** Test Cases ***
BookCarWhenLoggedIn
    LogInRental     ${userEmail}    ${userPassword}
    AttemptToBookVolvo
    FillInBooking
    VerifyCarToBeBooked
    LogOut

BookCarGherkin
    Given IAmLoggedIn
    When IBookACarAndFillInPayment
    Then CarShouldBeAddedToMyPage

CancelBookingOfCar
    CancelAndVerifyBooking




BookCarWhenNotLoggedIn
    AttemptToBookVolvo
    VerifyNotLoggedIn

WrongCardFormat
    WrongCardNumberFormatShouldProducePrompt