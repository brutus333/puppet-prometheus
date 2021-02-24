include prometheus
include prometheus::exporter::node
include prometheus::alertmanager
include prometheus::alerts
include prometheus::exporter::statsd
include prometheus::exporter::process
include prometheus::exporter::blackbox
include prometheus::exporter::beanstalkd

class { 'prometheus::exporter::postgres' :
  group                => 'postgres',
  user                 => 'postgres',
  postgres_auth_method => 'custom',
  data_source_custom   => {
    'DATA_SOURCE_NAME' => 'user=postgres host=/var/run/postgresql/ sslmode=disable',
  },
}
