class puppet::passenger {

  package {
    'puppetmaster-passenger':;
    'librack-ruby1.8':;
  }
  file { '/etc/puppet/rack':
    require => Package['puppetmaster-passenger'],
    source => "file:///usr/share/puppet/rack/puppetmasterd";
  }

}
