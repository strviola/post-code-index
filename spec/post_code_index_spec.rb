require 'spec_helper'

describe PostCodeIndex do
  describe %q<n_gram_array('abcbcd', n)> do
    subject { n_gram_array('abcbcd', n) }
    context 'n = 2' do
      let(:n) { 2 }
      it { is_expected.to match_array %w(ab bc cb bc cd) }
    end
    context 'n = 3' do
      let(:n) { 3 }
      it { is_expected.to match_array %w(abc bcb cbc bcd) }
    end
  end

  describe 'n_gram_post_code_words' do
    subject { n_gram_post_code_words(post_code_array) } # n = 2
    let(:post_code_array) do
      [
        13104, '169  ', '1690074', 'トウキョウト', 'シンジュクク', 'キタシンジュク',
        '東京都', '新宿区', '北新宿', 0, 0, 1, 0, 0, 0
      ]
    end
    it 'convert n-gram keyword to post-code hash' do
      is_expected.to eq(['1690074', ['東京', '京都', '新宿', '宿区', '北新']])
    end
  end

  describe 'n_gram_dictionary' do
    subject { n_gram_dictionary(csv_string) } # n = 2
    let(:csv_string) { <<~CSV }
      13104,"162  ","1620044","トウキョウト","シンジュクク","キクイチョウ","東京都","新宿区","喜久井町",0,0,0,0,0,0
      13104,"169  ","1690074","トウキョウト","シンジュクク","キタシンジュク","東京都","新宿区","北新宿",0,0,1,0,0,0
      13104,"162  ","1620834","トウキョウト","シンジュクク","キタマチ","東京都","新宿区","北町",0,0,0,0,0,0
    CSV
    it 'convert to dictionary keyword to post-codes array' do
      is_expected.to eq({
        '東京' => ['1620044', '1690074', '1620834'],
        '京都' => ['1620044', '1690074', '1620834'],
        '新宿' => ['1620044', '1690074', '1620834'],
        '宿区' => ['1620044', '1690074', '1620834'],
        '喜久' => ['1620044'],
        '久井' => ['1620044'],
        '井町' => ['1620044'],
        '北新' => ['1690074'],
        '北町' => ['1620834'],
      })
    end
  end

  xdescribe 'search_by_n_gram' do
    subject { search_by_n_gram(n_gram_dictionary, keyword) }
    let(:n_gram_dictionary) do
      {
        '東京' => ['1620044', '1690074', '1620834'],
        '京都' => ['1620044', '1690074', '1620834'],
        '新宿' => ['1620044', '1690074', '1620834'],
        '宿区' => ['1620044', '1690074', '1620834'],
        '喜久' => ['1620044'],
        '久井' => ['1620044'],
        '井町' => ['1620044'],
        '北新' => ['1690074'],
        '北町' => ['1620834'],
      }
    end
    context 'common keyword' do
      let(:keyword) { '新宿区' }
      it 'find post codes' do
        is_expected.to match_array ['1620044', '1690074', '1620834']
      end
    end
    context 'long keyword' do
      let(:keyword) { '新宿区喜久井町' }
      it 'find post codes' do
        is_expected.to match_array ['1620044']
      end
    end
  end
end
