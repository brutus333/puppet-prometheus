require 'spec_helper_acceptance'

describe 'prometheus mongodb exporter' do
  it 'mongodb_exporter works idempotently with no errors' do
    pp = 'include prometheus::mongodb_exporter'
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('mongodb_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end
  describe port(9216) do
    it { is_expected.to be_listening.with('tcp6') }
  end

  describe 'mongodb_exporter update from 0.3.1 to 0.11.0' do
    it 'is idempotent' do
      pp = "class{'prometheus::mongodb_exporter': version => '0.3.1'}"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('mongodb_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9216) do
      it { is_expected.to be_listening.with('tcp6') }
    end
    it 'is idempotent' do
      pp = "class{'prometheus::mongodb_exporter': version => '0.11.0'}"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe service('mongodb_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end

    describe port(9216) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
