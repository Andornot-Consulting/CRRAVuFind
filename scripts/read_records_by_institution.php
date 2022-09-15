<?php

// URL to fetch count by institutions
$crra_api_url = 'https://vufind.catholicresearch.org/vufind/api/v1/search';
$crra_url = 'https://vufind.catholicresearch.org/vufind/api/v1/search?ftype=AllFields&facet[]=institution&sort=relevance&page=1&limit=0&prettyPrint=true&lng=en';

$ch = curl_init($crra_url);

curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));

$institution_response = curl_exec($ch);
$curl_error = curl_error($ch);
curl_close($ch);
if ($curl_error) {
	print "Error retrieving institution data: ". $curl_error ."\n";
	exit();
}

$institution_response = json_decode($institution_response, true);
if (is_null($institution_response)) {
	print "Invalid institution data JSON\n";
	exit();
}

if (empty($institution_response['facets']) || empty($institution_response['facets']['institution'])) {
	print "No library institution data available\n";
	exit();
}

$institutions = $institution_response['facets']['institution'];
foreach ($institutions as $institution) {
	print "Institution: " . $institution['value'] . "\n";
	print "---\n";
	print  'Grand Total: ' . $institution['count'] . "\n\n";
	// build query to look for count by format
	parse_str($institution['href'], $output);
	$output['facet'][] = 'format';
	$format_institution_query = $crra_api_url . '?' . http_build_query($output);

	$format_ch = curl_init($format_institution_query);

	curl_setopt($format_ch, CURLOPT_HEADER, 0);
	curl_setopt($format_ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($format_ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));

	$format_response = curl_exec($format_ch);
	$curl_error = curl_error($format_ch);
	curl_close($format_ch);
	if ($curl_error) {
		print "Error retrieving format data: ". $curl_error ."\n";
		print "\n---\n\n";
		continue;
	}

	$format_response = json_decode($format_response, true);
	if (is_null($format_response)) {
		print "Invalid format data JSON\n";
		print "\n---\n\n";
		continue;
	}

	if (empty($format_response['facets']) || empty($format_response['facets']['format'])) {
		print "No format data available\n";
		print "\n---\n\n";
		continue;
	}

	$formats = $format_response['facets']['format'];
	print "Total by Format:\n";
	foreach ($formats as $format) {
		print '- ' . $format['value'] . ': ' . $format['count'] . "\n";
	}
	print "\n";

	// build query to look for count by building
	parse_str($institution['href'], $building_output);
	$building_output['facet'][] = 'building';
	$building_institution_query = $crra_api_url . '?' . http_build_query($building_output);

	$building_ch = curl_init($building_institution_query);

	curl_setopt($building_ch, CURLOPT_HEADER, 0);
	curl_setopt($building_ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($building_ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));

	$building_response = curl_exec($building_ch);
	$curl_error = curl_error($building_ch);
	curl_close($building_ch);
	if ($curl_error) {
		print "Error retrieving library data: ". $curl_error ."\n";
		print "\n---\n\n";
		continue;
	}

	$building_response = json_decode($building_response, true);
	if (is_null($format_response)) {
		print "Invalid library data JSON\n";
		print "\n---\n\n";
		continue;
	}

	if (empty($building_response['facets']) || empty($building_response['facets']['building'])) {
		print "\n\n---\n\n";
		continue;
	}

	$buildings = $building_response['facets']['building'];
	print "Total by Library:\n";
	foreach ($buildings as $building) {
		print '- ' . $building['value'] . ': ' . $building['count'] . "\n";
	}
	print "\n";
	print "\n---\n\n";
}
