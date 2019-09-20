# Class: prometheus::haproxy_exporter
#
# This module manages prometheus haproxy_exporter
#
# Parameters:
#  [*arch*]
#  Architecture (amd64 or i386)
#
#  [*bin_dir*]
#  Directory where binaries are located
#
#  [*cnf_scrape_uri*]
#  The URI to obtain HAProxy stats from
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

class prometheus::haproxy_exporter(
  Variant[Stdlib::HTTPUrl, Pattern[/unix:(?:\/.+)+/]] $cnf_scrape_uri,
  String $download_extension,
  Array $extra_groups,
  String $group,
  String $package_ensure,
  String $package_name,
  String $user,
  String $version,
  Prometheus::Uri $download_url_base,
  Boolean $purge_config_dir      = true,
  Boolean $restart_on_change     = true,
  Boolean $service_enable        = true,
  $service_ensure                = 'running',
  String $init_style             = $prometheus::init_style,
  String $install_method         = $prometheus::install_method,
  Boolean $manage_group          = true,
  Boolean $manage_service        = true,
  Boolean $manage_user           = true,
  String $os                     = $prometheus::os,
  String $extra_options          = '',
  Optional[String] $download_url = undef,
  String $arch                   = $prometheus::real_arch,
  Stdlib::Absolutepath $bin_dir  = $prometheus::bin_dir,
  Boolean $export_scrape_job     = false,
  Stdlib::Port $scrape_port      = 9101,
  String[1] $scrape_job_name     = 'haproxy',
  Optional[Hash] $scrape_job_labels = {},
) inherits prometheus {

  $real_download_url = pick($download_url,"${download_url_base}/download/v${version}/${package_name}-${version}.${os}-${arch}.${download_extension}")
  $notify_service = $restart_on_change ? {
    true    => Service['haproxy_exporter'],
    default => undef,
  }

  $options = "--haproxy.scrape-uri=\"${cnf_scrape_uri}\" ${extra_options}"

  prometheus::daemon { 'haproxy_exporter':
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
    options            => $options,
    init_style         => $init_style,
    service_ensure     => $service_ensure,
    service_enable     => $service_enable,
    manage_service     => $manage_service,
    export_scrape_job  => $export_scrape_job,
    scrape_port        => $scrape_port,
    scrape_job_name    => $scrape_job_name,
    scrape_job_labels  => $scrape_job_labels,
  }

}
