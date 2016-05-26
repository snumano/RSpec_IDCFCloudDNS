# coding: utf-8
require 'spec_helper'

# export ABC='abc'
# RSPEC_ID
# RSPEC_PW
# RSPEC_EXIST_ID

describe 'DNS' do
  before(:all) do
    visit '/'
    fill_in('username', :with => ENV['RSPEC_ID'])
    fill_in('password', :with => ENV['RSPEC_PW'])
    click_on('ログイン')
#    save_and_open_page
  end
  shared_examples_for 'check the sidebar' do
    specify "サイドバー" do
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
    specify{expect(page).to have_content 'DNSゾーン一覧'}
  end

  describe 'テンプレート' do
    before do
      visit '/dns/'
      click_on 'テンプレート'
    end
    it_should_behave_like 'check the sidebar'
    specify{expect(page).to have_content 'DNSテンプレート一覧'}
  end

  describe '逆引き' do
    before do
      visit '/dns/'
      click_on '逆引き'
    end

    it_should_behave_like 'check the sidebar'
    specify{expect(page).to have_content '逆引き'}
    specify{expect(page).to have_content 'IPアドレス名'}
  end

  describe '操作ログ' do
    before do
      visit '/dns/'
      click_on '操作ログ'
    end

    it_should_behave_like 'check the sidebar'
    specify{expect(page).to have_content '操作ログ'}
    specify{expect(page).to have_content '日時'}
    specify{expect(page).to have_content '対象'}
  end

  describe '利用規約' do
    before do
      visit '/dns/'
      within(:css, '#sidebar') do
        click_on '利用規約'
      end
    end

    it_should_behave_like 'check the sidebar'
    specify{expect(page).to have_content '利用規約'}
    specify{expect(page).to have_content 'DNS料金プラン'}
  end
end
