@RestResource(urlMapping='/sample/attach/get')

global with sharing class form_sample_getattach_api {
	@HttpGet
	global static ResultData getMessage(){
		ResultData result = new ResultData();

		RestRequest req = RestContext.request;
		String sfid = req.params.get('id');
		if(String.isBlank(sfid)) return result;

		//メッセージ取得
		String m_query = 'SELECT id,name,message__c,title__c FROM SampleMessage__c WHERE id=:sfid LIMIT 1';
		List<SampleMessage__c> messages = Database.query(m_query);
		SampleMessage__c message = messages[0];
		Id mid = message.Id;

		result.title = message.title__c;
		result.message = message.message__c;

		//添付ファイル取得
		String a_query = 'SELECT id,body,bodylength,contenttype,name,parentid FROM Attachment WHERE parentid=:mid';
		List<Attachment> attaches = Database.query(a_query);

		List<ResultFile> files = new List<ResultFile>();
		for(Attachment attach : attaches){
			ResultFile file = new ResultFile();
			file.id = attach.Id;
			file.name = attach.Name;
			file.size = attach.bodylength;
			file.type = attach.ContentType;
			files.add(file);
		}
		result.files = files;

		return result;
	}

	@HttpPost
	global static ResultFileBody getAttach(){
		ResultFileBody result = new ResultFileBody();

		RestRequest req = RestContext.request;
		String sfid = req.params.get('id');
		if(String.isBlank(sfid)) return result;

		//添付ファイル取得
		String a_query = 'SELECT id,body,bodylength,contenttype,name,parentid FROM Attachment WHERE Id=:sfid LIMIT 1';
		List<Attachment> attaches = Database.query(a_query);

		Attachment attache = attaches[0];
		result.file_body = EncodingUtil.base64Encode(attache.body);
		result.file_name = attache.Name;

		return result;
	}

	global class ResultData {
    global String title;
    global String message;
		global List<ResultFile> files;
  }

	global class ResultFile {
		global Id id;
		global String name;
		global String type;
		global String body;
		global Integer size;
	}

	global class ResultFileBody{
		global String file_body;
		global String file_name;
	}
}
