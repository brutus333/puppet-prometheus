# @summary This module manages prometheus blackbox_exporter
# @param arch
#  Architecture (amd64 or i386)
# @param bin_dir
#  Directory where binaries are located
# @param config_file
#  Absolute path to configuration file (blackbox module definitions)
# @param download_extension
#  Extension for the release binary archive
# @param download_url
#  Complete URL corresponding to the where the release binary archive can be downloaded
# @param download_url_base
#  Base URL for the binary archive
# @param extra_groups
#  Extra groups to add the binary user to
# @param extra_options
#  Extra options added to the startup command
# @param group
#  Group under which the binary is running
# @param init_style
#  Service startup scripts style (e.g. rc, upstart or systemd)
# @param install_method
#  Installation method: url or package (only url is supported currently)
# @param manage_group
#  Whether to create a group for or rely on external code for that
# @param manage_service
#  Should puppet manage the service? (default true)
# @param manage_user
#  Whether to create user or rely on external code for that
# @param modules
#  Structured, array of blackbox module definitions for different probe types
# @param os
#  Operating system (linux is the only one supported)
# @param package_ensure
#  If package, then use this for package ensure default 'latest'
# @param package_name
#  The binary package name - not available yet
# @param restart_on_change
#  Should puppet restart the service on configuration change? (default true)
# @param service_enable
#  Whether to enable the service from puppet (default true)
# @param service_ensure
#  State ensured for the service (default 'running')
# @param service_name
#  Name of the node exporter service (default 'blackbox_exporter')
# @param user
#  User which runs the service
# @param version
#  The binary release version
# @param config_mode
#  The permissions of the configuration files
# Example for configuring named blackbox modules via hiera
# details of the format: https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md
# @example
# prometheus::exporter::blackbox::modules:
#   simple_ssl:
#     prober: http
#     timeout: 10s
#     http:
#       fail_if_not_ssl: true
#   easy_tcp:
#     prober: tcp
#     tcp:
#       preferred_ip_protocol: ip4
class prometheus::exporter::blackbox (
  String[1] $config_file,
  String $download_extension,
  String[1] $download_url_base,
  Array[String] $extra_groups,
  String[1] $group,
  String[1] $package_ensure,
  String[1] $package_name,
  String[1] $user,
  String[1] $version,
  Boolean $restart_on_change              = true,
  Boolean $service_enable                 = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  String[1] $service_name                 = 'blackbox_exporter',
  Prometheus::Initstyle $init_style       = $facts['service_provider'],
  Prometheus::Install $install_method     = $prometheus::install_method,
  Boolean $manage_group                   = true,
  Boolean $manage_service                 = true,
  Boolean $manage_user                    = true,
  String[1] $os                           = downcase($facts['kernel']),
  String $extra_options                   = '',
  Optional[String] $download_url          = undef,
  String[1] $config_mode                  = $prometheus::config_mode,
  String[1] $arch                         = $prometheus::real_arch,
  String[1] $bin_dir                      = $prometheus::bin_dir,
  Hash $modules                           = {},
  Boolean $export_scrape_job              = false,
  Optional[Stdlib::Host] $scrape_host     = undef,
  Stdlib::Port $scrape_port               = 9115,
  String[1] $scrape_job_name              = 'blackbox',
  Optional[Hash] $scrape_job_labels       = undef,
) inherits prometheus {
  # Prometheus added a 'v' on the release name at 0.1.0 of blackbox
  if versioncmp ($version, '0.1.0') >= 0 {
    $release = "v${version}"
  }
  else {
    $release = $version
  }
  $real_download_url = pick($download_url,"${download_url_base}/download/${release}/${package_name}-${version}.${os}-${arch}.${download_extension}")
  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  $options = "--config.file=${config_file} ${extra_options}"

  file { $config_file:
    ensure  => file,
    owner   => 'root',
    group   => $group,
    mode    => $config_mode,
    content => template('prometheus/blackbox_exporter.yaml.erb'),
    notify  => $notify_service,
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
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    export_scrape_job  => $export_scrape_job,
    scrape_host        => $scrape_host,
    scrape_port        => $scrape_port,
    scrape_job_name    => $scrape_job_name,
    scrape_job_labels  => $scrape_job_labels,
  }
}
