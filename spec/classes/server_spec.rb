require 'spec_helper'

describe 'prometheus::server' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      [{ version: '2.0.0-rc.1', bin_dir: '/usr/local/bin', install_method: 'url' }].each do |parameters|
        context "with parameters #{parameters}" do
          let(:params) do
            parameters
          end

          if ['centos-7-x86_64', 'centos-8-x86_64', 'debian-9-x86_64', 'redhat-7-x86_64', 'redhat-8-x86_64', 'ubuntu-16.04-x86_64', 'ubuntu-18.04-x86_64'].include?(os)
            prom_version = parameters[:version] || '1.5.2'
            prom_major = prom_version[0]
            it {
              is_expected.to contain_class('systemd')
            }

            it {
              is_expected.to contain_systemd__unit_file('prometheus.service').with(
                'content' => File.read(fixtures('files', "prometheus#{prom_major}.systemd"))
              )
            }
            describe 'max_open_files' do
              context 'by default' do
                it {
                  content = catalogue.resource('systemd::unit_file', 'prometheus.service').send(:parameters)[:content]
                  expect(content).not_to include('LimitNOFILE')
                }
              end
              context 'when set to 1000000' do
                let(:params) do
                  parameters.merge('max_open_files' => 1_000_000)
                end

                it {
                  content = catalogue.resource('systemd::unit_file', 'prometheus.service').send(:parameters)[:content]
                  expect(content).to include('LimitNOFILE=1000000')
                }
              end
            end
            describe 'timeout_stop' do
              context 'by default' do
                it {
                  content = catalogue.resource('systemd::unit_file', 'prometheus.service').send(:parameters)[:content]
                  expect(content).not_to include('TimeoutStopSec')
                }
              end
              context 'when set to 5min' do
                let(:params) do
                  parameters.merge('timeout_stop' => '5min')
                end

                it {
                  content = catalogue.resource('systemd::unit_file', 'prometheus.service').send(:parameters)[:content]
                  expect(content).to include('TimeoutStopSec=5min')
                }
              end
            end
          end
        end
      end
    end
  end
end
