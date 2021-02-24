require 'spec_helper_acceptance'

describe 'prometheus bind exporter' do
  it 'bind_exporter works idempotently with no errors' do
    pp = 'include prometheus::exporter::bind'
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe 'default install' do
    describe service('bind_exporter') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
    describe port(9119) do
      it { is_expected.to be_listening.with('tcp6') }
    end
  end
end
