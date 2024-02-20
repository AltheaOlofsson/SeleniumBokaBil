*** Settings ***
Documentation   resource fil för test av rental3.infotiv.net
Library     SeleniumLibrary
Library     Collections
Library     OperatingSystem


*** Variables ***
${urlRental}    https://rental3.infotiv.net/
#login
${userEmail}    robot.selenium@robot.se
${userPassword}     123Robot
${LoggedIn}     False
${verify}       False
${CarToBeBooked}    //input[@id='bookTTpass5']
${LPOfBookedCar}    DHW439




*** Keywords ***
SetupBrowser
    [Documentation]     Opens Chrome
    [Tags]      Setup
    [Arguments]     ${urlRental}
    Open Browser    browser=Chrome
    Go To    ${urlRental}
    Wait Until Element Is Visible    //h1[@id='title']


#Login And Logout
LogInRental
    [Documentation]     Logs in on Rental Website
    [Tags]      Login
    [Arguments]     ${userEmail}    ${userPassword}
    Input Text    //input[@id='email']      ${userEmail}
    Input Text    //input[@id='password']    ${userPassword}  
    Click Element    //button[@id='login']
    Wait Until Element Is Visible    //label[@id='welcomePhrase']

CheckIfLoggedIn
    [Documentation]     Checks if user is logged in
    [Tags]      VerifyLoggedIn
    [Arguments]     ${LoggedIn}
    ${LoggedIn}=   Set Variable If    Element should be visible    //label[@id='welcomePhrase']    True     False
    RETURN    ${LoggedIn}

LogOut
    [Documentation]     Logs out from rental
    [Tags]      Logout
    Click Element    //button[@id='logout']

MakeSureImLoggedIn
    [Documentation]     Checks if logged in, Logs in if false.
    [Tags]      AssureLoggedIn
    ${LoginStatus}=     Run Keyword And Return Status    CheckIfLoggedIn    ${LoggedIn}
    Run Keyword If    not ${logged_in}    LogInRental    ${userEmail}    ${userPassword}
    Wait Until Element Is Visible    //label[@id='welcomePhrase']



#Find and book Cars
AttemptToBookVolvo
    [Documentation]     Attempt to book volvoXC90
    [Tags]      BookCar
    Click Element    //button[@id='continue']
    Wait Until Element Is Visible    //h1[@id='questionText']
    Click Element    ${CarToBeBooked}

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


#Verifications
VerifyCarToBeBooked
    [Documentation]     Verifies that the car is added to my Page
    [Tags]      BookedCars
    Click Element    //form[@name='logOut']//button[@id='mypage']
    Wait Until Element Is Visible    //h1[@id='historyText']
    @{LicencePlates}    CreateListofLicenceNumbers
    List Should Contain Value    ${LicencePlates}    ${LPOfBookedCar}

CreateListofLicenceNumbers
    [Documentation]     Creates a list of licence numbers of all booked cars
    [Tags]    AllBookedCars
    @{productTitles}     Create List
        FOR    ${locatorIndex}    IN RANGE    1    100
            ${element_present}=    Run Keyword And Return Status    Element Should Be Visible    //td[@id='licenseNumber${locatorIndex}']
            IF    ${element_present} == True
                @{WebpageProducts}       Get WebElements     //td[@id='licenseNumber${locatorIndex}']
                    FOR    ${element}    IN    @{WebpageProducts}
                        ${product_title}     Get Text    ${element}
                        Append To List     ${productTitles}       ${product_title}
                    END
            ELSE
                BREAK
            END
        END
    RETURN      ${productTitles}


FindIndexOfBookedCar
    [Documentation]     returns index of the booked car
    [Tags]    indexList
    ${BookedCars} =     CreateListofLicenceNumbers
    ${index} =    Get Index From List    ${BookedCars}    ${LPOfBookedCar}
    ${indexPlusOne} =   Evaluate     ${index} + 1
    RETURN    ${indexPlusOne}




#Cancel Bookings
CancelAndVerifyBooking
    [Documentation]     Checks if logged in, logs in if not and then cancels a booking and verifies it is removed from myPage.
    [Tags]      CancelAndVerify
    MakeSureImLoggedIn
    CancelBooking
    VerifyCancelation

CancelBooking   #(The third car)
    [Documentation]     Cancels a booking and returns to myPage
    [Tags]      Cancel
    Click Element    //button[@id='mypage']
    Wait Until Element Is Visible    //button[@id='unBook3']
    ${IndexOfCar} =     FindIndexOfBookedCar
    Click Element    //button[@id='unBook${IndexOfCar}']
    Handle Alert
    Click Element    //button[@id='mypage']

VerifyCancelation
    [Documentation]     Verifies a previously booked car is removed when canceled
    [Tags]      VerifyCancel
    @{LicencePlates}    CreateListofLicenceNumbers
    List Should Not Contain Value    ${LicencePlates}    ${LPOfBookedCar}



#Negative Tests
VerifyNotLoggedIn
    [Documentation]     Verifies that LoginPrompt is presented when booking is attempted when not logged in.
    [Tags]      Verify
    Alert Should Be Present



#GerkinTest
IAmLoggedIn
    [Documentation]     Enters credentials and verifies Logged in
    [Tags]      VG_Test
    MakeSureImLoggedIn

IBookACarAndFillInPayment
    [Documentation]     Chooses a car, press book and fill in payment information
    [Tags]      VG_Test
    AttemptToBookVolvo
    FillInBooking

CarShouldBeAddedToMyPage
    [Documentation]     Goes to my page and verifies the car is added to bookings
    [Tags]      VG_Test
    VerifyCarToBeBooked























WrongCardNumberFormatShouldProducePrompt
    [Documentation]
    [Tags]
    MakeSureImLoggedIn
    AttemptToBookVolvo
    FillInWrongCardNumberFormat
    AssertPromptIsVisible


FillInWrongCardNumberFormat
    [Documentation]
    [Tags]
    Wait Until Element Is Visible    //h1[@id='questionText']
    Input Text    //input[@id='cardNum']    5555555555555555
    Input Text    //input[@id='fullName']    Robot Selenium
    Select From List By Label    //select[@title='Month']    5
    Select From List By Label    //select[@title='Year']    2025
    Input Text    //input[@id='cvc']    888
    Click Element    //button[@id='confirm']

AssertPromptIsVisible
    [Documentation]
    [Tags]
    ${alertmessage}     Execute Javascript      return window.prompt.toString()
    Run Keyword If    "${alertmessage}" != ${EMPTY}    Set Test Variable    ${verify}     True
    Run Keyword If    "${alertmessage}" == ${EMPTY}    Set Test Variable    ${verify}     False
    Should Be True    ${verify}
