Pod::Spec.new do |s|
  s.name         = 'QMBFetchedResultsViewController'
  s.version      = '1.0.2'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/quemb/QMBFetchedResultsViewController'
  s.authors      =  {'Toni Moeckel' => 'tonimoeckel@gmail.com'}
  s.summary      = 'Fetched Results Controller'

# Source Info
  s.platform     =  :ios, '7.0'
  s.source       =  {:git => 'https://github.com/quemb/QMBFetchedResultsViewController.git', :tag => '1.0.2'}
  s.source_files = 'QMBFetchedResultsViewController/*.{h,m}'
  s.requires_arc = true

end
