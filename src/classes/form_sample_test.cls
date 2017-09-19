@isTest
private class form_sample_test {

	/**
	 * メッセージと添付ファイルを作るテスト
	 * form_sample_postattach_api.cls
	 */
	@isTest static void post_attach() {
		RestRequest req = new RestRequest();
		String json = '{'+
'	\"title\":\"タイトル\",'+
'	\"message\":\"メッセージ\",'+
'	\"files\":['+
'		{'+
'			\"file_name\":\"test.txt\",'+
'			\"file_type\":\"text\",'+
'			\"file_body\":\"MQo=\"'+
'		}'+
'	]'+
'}';
		req.requestBody = Blob.valueof(json);
		RestContext.request = req;
		form_sample_postattach_api.create();

		// 保存確認
		// メッセージ
		String m_query = 'SELECT title__c FROM SampleMessage__c LIMIT 1';
		List<SampleMessage__c> messages = Database.query(m_query);
		SampleMessage__c message = messages[0];
		System.assertEquals(message.title__c, 'タイトル');

		// 添付ファイル
		String a_query = 'SELECT name FROM Attachment LIMIT 1';
		List<Attachment> attaches = Database.query(a_query);
		Attachment attach = attaches[0];
		System.assertEquals(attach.name, 'test.txt');
	}

	/**
	 * メッセージと添付ファイルを取得するテスト
	 * form_sample_getattach_api.cls
	 */
	@isTest static void get_attach() {
		SampleMessage__c ms = new SampleMessage__c();
		ms.title__c = 'タイトル';
		ms.message__c = 'メッセージ';
		insert ms;

		Attachment att = new Attachment();
		att.Name = 'test.txt';
		att.Body = EncodingUtil.base64Decode('MQo=');
		att.parentid = ms.Id;
		insert att;

		RestRequest req = new RestRequest();
		req.addParameter('id', ms.Id);
		RestContext.request = req;
		form_sample_getattach_api.getMessage();

		req.addParameter('id', att.Id);
		RestContext.request = req;
		form_sample_getattach_api.getAttach();
	}

}
