<?php

namespace CRRA_Module\RecordDriver;

trait CRRATrait
{

    /**
     * Get all local finding aid URLs
     *
     * @return array
     */
    public function getLocalFindingAidUrl()
    {
        return isset($this->fields['localfindingaidurl_str_mv'])
            ? $this->fields['localfindingaidurl_str_mv'] : [];
    }

    /**
     * Get all remote finding aid URLs
     *
     * @return array
     */
    public function getRemoteFindingAidUrl()
    {
        return isset($this->fields['remotefindingaidurl_str_mv'])
            ? $this->fields['remotefindingaidurl_str_mv'] : [];
    }

    /**    
     * Get library name for the CRRA Marc record.
     *
     * @return string
     */
    public function getCRRALibrary()
    {
        return $this->fields['building'][0];
    }
    
    /**
     * Get institution name for the CRRA Marc record.
     *
     * @return string
     */
    public function getCRRAInstitution()
    {
        return $this->fields['institution'][0];

    }
    
    /**
     * Get the unique id for the CRRA Marc record.
     *
     * @return id
     */
    public function getCRRAKey()
    {
        return substr($this->fields['id'], 0, 3);

    }
    
    /**
     * Turn off the Ajax status for CRRA portal.
     * 
     * @return false
     */
    public function supportsAjaxStatus()
    {
        return false;
    }

}

