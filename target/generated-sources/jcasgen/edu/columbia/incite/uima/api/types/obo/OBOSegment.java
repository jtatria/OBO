

/* First created by JCasGen Mon Jun 18 18:20:05 CLT 2018 */
package edu.columbia.incite.uima.api.types.obo;

import org.apache.uima.jcas.JCas; 
import org.apache.uima.jcas.JCasRegistry;
import org.apache.uima.jcas.cas.TOP_Type;



/** Base type for segment span annotations
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * XML source: /home/jta/src/local/obo/obo-java/target/jcasgen/typesystem.xml
 * @generated */
public class OBOSegment extends OBOSpan {
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = JCasRegistry.register(OBOSegment.class);
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
  protected OBOSegment() {/* intentionally empty block */}
    
  /** Internal - constructor used by generator 
   * @generated
   * @param addr low level Feature Structure reference
   * @param type the type of this Feature Structure 
   */
  public OBOSegment(int addr, TOP_Type type) {
    super(addr, type);
    readObject();
  }
  
  /** @generated
   * @param jcas JCas to which this Feature Structure belongs 
   */
  public OBOSegment(JCas jcas) {
    super(jcas);
    readObject();   
  } 

  /** @generated
   * @param jcas JCas to which this Feature Structure belongs
   * @param begin offset to the begin spot in the SofA
   * @param end offset to the end spot in the SofA 
  */  
  public OBOSegment(JCas jcas, int begin, int end) {
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
  //* Feature: oboType

  /** getter for oboType - gets Entity type
   * @generated
   * @return value of the feature 
   */
  public String getOboType() {
    if (OBOSegment_Type.featOkTst && ((OBOSegment_Type)jcasType).casFeat_oboType == null)
      jcasType.jcas.throwFeatMissing("oboType", "edu.columbia.incite.uima.api.types.obo.OBOSegment");
    return jcasType.ll_cas.ll_getStringValue(addr, ((OBOSegment_Type)jcasType).casFeatCode_oboType);}
    
  /** setter for oboType - sets Entity type 
   * @generated
   * @param v value to set into the feature 
   */
  public void setOboType(String v) {
    if (OBOSegment_Type.featOkTst && ((OBOSegment_Type)jcasType).casFeat_oboType == null)
      jcasType.jcas.throwFeatMissing("oboType", "edu.columbia.incite.uima.api.types.obo.OBOSegment");
    jcasType.ll_cas.ll_setStringValue(addr, ((OBOSegment_Type)jcasType).casFeatCode_oboType, v);}    
   
    
  //*--------------*
  //* Feature: xpath

  /** getter for xpath - gets XPath expression of source
   * @generated
   * @return value of the feature 
   */
  public String getXpath() {
    if (OBOSegment_Type.featOkTst && ((OBOSegment_Type)jcasType).casFeat_xpath == null)
      jcasType.jcas.throwFeatMissing("xpath", "edu.columbia.incite.uima.api.types.obo.OBOSegment");
    return jcasType.ll_cas.ll_getStringValue(addr, ((OBOSegment_Type)jcasType).casFeatCode_xpath);}
    
  /** setter for xpath - sets XPath expression of source 
   * @generated
   * @param v value to set into the feature 
   */
  public void setXpath(String v) {
    if (OBOSegment_Type.featOkTst && ((OBOSegment_Type)jcasType).casFeat_xpath == null)
      jcasType.jcas.throwFeatMissing("xpath", "edu.columbia.incite.uima.api.types.obo.OBOSegment");
    jcasType.ll_cas.ll_setStringValue(addr, ((OBOSegment_Type)jcasType).casFeatCode_xpath, v);}    
   
    
  //*--------------*
  //* Feature: date

  /** getter for date - gets Session date
   * @generated
   * @return value of the feature 
   */
  public String getDate() {
    if (OBOSegment_Type.featOkTst && ((OBOSegment_Type)jcasType).casFeat_date == null)
      jcasType.jcas.throwFeatMissing("date", "edu.columbia.incite.uima.api.types.obo.OBOSegment");
    return jcasType.ll_cas.ll_getStringValue(addr, ((OBOSegment_Type)jcasType).casFeatCode_date);}
    
  /** setter for date - sets Session date 
   * @generated
   * @param v value to set into the feature 
   */
  public void setDate(String v) {
    if (OBOSegment_Type.featOkTst && ((OBOSegment_Type)jcasType).casFeat_date == null)
      jcasType.jcas.throwFeatMissing("date", "edu.columbia.incite.uima.api.types.obo.OBOSegment");
    jcasType.ll_cas.ll_setStringValue(addr, ((OBOSegment_Type)jcasType).casFeatCode_date, v);}    
   
    
  //*--------------*
  //* Feature: year

  /** getter for year - gets Session year
   * @generated
   * @return value of the feature 
   */
  public String getYear() {
    if (OBOSegment_Type.featOkTst && ((OBOSegment_Type)jcasType).casFeat_year == null)
      jcasType.jcas.throwFeatMissing("year", "edu.columbia.incite.uima.api.types.obo.OBOSegment");
    return jcasType.ll_cas.ll_getStringValue(addr, ((OBOSegment_Type)jcasType).casFeatCode_year);}
    
  /** setter for year - sets Session year 
   * @generated
   * @param v value to set into the feature 
   */
  public void setYear(String v) {
    if (OBOSegment_Type.featOkTst && ((OBOSegment_Type)jcasType).casFeat_year == null)
      jcasType.jcas.throwFeatMissing("year", "edu.columbia.incite.uima.api.types.obo.OBOSegment");
    jcasType.ll_cas.ll_setStringValue(addr, ((OBOSegment_Type)jcasType).casFeatCode_year, v);}    
  }

    