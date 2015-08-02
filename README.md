# LKTwitterKit

[![CI Status](http://img.shields.io/travis/lukaskollmer/LKTwitterKit.svg?style=flat)](https://travis-ci.org/lukaskollmer/LKTwitterKit)
[![Version](https://img.shields.io/cocoapods/v/LKTwitterKit.svg?style=flat)](http://cocoapods.org/pods/LKTwitterKit)
[![License](https://img.shields.io/cocoapods/l/LKTwitterKit.svg?style=flat)](http://cocoapods.org/pods/LKTwitterKit)
[![Platform](https://img.shields.io/cocoapods/p/LKTwitterKit.svg?style=flat)](http://cocoapods.org/pods/LKTwitterKit)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

LKTwitterKit requires iOS 8

## Installation

LKTwitterKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "LKTwitterKit"
```

## Usage

LKTwitterKit is entirely written in Swift.
To get started, you'll need to import LKTwitterKit

Swift:

```swift
import LKTwitterKit
```

Objective-C:

```objectivec
@import LKTwitterKit;
```


There are four available functions:

-  Tweet
-  Follow
-  Unfollow
-  Check if following


### Tweet something

```swift
Twitter.tweet("your tweet") {(success) -> Void in
}
```

### Follow someone

```swift
Twitter.follow("tim_cook")  {(success) -> Void in
}
```

### Unollow someone

```swift
Twitter.unfollow("tim_cook")  {(success) -> Void in
}
```

### Tweet something

```swift
Twitter.isFollowing("tim_cook")  {(isFollowing) -> Void in
}
```



## Author

Lukas Kollmer, lukas@kollmer.me

## License

LKTwitterKit is available under the MIT license. See the LICENSE file for more info.
