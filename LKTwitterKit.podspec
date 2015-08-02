Pod::Spec.new do |s|
  s.name         = "LKTwitterKit"
  s.version      = "0.1.1"
  s.summary      = "A small Twitter library written in Swift"
  s.description  = "LKTwitterKit is a library that allows you to access some basic Twitter features (tweet, follow, etc.) in your iOS app"
  s.homepage     = "http://github.com/lukaskollmer/LKTwitterKit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Lukas Kollmer" => "lukas@kollmer.me" }
  s.platform     = :ios, '8.0'
  s.source = { :git => "https://github.com/lukaskollmer/LKTwitterKit.git",
               :tag => s.version.to_s }
  s.source_files  = 'LKTwitterKit'
  s.frameworks = 'Foundation', 'UIKit', 'Accounts', 'Social'
  s.requires_arc = true
end
