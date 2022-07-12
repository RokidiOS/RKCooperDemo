use_frameworks!

platform :ios, '10.0'

target 'RKCooperDemo' do
  
  pod 'RKRTC', :git => "https://github.com/RokidiOS/RKRTC", :branch => '1.5.2_swift5.6.0'
  pod 'RKCooperationCore', :git => "https://github.com/RokidiOS/RKCooperationCore", :branch => '2.3.2_swift5.6.0'
  
  pod 'RKSassLog', :git => "https://github.com/RokidiOS/RKSassLog"

  pod 'RKIHandyJSON'
  pod 'RKILogger'

  pod 'QMUIKit'
  pod 'SnapKit'
  pod 'Kingfisher', '~>4.10.1'
  pod 'DoraemonKit'
  pod 'Moya', '~>15.0.0'
  pod 'LookinServer', :configurations => ['Debug']
  pod 'IQKeyboardManagerSwift'
  pod 'Bugly'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
