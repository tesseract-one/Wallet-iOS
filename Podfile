use_frameworks!
platform :ios, "11.0"


target :Tesseract do
    pod 'Fabric'
    pod 'Crashlytics'
    
    pod 'TesseractOpenWallet/WalletEthereum', :git => 'https://github.com/tesseract-one/ios-openwallet-sdk.git', :branch => 'master'

    pod 'TesseractEthereumWeb3/PromiseKit', :git => 'https://github.com/tesseract-one/ios-web3-ethereum.git', :branch => 'master'
    
    pod 'TesseractWallet/EthereumPromiseKit', :git => 'https://github.com/tesseract-one/swift-wallet-sdk.git', :branch => 'master', :submodules => true

    pod 'PromiseKit'
    pod 'ReactiveKit'
    pod 'Bond'
    
    pod 'MaterialTextField', '~> 1.0'
    pod 'SnapKit', '~> 4.2.0'

    # temporary. Should be removed
    pod 'Web3', :git => 'https://github.com/tesseract-one/Web3.swift.git', :branch => 'master'
    pod 'SQLite.swift', :git => 'https://github.com/stephencelis/SQLite.swift.git', :branch => 'master'
    pod 'TesseractEthereumBase', :git => 'https://github.com/tesseract-one/swift-ethereum-base.git', :branch => 'master'
    pod 'SerializableValue', :git => 'https://github.com/tesseract-one/swift-serializable.git', :branch => 'master'

    target :Extension do
        pod 'TesseractOpenWallet/WalletEthereum', :git => 'https://github.com/tesseract-one/ios-openwallet-sdk.git', :branch => 'master'

        pod 'TesseractEthereumWeb3/PromiseKit', :git => 'https://github.com/tesseract-one/ios-web3-ethereum.git', :branch => 'master'

        pod 'TesseractWallet/EthereumPromiseKit', :git => 'https://github.com/tesseract-one/swift-wallet-sdk.git', :branch => 'master', :submodules => true

        pod 'PromiseKit'
        pod 'ReactiveKit'
        pod 'Bond'        

        pod 'MaterialTextField', '~> 1.0'
        pod 'SnapKit', '~> 4.2.0'
        
        # temporary should be removed
        pod 'SQLite.swift', :git => 'https://github.com/stephencelis/SQLite.swift.git', :branch => 'master'
	      pod 'Web3', :git => 'https://github.com/tesseract-one/Web3.swift.git', :branch => 'master'
        pod 'TesseractEthereumBase', :git => 'https://github.com/tesseract-one/swift-ethereum-base.git', :branch => 'master'
    	  pod 'SerializableValue', :git => 'https://github.com/tesseract-one/swift-serializable.git', :branch => 'master'
    end
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
