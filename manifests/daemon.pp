# @summary This define managed prometheus daemons that don't have their own class
# @param version
#  The binary release version
# @param real_download_url
#  Complete URL corresponding to the where the release binary archive can be downloaded
# @param notify_service
#  The service to notify when something changes in this define
# @param user
#  User which runs the service
# @param install_method
#  Installation method: url or package
# @param download_extension
#  Extension for the release binary archive
# @param os
#  Operating system (linux is the only one supported)
# @param arch
#  Architecture (amd64 or i386)
# @param bin_dir
#  Directory where binaries are located
# @param bin_name
#  The name of the binary to execute
# @param package_name
#  The binary package name
# @param package_ensure
#  If package, then use this for package ensure default 'installed'
# @param manage_user
#  Whether to create user or rely on external code for that
# @param extra_groups
#  Extra groups of which the user should be a part
# @param manage_group
#  Whether to create a group for or rely on external code for that
# @param service_ensure
#  State ensured for the service (default 'running')
# @param service_enable
#  Whether to enable the service from puppet (default true)
# @param manage_service
#  Should puppet manage the service? (default true)
# @param extract_command
#  Custom command passed to the archive resource to extract the downloaded archive.
# @param extract_path
#  Path where to find extracted binary
# @param archive_bin_path
#  Path to the binary in the downloaded archive.
# @param init_style
#  Service startup scripts style (e.g. rc, upstart or systemd).
#  Can also be set to `none` when you don't want the class to create a startup script/unit_file for you.
#  Typically this can be used when a package is already providing the file.
# @param unit_after
#  List of units that should be started prior to this daemon. Only supported for the systemd init_style.
define prometheus::daemon (
  String[1] $version,
  Prometheus::Uri $real_download_url,
  $notify_service,
  String[1] $user,
  String[1] $group,
  String[1] $install_method               = $prometheus::install_method,
  String $download_extension              = $prometheus::download_extension,
  String[1] $os                           = $prometheus::os,
  String[1] $arch                         = $prometheus::real_arch,
  Stdlib::Absolutepath $bin_dir           = $prometheus::bin_dir,
  String[1] $bin_name                     = $name,
  Optional[String] $package_name          = undef,
  String[1] $package_ensure               = 'installed',
  Boolean $manage_user                    = true,
  Array $extra_groups                     = [],
  Boolean $manage_group                   = true,
  Boolean $purge                          = true,
  String $options                         = '',
  Prometheus::Initstyle $init_style       = $facts['service_provider'],
  Stdlib::Ensure::Service $service_ensure = 'running',
  Boolean $service_enable                 = true,
  Boolean $manage_service                 = true,
  Hash[String, Scalar] $env_vars          = {},
  Optional[String] $env_file_path         = $prometheus::env_file_path,
  Optional[String[1]] $extract_command    = $prometheus::extract_command,
  Stdlib::Absolutepath $extract_path      = '/opt',
  Stdlib::Absolutepath $archive_bin_path   = "/opt/${name}-${version}.${os}-${arch}/${name}",
  Boolean $export_scrape_job              = false,
  Stdlib::Host $scrape_host               = $facts['networking']['fqdn'],
  Optional[Stdlib::Port] $scrape_port     = undef,
  String[1] $scrape_job_name              = $name,
  Hash $scrape_job_labels                 = { 'alias' => $scrape_host },
  Array[String[1]] $unit_after            = [],
  Stdlib::Absolutepath $usershell         = $prometheus::usershell,
) {
  case $install_method {
    'url': {
      if $download_extension == '' {
        file { "/opt/${name}-${version}.${os}-${arch}":
          ensure => directory,
          owner  => 'root',
          group  => 0, # 0 instead of root because OS X uses "wheel".
          mode   => '0755',
        }
        -> archive { "/opt/${name}-${version}.${os}-${arch}/${name}":
          ensure          => present,
          source          => $real_download_url,
          checksum_verify => false,
          before          => File["/opt/${name}-${version}.${os}-${arch}/${name}"],
        }
      } else {
        archive { "/tmp/${name}-${version}.${download_extension}":
          ensure          => present,
          extract         => true,
          extract_path    => $extract_path,
          source          => $real_download_url,
          checksum_verify => false,
          creates         => $archive_bin_path,
          cleanup         => true,
          before          => File[$archive_bin_path],
          extract_command => $extract_command,
        }
      }
      file { $archive_bin_path:
        owner => 'root',
        group => 0, # 0 instead of root because OS X uses "wheel".
        mode  => '0555',
      }
      -> file { "${bin_dir}/${name}":
        ensure => link,
        notify => $notify_service,
        target => $archive_bin_path,
      }
    }
    'package': {
      package { $package_name:
        ensure => $package_ensure,
        notify => $notify_service,
      }
      if $manage_user {
        User[$user] -> Package[$package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${install_method} is invalid")
    }
  }
  if $manage_user {
    # if we manage the service, we need to reload it if our user changes
    # important for cases where another group gets added
    if $manage_service {
      User[$user] ~> $notify_service
    }
    ensure_resource('user', [$user], {
        ensure => 'present',
        system => true,
        groups => $extra_groups,
        shell  => $usershell,
    })

    if $manage_group {
      Group[$group] -> User[$user]
    }
  }
  if $manage_group {
    ensure_resource('group', [$group], {
        ensure => 'present',
        system => true,
    })
  }

  case $init_style { # lint:ignore:case_without_default
    'upstart': {
      file { "/etc/init/${name}.conf":
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        content => template('prometheus/daemon.upstart.erb'),
        notify  => $notify_service,
      }
      file { "/etc/init.d/${name}":
        ensure => link,
        target => '/lib/init/upstart-job',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
    }
    'systemd': {
      include 'systemd'
      systemd::unit_file { "${name}.service":
        content => epp('prometheus/daemon.systemd.epp', {
            'bin_dir'       => $bin_dir,
            'bin_name'      => $bin_name,
            'env_file_path' => $env_file_path,
            'group'         => $group,
            'name'          => $name,
            'options'       => $options,
            'unit_after'    => $unit_after,
            'user'          => $user
        }),
        notify  => $notify_service,
      }
      # Puppet 5 doesn't have https://tickets.puppetlabs.com/browse/PUP-3483
      # and camptocamp/systemd only creates this relationship when managing the service
      if $manage_service and versioncmp($facts['puppetversion'],'6.1.0') < 0 {
        Class['systemd::systemctl::daemon_reload'] -> Service[$name]
      }
    }
    # service_provider returns redhat on CentOS using sysv, https://tickets.puppetlabs.com/browse/PUP-5296
    'sysv','redhat': {
      file { "/etc/init.d/${name}":
        mode    => '0555',
        owner   => 'root',
        group   => 'root',
        content => template('prometheus/daemon.sysv.erb'),
        notify  => $notify_service,
      }
    }
    'debian': {
      file { "/etc/init.d/${name}":
        mode    => '0555',
        owner   => 'root',
        group   => 'root',
        content => template('prometheus/daemon.debian.erb'),
        notify  => $notify_service,
      }
    }
    'sles': {
      file { "/etc/init.d/${name}":
        mode    => '0555',
        owner   => 'root',
        group   => 'root',
        content => template('prometheus/daemon.sles.erb'),
        notify  => $notify_service,
      }
    }
    'launchd': {
      file { "/Library/LaunchDaemons/io.${name}.daemon.plist":
        mode    => '0644',
        owner   => 'root',
        group   => 'wheel',
        content => template('prometheus/daemon.launchd.erb'),
        notify  => $notify_service,
      }
    }
    'none': {}
  }

  if $env_file_path != undef {
    file { "${env_file_path}/${name}":
      mode    => '0644',
      owner   => 'root',
      group   => '0', # Darwin uses wheel
      content => template('prometheus/daemon.env.erb'),
      notify  => $notify_service,
    }
  }

  $init_selector = $init_style ? {
    'launchd' => "io.${name}.daemon",
    default   => $name,
  }

  $real_provider = $init_style ? {
    'sles'  => 'redhat',  # mimics puppet's default behaviour
    'sysv'  => 'redhat',  # all currently used cases for 'sysv' are redhat-compatible
    'none'  => undef,
    default => $init_style,
  }

  if $manage_service {
    service { $name:
      ensure   => $service_ensure,
      name     => $init_selector,
      enable   => $service_enable,
      provider => $real_provider,
    }
  }

  if $export_scrape_job {
    if $scrape_port == undef {
      fail('must set $scrape_port on exported daemon')
    }

    @@prometheus::scrape_job { "${scrape_job_name}_${scrape_host}_${scrape_port}":
      job_name => $scrape_job_name,
      targets  => ["${scrape_host}:${scrape_port}"],
      labels   => $scrape_job_labels,
    }
  }
}
