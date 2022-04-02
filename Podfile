use_frameworks!

platform :ios, '10.0'

def gitUrl (name)
   url = 'https://github.com/RokidiOS/'
   return url + name
end

target 'RKCooperDemo' do
  
  #pod 'RKRTC', :path => '../../../RKRTC'
  #pod 'RKRTC', :path => '../../../RKCore/RKRTCSDK'
  pod 'RKRTC', :git => gitUrl("RKRTC"), :branch => '1.0.0_swift5.5.2'
  
  #pod 'RKCooperationCore', :path => '../../../RKCore/RKCooperationCore'
  #pod 'RKCooperationCore', :path => '../../../RKCore/RKCoreSDK'
  pod 'RKCooperationCore', :git => gitUrl("RKCooperationCore"), :branch => '2.0.0_swift5.5.2'
  
  pod 'RKSassLog', :git => gitUrl("RKSassLog")
  pod 'RKIHandyJSON'
  pod 'RKILogger'

  pod 'QMUIKit'
  pod 'SnapKit'
  pod 'Kingfisher'
  pod 'DoraemonKit'
  pod 'Moya'
  pod 'LookinServer', :configurations => ['Debug']
  pod 'DoraemonKit'
  pod 'IQKeyboardManagerSwift'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end

