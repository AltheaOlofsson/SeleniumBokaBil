*** Settings ***
Documentation   resource fil för test av boka bil
Library     SeleniumLibrary
Library    Collections
Library    OperatingSystem


*** Variables ***
${urlRental}    https://rental3.infotiv.net/
${userEmail}    robot.selenium@robot.se
${userPassword}     123Robot
${LoggedIn}     False






*** Keywords ***
SetupBrowser
    [Documentation]     Opens Chrome
    [Tags]      Setup
    [Arguments]     ${urlRental}
    Open Browser    browser=Chrome
    Go To    ${urlRental}
    Wait Until Element Is Visible    //h1[@id='title']

LogInRental
    [Documentation]     Logs in on Rental Website
    [Tags]      Login
    [Arguments]     ${userEmail}    ${userPassword}
    Input Text    //input[@id='email']      ${userEmail}
    Input Text    //input[@id='password']    ${userPassword}  
    Click Element    //button[@id='login']
    Wait Until Element Is Visible    //label[@id='welcomePhrase']

AttemptToBookVolvo
    [Documentation]     Attempt to book volvoXC90
    [Tags]      BookCar
    Click Element    //button[@id='continue']
    Wait Until Element Is Visible    //h1[@id='questionText']
    Click Element    //tbody/tr[30]/td[5]/form[1]/input[4]
    
    
FillInBooking
    [Documentation]     Fill in the form to book a car
    [Tags]      Fill in form
    Wait Until Element Is Visible    //h1[@id='questionText']
    Input Text    //input[@id='cardNum']    5555777733331111
    Input Text    //input[@id='fullName']    Robot Selenium
    Select From List By Label    //select[@title='Month']    5
    Select From List By Label    //select[@title='Year']    2025
    Input Text    //input[@id='cvc']    888
    Click Element    //button[@id='confirm']
    Wait Until Element Is Visible    //h1[@id='questionTextSmall']

VerifyCarToBeBooked
    [Documentation]     Verifies that the car is added to my Page
    [Tags]      BookedCars
    Click Element    //form[@name='logOut']//button[@id='mypage']
    Wait Until Element Is Visible    //h1[@id='historyText']
    @{LicencePlates}    CreateListofLicenceNumbers
    List Should Contain Value    ${LicencePlates}    JKI321

CreateListofLicenceNumbers
    [Documentation]     Creates a list of licence numbers of all booked cars
    [Tags]    AllBookedCars

    @{productTitles}     Create List
    
    FOR    ${locatorIndex}    IN RANGE    1    100
        @{WebpageProducts}       Get WebElements     //td[@id='licenseNumber${locatorIndex}']
            FOR    ${element}    IN    @{WebpageProducts}
                ${product_title}     Get Text    ${element}
                Append To List     ${productTitles}       ${product_title}

            END
    END
    RETURN      ${productTitles}




CancelShouldProduceAlert
    [Documentation]
    [Tags]
    ${LoginStatus}=     Run Keyword And Return Status    CheckIfLoggedIn    ${LoggedIn}
    Run Keyword If    not ${logged_in}    LogInRental    ${userEmail}    ${userPassword}
    CancelBooking


CancelBooking
    [Documentation]     Cancels a booked car
    [Tags]      Cancel
    Click Element    //button[@id='mypage']
    Wait Until Element Is Visible    //button[@id='unBook3']
    Click Element    //button[@id='unBook3']
    Handle Alert
    Click Element    //button[@id='mypage']
        @{LicencePlates}    CreateListofLicenceNumbers
    List Should Not Contain Value    ${LicencePlates}    JKI321


CheckIfLoggedIn
    [Documentation]     Checks if user is logged in
    [Tags]      VerifyLoggedIn
    [Arguments]     ${LoggedIn}
    ${LoggedIn}=   Set Variable If    Element should be visible    //label[@id='welcomePhrase']    True     False
    RETURN    ${LoggedIn}
    
    
LogOut
    [Documentation]
    [Tags]
    Click Element    //button[@id='logout']




    





VerifyNotLoggedIn
    [Documentation]     Verifies that LoginPrompt is presented when booking is attempted when not logged in.
    [Tags]      Verify
    Alert Should Be Present
    





