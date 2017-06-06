# rain_sensor

[Yahoo! 気象情報API](https://developer.yahoo.co.jp/webapi/map/openlocalplatform/v1/weather.html) を使って，ピンポイントの場所の降水をお知らせします．

API で取得できる降雨情報の実測値と，以降1時間の降雨予測値から， `雨が降り始めた` ， `雨が降りそう` ， `雨が強くなりそう，弱くなりそう` ，`雨が止みそう` , `雨が止んだ` ，といった情報を提供します．

## 導入方法

### Yahoo! JAPAN の API 利用準備

使用するには， Yahoo! JAPAN ID のアカウントが必要です．

以下の URL から，ログインの上アプリ登録をおこない `アプリケーションID` を取得してください．

=> https://developer.yahoo.co.jp/start/

### Slack の incoming webhook の準備


### 環境変数の設定

* slack, yahoo への設定をおこなってください．
* 測定地点の緯度経度を `LOCATION_COORDINATES='139.700306,35.689407'` のように設定してください．
  * '`経度`,`緯度`' であることに注意してください（Google maps では逆の表現です）
* `LOCATION_NAME` は通知時の表示用です

```
$ cp .env.example .env
$ vi .env
```
```sh
export SLACK_ACCESS_TOKEN='xxx'
export SLACK_NOTIFY_TO='#xxx'
export SLACK_ERROR_NOTIFY_TO='#xxx'
export YAHOO_APP_ID='xxx'
export LOCATION_COORDINATES='139.700306,35.689407'
export LOCATION_NAME='新宿駅'
```

### crontab の設定

```
$ cp config/schedule.rb.example config/schedule.rb
$ bundle install --without test development --path vender/bundle
$ bundle exec whenever -w
```

## 備考

### 雨の強さについて

雨量強度の表現は以下を参考にしています

http://www.jma.go.jp/jma/kishou/know/yougo_hp/amehyo.html
