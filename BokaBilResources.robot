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
    [Tags]      Login
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
    [Tags]      Logout
    Click Element    //button[@id='logout']

I make sure I am logged in
    [Documentation]     Checks if logged in, Logs in if false.
    [Tags]      AssureLoggedIn
    ${LoginStatus}=     Run Keyword And Return Status    Check if I am Logged In    ${LoggedIn}
    Run Keyword If    not ${logged_in}    I log in to rental    ${userEmail}    ${userPassword}
    Wait Until Element Is Visible    //label[@id='welcomePhrase']



#Find and book Cars
I attempt to book car
    [Documentation]     Attempt to book Car
    [Tags]      BookCar
    Click Element    //button[@id='continue']
    Wait Until Element Is Visible    //h1[@id='questionText']
    Click Element    ${AudiTT}

I fill in Booking
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
Booked car should be added to my page
    [Documentation]     Verifies that the car is added to my Page
    [Tags]      BookedCars
    Click Element    //form[@name='logOut']//button[@id='mypage']
    Wait Until Element Is Visible    //h1[@id='historyText']
    @{LicencePlates}    CreateListofLicenceNumbers
    List Should Contain Value    ${LicencePlates}    ${LPOfBookedCar}

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
I cancel a booking   #(The third car)
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
    [Tags]      Verify
    Alert Should Be Present
















