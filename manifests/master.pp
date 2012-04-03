# Class: puppet::master
#
#   This class controls puppetmasterd.
#
#
class puppet::master (
  $version = 'present',
  $active = true
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

  if $puppet::master_init_config {
    sysvinit::init::config { "$puppet_master":
      changes => $puppet::master_init_config,
    }
  }

  service { 'puppet-master':
    name => $puppet_master,
    ensure => $active ? {
      true => running,
      default => stopped,
    },
    enable => $active,
#    pattern => ,
    require => Package['puppet-master'],
    before => Anchor['puppet::master::end'],
  }
  Puppet::Config <| |> -> Service['puppet-master']

}
