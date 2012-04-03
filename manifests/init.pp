# Class: puppet
#

class puppet (
  $version = 'present',
  $agent = 'active',
  $agent_init_config = false,
  $master = false,
  $master_init_config = false
  ) {

  anchor { 'puppet::begin': }
  anchor { 'puppet::end': }


  if $agent {
    class { 'puppet::agent':
      version => $version,
      active => $agent ? {
        'active' => true,
        default => false,
      },
    }
  }
  if $master {
    class { 'puppet::master':
      version => $version,
      active => $master ? {
        'active' => true,
        default => false,
      },
    }
  }
}

define puppet::config ( $content ) {
  file { "$name":
    mode => 644, owner => root, group => 0,
    content => $content,
  }
}
