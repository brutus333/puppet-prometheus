require 'spec_helper_acceptance'

describe 'prometheus dellhw_exporter' do
  it 'dellhw_exporter works idempotently with no errors' do
    pp = 'include prometheus::exporter::dellhw'
    # Run it twice and test for idempotency
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe service('dellhw_exporter') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe port(9137) do
    it { is_expected.to be_listening.with('tcp6') }
  end
end
