# Uncomment this line to define a global platform for your project
platform :ios, '7.0'

target 'Converge' do
    source 'https://github.com/CocoaPods/Specs.git'
    pod 'Converge', :path => './'
end

target 'Converge Tests' do
    # Note: 'Duplicate symbols' problem when using Cocoapods with Static Library tests: https://github.com/CocoaPods/CocoaPods/issues/1729
    #
    # To work around this problem, we have done the following:
    # 1. Under Project > Info, set the Build Configuration for the 'Converge Tests' target to be Pods-Converge.debug, which is the same as the one for the 'Converge' target (normally, Tests should have its own build config)
    # 2. Under Project > Targets > Converge Tests > Build Phases, Link Binary With Libraries, remove the link to libConverge.a (normally, the tests would need this link, but Cocoapods will do that for us in the build config, I guess)
    #
    # This will all probably break in a future version of Xcode, because programming is terrible. If/when this happens, I guess we should first try reversing the above steps, before finding a new workaround.
end
