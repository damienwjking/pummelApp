source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
target ‘pummel’ do
pod 'Alamofire'
pod 'RSKGrowingTextView'
pod 'AlamofireImage'
pod 'UIColor+FlatColors'
pod 'Cartography'
pod 'ReactiveUI'
pod 'LocationPicker', '0.6.0'
pod 'Mixpanel'
pod 'CVCalendar', '1.3.0'
pod 'Branch'
pod 'Firebase'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |configuration|
            configuration.build_settings['SWIFT_VERSION'] = "2.3"
        end
    end
end
