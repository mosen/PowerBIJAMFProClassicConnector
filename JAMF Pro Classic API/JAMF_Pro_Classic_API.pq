// This file contains your Data Connector logic
section JAMF_Pro_Classic_API;

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

// BEGIN - Implementation Methods



// COMPUTERS
[DataSource.Kind="JAMF_Pro_Classic_API", Publish="JAMF_Pro_Classic_API.Computers.Publish"]
shared JAMF_Pro_Classic_API.Computers = Value.ReplaceType(ComputersImpl, ComputersType);

ComputersType = type function (
    baseurl as (type text meta [
        Documentation.FieldCaption = "JAMF Pro Server URL",
        Documentation.FieldDescription = "The fully qualified URL including port number of your JAMF Pro server"
    ]))
    as table meta [
        Documentation.Name = "JAMF Pro Classic API - Get Computers (Basic)",
        Documentation.LongDescription = "Get a list of computers in JAMF Pro with a basic subset of information about each computer."
    ];

ComputersImpl = (baseurl as text) as table =>
    let
        response = JSSResource(baseurl, "/computers/subset/basic"),
        tables = Xml.Tables(response, [ NavigationTable = false ]),
        computers = tables[computer]{0}
    in
        computers;

JAMF_Pro_Classic_API.Computers.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "JAMF Pro Classic API - Computers", "JAMF Pro Classic API - Computers" },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = JAMF_Pro_Classic_API.Icons,
    SourceTypeImage = JAMF_Pro_Classic_API.Icons
];

// COMPUTER APPLICATIONS
[DataSource.Kind="JAMF_Pro_Classic_API__ComputerApplications", Publish="JAMF_Pro_Classic_API__ComputerApplications.Publish"]
shared JAMF_Pro_Classic_API__ComputerApplications.Content = Value.ReplaceType(ComputerApplicationsImpl, ComputerApplicationsType);

ComputerApplicationsType = type function (
    baseurl as (type text meta [
        Documentation.FieldCaption = "JAMF Pro Server URL",
        Documentation.FieldDescription = "The fully qualified URL including port number of your JAMF Pro server"
    ]),
    appname as (type text meta [
        Documentation.FieldCaption = "Application Name",
        Documentation.FieldDescription = "The full name of the application bundle"
    ]))
    as table meta [
        Documentation.Name = "JAMF Pro Classic API - Get Computer Applications (by name)",
        Documentation.LongDescription = "Get a list of computers in JAMF Pro with a specified application name installed."
    ];

ComputerApplicationsImpl = (baseurl as text, appname as text) =>
    let
        response = JSSResource(baseurl, "/computerapplications/application/" + appname),
        tables = Xml.Tables(response, [ NavigationTable = false ]),
        computers = tables[unique_computers]{0}
    in
        computers;

JAMF_Pro_Classic_API__ComputerApplications.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "JAMF Pro Classic API - Computer Applications (name)", "JAMF Pro Classic API - Computer Applications (name)" },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = JAMF_Pro_Classic_API.Icons,
    SourceTypeImage = JAMF_Pro_Classic_API.Icons
];

// COMPUTER COMMANDS
[DataSource.Kind="JAMF_Pro_Classic_API", Publish="JAMF_Pro_Classic_API.ComputerCommands.Publish"]
shared JAMF_Pro_Classic_API.ComputerCommands = Value.ReplaceType(ComputerCommandsImpl, ComputerCommandsType);

ComputerCommandsType = type function (
    baseurl as (type text meta [
        Documentation.FieldCaption = "JAMF Pro Server URL",
        Documentation.FieldDescription = "The fully qualified URL including port number of your JAMF Pro server"
    ]),
    optional command as (type text meta [
        Documentation.FieldCaption = "Specific Command Type",
        Documentation.FieldDescription = "The name of the specific command type to return instances of",
        Documentation.AllowedValues = { "CertificateList", "EraseDevice", "InstallApplication", "InstalledApplicationList", "InstallProfile", "ProfileList", "RemoveProfile", "SecurityInfo", "UserList" }
    ])
    )
    as table meta [
        Documentation.Name = "JAMF Pro Classic API - Get Computer Commands",
        Documentation.LongDescription = "Get a list of computer commands in JAMF Pro."
    ];

ComputerCommandsImpl = (baseurl as text, optional command as text) as table =>
    let
        response = JSSResource(baseurl, "/computercommands"),
        tables = Xml.Tables(response, [ NavigationTable = false ]),
        computercommands = tables[computer_command]{0}
    in
        computercommands;

JAMF_Pro_Classic_API.ComputerCommands.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "JAMF Pro Classic API - Computer Commands", "JAMF Pro Classic API - Computer Commands" },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = JAMF_Pro_Classic_API.Icons,
    SourceTypeImage = JAMF_Pro_Classic_API.Icons
];

// MOBILE DEVICE COMMANDS
JAMF_Pro_Classic_API.MobileDeviceCommands.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "JAMF Pro Classic API - Mobile Device Commands", "JAMF Pro Classic API - Mobile Device Commands" },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = JAMF_Pro_Classic_API.Icons,
    SourceTypeImage = JAMF_Pro_Classic_API.Icons
];

[DataSource.Kind="JAMF_Pro_Classic_API", Publish="JAMF_Pro_Classic_API.MobileDeviceCommands.Publish"]
shared JAMF_Pro_Classic_API.MobileDeviceCommands = (baseurl as text) => 
    let 
        response = JSSResource(baseurl, "/mobiledevicecommands"),
        tables = Xml.Tables(response, [ NavigationTable = false ]),
        commands = tables[mobile_device_command]{0}
    in
        commands;

// PACKAGES
JAMF_Pro_Classic_API.Packages.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "JAMF Pro Classic API - Packages", "JAMF Pro Classic API - Packages" },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = JAMF_Pro_Classic_API.Icons,
    SourceTypeImage = JAMF_Pro_Classic_API.Icons
];

[DataSource.Kind="JAMF_Pro_Classic_API", Publish="JAMF_Pro_Classic_API.Packages.Publish"]
shared JAMF_Pro_Classic_API.Packages = (baseurl as text) => 
    let 
        response = JSSResource(baseurl, "/packages"),
        tables = Xml.Tables(response, [ NavigationTable = false ]),
        packages = tables[package]{0}
    in
        packages;

// POLICIES
JAMF_Pro_Classic_API.Policies.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { "JAMF Pro Classic API - Policies", "JAMF Pro Classic API - Policies" },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = JAMF_Pro_Classic_API.Icons,
    SourceTypeImage = JAMF_Pro_Classic_API.Icons
];

[DataSource.Kind="JAMF_Pro_Classic_API", Publish="JAMF_Pro_Classic_API.Policies.Publish"]
shared JAMF_Pro_Classic_API.Policies = (baseurl as text) => 
    let 
        response = JSSResource(baseurl, "/policies"),
        tables = Xml.Tables(response, [ NavigationTable = false ]),
        policies = tables[policy]{0}
    in
        policies;


