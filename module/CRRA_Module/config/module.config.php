<?php

return array (
  'vufind' => 
  array (
    'plugin_managers' => 
    array (
      'recorddriver' => 
      array (
        'factories' => 
        array (
          'CRRA_Module\\RecordDriver\\SolrDefault' => 'CRRA_Module\\RecordDriver\\SolrDefaultFactory',
          'CRRA_Module\\RecordDriver\\SolrMarc' => 'CRRA_Module\\RecordDriver\\SolrDefaultFactory',
        ),
        'aliases' => 
        array (
          'VuFind\\RecordDriver\\SolrDefault' => 'CRRA_Module\\RecordDriver\\SolrDefault',
          'VuFind\\RecordDriver\\SolrMarc' => 'CRRA_Module\\RecordDriver\\SolrMarc',
        ),
        'delegators' => 
        array (
          'CRRA_Module\\RecordDriver\\SolrMarc' => 
          array (
            0 => 'CRRA_Module\\RecordDriver\\IlsAwareDelegatorFactory',
          ),
        ),
      ),
    ),
  ),
);
