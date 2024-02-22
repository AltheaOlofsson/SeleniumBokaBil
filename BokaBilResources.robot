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
${WrongEmail}   wrong.seleniumrobot.se
#Car to be Booked
${AudiTT}    //input[@id='bookTTpass5']
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
I log in to rental
    [Documentation]     Logs in on Rental Website
    [Tags]      Login   VG_Test
    [Arguments]     ${userEmail}    ${userPassword}
    Input Text    //input[@id='email']      ${userEmail}
    Input Text    //input[@id='password']    ${userPassword}  
    Click Element    //button[@id='login']
    Wait Until Element Is Visible    //label[@id='welcomePhrase']

Check if I am Logged In
    [Documentation]     Checks if user is logged in
    [Tags]      VerifyLoggedIn
    [Arguments]     ${LoggedIn}
    ${LoggedIn}=   Set Variable If    Element should be visible    //label[@id='welcomePhrase']    True     False
    RETURN    ${LoggedIn}

I Log Out
    [Documentation]     Logs out from rental
    [Tags]      Logout      VG_Test
    Click Element    //button[@id='logout']

I make sure I am logged in
    [Documentation]     Checks if logged in, Logs in if false.
    [Tags]      AssureLoggedIn
    ${LoginStatus}=     Run Keyword And Return Status    Check if I am Logged In    ${LoggedIn}
    Run Keyword If    not ${logged_in}    I log in to rental    ${userEmail}    ${userPassword}
    Wait Until Element Is Visible    //label[@id='welcomePhrase']
    I am at startpage

I am at startpage
    [Documentation]     Makes sure i am at start page
    [Tags]     Startpage
    Click Element    //h1[@id='title']
    Wait Until Element Is Visible    //h1[@id='questionText']



#Select Dates
I Select Dates
    [Documentation]     choose dates to rent car
    [Tags]      SelectDate      VG_Test
    Input Text    //input[@id='start']    0228
    Click Element    //input[@id='end']
    Input Text    //input[@id='end']    0303

Search for selected dates are visible
    [Documentation]     verifies that the entered timeperiod is shown
    [Tags]      verifyDateSelection
    Click Element    //button[@id='continue']
    Page Should Contain    2024-02-28 – 2024-03-03

#Find and book Cars
I attempt to book a car
    [Documentation]     Attempt to book Car,
    [Tags]      BookCar     VG_Test
    Click Element    //button[@id='continue']
    Wait Until Element Is Visible    //label[@for='start']
    Click Element    ${AudiTT}

I fill in Booking
    [Documentation]     Fill in the form to book a car
    [Tags]      Fill in form        VG_Test
    Wait Until Element Is Visible    //h1[@id='questionText']
    Input Text    //input[@id='cardNum']    5555777733331111
    Input Text    //input[@id='fullName']    Robot Selenium
    Select From List By Label    //select[@title='Month']    5
    Select From List By Label    //select[@title='Year']    2025
    Input Text    //input[@id='cvc']    888
    Click Element    //button[@id='confirm']
    Wait Until Element Is Visible    //h1[@id='questionTextSmall']

Booked car should be added to my page
    [Documentation]     Verifies that the car is added to my Page
    [Tags]      BookedCars      VG_Test
    Click Element    //form[@name='logOut']//button[@id='mypage']
    Wait Until Element Is Visible    //h1[@id='historyText']
    @{LicencePlates}    CreateListofLicenceNumbers
    List Should Contain Value    ${LicencePlates}    ${LPOfBookedCar}


#Lists
CreateListofLicenceNumbers
    [Documentation]     Creates a list of licence numbers of all booked cars
    [Tags]    AllBookedCars
    @{LicencePlates}     Create List
        FOR    ${IndexNumber}    IN RANGE    1    100
            ${elementIsPresent}=    Run Keyword And Return Status    Element Should Be Visible    //td[@id='licenseNumber${IndexNumber}']
            IF    ${elementIsPresent} == True
                @{BookedCarsLP}       Get WebElements     //td[@id='licenseNumber${IndexNumber}']
                    FOR    ${CarPlate}    IN    @{BookedCarsLP}
                        ${LicenceNumber}     Get Text    ${CarPlate}
                        Append To List     ${LicencePlates}       ${LicenceNumber}
                    END
            ELSE
                BREAK
            END
        END
    RETURN      ${LicencePlates}

FindIndexOfBookedCar
    [Documentation]     returns index of the booked car
    [Tags]    indexList
    ${BookedCars} =     CreateListofLicenceNumbers
    ${index} =    Get Index From List    ${BookedCars}    ${LPOfBookedCar}
    ${indexPlusOne} =   Evaluate     ${index} + 1
    RETURN    ${indexPlusOne}




#Cancel Bookings
I cancel a booking
    [Documentation]     Cancels a booking and returns to myPage
    [Tags]      Cancel
    Click Element    //button[@id='mypage']
    Wait Until Element Is Visible    //button[@id='unBook1']
    ${IndexOfCar} =     FindIndexOfBookedCar
    Click Element    //button[@id='unBook${IndexOfCar}']
    Handle Alert
    Click Element    //button[@id='mypage']

Car should not be visible on My Page
    [Documentation]     Verifies a previously booked car is removed when canceled
    [Tags]      VerifyCancel
    @{LicencePlates}    CreateListofLicenceNumbers
    List Should Not Contain Value    ${LicencePlates}    ${LPOfBookedCar}



#Negative Tests
Alert Should be presented
    [Documentation]     Verifies that LoginPrompt is presented when booking is attempted when not logged in.
    [Tags]      NotLoggedIn
    Alert Should Be Present

I Attempt login with wrong Email
    [Documentation]     Attempt to log in to rental with an invalid Email should produce an error message
    [Tags]      WrongEmail
    [Arguments]     ${WrongEmail}   ${userPassword}
    Input Text    //input[@id='email']    ${WrongEmail}
    Input Text    //input[@id='password']    ${userPassword}
    Click Element    //button[@id='login']

Login Error should be visible
    [Documentation]     Attempt to log in to rental with an invalid Email should produce an error message
    [Tags]    WrongEmailError
    Element Should Be Visible    //label[@id='signInError']















