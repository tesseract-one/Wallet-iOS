Pod::Spec.new do |s|
  s.name             = 'TesSDK'
  s.version          = '0.0.1'
  s.summary          = 'Tesseract OpenWallet SDK for Swift'

  s.description      = <<-DESC
Swift library for working with OpenWallet protocol.
                       DESC

  s.homepage         = 'https://github.com/crossroadlabs/ios-sdk'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tesseract Systems, Inc.' => 'info@gettes.io' }
  s.source           = { :git => 'https://github.com/crossroadlabs/ios-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tesseract_io'

  s.ios.deployment_target = '11.0'
  
  s.source_files = 'Sources/TesSDK/**/*.swift'

  s.dependency 'PromiseKit', '~> 6.8'
  s.dependency 'CKMnemonic', '~> 0.1'
  #s.dependency 'BigInt'

  s.dependency 'Web3'
  s.dependency 'Web3/PromiseKit'
end
