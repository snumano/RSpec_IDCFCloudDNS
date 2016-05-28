# coding: utf-8
require 'spec_helper'

# export ABC='abc'
# RSPEC_ID
# RSPEC_PW

domain_word = FFaker::Internet.domain_word
domain_name = domain_word + '.com'
record_a_label= 'a'
record_a_name = record_a_label + '.' + domain_name
if record_a_name.length > 20
  record_a_name_short = record_a_name[0,20] + '...'
else
  record_a_name_short = record_a_name
end
ip_address = FFaker::Internet.ip_v4_address
unsupported_domain = '.xxx'
multibyte_domain = '日本語.com'
current_time = Time.now.strftime("%Y%m%d%H%M%S")

domain_name_63char_label = current_time + 'a'*49 + '.com'
domain_name_63char_label_short = domain_name_63char_label[0,20] + '...'
domain_name_over63char_label = current_time + 'a'*50 + '.com'
domain_name_255char  = current_time + 'b'*49 + '.' + 'c'*63 + '.' + 'd'*63 + '.' + 'e'*59 + '.com'
domain_name_255char_short = domain_name_255char[0,20] + '...'
domain_name_over255char  = current_time + 'b'*49 + '.' + 'c'*63 + '.' + 'd'*63 + '.' + 'e'*60 + '.com'

p domain_name
p ip_address
p current_time
p domain_name_63char_label
p domain_name_63char_label_short
p domain_name_255char
p domain_name_255char_short
p domain_name_over255char

describe 'DNS' do
  before(:all) do
    visit '/'
    fill_in('username', :with => ENV['RSPEC_ID'])
    fill_in('password', :with => ENV['RSPEC_PW'])
    click_on('ログイン')
#    save_and_open_page
  end
  shared_examples_for 'check the sidebar' do
    example "サイドバー" do
      expect(page).to have_content 'ゾーン'
      expect(page).to have_content 'テンプレート'
      expect(page).to have_content '逆引き'
      expect(page).to have_content '操作ログ'
      expect(page).to have_content '利用規約'
    end
  end

#️# selenium convertする
#  subject{page}
  describe 'ゾーン' do
    before do
      visit '/dns/'
    end

    it_should_behave_like 'check the sidebar'
    example{expect(page).to have_content 'DNSゾーン一覧'}
    
    describe 'DNSゾーン作成' do
      before do
        click_on 'DNSゾーン作成'
        sleep(1)
      end
      context '成功' do
        example 'ゾーン名 ***.com' do
          fill_in('name', :with => domain_name)
          sleep(1)
          click_on '作成する'
          sleep(1)
          expect(page).to have_content 'こちらの情報で登録しますか？'
          click_on 'はい'
          sleep(1)
          expect(page).to have_content 'ゾーンの登録を完了しました。'
        end
        example 'ラベル63文字' do
          fill_in('name', :with => domain_name_63char_label)
          sleep(1)
          click_on '作成する'
          sleep(1)
          expect(page).to have_content 'こちらの情報で登録しますか？'
          click_on 'はい'
          sleep(1)
          expect(page).to have_content 'ゾーンの登録を完了しました。'
        end
        example 'ゾーン名255文字' do
          fill_in('name', :with => domain_name_255char)
          sleep(1)
          click_on '作成する'
          sleep(1)
          expect(page).to have_content 'こちらの情報で登録しますか？'
          click_on 'はい'
          sleep(1)
          expect(page).to have_content 'ゾーンの登録を完了しました。'
        end
      end
      context '失敗' do 
        example 'ゾーン名 空白' do
          click_on '作成する'
          expect(page).to have_content '必須です。'
        end
        example 'ゾーン名 TLDなし' do
          fill_in('name', :with => domain_word)
          sleep(1)
          click_on '作成する'
          expect(page).to have_content 'ドメイン名が不正です。'
        end
        example 'サポート外TLD(.xxx)' do
          fill_in('name', :with => domain_word + unsupported_domain)
          sleep(1)
          click_on '作成する'
          expect(page).to have_content 'ドメイン名が不正です。'
        end
        example 'マルチバイトTLD(.東京)'do
          fill_in('name', :with => multibyte_domain)
          sleep(1)
          click_on '作成する'
          expect(page).to have_content 'ドメイン名が不正です。'
        end
        example 'ラベル63文字超過' do
          fill_in('name', :with => domain_name_over63char_label)
          sleep(1)
          click_on '作成する'
          expect(page).to have_content 'ドメイン名が不正です。'
        end
        example 'ゾーン名255文字超過' do
          fill_in('name', :with => domain_name_over255char)
          sleep(1)
          click_on '作成する'
          expect(page).to have_content '255文字以内で設定してください。'
        end
      end
    end
    describe 'DNSレコード一覧' do
      before do
        sleep(1)
        click_on domain_name
      end
      example '表示' do
        expect(page).to have_content domain_name
        expect(page).to have_content 'DNSゾーン詳細'
      end
      describe 'レコード登録' do
        context '登録成功' do
          example 'Aレコード' do
            click_on 'レコード登録'
            sleep(1)
            fill_in('name', :with => record_a_label)
            select 'A', from: 'form-input-type'
            fill_in('content', :with => ip_address)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
            sleep(1)
            expect(page).to have_content record_a_name_short
            expect(page).to have_content ip_address
          end
          example 'CNAMEレコード'
          example 'AAAAレコード'
          example 'MXレコード'
          example 'TXTレコード'
          example 'SRVレコード'
        end
        context '登録失敗' do
          context '必須項目未入力' do
            example 'Aレコード' do
              click_on 'レコード登録'
              click_on '登録する'
              sleep(1)
              within(:css, '#dns_record_create_form > div:nth-child(14) > div > div') do
                expect(page).to have_content '必須です。'
              end
              within(:css, '#dns_record_create_form > div:nth-child(16) > div > div') do
                expect(page).to have_content '必須です。'
              end
            end
            example 'CNAMEレコード'
            example 'AAAAレコード'
            example 'MXレコード'
            example 'TXTレコード'
            example 'SRVレコード'
          end
          context '限界値外' do
            example 'Aレコード'
            example 'CNAMEレコード'
            example 'AAAAレコード'
            example 'MXレコード'
            example 'TXTレコード'
            example 'SRVレコード'
          end
          context '不適切値' do
            example 'Aレコード'
            example 'CNAMEレコード'
            example 'AAAAレコード'
            example 'MXレコード'
            example 'TXTレコード'
            example 'SRVレコード'
          end
        end
      end
      describe 'レコード詳細' do
        example 'Aレコード'
        example 'CNAMEレコード'
        example 'AAAAレコード'
        example 'MXレコード'
        example 'TXTレコード'
        example 'SRVレコード'
      end
      describe 'レコード削除' do
        context '削除成功' do
          example 'Aレコード'
          example 'CNAMEレコード'
          example 'AAAAレコード'
          example 'MXレコード'
          example 'TXTレコード'
          example 'SRVレコード'
        end
        context '削除失敗' do
          example 'Aレコード'
          example 'CNAMEレコード'
          example 'AAAAレコード'
          example 'MXレコード'
          example 'TXTレコード'
          example 'SRVレコード'
        end
      end
    end
    describe 'ゾーン削除' do
      describe 'DNSゾーン削除' do
        example 'ゾーン名 ***.com' do
          click_on domain_name
          expect(page).to have_content domain_name
          # 「DNSゾーン詳細」をクリック。click_onでは動作せず。
          find(:xpath,'//*[@id="zone-detail"]/div/ol/li[1]/a').click
          click_on 'ゾーン削除'
          sleep(1)
          expect(page).to have_content 'このゾーンを削除しますか？'
          click_on 'はい'
          sleep(1)
          expect(page).to have_content 'ゾーンの削除が完了しました。'
          click_on 'OK'        
        end
        example 'ラベル名63文字' do
          click_on domain_name_63char_label_short
          expect(page).to have_content domain_name_63char_label
          # 「DNSゾーン詳細」をクリック。click_onでは動作せず。
          find(:xpath,'//*[@id="zone-detail"]/div/ol/li[1]/a').click
          click_on 'ゾーン削除'
          sleep(1)
          expect(page).to have_content 'このゾーンを削除しますか？'
          click_on 'はい'
          sleep(1)
          expect(page).to have_content 'ゾーンの削除が完了しました。'
          click_on 'OK'        
        end
        example 'ゾーン名255文字' do
          click_on domain_name_255char_short
          expect(page).to have_content domain_name_255char
          # 「DNSゾーン詳細」をクリック。click_onでは動作せず。
          find(:xpath,'//*[@id="zone-detail"]/div/ol/li[1]/a').click
          click_on 'ゾーン削除'
          sleep(1)
          expect(page).to have_content 'このゾーンを削除しますか？'
          click_on 'はい'
          sleep(1)
          expect(page).to have_content 'ゾーンの削除が完了しました。'
          click_on 'OK'        
        end
      end
    end
  end

  describe 'テンプレート' do
    before do
      visit '/dns/'
      click_on 'テンプレート'
    end
    it_should_behave_like 'check the sidebar'
    example{expect(page).to have_content 'DNSテンプレート一覧'}
  end

  describe '逆引き' do
    before do
      visit '/dns/'
      click_on '逆引き'
    end

    it_should_behave_like 'check the sidebar'
    example{expect(page).to have_content '逆引き'}
    example{expect(page).to have_content 'IPアドレス名'}
  end

  describe '操作ログ' do
    before do
      visit '/dns/'
      click_on '操作ログ'
    end

    it_should_behave_like 'check the sidebar'
    example{expect(page).to have_content '操作ログ'}
    example{expect(page).to have_content '日時'}
    example{expect(page).to have_content '対象'}
  end

  describe '利用規約' do
    before do
      visit '/dns/'
      within(:css, '#sidebar') do
        click_on '利用規約'
      end
    end

    it_should_behave_like 'check the sidebar'
    example{expect(page).to have_content '利用規約'}
    example{expect(page).to have_content 'DNS料金プラン'}
  end
end
