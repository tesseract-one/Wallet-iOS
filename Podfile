use_frameworks!
platform :ios, "11.0"

def common_pods
  pod 'Tesseract.OpenWallet/Wallet.Ethereum', '~> 0.1'
  pod 'Tesseract.Wallet/PromiseKit', '~> 0.1'
  pod 'Tesseract.Wallet/Ethereum', '~> 0.1'
  
  pod 'Tesseract.EthereumWeb3/PromiseKit', :git => 'https://github.com/tesseract-one/EthereumWeb3.swift.git', :branch => 'master'
  
  pod 'PromiseKit', '~> 6.8'
  
  pod 'ReactiveKit', '~> 3.12'
  pod 'Bond', '~> 7.5'
  
  pod 'SnapKit', '~> 5.0'
  
  # temporary. Should be removed
  pod 'Web3', :git => 'https://github.com/tesseract-one/Web3.swift.git', :branch => 'master'
end

target :Tesseract do
    common_pods

    target :Extension do
        common_pods
    end
end
