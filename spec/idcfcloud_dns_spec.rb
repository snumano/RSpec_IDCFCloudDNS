# coding: utf-8
require 'spec_helper'

# export ABC='abc'
# RSPEC_ID
# RSPEC_PW

domain_word = FFaker::Internet.domain_word
domain_name = domain_word + '.com'
record_name= 'www'
ip_address = '10.10.10.1'
p domain_name
p record_name
p ip_address

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
      end
      context '成功' do
        example 'ゾーン名 ***.com' do
          sleep(1)
          fill_in('name', :with => domain_name)
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
          sleep(1)
          fill_in('name', :with => domain_word)
          sleep(1)
          click_on '作成する'
          expect(page).to have_content 'ドメイン名が不正です。'
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
            fill_in('name', :with => record_name)
            select 'A', from: 'form-input-type'
            fill_in('content', :with => ip_address)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
            sleep(1)
            expect(page).to have_content record_name + '.' + domain_name
            expect(page).to have_content ip_address
          end
          example 'CNAMEレコード'
          example 'AAAAレコード'
          example 'MXレコード'
          example 'TXTレコード'
          example 'SRVレコード'
        end
        context '登録失敗' do
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
      end
      describe 'レコード詳細' do
        example 'CNAMEレコード'
        example 'AAAAレコード'
        example 'MXレコード'
        example 'TXTレコード'
        example 'SRVレコード'
      end
      describe 'レコード削除' do
        context '削除成功' do
          example 'Aレコード'
          example 'AAAAレコード'
          example 'MXレコード'
          example 'TXTレコード'
          example 'SRVレコード'
        end
        context '削除失敗' do
          example 'Aレコード'
          example 'AAAAレコード'
          example 'MXレコード'
          example 'TXTレコード'
          example 'SRVレコード'
        end
      end
      describe 'DNSゾーン削除' do
        example '削除完了' do
#          save_and_open_page
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
