require 'spec_helper'

describe 'prometheus::exporter::puppetdb' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with all defaults' do
        describe 'with all defaults' do
          it { is_expected.to compile.with_all_deps }
          if facts[:os]['name'] == 'Archlinux'
            it { is_expected.to contain_package('puppetdb_exporter') }
            it { is_expected.not_to contain_file('/usr/local/bin/puppetdb_exporter') }
            it { is_expected.not_to contain_archive('/tmp/puppetdb_exporter-1.1.0.tar.gz') }
          else
            it { is_expected.to contain_archive('/tmp/puppetdb_exporter-1.1.0.tar.gz') }
            it { is_expected.to contain_file('/usr/local/bin/puppetdb_exporter').with('target' => '/opt/prometheus-puppetdb-exporter-1.1.0.linux-amd64/prometheus-puppetdb-exporter') }
            it { is_expected.to contain_file('/opt/prometheus-puppetdb-exporter-1.1.0.linux-amd64/prometheus-puppetdb-exporter') }
            it { is_expected.not_to contain_package('puppetdb_exporter') }
          end
          it { is_expected.to contain_prometheus__daemon('puppetdb_exporter') }
          it { is_expected.to contain_user('puppetdb-exporter') }
          it { is_expected.to contain_group('puppetdb-exporter') }
          it { is_expected.to contain_service('puppetdb_exporter') }
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to contain_systemd__unit_file('puppetdb_exporter.service') }
        end
      end
    end
  end
end
