use_frameworks!

platform :ios, '10.0'

target 'RKCooperDemo' do
  
  ## RTC sdk
#   pod 'RKRTC', :path => '../../RKRTCSDK'
#   pod 'RKRTC', :path => '../RKRTC'
#   pod 'RKRTC', :git => "https://github.com/RokidiOS/RKRTC", :branch => '1.3.1_swift5.6.0'
  ## 维护最新的两个Swift版本，需要拉取对应版本的sdk，目前支持5.5.2、5.6.0
  pod 'RKRTC', :git => "https://github.com/RokidiOS/RKRTC", :branch => '1.3.1_swiftx.x.x'
  
  ## 协作 sdk
#   pod 'RKCooperationCore', :path => '../../RKCooperationCore'
#   pod 'RKCooperationCore', :path => '../RKCooperationCore'
#   pod 'RKCooperationCore', :git => "https://github.com/RokidiOS/RKCooperationCore", :branch => '2.2.1_swift5.6.0'
  ## 维护最新的两个Swift版本，需要拉取对应版本的sdk，目前支持5.5.2、5.6.0
  pod 'RKCooperationCore', :git => "https://github.com/RokidiOS/RKCooperationCore", :branch => '2.2.1_swiftx.x.x'
  
  ## IM sdk
  # pod 'RKIMCore', :path => '../../RKIMCore/Framework'
#   pod 'RKIMCore', :git => "https://github.com/RokidiOS/RKIMCore", :branch => "0.1.2_swift5.6.0"
  ## 维护最新的两个Swift版本，需要拉取对应版本的sdk，目前支持5.5.2、5.6.0
  pod 'RKIMCore', :git => "https://github.com/RokidiOS/RKIMCore", :branch => "0.1.2_swiftx.x.x"
  
  pod 'RKSocket', :git => "https://github.com/RokidiOS/RKSocket"
  
  pod 'RKSassLog', :git => "https://github.com/RokidiOS/RKSassLog"
  pod 'RKIHandyJSON'
  pod 'RKILogger'
  
  pod 'QMUIKit'
  pod 'SnapKit'
  pod 'Kingfisher'
  pod 'Moya'
  pod 'LookinServer', :configurations => ['Debug']
  pod 'DoraemonKit'
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

