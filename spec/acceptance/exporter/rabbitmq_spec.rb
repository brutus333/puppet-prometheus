require 'spec_helper_acceptance'

describe 'prometheus rabbitmq_exporter' do
  it 'rabbitmq_exporter works idempotently with no errors' do
    pp = <<-EOS
      class { 'prometheus::exporter::rabbitmq':
        extra_env_vars => {
          'PUBLISH_PORT' => '9419',
        },
        scrape_port    => 9419,
      }
    EOS
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe 'prometheus rabbitmq_exporter version 0.25.2' do
    it 'rabbitmq_exporter installs with version 0.25.2' do
      pp = <<-EOS
        class { 'prometheus::exporter::rabbitmq':
          version        => '0.25.2',
          extra_env_vars => {
            'PUBLISH_PORT' => '9419',
          },
          scrape_port    => 9419,
        }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('rabbitmq_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9090) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end

  describe 'prometheus rabbitmq_exporter version 0.29.0' do
    it 'rabbitmq_exporter installs with version 0.29.0' do
      pp = <<-EOS
        class { 'prometheus::exporter::rabbitmq':
          version        => '0.29.0',
          extra_env_vars => {
            'PUBLISH_PORT' => '9419',
          },
          scrape_port    => 9419,
        }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('rabbitmq_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9090) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
