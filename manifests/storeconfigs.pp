class puppet::storeconfigs (
  $thin = false,
  $adapter = 'sqlite3',
  $dbuser = 'puppet',
  $dbserver = 'localhost',
  $dbpassword = false,
  $dbsocket = '/var/run/mysqld/mysqld.sock',
  ) {

  package { 'rails': }

  puppet::master::config { 'storeconfigs':
    changes => [
                'set storeconfigs true',
                "set dbadapter $adapter",
                ],
  }

  case $adapter {
    'sqlite3': {
      package {
        'sqlite3':;
        'libsqlite3-ruby':
          before => Service['puppet-master'];
      }
    }
    'mysql': {
      package { 'libmysql-ruby1.8':
        before => Service['puppet-master'];
      }
      puppet::master::config { 'storeconfigs-mysql':
        require => Puppet::Master::Config['storeconfigs'],
        changes => [
                    "set dbuser $dbuser",
                    "set dbpassword $dbpassword",
                    "set dbserver $dbserver",
                    "set dbsocket $dbsocket",
                    ];
      }
    }
  }
}
