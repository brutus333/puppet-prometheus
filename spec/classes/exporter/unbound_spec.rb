require 'spec_helper'

describe 'prometheus::exporter::unbound' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('prometheus') }
        it { is_expected.to contain_prometheus__daemon('unbound_exporter') }
        it { is_expected.to contain_service('unbound_exporter') }
        it { is_expected.to contain_group('unbound-exporter') }
        it { is_expected.to contain_user('unbound-exporter') }
        it { is_expected.to contain_systemd__unit_file('unbound_exporter.service') }

        if facts[:os]['family'] == 'RedHat'
          it { is_expected.to contain_file('/etc/sysconfig/unbound_exporter') }
          it { is_expected.not_to contain_file('/etc/default/unbound_exporter') }
        else
          it { is_expected.to contain_file('/etc/default/unbound_exporter') }
          it { is_expected.not_to contain_file('/etc/sysconfig/unbound_exporter') }
        end
      end
    end
  end
end
