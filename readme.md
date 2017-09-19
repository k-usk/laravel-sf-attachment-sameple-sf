# 添付ファイル送信サンプル
## 概要
Laravelを利用し、SalesforceのRestAPI経由で、添付ファイルオブジェクトにレコードを作成するサンプル。

Laravel側のRestAPIのコードは以下のリポジトリを参照。  
<https://github.com/k-usk/laravel-sf-attachment-sameple-php>

## 検証環境

* [Vagrant (Scotch Box 3.0)](https://box.scotch.io/)
* PHP 7.0
* Laravel 5.4.32

## オブジェクト定義
カスタムオブジェクトとして、メッセージ、というオブジェクトを作成した。

#### メッセージ `SampleMessage__c`

| 項目名 | API参照名 | 型 |
| :-- | :-- | :-- |
| メッセージ名 | `Name` | 自動採番 |
| メッセージ | `message__c` | ロングテキストエリア(32768) |
| 件名 | `title__c` | テキスト(255) |

ファイルを保存するオブジェクトは標準の「添付ファイル」オブジェクトを利用。  
以下は使用した項目のみ。

#### 添付ファイル `Attachment`

| 項目名 | API参照名 | 型 |
| :-- | :-- | :-- |
|  | `Name` |  |
| 符号化されたファイルデータ | `Body` | base64 |
| ファイルサイズ(バイト) | `Bodylength` | int |
| コンテンツタイプ | `Contenttype` | string |
| 親オブジェクトID | `Parentid` | reference |

## API仕様
### メッセージ取得API
送信されたIDのメッセージと紐づく添付ファイルの情報を返却する。

#### リクエスト

`?id={SFID}` : メッセージのSFID

#### レスポンス

```
{
	"title":"タイトル",
	"message":"メッセージ",
	"files":[
		{
			"id":"SFID",
			"name":"ファイル名",
			"size":123,
			"type":"コンテンツタイプ"
		},
		{
			...
		},
		...
	]
}
```

### ファイル取得API
送信された添付ファイルのIDのファイル情報を返却する。

#### リクエスト

`?id={SFID}` : 添付ファイルのSFID

#### レスポンス

```
{
	"file_body":"base64符号化されたファイルデータ",
	"file_name":"ファイル名"
}	
```

### メッセージ保存API
送信されたメッセージ内容と添付ファイルをSFへ保存する。

####リクエスト

```
{
	"title":"タイトル",
	"message":"メッセージ",
	"files":[
		{
			"file_name":"ファイル名",
			"file_type":"ファイルタイプ",
			"file_body":"base64符号化されたファイルデータ"
		},
		{
			...
		},
		...
	]
}
```

####レスポンス

```
{
	"success":true
}	
```

## ファイルサイズ制限について

送信する際のファイルサイズの制限は、PHP側の制限とSF側の制限が存在する。

PHPの設定に関しては`php.ini`での設定となるので変更が可能。  
(下の表ではScotchboxのデフォルト設定)  
しかし、SF側の設定はガバナ制限となるため、変更は不可。  
よって、実質、5MBまでの制限となる。

| 種類 | 項目 | 容量 |
| :-- | :-- | :-- |
| PHP | `post_max_size` | 2M |
|  | `upload_max_filesize` | 8M |
| SF | ヒープ制限 | 6MB |

* [ファイルのアップロード（１）ファイルのサイズの制限：制限なしでも制限ある](http://www.larajapan.com/2016/03/26/%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%AE%E3%82%A2%E3%83%83%E3%83%97%E3%83%AD%E3%83%BC%E3%83%89%EF%BC%88%EF%BC%91%EF%BC%89%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%AE%E3%82%B5%E3%82%A4%E3%82%BA/)
* [ガバナ制限](https://developer.salesforce.com/docs/atlas.ja-jp.salesforce_app_limits_cheatsheet.meta/salesforce_app_limits_cheatsheet/salesforce_app_limits_platform_apexgov.htm)
* [【Salesforce】System.LimitException: Apex heap size too large:](http://www.subnetwork.jp/blog/?p=710)
