import module namespace uima="http://incite.columbia.edu/uima/TypeSystem";

declare variable $name := "OBOTypes";
declare variable $desc := "Types for TEI annotations in the Old Bailey Online Corpus";
declare variable $version := "1.0";
declare variable $vendor := "Incite - Columbia University";

declare variable $root := "/home/jta/src/local";
declare variable $base := "edu.columbia.incite.uima.api.types";
declare variable $ns := $base || ".obo";

declare variable $importPath := $root
|| "/incite/incite-lector/src/main/resources/desc/type/InciteTypes.xml";
declare variable $filePath   := $root
|| "/obo/obo-java/src/main/resources/desc/type/" || $name || ".xml";

declare variable $spanBase   := $base || ".Span";
declare variable $segmentBase := $base || ".Segment";
declare variable $entityBase  := $base || ".Entity";

let $typeF := uima:feature( "oboType", "Entity type", $uima:String )
let $xpathF := uima:feature( "xpath", "XPath expression of source", $uima:String )

let $baseT := uima:type(
  $ns || ".OBOSpan"
  , "Base type for OBO span annotations"
  , $spanBase
  , ( $typeF, $xpathF )
)

(: OBO entity types :)
let $entityT := uima:type(
  $ns || ".OBOEntity"
  , "Base type for entity span annotations"
  , uima:fsName( $baseT )
)

(: Generic entities :)
let $dateT  := uima:type( $ns || ".Date", "Date" , uima:fsName( $entityT ), () )
let $labelT := uima:type( $ns || ".Label", "Entity label" , uima:fsName( $entityT ), () )
let $genericEntities := ( $dateT, $labelT )

(: Named entities :)
let $namedT := uima:type(
  $ns || ".Named"
  , "Base type for named entities"
  , uima:fsName( $entityT )
)

let $givenF := uima:feature( "given", "Given name", $uima:String )
let $surnameF := uima:feature( "surname", "Surname", $uima:String )
let $genderF := uima:feature( "gender", "Gender", $uima:String )
let $ageF := uima:feature( "age", "Age", $uima:String )
let $occF := uima:feature( "occupation", "Occupation", $uima:String )
let $personT := uima:type(
  $ns || ".Person"
  , "Personal names"
  , uima:fsName( $namedT )
  , ( $givenF, $surnameF, $genderF, $ageF, $occF )
)

let $placeNameF := uima:feature( "placeName", "Place name", $uima:String )
let $placeTypeF := uima:feature( "placeType", "Place type", $uima:String )
let $placeT := uima:type(
  $ns || ".Place"
  , "Place name"
  , uima:fsName( $namedT )
  , ( $placeNameF, $placeTypeF )
)
let $namedEntities := ( $namedT, $personT, $placeT )

(: Legal entities :)
let $catF := uima:feature( "category", "Category", $uima:String )
let $subcatF := uima:feature( "subcategory", "Subcategory", $uima:String )

let $legalT := uima:type( $ns || ".Legal", "Base type for legal entities" , uima:fsName( $entityT ), ( $catF, $subcatF ) )

let $offenceT := uima:type(
  $ns || ".Offence", "Offence description", uima:fsName( $legalT ), ()
)

let $verdictT := uima:type(
  $ns || ".Verdict", "Verdict description", uima:fsName( $legalT ), ()
)

let $punishmentT := uima:type(
  $ns || ".Punishment", "Punishment description", uima:fsName( $legalT ), ()
)
let $legalEntities := ( $legalT, $offenceT, $verdictT, $punishmentT )

let $entities := ( $entityT, $genericEntities, $namedEntities, $legalEntities )

(: OBO segment types :)
let $yearF := uima:feature( "year", "Session year", $uima:String )
let $dateF := uima:feature( "date", "Session date", $uima:String )
let $segmentT := uima:type(
  $ns || ".OBOSegment"
  , "Base type for segment span annotations"
  , uima:fsName( $baseT )
  , ( $typeF, $xpathF, $dateF, $yearF )
)

let $dupesF := uima:feature( "proc_dupes","", $uima:StringArray )
let $doesF := uima:feature( "proc_does","", $uima:StringArray )
let $dirsF := uima:feature( "proc_dirs","", $uima:StringArray )
let $sessionT := uima:type(
  $ns || ".Session"
  , "Session metadata"
  , uima:fsName( $segmentT )
  , ( $dupesF, $doesF, $dirsF )
)

let $sectionT := uima:type(
  $ns || ".Section"
  , "Base types for document sections"
  , uima:fsName( $segmentT )
  (: TODO why are these defined again here? :)
  , ( $typeF, $xpathF, $dateF, $yearF )
)
let $segments := ( $segmentT, $sessionT, $sectionT )

(: Trial accounts :)
let $chaDefF := uima:feature( "defendant", "Defendant name", uima:fsName( $personT ) )
let $chaOffF := uima:feature( "offence", "Offence description", uima:fsName( $offenceT ) )
let $chaVerF := uima:feature( "verdict", "Verdict description", uima:fsName( $verdictT ) )
let $chargeT := uima:type(
  $ns || ".Charge"
  , "Criminal charge"
  , $uima:AnnotationBase (: no indexing, access through trialAccounts :)
  , (
    uima:feature( "chargeId", "Criminal Charge Id", $uima:String )
    , $chaDefF, $chaOffF, $chaVerF
  )
)


let $chargesF := uima:feature(
  "charges", "Charges in this trial", $uima:FSArray, uima:fsName( $chargeT ), true()
)
let $trialT := uima:type( $ns || ".TrialAccount", "Trial accounts", uima:fsName( $sectionT ), $chargesF )
let $trials := ( $chargeT, $trialT )

let $ts := uima:typeSystem( $name, $desc, $version, $vendor, (
  $baseT, $entities, $segments, $trials
), uima:import( $importPath  ) )


return ( $ts, file:write( $filePath, $ts ) )
