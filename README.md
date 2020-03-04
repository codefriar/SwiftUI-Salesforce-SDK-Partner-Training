#  SwiftUI, & Salesforce SDK Partner Training Learning App

## What is this?

In Febuary of 2020, we held a workshop for ISV's and SI partners to train to build native apps using Swift, SwiftUI, Combine and the Salesforce Mobile SDK for iOS.
During that workshop, learners worked on developing a single application tightly integrated with Salesforce that intitally shows a list of Accounts. When the user taps on an account, the app queries and displays a list of Contacts associated with that account. When the user taps on a contact, it displays that contacts' details, and a map view of the contacts address. Users can tap on the custom map pin, and see directions from the users current location, to the contacts address. Additionally, users can select or take photos and upload them as Salesforce files attachment related to the contact record. Users can also edit the contacts' details and have those details mirrored back to Salesforce when done. Finally, the app includes the ability to scan a QR Code (or other barcode types) to create a new contact associated with the currently displayed Account. This repo holds a final, working version of a learning app demostrating app development with Swift, SwiftUI, and the Salesforce mobile SDK for iOS.

It is built with Swift 5+, Xcode 11.3.1.

> In so far as this is a *learning* app, little consideration has been given to UI Aesthetics. Buttons and UI controls are placed with a focus on ease-of-illustrating functionality, not proper app design. This application is not designed to be a production, or even proof of concept, but rather as a learning experience.

## Who is it for?

This repo is primarily for attendees to the workshop. But it should serve anyone wanting to learn SwiftUI, Combine and the Salesforce mobile SDK for iOS. You'll find examples of Offline Access, Sync, Queries and Updates rest calls. It also includes a solid MKMapView wrapper for SwiftUI, as well as examples for integrating and using Swift Package Manager packages. 

## Who do I talk to for support?

Support is only provided via this github repo's issues tab.

## What's it good for?

Honestly? It's not an app that meets business needs. It exists only to illustrate the concepts and syntax of topics covered at the workshop. However, you may find it useful for looking at abstractions and convience wrappers to the Salesforce Mobile SDK for iOS, as well as a functional example of Combine and core SwiftUI techniques.

## How do I use it?

Using this repository requires a few prerequisites.

### Prerequisites

* [A working installation of Cocoapods.](https://cocoapods.org/)
* [A working installation of NPM / Node.](https://www.npmjs.com/)
* Xcode 11.3.1 or higher
* Swift 5+
* A device with iOS 13+ or a Simulator running iOS 13+

Once you've met these prerequisites the setup is pretty quick.

1. Clone this repo to your local computer
2. Using the command line navigate to your cloned directory and execute the following:
```cmd
node install.js
``` 
3. When the install completes successfully you *MUST* open the generated .xcworkspace file.
4. If your checkout will not immediately build, please verify you opened the .xcworkspace file, and *not* the .xcodeproj file.

