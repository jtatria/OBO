

/* First created by JCasGen Mon Jun 18 18:20:05 CLT 2018 */
package edu.columbia.incite.uima.api.types.obo;

import org.apache.uima.jcas.JCas; 
import org.apache.uima.jcas.JCasRegistry;
import org.apache.uima.jcas.cas.TOP_Type;



/** Place name
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * XML source: /home/jta/src/local/obo/obo-java/target/jcasgen/typesystem.xml
 * @generated */
public class Place extends Named {
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = JCasRegistry.register(Place.class);
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int type = typeIndexID;
  /** @generated
   * @return index of the type  
   */
  @Override
  public              int getTypeIndexID() {return typeIndexID;}
 
  /** Never called.  Disable default constructor
   * @generated */
  protected Place() {/* intentionally empty block */}
    
  /** Internal - constructor used by generator 
   * @generated
   * @param addr low level Feature Structure reference
   * @param type the type of this Feature Structure 
   */
  public Place(int addr, TOP_Type type) {
    super(addr, type);
    readObject();
  }
  
  /** @generated
   * @param jcas JCas to which this Feature Structure belongs 
   */
  public Place(JCas jcas) {
    super(jcas);
    readObject();   
  } 

  /** @generated
   * @param jcas JCas to which this Feature Structure belongs
   * @param begin offset to the begin spot in the SofA
   * @param end offset to the end spot in the SofA 
  */  
  public Place(JCas jcas, int begin, int end) {
    super(jcas);
    setBegin(begin);
    setEnd(end);
    readObject();
  }   

  /** 
   * <!-- begin-user-doc -->
   * Write your own initialization here
   * <!-- end-user-doc -->
   *
   * @generated modifiable 
   */
  private void readObject() {/*default - does nothing empty block */}
     
 
    
  //*--------------*
  //* Feature: placeName

  /** getter for placeName - gets Place name
   * @generated
   * @return value of the feature 
   */
  public String getPlaceName() {
    if (Place_Type.featOkTst && ((Place_Type)jcasType).casFeat_placeName == null)
      jcasType.jcas.throwFeatMissing("placeName", "edu.columbia.incite.uima.api.types.obo.Place");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Place_Type)jcasType).casFeatCode_placeName);}
    
  /** setter for placeName - sets Place name 
   * @generated
   * @param v value to set into the feature 
   */
  public void setPlaceName(String v) {
    if (Place_Type.featOkTst && ((Place_Type)jcasType).casFeat_placeName == null)
      jcasType.jcas.throwFeatMissing("placeName", "edu.columbia.incite.uima.api.types.obo.Place");
    jcasType.ll_cas.ll_setStringValue(addr, ((Place_Type)jcasType).casFeatCode_placeName, v);}    
   
    
  //*--------------*
  //* Feature: placeType

  /** getter for placeType - gets Place type
   * @generated
   * @return value of the feature 
   */
  public String getPlaceType() {
    if (Place_Type.featOkTst && ((Place_Type)jcasType).casFeat_placeType == null)
      jcasType.jcas.throwFeatMissing("placeType", "edu.columbia.incite.uima.api.types.obo.Place");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Place_Type)jcasType).casFeatCode_placeType);}
    
  /** setter for placeType - sets Place type 
   * @generated
   * @param v value to set into the feature 
   */
  public void setPlaceType(String v) {
    if (Place_Type.featOkTst && ((Place_Type)jcasType).casFeat_placeType == null)
      jcasType.jcas.throwFeatMissing("placeType", "edu.columbia.incite.uima.api.types.obo.Place");
    jcasType.ll_cas.ll_setStringValue(addr, ((Place_Type)jcasType).casFeatCode_placeType, v);}    
  }

    