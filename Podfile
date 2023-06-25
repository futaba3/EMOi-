
platform :ios, '11.0'

target 'Goods3' do
  use_frameworks!

  pod 'Firebase/Storage'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Database'
  pod 'FirebaseUI'
  pod 'FirebaseStorageUI'

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
   end
  end
end

