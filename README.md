Deemly Sign-Up on iOS
=====================

The Deemly sign-up flow is made to work well in Safari on iOS and
this project contains a component to trigger the flow from a native app.

You need to provide your Deemly App Id to identify your site and to configure the iOS app to handle 
a specific URL-scheme for getting the sign-up results back into your app. 

To install the Deemly helper class, you drag `Deemly.swift` into your project and configure your
`Info.plist` with the lines

````
<key>DeemlyAppIdentifier</key>
<string>$APP_ID</string>

<key>CFBundleURLTypes</key>
<array><dict>
  <key>CFBundleTypeRole</key><string>Editor</string>
  <key>CFBundleURLName</key><string></string>
  <key>CFBundleURLSchemes</key><array>
    <string>deemly-$APP_ID</string>
  </array>
</dict></array>
````
Substitute your Deemly App ID instead of `$APP_ID`.

Furthermore you need to call `Deemly.open(url:)` from one of the URL handling methods in your app delegate
and `AppDelegate.swift` in this project shows how to do this.

To start the sign-up flow you call the following

````
Deemly.OpenSignUpFlow(email: "example@deemly.dk", fullName: "Full Name",
                      presenter: viewControllerOrNil, 
                      completion: { deemlyId in

            if deemlyId == nil {
               // sign-up was cancelled
            } else {
               // deemlyId identifies the user on Deemly
            }
        })
````

Your `Info.plist` configuration and URL handling will be checked and the app will crash to let you know 
what's wrong using methods names that are very obvious in your stack trace.

If everything looks correct a browser will be shown to handle the sign-up flow and the callback will be made
when the user completes sign-up or gives up.

Display the users Trust Profile
===============================

You use the `deemlyId` to show a Trust Profile. As it requires the secret API key it is best done on your server.
Please see the [documentation](https://deemly.co/developers/documentation/trust-profile-api/) for details.
