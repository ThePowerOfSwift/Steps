## Steps for iOS
Steps is a simple step counting widget for iOS written in Swift. It uses App Groups to share data between the container app and widget and UIVisualEffectView for blurring. It uses the CMPedometer API in iOS 8 to show steps and distance, and floors climbed on devices that support it.

### App Groups Setup
- Go to [Apple Developer](https://developer.apple.com/account/ios/identifiers/applicationGroup/applicationGroupList.action) and add a new App Group to your account (don't worry, these can be removed later).
- Use Xcode's Find and Replace feature to replace `group.SachinPatel.Steps.TodayExtensionSharingDefaults` with the identifier of your new App Group.
- Under Project Settings > Capabilities > App Groups, make sure App Groups are turned on and that your identifier is checked.

<p align="center">
<img src="https://github.com/gizmosachin/steps/blob/master/steps-hero.png"/>
</p>

## License

Steps is available under the MIT license. See the LICENSE file for more info.
