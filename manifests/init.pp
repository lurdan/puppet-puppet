# Class: puppet
#
# Usage:
#   class { 'puppet':
#     agent => false,
#     master => true,
#   }
class puppet (
  $version = 'latest',
  $agent = 'active',
  $agent_init_config = false,
  $master = false,
  $master_init_config = false
  ) {

  anchor { 'puppet::begin': }
  anchor { 'puppet::end': }

  class { 'augeas':; }

  # workaround for prerequisites
  package { 'facter':; }
  case $::operatingsystem {
    /(?i-mx:debian|ubuntu)/: {
      package {
        'pciutils':
          before => Package['facter'];
        'puppet-common':
          ensure => $version,
          require => $::puppetversion ? {
            # workaround for old debian package (< 2.7)
            /^2.6/ => Class['augeas'],
            default => Package['facter'],
          },
          before => Anchor['puppet::end'];
      }
    }
    /(?i-mx:redhat|centos)/: {
      $pciutils_pkg = $::lsbmajdistrelease ? {
        '5' => 'pciutils',
        '6' => 'pciutils-libs',
      }
      package {
        "$pciutils_pkg":
          before => Package['facter'];
      }
    }
  }

  if $agent {
    class { 'puppet::agent':
      version => $version,
      active => $agent ? {
        'active' => true,
        default => false,
      },
      init_config => $agent_init_config,
    }
  }

  if $master {
    class { 'puppet::master':
      version => $version,
      active => $master ? {
        'active' => true,
        default => false,
      },
      init_config => $master_init_config,
    }
  }
}

define puppet::config (
  $changes,
  $section = 'main',
  $onlyif = false
  ) {

  if ! ($section in [ 'main', 'master', 'agent' ]) {
    fail("section parameter must be main/master/agent")
  }

  case $onlyif {
    false: {
      augeas { "/etc/puppet/puppet.conf-${section}-${name}":
        context => "/files/etc/puppet/puppet.conf/${section}/",
        changes => $changes,
        require => $::operatingsystem ? {
          /(?i-mx:debian|ubuntu)/ => Package['puppet-common'],
          /(?i-mx:redhat|centos)/ => Package['puppet'],
        },
      }
    }
    default: {
      augeas { "/etc/puppet/puppet.conf-${section}-${name}":
        context => "/files/etc/puppet/puppet.conf/${section}/",
        changes => $changes,
        onlyif => $onlyif,
        require => Package['puppet-common'],
      }
    }
  }
}

# concat { '/etc/puppet/auth.conf':
#   require => Package['puppet-common'],
# }
# define puppet::config::auth () {
# }
