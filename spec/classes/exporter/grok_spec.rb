require 'spec_helper'

describe 'prometheus::exporter::grok' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '1.0.0.RC3',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url',
            config: {
              'global' => {
                'config_version' => 3
              },
              'input' => {
                'type' => 'file',
                'path' => '/var/log/syslog'
              },
              'metrics' => [
                {
                  'name'  => 'syslog_errors',
                  'type'  => 'counter',
                  'help'  => 'number of syslog errors',
                  'match' => 'error'
                }
              ]
            }
          }
        end

        describe 'with all defaults' do
          it { is_expected.to contain_class('prometheus') }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/usr/local/bin/grok_exporter').with('target' => '/opt/grok_exporter-1.0.0.RC3.linux-amd64/grok_exporter') }
          it { is_expected.to contain_prometheus__daemon('grok_exporter') }
          it { is_expected.to contain_user('grok-exporter') }
          it { is_expected.to contain_group('grok-exporter') }
          it { is_expected.to contain_service('grok_exporter') }
          it { is_expected.to contain_archive('/tmp/grok_exporter-1.0.0.RC3.zip') }
          it { is_expected.to contain_file('/opt/grok_exporter-1.0.0.RC3.linux-amd64/grok_exporter') }
          it { is_expected.to contain_file('/etc/grok-exporter.yaml').with_content(File.read(fixtures('files', 'grok-exporter.yaml'))) }
        end
      end
    end
  end
end
