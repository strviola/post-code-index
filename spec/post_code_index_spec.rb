require 'spec_helper'

describe PostCodeIndex do
  describe %q<n_gram_array('abcbcd', n)> do
    subject { n_gram_array('abcbcd', n) }
    context 'n = 2' do
      let(:n) { 2 }
      it { is_expected.to match_array %w(ab bc cb bc cd d) }
    end
    context 'n = 3' do
      let(:n) { 3 }
      it { is_expected.to match_array %w(abc bcb cbc bcd cd d) }
    end
  end
end
