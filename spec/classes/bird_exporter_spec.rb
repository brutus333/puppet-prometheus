require 'spec_helper'

describe 'prometheus::bird_exporter' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end
      let(:params) do
        {
          service_name: 'bird_exporter'
        }
      end

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('prometheus') }
        it { is_expected.to contain_prometheus__daemon('bird_exporter') }
        it { is_expected.to contain_service('bird_exporter') }
        it { is_expected.to contain_group('bird-exporter') }
        it { is_expected.to contain_user('bird-exporter') }
        it { is_expected.to contain_file('/usr/local/bin/bird_exporter') }
        it { is_expected.to contain_archive('/opt/bird_exporter-1.2.4.linux-amd64/bird_exporter') }
        it { is_expected.to contain_file('/opt/bird_exporter-1.2.4.linux-amd64/bird_exporter') }
        it { is_expected.to contain_file('/opt/bird_exporter-1.2.4.linux-amd64').with_ensure('directory') }

        if facts[:os]['release']['major'].to_i == 6
          it { is_expected.to contain_file('/etc/init.d/bird_exporter') }
        else
          it { is_expected.to contain_systemd__unit_file('bird_exporter.service') }
        end

        if facts[:os]['family'] == 'RedHat'
          it { is_expected.not_to contain_file('/etc/sysconfig/bird_exporter') }
        else
          it { is_expected.not_to contain_file('/etc/default/bird_exporter') }
        end
      end

      context 'with env vars' do
        let :params do
          {
            env_vars: {
              blub: 'foobar'
            }
          }
        end

        it { is_expected.to compile.with_all_deps }
        if facts[:os]['family'] == 'RedHat'
          it { is_expected.to contain_file('/etc/sysconfig/bird_exporter') }
          it { is_expected.not_to contain_file('/etc/default/bird_exporter') }
        else
          it { is_expected.to contain_file('/etc/default/bird_exporter') }
          it { is_expected.not_to contain_file('/etc/sysconfig/bird_exporter') }
        end
      end
    end
  end
end
