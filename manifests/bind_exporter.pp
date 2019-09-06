# Class: prometheus::bind_exporter
#
# This module manages prometheus bind_exporter
#
# Parameters:
#  [*arch*]
#  Architecture (amd64 or i386)
#
#  [*bin_dir*]
#  Directory where binaries are located
#
#  [*config_mode*]
#  The permissions of the configuration files
#
#  [*download_extension*]
#  Extension for the release binary archive
#
#  [*download_url*]
#  Complete URL corresponding to the where the release binary archive can be downloaded
#
#  [*download_url_base*]
#  Base URL for the binary archive
#
#  [*extra_groups*]
#  Extra groups to add the binary user to
#
#  [*extra_options*]
#  Extra options added to the startup command
#
#  [*group*]
#  Group under which the binary is running
#
#  [*init_style*]
#  Service startup scripts style (e.g. rc, upstart or systemd)
#
#  [*install_method*]
#  Installation method: url or package (only url is supported currently)
#
#  [*manage_group*]
#  Whether to create a group for or rely on external code for that
#
#  [*manage_service*]
#  Should puppet manage the service? (default true)
#
#  [*manage_user*]
#  Whether to create user or rely on external code for that
#
#  [*os*]
#  Operating system (linux is the only one supported)
#
#  [*package_ensure*]
#  If package, then use this for package ensure default 'latest'
#
#  [*package_name*]
#  The binary package name - not available yet
#
#  [*purge_config_dir*]
#  Purge config files no longer generated by Puppet
#
#  [*restart_on_change*]
#  Should puppet restart the service on configuration change? (default true)
#
#  [*service_enable*]
#  Whether to enable the service from puppet (default true)
#
#  [*service_ensure*]
#  State ensured for the service (default 'running')
#
#  [*user*]
#  User which runs the service
#
#  [*version*]
#  The binary release version

class prometheus::bind_exporter (
  String $download_extension,
  Variant[Stdlib::HTTPSUrl, Stdlib::HTTPUrl] $download_url_base,
  Array[String[1]] $extra_groups,
  String[1] $group,
  String[1] $package_ensure,
  String[1] $package_name,
  String[1] $user,
  String[1] $version,
  Boolean $purge_config_dir                                          = true,
  Boolean $restart_on_change                                         = true,
  Boolean $service_enable                                            = true,
  String[1] $service_ensure                                          = 'running',
  String $service_name                                               = 'bind_exporter',
  String[1] $init_style                                              = $prometheus::init_style,
  String[1] $install_method                                          = $prometheus::install_method,
  Boolean $manage_group                                              = true,
  Boolean $manage_service                                            = true,
  Boolean $manage_user                                               = true,
  String[1] $os                                                      = $prometheus::os,
  String $extra_options                                              = '',
  Hash[String, Scalar] $env_vars                                     = {},
  Optional[Variant[Stdlib::HTTPSUrl, Stdlib::HTTPUrl]] $download_url = undef,
  String[1] $config_mode                                             = $prometheus::config_mode,
  String[1] $arch                                                    = $prometheus::real_arch,
  Stdlib::Absolutepath $bin_dir                                      = $prometheus::bin_dir,
  Boolean $export_scrape_job                                         = false,
  Stdlib::Port $scrape_port                                          = 9119,
  String[1] $scrape_job_name                                         = 'bind',
) inherits prometheus {

  #Please provide the download_url for versions < 0.9.0
  $real_download_url    = pick($download_url,"${download_url_base}/download/v${version}/${package_name}-${version}.${os}-${arch}.${download_extension}")
  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  prometheus::daemon { $service_name:
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os                 => $os,
    arch               => $arch,
    real_download_url  => $real_download_url,
    bin_dir            => $bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    group              => $group,
    manage_group       => $manage_group,
    purge              => $purge_config_dir,
    options            => $extra_options,
    env_vars           => $env_vars,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    export_scrape_job  => $export_scrape_job,
    scrape_port        => $scrape_port,
    scrape_job_name    => $scrape_job_name,
  }
}
