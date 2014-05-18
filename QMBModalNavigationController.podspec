Pod::Spec.new do |s|
  s.name         = 'QMBFetchedResultsViewController'
  s.version      = '1.0'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/quemb/QMBFetchedResultsViewController'
  s.authors      =  {'Toni Moeckel' => 'tonimoeckel@gmail.com'}
  s.summary      = ''

# Source Info
  s.platform     =  :ios, '7.0'
  s.source       =  {:git => 'https://github.com/quemb/QMBFetchedResultsViewController.git', :tag => '1.0'}
  s.source_files = 'QMBModalNavigationController/*.{h,m}'
  s.requires_arc = true

end