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

  describe 'n_gram_record_hash' do
    subject { n_gram_record_hash(post_code_array) } # n = 2
    let(:post_code_array) do
      [
        13104, '169  ', '1690074', 'トウキョウト', 'シンジュクク', 'キタシンジュク',
        '東京都', '新宿区', '北新宿', 0, 0, 1, 0, 0, 0
      ]
    end
    it 'convert n-gram keyword to post-code hash' do
      is_expected.to eq({
        '東京' => '1690074',
        '京都' => '1690074',
        '都' => '1690074',
        '新宿' => '1690074',
        '宿区' => '1690074',
        '区' => '1690074',
        '北新' => '1690074',
        '宿' => '1690074',
      })
    end
  end
end
