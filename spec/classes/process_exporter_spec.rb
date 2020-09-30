require 'spec_helper'

describe 'prometheus::process_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('prometheus') }
        it { is_expected.to contain_user('process-exporter') }
        it { is_expected.to contain_group('process-exporter') }
        it { is_expected.to contain_prometheus__daemon('process-exporter').with(options: '-config.path=/etc/process-exporter.yaml ') }
        it { is_expected.to contain_service('process-exporter') }
      end

      context 'with version specified' do
        let(:params) do
          {
            version: '0.2.4',
            arch: 'amd64',
            os: 'linux',
            bin_dir: '/usr/local/bin',
            install_method: 'url',
            service_name: 'process-exporter'
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_archive('/tmp/process-exporter-0.2.4.tar.gz') }
        describe 'install correct binary' do
          it { is_expected.to contain_file('/usr/local/bin/process-exporter').with('target' => '/opt/process-exporter-0.2.4.linux-amd64/process-exporter') }
        end
      end

      context 'with has_watched_processes specified' do
        let(:params) do
          {
            hash_watched_processes: {
              'process_names' => [
                {
                  'name'    => '{{.Matches}}',
                  'cmdline' => ['.*process1.*']
                },
                {
                  'name'    => '{{.Matches}}',
                  'cmdline' => ['.*process2.*']
                }
              ]
            }
          }
        end

        describe 'has config_path file with expected content' do
          it { is_expected.to contain_file('/etc/process-exporter.yaml').with_content(File.read(fixtures('files', 'process-exporter.yaml'))) }
        end
      end
    end
  end
end
