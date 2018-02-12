require 'spec_helper'

describe PostCodeIndex do
  describe %q<n_gram_array('abcbcd', n)> do
    subject { n_gram_array('abcbcd', n) }
    context 'n = 2' do
      let(:n) { 2 }
      it { is_expected.to match_array %w(ab bc cb bc cd) }
    end
    context 'n = 6' do
      let(:n) { 6 }
      it { is_expected.to match_array %w(abcbcd) }
    end
    context 'n = 10 (bigger than string size)' do
      let(:n) { 10 }
      it { is_expected.to match_array %w(abcbcd) }
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
      is_expected.to eq(['1690074', ['東京', '京都', '都新', '新宿', '宿区', '区北', '北新']])
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
        '都新' => ['1620044', '1690074', '1620834'],
        '新宿' => ['1620044', '1690074', '1620834'],
        '宿区' => ['1620044', '1690074', '1620834'],
        '区喜' => ['1620044'],
        '喜久' => ['1620044'],
        '久井' => ['1620044'],
        '井町' => ['1620044'],
        '区北' => ['1690074', '1620834'],
        '北新' => ['1690074'],
        '北町' => ['1620834'],
      })
    end
  end

  describe 'search_by_n_gram' do
    subject { search_by_n_gram(n_gram_dictionary, keyword) }
    let(:n_gram_dictionary) do
      {
        '東京' => ['1620044', '1690074', '1620834'],
        '京都' => ['1620044', '1690074', '1620834'],
        '都新' => ['1620044', '1690074', '1620834'],
        '新宿' => ['1620044', '1690074', '1620834'],
        '宿区' => ['1620044', '1690074', '1620834'],
        '区喜' => ['1620044'],
        '喜久' => ['1620044'],
        '久井' => ['1620044'],
        '井町' => ['1620044'],
        '区北' => ['1690074', '1620834'],
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

  describe 'find_record' do
    subject { find_record(dictionary, post_codes, keyword_div) }
    let(:dictionary) do
      {
        '6020824' => [['26102', '602  ', '6020824', 'キョウトフ', 'キョウトシカミギョウク', 'イッシンチョウ',
          '京都府', '京都市上京区', '一真町', '0', '0', '0', '0', '0', '0']],
        '6028272' => [
          [
            '26102', '602  ', '6028272', 'キョウトフ', 'キョウトシカミギョウク', 'カメキチョウ',
            '京都府', '京都市上京区', '亀木町', '0', '0', '0', '0', '0', '0'
          ], [
            '26102', '602  ', '6028272', 'キョウトフ', 'キョウトシカミギョウク', 'カメキチョウ',
            '京都府', '京都市上京区', '架空町', '0', '0', '0', '0', '0', '0'
          ],
        ],
        '6028062' => [
          [
            '26102', '602  ', '6028062', 'キョウトフ', 'キョウトシカミギョウク', 'カメヤチョウ', '京都府', '京都市上京区',
            '亀屋町（油小路通上長者町下る、油小路通下長者町上る、油小路通', '0', '0', '0', '0', '0', '0'
          ], [
            '26102', '602  ', '6028062', 'キョウトフ', 'キョウトシカミギョウク', 'カメヤチョウ', '京都府', '京都市上京区',
            '中長者町上る、油小路通中長者町下る、上長者町通油小路西入、上長者町通油小', '0', '0', '0', '0', '0', '0'
          ],[
            '26102', '602  ', '6028062', 'キョウトフ', 'キョウトシカミギョウク', 'カメヤチョウ', '京都府', '京都市上京区',
            '路東入）', '0', '0', '0', '0', '0', '0'
          ],
        ]
      }
    end
    context 'find one record' do
      let(:post_codes) { ['6020824'] }
      let(:keyword_div) { ['一真町'] }
      it 'find record' do
        is_expected.to match_array [[
          '26102', '602  ', '6020824', 'キョウトフ', 'キョウトシカミギョウク', 'イッシンチョウ',
          '京都府', '京都市上京区', '一真町', '0', '0', '0', '0', '0', '0'
        ]]
      end
    end
    context 'find devided record' do
      let(:post_codes) { ['6028062'] }
      let(:keyword_div) { ['亀屋町'] }
      it 'concat records and find' do
        is_expected.to match_array [[
          '26102', '602  ', '6028062', 'キョウトフ', 'キョウトシカミギョウク', 'カメヤチョウ', '京都府', '京都市上京区',
          '亀屋町（油小路通上長者町下る、油小路通下長者町上る、油小路通中長者町上る、油小路通中長者町下る、上長者町通油小路西入、上長者町通油小路東入）',
          '0', '0', '0', '0', '0', '0'
        ]]
      end
    end
    context 'find duplicated record' do
      let(:post_codes) { ['6028272'] }
      let(:keyword_div) { ['京', '亀'] }
      it 'find record in duplicated record' do
        is_expected.to match_array [[
          '26102', '602  ', '6028272', 'キョウトフ', 'キョウトシカミギョウク', 'カメキチョウ',
          '京都府', '京都市上京区', '亀木町', '0', '0', '0', '0', '0', '0'
        ]]
      end
    end
  end
end
