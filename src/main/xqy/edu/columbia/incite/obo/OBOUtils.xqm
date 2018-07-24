module namespace obo="http://incite.columbia.edu/obo/OBOUtils";

declare variable $obo:db := 'pob_7-2';

declare function obo:get( $path as xs:string ) as element()* {
  let $doc := fn:replace( $path, "/(.*?)/.*", "$1" )
  let $xpath := fn:replace( $path, ".*/div0\[1\]/", "" )
  let $query := 'db:attribute( "' || $obo:db || '", "' || $doc || '" )/parent::div0/' || $xpath
  return xquery:eval( $query )
};