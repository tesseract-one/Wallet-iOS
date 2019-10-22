use_modular_headers!
platform :ios, "11.0"

def common_pods
  pod 'Tesseract.OpenWallet/Wallet.Ethereum', '~> 0.1'
  pod 'Tesseract.Wallet/PromiseKit', '~> 0.1'
  pod 'Tesseract.Wallet/Ethereum', '~> 0.1'
  
  pod 'Tesseract.EthereumWeb3/PromiseKit', '~> 0.1'
  
  pod 'PromiseKit', '~> 6.8'
  
  pod 'ReactiveKit', '~> 3.13.0'
  pod 'Bond', '~> 7.6'
  
  pod 'SnapKit', '~> 5.0'
end

target :Tesseract do
    common_pods

    target :Extension do
        common_pods
    end
end
