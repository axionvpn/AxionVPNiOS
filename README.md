## AxionVPNiOS

AxionVPNiOS is an iOS app that implements OpenVPN VPN protocol paired with Apple's new [Network Extension Framework](https://developer.apple.com/library/ios/documentation/NetworkExtension/Reference/Network_Extension_Framework_Reference/). The project shares code with its sibling OS X app (Coming soon), which can be found in the AxionVPNFramework project.

## Structure

When attempting to build either iOS or OS X project, you must make sure your folder structure is correct in order to build the app. The correct folder stucture is below:

* AxionVPN (A folder that will contain the other git projects)
   1. AxionVPNFramework (Framework)
   2. AxionVPNiOS (A clone of this project, the iOS App)
   3. AxionVPNOSX (Coming Soon)

## Third Party Code

Inside of AxionVPNFramework  are other third-party open source projects.

* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* [STUtils](https://github.com/ldandersen/STUtils)
* [TPKeyboardAvoiding](https://github.com/michaeltyson/TPKeyboardAvoiding)
