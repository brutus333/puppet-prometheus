require 'spec_helper'

describe 'prometheus::exporter::apache' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
        if facts[:os]['release']['major'].to_i == 6
          it { is_expected.to contain_file('/etc/init.d/apache_exporter') }
        else
          it { is_expected.to contain_systemd__unit_file('apache_exporter.service') }
        end

        if facts[:os]['name'] == 'Archlinux'
          it { is_expected.to contain_package('apache_exporter') }
          it { is_expected.not_to contain_archive('/tmp/apache_exporter-0.8.0.tar.gz') }
          it { is_expected.not_to contain_file('/opt/apache_exporter-0.8.0.linux-amd64/apache_exporter') }
        else
          it { is_expected.not_to contain_package('apache-exporter') }
          it { is_expected.to contain_archive('/tmp/apache_exporter-0.8.0.tar.gz') }
          it { is_expected.to contain_file('/opt/apache_exporter-0.8.0.linux-amd64/apache_exporter') }
        end
      end
      context 'with some params' do
        let(:params) do
          {
            version: '0.5.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'with specific params' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_archive('/tmp/apache_exporter-0.5.0.tar.gz') }
          it { is_expected.to contain_file('/opt/apache_exporter-0.5.0.linux-amd64/apache_exporter') }
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to contain_group('apache-exporter') }
          it { is_expected.to contain_user('apache-exporter') }
          it { is_expected.to contain_prometheus__daemon('apache_exporter').with('options' => '-scrape_uri "http://localhost/server-status?auto" ') }
          it { is_expected.to contain_service('apache_exporter') }
        end
        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/apache_exporter').with('target' => '/opt/apache_exporter-0.5.0.linux-amd64/apache_exporter') }
        end
      end

      context 'with version, scrape_uri and extra options specified' do
        let(:params) do
          {
            scrape_uri: 'http://127.0.0.1/server-status?auto',
            extra_options: '-test',
            version: '0.4.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'with specific params' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_archive('/tmp/apache_exporter-0.4.0.tar.gz') }
          it { is_expected.to contain_file('/opt/apache_exporter-0.4.0.linux-amd64/apache_exporter') }
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to contain_group('apache-exporter') }
          it { is_expected.to contain_user('apache-exporter') }
          it { is_expected.to contain_prometheus__daemon('apache_exporter').with('options' => '-scrape_uri "http://127.0.0.1/server-status?auto" -test') }
          it { is_expected.to contain_service('apache_exporter') }
        end
        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/apache_exporter').with('target' => '/opt/apache_exporter-0.4.0.linux-amd64/apache_exporter') }
        end
      end

      context 'with version 0.8.0+' do
        let(:params) do
          {
            scrape_uri: 'http://127.0.0.1/server-status?auto',
            extra_options: '--test',
            version: '0.8.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'uses argument prefix correctly' do
          it { is_expected.to contain_prometheus__daemon('apache_exporter').with('options' => '--scrape_uri "http://127.0.0.1/server-status?auto" --test') }
        end
      end
    end
  end
end
