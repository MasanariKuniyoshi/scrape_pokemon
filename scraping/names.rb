#!/usr/bin/env ruby
#-*- coding: utf-8 -*-
 
#webに接続するためのライブラリ
require "open-uri"
#クレイピングに使用するライブラリ
require "nokogiri"
 
#クレイピング対象のURL
url = "https://wiki.xn--rckteqa2e.com/wiki/%E3%83%9D%E3%82%B1%E3%83%A2%E3%83%B3%E3%81%AE%E5%A4%96%E5%9B%BD%E8%AA%9E%E5%90%8D%E4%B8%80%E8%A6%A7"
#取得するhtml用charset
charset = nil

html = open(url) do |page|
  #charsetを自動で読み込み、取得
  charset = page.charset
  #中身を読む
  page.read
end
 
# Nokogiri で切り分け
contents = Nokogiri::HTML.parse(html,nil,charset)

# -------------------引き抜きたいところを指定→変数に代入---------------
pokemon = []
contents.search('table.graytable>tbody>tr').each do |node|
  number = node.css('td:nth-child(1)').text.chomp
  next if number.empty?
  jpn_name = node.css('td:nth-child(2)').text.chomp
  eng_name = node.css('td:nth-child(3)').text.chomp
  deu_name = node.css('td:nth-child(4)').text.chomp
  fra_name = node.css('td:nth-child(5)').text.chomp
  kor_name = node.css('td:nth-child(6)').text.chomp
  chs_name = node.css('td:nth-child(7)').text.chomp
  cht_name = node.css('td:nth-child(8)').text.chomp
  
  pokemon << {number: number, jpn_name: jpn_name, eng_name: eng_name, deu_name: deu_name,
              fra_name: fra_name, kor_name: kor_name, chs_name: chs_name, cht_name: cht_name }
end


# -----------------csvファイルに保存------------------
# csvの読み込み-CSV関連がいろいろできるようになる
require 'csv'

header = ['図鑑番号','日本名','英語','ドイツ語','フランス語','韓国語','中国語(簡)','中国語(繁)']
pokemon_names_csv = pokemon.map{|res| [ res[:number], res[:jpn_name], res[:eng_name], res[:deu_name], res[:fra_name], res[:kor_name], res[:chs_name], res[:cht_name] ] }
CSV.open('../files/csv/pokemon_names.csv', 'w') do |csv|
  # ヘッダーの設定
  csv << header
  # ボディの入力
  pokemon_names_csv.each do |r|
    csv << r
  end
end


# ---------------jsonファイルに保存--------------------
# jsonの読み込み-JSON関連がいろいろできるようになる
require 'json'

pokemon_names_json = pokemon.map{|res| { res[:number] => { jpn_name: res[:jpn_name], eng_name: res[:eng_name], deu_name: res[:deu_name], fra_name: res[:fra_name],
                                                        kor_name: res[:kor_name], chs_name: res[:chs_name], cht_name: res[:cht_name]}}}
pokemon_names_json.unshift({ 'number' => { jpn_name: '日本語', eng_name: '英語', deu_name: 'ドイツ語', fra_name: 'フランス語',
  kor_name: '韓国語', chs_name: '中国語(簡)', cht_name: '中国語(繁)'}})

File.open('../files/json/pokemon_names.json', 'w') do |file|
    arranged_str = JSON.pretty_generate(pokemon_names_json)
    file << arranged_str
end