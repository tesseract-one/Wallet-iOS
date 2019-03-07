use_frameworks!
platform :ios, "11.0"


target :Tesseract do
    pod 'PromiseKit'
    pod 'ReactiveKit'
    pod 'Bond'
    
    pod 'Motion', :git => 'https://github.com/CosmicMind/Motion.git', :branch => 'development'
    pod 'Material', :git => 'https://github.com/CosmicMind/Material.git', :branch => 'development'

    pod 'Web3', :git => 'https://github.com/crossroadlabs/Web3.swift.git', :branch => 'master'
    pod 'Web3/PromiseKit', :git => 'https://github.com/crossroadlabs/Web3.swift.git', :branch => 'master'

    pod 'Fabric'
    pod 'Crashlytics'
    
    pod 'CKMnemonic'

    target :Extension do
        pod 'Web3', :git => 'https://github.com/crossroadlabs/Web3.swift.git', :branch => 'master'
        pod 'Web3/PromiseKit', :git => 'https://github.com/crossroadlabs/Web3.swift.git', :branch => 'master'
        
        pod 'CKMnemonic'
        
        pod 'PromiseKit'
        pod 'ReactiveKit'
        pod 'Bond'
    end
end

target :TesSDK do
    pod 'PromiseKit'
    pod 'CKMnemonic'
    pod 'Web3', :git => 'https://github.com/crossroadlabs/Web3.swift.git', :branch => 'master'
    pod 'Web3/PromiseKit', :git => 'https://github.com/crossroadlabs/Web3.swift.git', :branch => 'master'
end

post_install do |pi|
  # https://github.com/CocoaPods/CocoaPods/issues/7314
  fix_deployment_target(pi)
end

def fix_deployment_target(pod_installer)
  if !pod_installer
    return
  end
  puts "Make the pods deployment target version the same as our target"
  
  project = pod_installer.pods_project
  deploymentMap = {}
  project.build_configurations.each do |config|
    deploymentMap[config.name] = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
  end
  # p deploymentMap
  
  project.targets.each do |t|
    puts "  #{t.name}"
    t.build_configurations.each do |config|
      oldTarget = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
      newTarget = deploymentMap[config.name]
      if oldTarget == newTarget
        next
      end
      puts "    #{config.name} deployment target: #{oldTarget} => #{newTarget}"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = newTarget
    end
  end
end