![Bitrise status](https://app.bitrise.io/app/ecf330d4413bcbef.svg?token=mkeSPrlDTxCmQg5AqAaG8Q)

# typefaster

This repo contains the sources of the [Type Faster app](https://apps.apple.com/app/id1013588476) - a typing trainer app, where users can check their typing speed, compete with each other through GameCenter Leaderboards and practice with small texts on two languages:
- English
- Russian

Originally it was written in Objective-C and rewritten to Swift 5.2.
You can find old Objective-C version in a [seperate branch](https://github.com/squatchus/typefaster/tree/objc).
For routing and view layer the app uses MVVM-C architecture with closure based approach (inspired by [this talk](https://www.youtube.com/watch?v=Pt9TGFzLVzc)). It also uses SOA for the layer of business logic.

Supports iOS 13+ with some neat features like Dark Mode.

![alt text](https://thumb.tildacdn.com/tild3134-6434-4533-b230-313935313861/-/format/webp/2_3center.png "Type Faster app")
