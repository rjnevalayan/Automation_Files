*** Settings ***
Library    SeleniumLibrary
Library    Libraries/Users.py
Library    String
Library    Collections
Variables    Variables/variable.py

Test Setup    Launch Browser   
Suite Teardown     Close Browser

*** Variables ***
@{add_to_list}
@{identity_name_lists}

*** Test Cases ***
Test Case 1
    Fetch Data
    Go To Link
    FOR    ${user}    IN    @{USERS}
        Go To Link
        Open Add Identity Modal
        Wait Until Element Is Visible    //form//div//div//h6[text()="Identity"]    timeout=5
        Add User    ${user}
    END
    Identity Data
    Display All Names

Test Case 2
    Check User With Zero Order

*** Keywords ***

Launch Browser
    [Arguments]    ${url}=https://marmelab.com/react-admin-demo
    ${options}    Set Variable    add_argument("--start-maximized")
    Open Browser    ${url}    chrome    options=${options}
    Login Users    demo    demo

Input Text
    [Arguments]  ${locator}  ${value}
    SeleniumLibrary.Input Text    ${locator}    ${value}

Login Users
    [Arguments]    ${user}    ${password}
    Input Text    name:username    ${user}
    Input Text    name:password    ${password}
    Click Button    //button

Go To Link
    [Arguments]    ${text}=Customers
    Click Element    //a[text()="${text}"]
    Wait Until Element Is Visible    //tbody//tr

Fetch Data
    ${users}    Get Users Via Api
    Set Suite Variable    ${USERS}    ${users}

Open Add Identity Modal
    Click Element    //a[@aria-label="Create"]
    Wait Until Element Is Visible    ${identity_txt_firstName}
    Sleep  1s

Add User
    [Arguments]    ${user}
    ${firstName}    Evaluate  " ".join("${user['name']}".split()[:-1]).strip()
    ${lastName}    Evaluate  " ".join("${user['name']}".split()[-1:]).strip()
    ${state}    Generate Random String
    ${generated_password}    Generate Password

    Input Text    ${identity_txt_firstName}  ${firstName}
    Input Text    ${identity_txt_lastName}   ${lastName}
    Input Text    ${identity_txt_email}   ${user['email']}
    Input Date    ${identity_txt_birthday}   ${user['birthday']}
    Input Text    ${identity_txt_address}    ${user['address']['suite']} ${user['address']['street']}
    Input Text    ${identity_txt_city}    ${user['address']['city']}
    Input Text    ${identity_txt_state}    ${state}
    Input Text    ${identity_txt_zipcode}    ${user['address']['zipcode']}
    Input Text    ${identity_txt_password}    ${generated_password}
    Input Text    ${identity_txt_confirm_password}    ${generated_password}
    Click Button     //button[@type="submit"]

    Append To List    ${add_to_list}    ${user['name']}
    Wait Until Element Is Visible    //button[text()="Delete"]
    Go To Link

Input Date
    [Arguments]    ${locator}    ${date}
    Click Element At Coordinates    ${locator}    0    0
    Press Keys    None    ${date}

Get Created Records Displayed
    Wait WebElement to Load  
    ${web_elems}    Get WebElement    //tbody//tr
    ${len}    Get Length    ${web_elems}
    ${list}    Create List

    FOR    ${i}    IN RANGE    1    ${len}+1
        ${name}    Get Text    ((//tbody//tr)[${i}]//td)[2]
        ${name}    Evaluate    """${name}""".replace("\\n","")[1.:]


        Append To List    ${list}    ${name}
    END

    FOR    ${name}    IN    @{identity_name_lists}
        IF    '${name}' not in '${list}'
            Fail    ${name} is not included
        END
        
    END
    Log To Console    All Users Created Are Displayed

Identity Data
    FOR    ${user}    IN    @{USERS}
        Append To List    ${identity_name_lists}    ${user['name']}
    END

Display All Names
    Wait WebElement to Load
    Wait Until Element Is Visible    //tbody//tr[1]
    ${web_elems}    Get WebElements    //tbody//tr
    Sleep    6s
    ${len}    Get Length    ${web_elems}
    FOR    ${i}    IN RANGE    1   ${len}+1
        ${current_tr}    Set Variable    ((//tbody//tr)[${i}]//td)[2]
        ${tr_text}    Get Text    ${current_tr}
        ${tr_text}    Evaluate    """${tr_text}""".replace("\\n","")[1:] 
        ${orders_zero_list}  Create List
       

        ${user_status}    Set Variable
        IF    "${tr_text}" in ${add_to_list}
            ${user_status}    Set Variable    Test Created User
        ELSE
            ${user_status}    Set Variable    Existing User
        END

        
        ${last_seen}    Get Text    ((//tbody//tr)[${i}]//td)[3]
        ${orders}    Get Text    ((//tbody//tr)[${i}]//td)[4]
        ${total_spent}    Get Text    ((//tbody//tr)[${i}]//td)[5]
        ${last_purchase}    Get Text    ((//tbody//tr)[${i}]//td)[6]
        ${news}    SeleniumLibrary.Get Element Attribute    ((//tbody//tr)[${i}]//td)[7]//span//*[name()='svg']    aria-label   
        ${segments}    Get Text    ((//tbody//tr)[${i}]//td)[8]


        Log To Console    ---------- User ${i} ----------
        Log To Console    ${user_status} : ${tr_text}
        Log To Console    Last seen : ${last_seen}
        Log To Console    Orders : ${orders}
        Log To Console    Total spent : ${total_spent}
        Log To Console    Latest purchase : ${last_purchase}
        Log To Console    News : ${news}
        Log To Console    Segments : ${segments}
        
    END

Wait WebElement to Load
    [Arguments]    ${locator}=//tbody//tr[1]
    Go To Link    Customers
    Wait Until Element Is Visible    ${locator}
    Sleep    6s

Check User With Zero Order
    Wait WebElement to Load
    ${web_elems}    Get WebElements    //tbody//tr
    ${len}    Get Length    ${web_elems}

    ${list_of_users_with_zero_orders}    Create List

    FOR    ${i}    IN RANGE    1    ${len}+1
       ${name}    Get Text    ((//tbody//tr)[${i}]//td)[2]
       ${orders}    Get Text    ((//tbody//tr)[${i}]//td)[4]

       IF    '${orders}'=='0'
          ${name}    Evaluate    """${name}""".replace("\\n","")[1:]     
           Append To List    ${list_of_users_with_zero_orders}    ${name} 
        #    Log To Console    ${name}
       END
    END
    
    ${found_no_orders}    Evaluate    len(${list_of_users_with_zero_orders})
    Log To Console    ${found_no_orders}
    IF    ${found_no_orders}>0
       Log To Console    \n\nUsers with 0 orders found.
       Fail    ${list_of_users_with_zero_orders} 
    END



    
