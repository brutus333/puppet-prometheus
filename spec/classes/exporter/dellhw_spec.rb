require 'spec_helper'

describe 'prometheus::exporter::dellhw' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(os_specific_facts(facts))
      end

      context 'with all defaults' do
        describe 'with all defaults' do
          it { is_expected.to compile.with_all_deps }
          if facts[:os]['name'] == 'Archlinux'
            it { is_expected.to contain_package('dellhw_exporter') }
            it { is_expected.not_to contain_file('/usr/local/bin/dellhw_exporter') }
            it { is_expected.not_to contain_archive('/tmp/dellhw_exporter-1.6.0.tar.gz') }
          else
            it { is_expected.to contain_archive('/tmp/dellhw_exporter-1.6.0.tar.gz') }
            it { is_expected.to contain_file('/usr/local/bin/dellhw_exporter').with('target' => '/opt/dellhw_exporter-1.6.0.linux-amd64/dellhw_exporter') }
            it { is_expected.to contain_file('/opt/dellhw_exporter-1.6.0.linux-amd64/dellhw_exporter') }
            it { is_expected.not_to contain_package('dellhw_exporter') }
          end
          it { is_expected.to contain_prometheus__daemon('dellhw_exporter') }
          it { is_expected.to contain_user('dellhw-exporter') }
          it { is_expected.to contain_group('dellhw-exporter') }
          it { is_expected.to contain_service('dellhw_exporter') }
          it { is_expected.to contain_class('prometheus') }
        end
      end
    end
  end
end
