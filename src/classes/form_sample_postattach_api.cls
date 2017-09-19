@RestResource(urlMapping='/sample/attach/post')

global with sharing class form_sample_postattach_api {
	@HttpPost
	global static ResultData create() {
		ResultData result = new ResultData();
		result.success = false;

		//POSTデータの取得
		RestRequest req = RestContext.request;
		String data = req.requestBody.toString();
		// System.debug(data);
		if(String.isBlank(data)){
			return result;
		}

		form_sample_postattach_json json_data = form_sample_postattach_json.parse(data);

		//メッセージの保存
		SampleMessage__c message = new SampleMessage__c();
		message.message__c = json_data.message;
		message.title__c = json_data.title;
		insert message;

		//添付ファイル
		List<form_sample_postattach_json.File> files = json_data.files;

		List<Attachment> insert_attaches = new List<Attachment>();
		for(form_sample_postattach_json.File file : files){
			if(String.isNotBlank(file.file_body)){
				Attachment attach = new Attachment();
				attach.parentid = message.Id;
				attach.Name = file.file_name;
				attach.Body = EncodingUtil.base64Decode(file.file_body);
				if(String.isNotBlank(file.file_type)) attach.ContentType = file.file_type;
				insert_attaches.add(attach);
			}
		}

		if(insert_attaches.size() > 0) insert insert_attaches;

		result.success = true;
		return result;
	}

	global class ResultData {
		global boolean success;
  }
}
