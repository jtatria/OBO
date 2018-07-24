

/* First created by JCasGen Mon Jun 18 18:20:05 CLT 2018 */
package edu.columbia.incite.uima.api.types.obo;

import org.apache.uima.jcas.JCas; 
import org.apache.uima.jcas.JCasRegistry;
import org.apache.uima.jcas.cas.TOP_Type;

import edu.columbia.incite.uima.api.types.Span;


/** Base type for OBO span annotations
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * XML source: /home/jta/src/local/obo/obo-java/target/jcasgen/typesystem.xml
 * @generated */
public class OBOSpan extends Span {
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = JCasRegistry.register(OBOSpan.class);
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
  protected OBOSpan() {/* intentionally empty block */}
    
  /** Internal - constructor used by generator 
   * @generated
   * @param addr low level Feature Structure reference
   * @param type the type of this Feature Structure 
   */
  public OBOSpan(int addr, TOP_Type type) {
    super(addr, type);
    readObject();
  }
  
  /** @generated
   * @param jcas JCas to which this Feature Structure belongs 
   */
  public OBOSpan(JCas jcas) {
    super(jcas);
    readObject();   
  } 

  /** @generated
   * @param jcas JCas to which this Feature Structure belongs
   * @param begin offset to the begin spot in the SofA
   * @param end offset to the end spot in the SofA 
  */  
  public OBOSpan(JCas jcas, int begin, int end) {
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
    if (OBOSpan_Type.featOkTst && ((OBOSpan_Type)jcasType).casFeat_oboType == null)
      jcasType.jcas.throwFeatMissing("oboType", "edu.columbia.incite.uima.api.types.obo.OBOSpan");
    return jcasType.ll_cas.ll_getStringValue(addr, ((OBOSpan_Type)jcasType).casFeatCode_oboType);}
    
  /** setter for oboType - sets Entity type 
   * @generated
   * @param v value to set into the feature 
   */
  public void setOboType(String v) {
    if (OBOSpan_Type.featOkTst && ((OBOSpan_Type)jcasType).casFeat_oboType == null)
      jcasType.jcas.throwFeatMissing("oboType", "edu.columbia.incite.uima.api.types.obo.OBOSpan");
    jcasType.ll_cas.ll_setStringValue(addr, ((OBOSpan_Type)jcasType).casFeatCode_oboType, v);}    
   
    
  //*--------------*
  //* Feature: xpath

  /** getter for xpath - gets XPath expression of source
   * @generated
   * @return value of the feature 
   */
  public String getXpath() {
    if (OBOSpan_Type.featOkTst && ((OBOSpan_Type)jcasType).casFeat_xpath == null)
      jcasType.jcas.throwFeatMissing("xpath", "edu.columbia.incite.uima.api.types.obo.OBOSpan");
    return jcasType.ll_cas.ll_getStringValue(addr, ((OBOSpan_Type)jcasType).casFeatCode_xpath);}
    
  /** setter for xpath - sets XPath expression of source 
   * @generated
   * @param v value to set into the feature 
   */
  public void setXpath(String v) {
    if (OBOSpan_Type.featOkTst && ((OBOSpan_Type)jcasType).casFeat_xpath == null)
      jcasType.jcas.throwFeatMissing("xpath", "edu.columbia.incite.uima.api.types.obo.OBOSpan");
    jcasType.ll_cas.ll_setStringValue(addr, ((OBOSpan_Type)jcasType).casFeatCode_xpath, v);}    
  }

    