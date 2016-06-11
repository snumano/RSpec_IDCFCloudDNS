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
  shared_examples_for 'check the sidebar' do
    example "サイドバー" do
      expect(page).to have_content 'ゾーン'
      expect(page).to have_content 'テンプレート'
      expect(page).to have_content '逆引き'
      expect(page).to have_content '操作ログ'
      expect(page).to have_content '通知先'
      expect(page).to have_content '利用規約'
    end
  end

#?# selenium convertする
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
        example 'ゾーン名 ***.com digコマンド確認'
        example 'ラベル63文字' do
          sleep(1)
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
          sleep(1)
          fill_in('name', :with => domain_name_255char)
          sleep(1)
          click_on '作成する'
          sleep(2)
          expect(page).to have_content 'こちらの情報で登録しますか？'
          click_on 'はい'
          sleep(2)
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
          sleep(1)
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
    end   # temp 以下のDNSレコード一覧の後ろにendを挿入。全体をインデントする
    describe 'DNSレコード一覧' do
      before do
        sleep(2)
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
          example 'Aレコード ワイルドカード*' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'A'
            sleep(1)
            fill_in('name', :with => '*')
            fill_in('content', :with => ip_v4_address)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
          end
          example 'Aレコード レコード名空白@' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'A'
            sleep(1)
            fill_in('name', :with => '@')
            fill_in('content', :with => ip_v4_address)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
          end
          example 'CNAMEレコード' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'CNAME'
            sleep(1)
            fill_in('name', :with => record_cname_label)
            fill_in('content', :with => record_a_name)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
            sleep(1)
            expect(page).to have_content convert_short(record_cname_name)
          end
          example 'CNAMEレコード ワイルドカード*' do
            pending('Aレコードの*と重複するのでエラーになる。')
            click_on 'レコード登録'
            sleep(1)
            click_on 'CNAME'
            sleep(1)
            fill_in('name', :with => '*')
            fill_in('content', :with => record_a_name)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
            sleep(1)
            expect(page).to have_content convert_short(record_cname_name)
          end
          example 'AAAAレコード' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'AAAA'
            sleep(1)
            fill_in('name', :with => record_aaaa_label)
            fill_in('content', :with => ip_v6_address)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
            sleep(1)
            expect(page).to have_content convert_short(record_aaaa_name)
            expect(page).to have_content ip_v6_address
          end
          example 'AAAAレコード ワイルドカード*' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'AAAA'
            sleep(1)
            fill_in('name', :with => '*')
            fill_in('content', :with => ip_v6_address)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
          end
          example 'AAAAレコード レコード名空白@' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'AAAA'
            sleep(1)
            fill_in('name', :with => '@')
            fill_in('content', :with => ip_v6_address)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
          end
          example 'MXレコード' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'MX'
            sleep(1)
            fill_in('name', :with => record_mx_label)
            fill_in('content', :with => record_a_name)
            fill_in('prio', :with => '1')
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
            sleep(1)
            expect(page).to have_content convert_short(record_mx_name)
          end
          example 'MXレコード ワイルドカード*' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'MX'
            sleep(1)
            fill_in('name', :with => '*')
            fill_in('content', :with => record_a_name)
            fill_in('prio', :with => '1')
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
          end
          example 'MXレコード レコード名空白@' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'MX'
            sleep(1)
            fill_in('name', :with => '@')
            fill_in('content', :with => record_a_name)
            fill_in('prio', :with => '1')
            click_on '登録する'
            sleep(2)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
          end
          example 'TXTレコード' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'TXT'
            sleep(1)
            fill_in('name', :with => record_txt_label)
            fill_in('content', :with => content_txt)
            click_on '登録する'
            sleep(2)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
            sleep(1)
            expect(page).to have_content convert_short(record_txt_name)
            expect(page).to have_content content_txt
          end
          example 'TXTレコード ワイルドカード*' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'TXT'
            sleep(1)
            fill_in('name', :with => '*')
            fill_in('content', :with => content_txt)
            click_on '登録する'
            sleep(1)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
          end
          example 'TXTレコード レコード名空白@' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'TXT'
            sleep(1)
            fill_in('name', :with => '@')
            fill_in('content', :with => content_txt)
            click_on '登録する'
            sleep(2)
            expect(page).to have_content 'レコードを登録しますか？'
            sleep(1)
            click_on 'はい'
          end
          example 'SRVレコード' do
            click_on 'レコード登録'
            sleep(1)
            click_on 'SRV'
            sleep(1)
            fill_in('name', :with => record_srv_label)
            fill_in('content', :with => content_srv)
            fill_in('prio', :with => '1')
            click_on '登録する'
            sleep(2)
            expect(page).to have_content 'レコードを登録しますか？'
            click_on 'はい'
            sleep(1)
            expect(page).to have_content convert_short(record_srv_name)
            expect(page).to have_content content_srv
          end
        end
        context '登録失敗' do
          context '必須項目未入力' do
            example 'Aレコード' do
              click_on 'レコード登録'
              sleep(1)
              click_on 'A'
              sleep(1)
              click_on '登録する'
              sleep(1)
              within(:css, 'div.has-error:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
              within(:css, 'div.default-value > div:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
            end
            example 'CNAMEレコード' do
              click_on 'レコード登録'
              sleep(1)
              click_on 'CNAME'
              sleep(1)
              click_on '登録する'
              sleep(1)
              within(:css, 'div.has-error:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
              within(:css, 'div.default-value > div:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
            end
            example 'AAAAレコード' do
              click_on 'レコード登録'
              sleep(1)
              click_on 'AAAA'
              sleep(1)
              click_on '登録する'
              sleep(1)
              within(:css, 'div.has-error:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
              within(:css, 'div.default-value > div:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
            end
            example 'MXレコード' do
              click_on 'レコード登録'
              sleep(1)
              click_on 'MX'
              sleep(1)
              click_on '登録する'
              sleep(1)
              within(:css, 'div.has-error:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
              within(:css, 'div.default-value > div:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
              within(:css, '#dns_record_create_form > div.type_part.form-group.has-error') do
                expect(page).to have_content '必須です。'
              end
            end
            example 'TXTレコード' do
              click_on 'レコード登録'
              sleep(1)
              click_on 'TXT'
              sleep(1)
              click_on '登録する'
              sleep(1)
              within(:css, 'div.has-error:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
              within(:css, 'div.default-value > div:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
            end
            example 'SRVレコード' do
              click_on 'レコード登録'
              sleep(1)
              click_on 'SRV'
              sleep(1)
              click_on '登録する'
              sleep(1)
              within(:css, 'div.has-error:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
              within(:css, 'div.default-value > div:nth-child(2)') do
                expect(page).to have_content '必須です。'
              end
              within(:css, '#dns_record_create_form > div.type_part.form-group.has-error') do
                expect(page).to have_content '必須です。'
              end
            end
          end
          context '異常値' do
            context '全レコード共通' do
              example 'ラベル名63文字超過' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'A'
                sleep(1)
                fill_in('name', :with => record_name_label_over63char)

                fill_in('content', :with => ip_v4_address)
                click_on '登録する'
                sleep(2)
                expect(page).to have_content '半角英数字とハイフンとピリオドのみでラベル名63文字以内、ドメイン名全体で253文字以内で入力してください。ただし、レコード先頭と末尾にハイフンは使用できません。レコード名の*はワイルドカードとして、@はホスト名空白として設定されます。'
              end
              example 'レコード全体255文字超過' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'A'
                sleep(1)
                fill_in('name', :with => record_name_all_over255char)
                fill_in('content', :with => ip_v4_address)
                click_on '登録する'
                sleep(1)
                expect(page).to have_content '半角英数字とハイフンとピリオドのみでラベル名63文字以内、ドメイン名全体で253文字以内で入力してください。ただし、レコード先頭と末尾にハイフンは使用できません。レコード名の*はワイルドカードとして、@はホスト名空白として設定されます。'
              end
              example 'TTL600-86400以外(599)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'A'
                sleep(1)
                fill_in('name', :with => record_a_label)
                fill_in('content', :with => ip_v4_address)
                fill_in('ttl', :with => 599)
                click_on '登録する'
                sleep(2)
                within(:css, '.has-error') do
                  expect(page).to have_content '半角数字600-86400で入力してください。'
                end
              end
              example 'TTL600-86400以外(86401)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'A'
                sleep(1)
                fill_in('name', :with => record_a_label)
                fill_in('content', :with => ip_v4_address)
                fill_in('ttl', :with => 86401)
                click_on '登録する'
                sleep(2)
                within(:css, '.has-error') do
                  expect(page).to have_content '半角数字600-86400で入力してください。'
                end
              end
            end
            context 'Aレコード' do
              example '値がIPv4以外(文字列)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'A'
                sleep(1)
                fill_in('name', :with => record_a_label)
                fill_in('content', :with => 'aaa')
                click_on '登録する'
                within(:css, 'div.default-value > div:nth-child(2)') do
                  expect(page).to have_content 'IPv4アドレスを入力してください。'
                end
              end
            end
            context 'CNAMEレコード' do
              example 'レコード名空白@' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'CNAME'
                sleep(1)
                fill_in('name', :with => '@')
                fill_in('content', :with => record_a_name)
                click_on '登録する'
                sleep(1)
                within(:css, 'div.has-error:nth-child(2)') do
                  expect(page).to have_content 'CNAMEレコードは他のデータと共存できません。'
                end
              end
              example '既存CNAMEレコードとレコード名が重複' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'CNAME'
                sleep(1)
                fill_in('name', :with => record_cname_label)
                fill_in('content', :with => record_cname_name)
                click_on '登録する'
                sleep(1)
                expect(page).to have_content 'CNAME'
                within(:css, 'div.has-error:nth-child(2)') do
                  expect(page).to have_content 'CNAMEレコードは他のデータと共存できません。'
                end
              end
              example '他レコード(CNAME以外)とレコード名が重複' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'CNAME'
                sleep(1)
                fill_in('name', :with => record_a_label)
                fill_in('content', :with => record_cname_name)
                click_on '登録する'
                sleep(1)
                expect(page).to have_content 'CNAME'
                within(:css, 'div.has-error:nth-child(2)') do
                  expect(page).to have_content 'CNAMEレコードは他のデータと共存できません。'
                end
              end
              example '値のFQDNの末尾に.が付与' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'CNAME'
                sleep(1)
                fill_in('name', :with => record_cname_label + '2')
                fill_in('content', :with => record_cname_name + '.')
                click_on '登録する'
                sleep(1)
                expect(page).to have_content 'CNAME'
                within(:css, 'div.default-value > div:nth-child(2)') do
                  expect(page).to have_content '半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。CNAMEは、同じレコード名に対して1つの値しか登録できません。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
              example '値が255文字超過' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'CNAME'
                sleep(1)
                fill_in('name', :with => record_cname_label + '2')
                fill_in('content', :with => domain_name_over255char)
                click_on '登録する'
                sleep(2)
                within(:css, 'div.default-value > div:nth-child(2)') do
                  expect(page).to have_content '半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。CNAMEは、同じレコード名に対して1つの値しか登録できません。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
            end
            context 'AAAAレコード' do
              example '値がIPv6以外(文字列)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'AAAA'
                sleep(1)
                fill_in('name', :with => record_aaaa_label)
                fill_in('content', :with => 'aaa')
                click_on '登録する'
                within(:css, 'div.default-value > div:nth-child(2)') do
                  expect(page).to have_content 'IPv6アドレスを入力してください。'
                end
              end
              example '値がIPv6以外(IPv4)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'AAAA'
                sleep(1)
                fill_in('name', :with => record_aaaa_label)
                fill_in('content', :with => ip_v4_address)
                click_on '登録する'
                within(:css, 'div.default-value > div:nth-child(2)') do
                  expect(page).to have_content 'IPv6アドレスを入力してください。'
                end
              end
            end
            context 'MXレコード' do
              example '値がFQDN以外' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'MX'
                sleep(1)
                fill_in('name', :with => record_mx_label)
                fill_in('content', :with => 'aaa')
                fill_in('prio', :with => '1')
                click_on '登録する'
                sleep(1)
                within(:css, 'div.default-value > div:nth-child(2)') do
                  expect(page).to have_content '半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。当該レコードの値はAレコードやAAAAレコードをもつものを指定できますが、CNAMEのレコード名を指定する事はできません。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
              example '値が255文字超過' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'MX'
                sleep(1)
                fill_in('name', :with => record_mx_label)
                fill_in('content', :with => domain_name_over255char)
                fill_in('prio', :with => '1')
                click_on '登録する'
                sleep(2)
                within(:css, 'div.default-value > div:nth-child(2)') do
                  expect(page).to have_content '半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。当該レコードの値はAレコードやAAAAレコードをもつものを指定できますが、CNAMEのレコード名を指定する事はできません。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
              example '優先度が文字列' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'MX'
                sleep(1)
                fill_in('name', :with => record_mx_label)
                fill_in('content', :with => record_a_name)
                fill_in('prio', :with => 'aaa')
                click_on '登録する'
                sleep(1)
                within(:css, '#dns_record_create_form > div.type_part.form-group.has-error') do
                  expect(page).to have_content '半角数字0～65535の間で入力してください。'
                end
              end
              example '優先度が0-65535以外(-1)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'MX'
                sleep(1)
                fill_in('name', :with => record_mx_label)
                fill_in('content', :with => record_a_name)
                fill_in('prio', :with => -1)
                click_on '登録する'
                sleep(1)
                within(:css, '#dns_record_create_form > div.type_part.form-group.has-error') do
                  expect(page).to have_content '半角数字0～65535の間で入力してください。'
                end
              end
              example '優先度が0-65535以外(65536)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'MX'
                sleep(1)
                fill_in('name', :with => record_mx_label)
                fill_in('content', :with => record_a_name)
                fill_in('prio', :with => 65536)
                click_on '登録する'
                sleep(1)
                within(:css, '#dns_record_create_form > div.type_part.form-group.has-error') do
                  expect(page).to have_content '半角数字0～65535の間で入力してください。'
                end
              end
            end
            context 'TXTレコード' do
              example 'ダブルクォテーション内の文字列が255文字超過' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'TXT'
                sleep(1)
                fill_in('name', :with => record_txt_label)
                fill_in('content', :with => content_txt_over255char_double_quotation)
                click_on '登録する'
                sleep(1)
#                within(:css, 'div.default-value > div:nth-child(2)') do
                  expect(page).to have_content '半角英数字、半角記号で入力してください。1つの文字列の最大長は255文字です。連結したあとの1つのレコードは1024文字以内で入力してください。'
#                end
              end
              example '全体の文字列が1024文字超過' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'TXT'
                sleep(1)
                fill_in('name', :with => record_txt_label)
                fill_in('content', :with => content_txt_over1024char)
                click_on '登録する'
                sleep(1)
#                within(:css, 'div.default-value > div:nth-child(2)') do
                  expect(page).to have_content '半角英数字、半角記号で入力してください。1つの文字列の最大長は255文字です。連結したあとの1つのレコードは1024文字以内で入力してください。'
#                end
              end
            end
            context 'SRVレコード' do
              example 'レコード名がフォーマット外' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'SRV'
                sleep(1)
                fill_in('name', :with => 'aaa')
                fill_in('content', :with => content_srv)
                fill_in('prio', :with => '1')
                click_on '登録する'
                sleep(1)
                within(:css, 'div.has-error:nth-child(2)') do
                  expect(page).to have_content '「_service._prot」のフォーマットで入力してください。「_service」「_prot」はそれぞれ2文字以上63文字以内、ドメイン名全体で253文字以内で入力してください。'
                end
              end
              example 'weightが0-65535以外(-1)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'SRV'
                sleep(1)
                fill_in('name', :with => record_srv_label)
                fill_in('content', :with => '-1 5060 sip.example.com')
                fill_in('prio', :with => '1')
                click_on '登録する'
                sleep(1)
                within(:css, '#dns_record_create_form > div.form-group.default-value.has-error') do
                  expect(page).to have_content 'weightとportは半角数字0-65535で入力してください。hostは半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
              example 'weightが0-65535以外(65536)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'SRV'
                sleep(1)
                fill_in('name', :with => record_srv_label)
                fill_in('content', :with => '65536 5060 sip.example.com')
                fill_in('prio', :with => '1')
                sleep(1)
                click_on '登録する'
                sleep(2)
                within(:css, '#dns_record_create_form > div.form-group.default-value.has-error') do
                  expect(page).to have_content 'weightとportは半角数字0-65535で入力してください。hostは半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
              example 'portが0-65535以外(-1)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'SRV'
                sleep(1)
                fill_in('name', :with => record_srv_label)
                fill_in('content', :with => '0 -1 sip.example.com')
                fill_in('prio', :with => '1')
                click_on '登録する'
                sleep(1)
                within(:css, '#dns_record_create_form > div.form-group.default-value.has-error') do
                  expect(page).to have_content 'weightとportは半角数字0-65535で入力してください。hostは半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
              example 'portが0-65535以外(65536)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'SRV'
                sleep(1)
                fill_in('name', :with => record_srv_label)
                fill_in('content', :with => '0 65536 sip.example.com')
                fill_in('prio', :with => '1')
                click_on '登録する'
                sleep(1)
                within(:css, '#dns_record_create_form > div.form-group.default-value.has-error') do
                  expect(page).to have_content 'weightとportは半角数字0-65535で入力してください。hostは半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
              example 'ホスト名が未入力' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'SRV'
                sleep(1)
                fill_in('name', :with => record_srv_label)
                fill_in('content', :with => '0 65535')
                fill_in('prio', :with => '1')
                click_on '登録する'
                sleep(1)
                within(:css, '#dns_record_create_form > div.form-group.default-value.has-error') do
                  expect(page).to have_content 'weightとportは半角数字0-65535で入力してください。hostは半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
              example 'ホスト名がFQDN以外' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'SRV'
                sleep(1)
                fill_in('name', :with => record_srv_label)
                fill_in('content', :with => '0 65535 aaa')
                fill_in('prio', :with => '1')
                click_on '登録する'
                sleep(2)
                within(:css, '#dns_record_create_form > div.form-group.default-value.has-error') do
                  expect(page).to have_content 'weightとportは半角数字0-65535で入力してください。hostは半角英数字、ドット（.）、ハイフン（-）で、255文字以内で入力してください。ホスト名の末尾の.(ドット)は不要です。'
                end
              end
              example '優先度が0-65535以外(-1)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'SRV'
                sleep(1)
                fill_in('name', :with => record_srv_label)
                fill_in('content', :with => content_srv)
                fill_in('prio', :with => -1)
                click_on '登録する'
                sleep(1)
                within(:css, '#dns_record_create_form > div.type_part.form-group.has-error') do
                  expect(page).to have_content '半角数字0～65535の間で入力してください。'
                end
              end
              example '優先度が0-65535以外(65536)' do
                click_on 'レコード登録'
                sleep(1)
                click_on 'SRV'
                sleep(1)
                fill_in('name', :with => record_srv_label)
                fill_in('content', :with => content_srv)
                fill_in('prio', :with => 65536)
                click_on '登録する'
                sleep(1)
                within(:css, '#dns_record_create_form > div.type_part.form-group.has-error') do
                  expect(page).to have_content '半角数字0～65535の間で入力してください。'
                end
              end
            end
          end
        end
      end
      describe 'レコード編集' do
        example 'Aレコード' do
#          pending('レコード名のelementをうまく探せない') 
          first('a', :text => convert_short(record_a_name)).click
          sleep(1)
          expect(find("#dns_record_edit_form > div:nth-child(1) > div > button.btn.button-to-radio.btn-primary").text).to eq 'A'
          expect(page).to have_content 'レコード編集'
          expect(page).to have_content domain_name
          expect(find("#form-input-name").value).to eq record_a_label
          expect(find("#form-input-content-a").value).to eq ip_v4_address
        end
      end
      describe 'レコード削除' do
        example 'Aレコード' do
          find(:xpath,'(//button[@type="button"])[7]').click
          sleep(1)
          expect(page).to have_content 'レコードを削除しますか？'
          click_on 'はい'
          sleep(1)
        end
      end
    end
#    end   # temp
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
      example 'ラベル名63文字' do
        click_on convert_short(domain_name_63char_label)
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
        expect(page).not_to have_content domain_name_63char_label
      end
      example 'ゾーン名255文字' do
        click_on convert_short(domain_name_255char)
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
      example 'ゾーン名 ***.com digコマンド確認'
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
