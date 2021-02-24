# @summary manages prometheus postfix_exporter
# @example Basic usage
#   include prometheus::exporter::postfix
# @see https://github.com/kumina/postfix_exporter
# @param install_method
#   Installation method: `url` or `package`. (Note `package` is not available on most OSes.)
# @param download_url
#   Complete URL corresponding to the where the release can be downloaded. (This option is only relevant when `install_method` is `url`.)
# @param download_url_base
#   Base URL for the binary archive. (This option is only relevant when `install_method` is `url`.)
# @param download_extension
#   Extension for the release binary archive. (This option is only relevant when `install_method` is `url`.)
# @param version
#   The binary release version. (This option is only relevant when `install_method` is `url`.)
# @param package_ensure
#   Used when `install_method` is `package`.
# @param package_name
#   Used when `install_method` is `package`.
# @param manage_user
#   Whether to create and manage the exporter's user. This can eg. be set to `false` if your package already creates a user for you.
# @param user
#   User which runs the service.
# @param manage_group
#   Whether to create and manage the exporter's group. This can eg. be set to `false` if your package already creates a group for you.
# @param group
#   Group to run the service as.
# @param extra_groups
#   Extra groups to add the exporter user to.
# @param manage_service
#   Should puppet manage the service?
# @param init_style
#   Service startup scripts style. When not set, the correct default for your OS will be used.
#   Can also be set to `none` when you don't want the class to create a startup script/unit_file for you.
#   Typically this can be used when a package is already providing the file.
# @param service_name
#   The name of the service.
# @param service_ensure
#   Desired state for the service.
# @param service_enable
#   Whether to enable the service from puppet.
# @param extra_options
#   Extra options added to the startup command. Override these if you want to monitor a logfile instead of systemd.
# @param restart_on_change
#   Should puppet restart the service on configuration change?
# @param export_scrape_job
#   Whether to export a `prometheus::scrape_job` to puppetDB for collecting on your prometheus server.
# @param scrape_port
#   The port to use in the scrape job.  This won't normally need to be changed unless you run the exporter with a non-default port by overriding `extra_options`.
# @param scrape_job_name
#   The name of the scrape job. When configuring prometheus with this puppet module, the jobs to be collected are configured with `prometheus::collect_scrape_jobs`.
# @param scrape_job_labels
#   Labels to configure on the scrape job. If not set, the `prometheus::daemon` default (`{ 'alias' => $scrape_host }`) will be used.
class prometheus::exporter::postfix (
  # Installation options
  Enum['url','package'] $install_method   = 'url',
  Optional[Stdlib::HTTPUrl] $download_url = undef,
  Stdlib::HTTPUrl $download_url_base      = 'https://github.com/kumina/postfix_exporter/releases',
  String $download_extension              = '',
  String[1] $version                      = '0.2.0',

  # Package options (relevant when `install_method == 'package'`)
  String[1] $package_ensure               = 'installed',
  String[1] $package_name                 = 'postfix_exporter',

  # user/group configuration
  Boolean          $manage_user  = true,
  String[1]        $user         = 'postfix-exporter',
  Boolean          $manage_group = true,
  String[1]        $group        = 'postfix-exporter',
  Array[String[1]] $extra_groups = [],

  # service related options
  Boolean                         $manage_service = true,
  Optional[Prometheus::Initstyle] $init_style     = undef,
  String[1]                       $service_name   = 'postfix_exporter',
  Stdlib::Ensure::Service         $service_ensure = 'running',
  Boolean                         $service_enable = true,

  # exporter configuration
  String  $extra_options     = '--systemd.enable --systemd.unit=\'postfix.service\' --postfix.logfile_path=\'\'',
  Boolean $restart_on_change = true,

  # scrape job configuration
  Boolean        $export_scrape_job = false,
  Optional[Stdlib::Host] $scrape_host  = undef,
  Stdlib::Port   $scrape_port       = 9154,
  String[1]      $scrape_job_name   = 'postfix',
  Optional[Hash] $scrape_job_labels = undef,
) {
  include prometheus

  $real_download_url = pick($download_url,"${download_url_base}/download/${version}/${package_name}")
  $notify_service = $restart_on_change ? {
    true    => Service[$service_name],
    default => undef,
  }

  prometheus::daemon { $service_name:
    install_method     => $install_method,
    version            => $version,
    download_extension => $download_extension,
    os                 => $prometheus::os,
    arch               => $prometheus::real_arch,
    real_download_url  => $real_download_url,
    bin_dir            => $prometheus::bin_dir,
    notify_service     => $notify_service,
    package_name       => $package_name,
    package_ensure     => $package_ensure,
    manage_user        => $manage_user,
    user               => $user,
    extra_groups       => $extra_groups,
    group              => $group,
    manage_group       => $manage_group,
    options            => $extra_options,
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
