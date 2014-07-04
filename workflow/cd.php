<?php
define("WF_QUERY", $query);
require_once('workflows.php');
require_once('underscore.php');
$wf = new Workflows();
$filepath = "data.json";

#ファイルがないもしくは、1日以上経っている場合は更新する
if ( !file_exists($filepath) || (filemtime($filepath) <= time()-86400) ) {
	$url = "https://app.codegrid.net/api/entry";
	$data = json_decode(@file_get_contents($url, 0, $context));
	if (count($data)) {
		file_put_contents($filepath, json_encode($data));
	}
}

$json = json_decode(file_get_contents($filepath));

$dataList = __::filter($json, function($entry) {
	$findTitle = stripos($entry->title, constant('WF_QUERY')) !== false;
	$findDescription = stripos($entry->description, constant('WF_QUERY')) !== false;
	$findTag = __::filter($entry->tag, function($tag){
		return stripos($tag, constant('WF_QUERY')) !== false;
	});
	return $findTitle || $findDescription || $findTag;
});

foreach($dataList as $data) {
	$wf_url = "https://app.codegrid.net/entry/".urldecode($data->slug);
	$wf_title = urldecode($data->title);
	$wf_description = urldecode($data->description);
	$wf_icon = 'icon.png';
	# 無料記事の場合はアイコンを変更する
	if ($data->expose == true) {
		$wf_icon = 'icon-unlock.png';
	}
	$wf->result(
		time(),
		$wf_url,
		$wf_title,
		$wf_description,
		$wf_icon
	);
}

echo $wf->toxml();
?>
