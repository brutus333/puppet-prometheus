require 'spec_helper_acceptance'

describe 'prometheus graphite exporter' do
  it 'graphite_exporter works idempotently with no errors' do
    pp = 'include prometheus::exporter::graphite'
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('graphite_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  describe port(9109) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'graphite_exporter update from 0.2.0 to 0.7.1' do
    it 'is idempotent' do
      pp = "class{'prometheus::exporter::graphite': version => '0.2.0'}"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('graphite_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9109) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::exporter::graphite': version => '0.7.1'}"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('graphite_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9109) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
