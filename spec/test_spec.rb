require 'spec_helper'

# export ABC='abc'
# RSPEC_ID
# RSPEC_PW

domain_word = FFaker::Internet.domain_word
domain_name = domain_word + '.com'

=begin
def convert_short(record_name)
  record_name.length > 20 ? record_name[0,20] + '...' : record_name
end
=end

record_a_label= 'a'
record_a_name = record_a_label + '.' + domain_name
record_cname_label= 'cname'
record_cname_name = record_cname_label + '.' + domain_name
record_aaaa_label= 'aaaa'
record_aaaa_name = record_aaaa_label + '.' + domain_name
record_mx_label= 'mx'
record_mx_name = record_mx_label + '.' + domain_name
record_txt_label= 'txt'
record_txt_name = record_txt_label + '.' + domain_name
record_srv_label= '_sip._udp'
record_srv_name = record_srv_label + '.' + domain_name
ip_v4_address = FFaker::Internet.ip_v4_address
ip_v6_address = Faker::Internet.ip_v6_address
unsupported_domain = '.xxx'
multibyte_domain = '日本語.com'
current_time = Time.now.strftime("%Y%m%d%H%M%S")
content_txt = 'memo' + current_time
content_srv = '0 5060 sip.example.com'
content_txt_over255char_double_quotation = '"' + 'a'*256 + '"'
content_txt_over1024char = 'a'*1025

domain_name_63char_label = current_time + 'a'*49 + '.com'
domain_name_over63char_label = current_time + 'a'*50 + '.com'
domain_name_255char  = current_time + 'b'*49 + '.' + 'c'*63 + '.' + 'd'*63 + '.' + 'e'*59 + '.com'
domain_name_over255char  = current_time + 'b'*49 + '.' + 'c'*63 + '.' + 'd'*63 + '.' + 'e'*60 + '.com'
record_name_label_over63char = current_time + 'f'*50 + '.com'
record_name_all_over255char  = current_time + 'g'*49 + '.' + 'h'*63 + '.' + 'i'*63 + '.' + 'j'*63

p domain_name
p ip_v4_address
p ip_v6_address
p current_time
p domain_name_63char_label
p domain_name_255char
p domain_name_over255char

describe 'DNS' do
  before(:all) do
    visit '/'
    fill_in('username', :with => ENV['RSPEC_ID'])
    fill_in('password', :with => ENV['RSPEC_PW'])
    click_on('ログイン')
#    save_and_open_page
  end
  describe 'ゾーン' do
    before do
      visit '/dns/'
    end

    example{expect(page).to have_content 'DNSゾーン一覧'}
    
    describe 'DNSゾーン作成' do
      before do
        click_on 'DNSゾーン作成'
        sleep(1)
      end
      context '成功' do
        example 'ゾーン名 ***.com' do
          sleep(2)
          fill_in('name', :with => domain_name)
          sleep(1)
          click_on '作成する'
          sleep(1)
          expect(page).to have_content 'こちらの情報で登録しますか？'
          click_on 'はい'
          sleep(2)
          expect(page).to have_content 'ゾーンの登録を完了しました。'
        end
      end
    end
    describe 'DNSレコード一覧' do
      before do
        sleep(2)
        click_on convert_short(domain_name)
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
            click_on 'A'
            sleep(1)
            fill_in('name', :with => record_a_label)
            fill_in('content', :with => ip_v4_address)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
            sleep(1)
            expect(page).to have_content convert_short(record_a_name)
            expect(page).to have_content ip_v4_address
          end
        end
      end
      describe 'レコード編集' do
        example 'Aレコード' do
#          pending('レコード名のelementをうまく探せない') 
#           click_on convert_short(record_a_name)
#          first('a', :text => convert_short(record_a_name)).click
          find('a', :text => convert_short(record_a_name)).click
#          page.all('a', :text => convert_short(record_a_name))[0].click
          sleep(1)
#          p find("#dns_record_edit_form > div:nth-child(1) > div > button.btn.button-to-radio.btn-primary").text
          expect(find("#dns_record_edit_form > div:nth-child(1) > div > button.btn.button-to-radio.btn-primary").text).to eq 'A'
          expect(page).to have_content 'レコード編集'
          expect(page).to have_content domain_name
          expect(find("#form-input-name").value).to eq record_a_label
          expect(find("#form-input-content-a").value).to eq ip_v4_address
        end
      end
    end
    describe 'ゾーン削除' do
      example 'ゾーン名 ***.com' do
        click_on domain_name
        expect(page).to have_content convert_short(domain_name)
        # 「DNSゾーン詳細」をクリック。click_onでは動作せず。
        find(:xpath,'//*[@id="zone-detail"]/div/ol/li[1]/a').click
        click_on 'ゾーン削除'
        sleep(1)
        expect(page).to have_content 'このゾーンを削除しますか？'
        click_on 'はい'
        sleep(2)
        expect(page).to have_content 'ゾーンの削除が完了しました。'
        click_on 'OK'
        expect(page).not_to have_content convert_short(domain_name)
      end
    end
  end
end
