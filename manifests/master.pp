# Class: puppet::master
#
#   This class controls puppetmasterd.
#
#
class puppet::master (
  $version = 'present',
  $active = true,
  $init_config = false
  ) {

  anchor { 'puppet::master::begin': }
  anchor { 'puppet::master::end': }

  $puppet_master = $::operatingsystem ? {
    /(?i-mx:redhat|centos)/ => 'puppet-server',
    default => 'puppetmaster',
  }
  package { 'puppet-master':
    ensure => $version,
    name => $puppet_master,
    require => [ Anchor['puppet::master::begin'], Package['puppet-agent'] ],
  }

  if $init_config {
    sysvinit::init::config { "$puppet_master":
      changes => $init_config,
    }
  }

  service { 'puppet-master':
    name => $puppet_master,
    ensure => $active ? {
      true => running,
      default => stopped,
    },
    enable => $active,
    # TODO: properly detect passenger service.
    hasstatus => $active,
    pattern => '/puppet master',
    require => Package['puppet-master'],
    before => Anchor['puppet::master::end'],
  }
  Puppet::Config <| |> -> Service['puppet-master']

}

define puppet::master::config (
  $changes,
  $onlyif = false
  ) {
  puppet::config { "${name}":
    section => 'master',
    changes => $changes,
    onlyif => $onlyif,
    require => Package['puppet-master'],
  }
}
