# Class: puppet::agent
#
class puppet::agent (
  $version = 'present',
  $active = true,
  $init_config = false
  ) {

#  if ! ($active in [ "true", "false" ]) {
#    fail("active parameter must be true/false")
#  }

  anchor { 'puppet::agent::begin': }
  anchor { 'puppet::agent::end': }

  $puppet_agent = $::operatingsystem ? {
    default => 'puppet',
  }
  package { 'puppet-agent':
    name => $puppet_agent,
    ensure => $version,
    require => [ Anchor['puppet::agent::begin'], Package['lsb'] ];
  }

  if $init_config {
    sysvinit::init::config { "$puppet_agent":
     changes => $init_config,
    }
  }

  service { 'puppet-agent':
    name => $puppet_agent,
    ensure => $active ? {
      true => running,
      default => stopped,
    },
    enable => $active,
    hasstatus => true,
    pattern => '/puppet agent',
    require => Package['puppet-agent'],
    before => Anchor['puppet::agent::end'],
  }
  Puppet::Config <| |> -> Service['puppet-agent']
}

define puppet::agent::config (
  $changes,
  $onlyif = false
  ) {
  puppet::config { "${name}":
    section => 'agent',
    changes => $changes,
    onlyif => $onlyif,
    require => Package['puppet-agent'],
  }
}
