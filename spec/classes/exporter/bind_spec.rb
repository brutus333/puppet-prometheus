require 'spec_helper'

describe 'prometheus::exporter::bind' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with all defaults' do
        let(:params) do
          {
            version: '0.2.0',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url'
          }
        end

        describe 'with specific params' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to contain_group('bind-exporter') }
          it { is_expected.to contain_user('bind-exporter') }
          it { is_expected.to contain_prometheus__daemon('bind_exporter').with('options' => '') }
          it { is_expected.to contain_service('bind_exporter') }
        end
        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/bind_exporter').with('target' => '/opt/bind_exporter-0.2.0.linux-amd64/bind_exporter') }
        end
      end

      context 'with extra options specified' do
        let(:params) do
          {
            extra_options: "-bind.pid-file /var/run/named/named.pid -bind.stats-groups 'server,view,tasks'"
          }
        end

        describe 'with specific options' do
          it { is_expected.to contain_prometheus__daemon('bind_exporter').with('options' => "-bind.pid-file /var/run/named/named.pid -bind.stats-groups 'server,view,tasks'") }
        end
      end
    end
  end
end
