platform :osx, '10.11'
use_frameworks!

target 'AudioSelector' do
    pod 'SwiftyConstraints', :git => 'https://github.com/semiroot/SwiftyConstraints'
    pod 'AMCoreAudio', '~> 3.1'
    pod 'AudioKit', '~> 4.0'
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
end

swift3 = ['SwiftyConstraints', 'AMCoreAudio'] # if these pods are in Swift 3.2
swift4 = ['AudioKit', 'RxSwift', 'RxCocoa'] # if these pods are in Swift 4

post_install do |installer|
    installer.pods_project.targets.each do |target|
        swift_version = nil
        if swift3.include?(target.name)
            swift_version = '3.2'
        end
        if swift4.include?(target.name)
            swift_version = '4.0'
        end
        if swift_version
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = swift_version
            end
        end
    end
end
