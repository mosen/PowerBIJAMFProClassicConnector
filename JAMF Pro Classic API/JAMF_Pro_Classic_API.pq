// This file contains your Data Connector logic
section JAMF_Pro_Classic_API;

[DataSource.Kind="JAMF_Pro_Classic_API", Publish="JAMF_Pro_Classic_API.Computers.Publish"]
shared JAMF_Pro_Classic_API.Computers = (baseurl as text) =>
    let
        response = JSSResource(baseurl, "/computers/subset/basic"),
        tables = Xml.Tables(response, [ NavigationTable = false ]),
        computers = tables[computer]{0}
    in
        computers;

[DataSource.Kind="JAMF_Pro_Classic_API", Publish="JAMF_Pro_Classic_API.MobileDeviceCommands.Publish"]
shared JAMF_Pro_Classic_API.MobileDeviceCommands = (baseurl as text) => 
    let 
        response = JSSResource(baseurl, "/mobiledevicecommands"),
        tables = Xml.Tables(response, [ NavigationTable = false ]),
        commands = tables[mobile_device_command]{0}
    in
        commands;

// Data Source Kind description
JAMF_Pro_Classic_API = [
    Authentication = [
        UsernamePassword = [
            UsernameLabel = "JAMF Pro API Username",
            PasswordLabel = "JAMF Pro API Password",
            Label = "Enter your JAMF Pro API Credentials"
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
JAMF_Pro_Classic_API.Computers.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "JAMF Pro Classic API - Computers", "JAMF Pro Classic API - Computers" },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = JAMF_Pro_Classic_API.Icons,
    SourceTypeImage = JAMF_Pro_Classic_API.Icons
];

JAMF_Pro_Classic_API.MobileDeviceCommands.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "JAMF Pro Classic API - Mobile Device Commands", "JAMF Pro Classic API - Mobile Device Commands" },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = JAMF_Pro_Classic_API.Icons,
    SourceTypeImage = JAMF_Pro_Classic_API.Icons
];

JAMF_Pro_Classic_API.Icons = [
    Icon16 = { Extension.Contents("JAMF_Pro_Classic_API16.png"), Extension.Contents("JAMF_Pro_Classic_API20.png"), Extension.Contents("JAMF_Pro_Classic_API24.png"), Extension.Contents("JAMF_Pro_Classic_API32.png") },
    Icon32 = { Extension.Contents("JAMF_Pro_Classic_API32.png"), Extension.Contents("JAMF_Pro_Classic_API40.png"), Extension.Contents("JAMF_Pro_Classic_API48.png"), Extension.Contents("JAMF_Pro_Classic_API64.png") }
];


GetJamfProToken = (website as text) =>
    let
        username = Record.Field(Extension.CurrentCredential(), "Username"),
        password = Record.Field(Extension.CurrentCredential(), "Password"),
        bytes = Text.ToBinary(username & ":" & password),
        credentials = Binary.ToText(bytes, BinaryEncoding.Base64),
        source = Web.Contents(website & "/uapi/auth/tokens",
        [
            Headers = [#"Authorization" = "Basic " & credentials,
                #"Accepts" = "application/json"],
            Content=Text.ToBinary(" ")
        ]),
        json = Json.Document(source),
        first = Record.Field(json,"token"),
        auth = Extension.CurrentCredential(),
        auth2 = Record.Field(auth, "Password")
    in
        first;

BasicAuthorizationHeader = () =>
    let
        username = Record.Field(Extension.CurrentCredential(), "Username"),
        password = Record.Field(Extension.CurrentCredential(), "Password"),
        bytes = Text.ToBinary(username & ":" & password),
        credentials = Binary.ToText(bytes, BinaryEncoding.Base64),
        value = "Basic " & credentials
    in
        value;

JSSResource = (baseurl as text, relativepath as text) =>
    let authheader = BasicAuthorizationHeader(),
        source = Web.Contents(baseurl & "/JSSResource",
        [
            Headers = [
                #"Accept" = "text/xml",
                #"Authorization" = authheader
            ],
            RelativePath = relativepath
        ])
    in
        source;
