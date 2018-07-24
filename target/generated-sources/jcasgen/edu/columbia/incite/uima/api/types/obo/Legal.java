

/* First created by JCasGen Mon Jun 18 18:20:05 CLT 2018 */
package edu.columbia.incite.uima.api.types.obo;

import org.apache.uima.jcas.JCas; 
import org.apache.uima.jcas.JCasRegistry;
import org.apache.uima.jcas.cas.TOP_Type;



/** Base type for legal entities
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * XML source: /home/jta/src/local/obo/obo-java/target/jcasgen/typesystem.xml
 * @generated */
public class Legal extends OBOEntity {
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = JCasRegistry.register(Legal.class);
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
  protected Legal() {/* intentionally empty block */}
    
  /** Internal - constructor used by generator 
   * @generated
   * @param addr low level Feature Structure reference
   * @param type the type of this Feature Structure 
   */
  public Legal(int addr, TOP_Type type) {
    super(addr, type);
    readObject();
  }
  
  /** @generated
   * @param jcas JCas to which this Feature Structure belongs 
   */
  public Legal(JCas jcas) {
    super(jcas);
    readObject();   
  } 

  /** @generated
   * @param jcas JCas to which this Feature Structure belongs
   * @param begin offset to the begin spot in the SofA
   * @param end offset to the end spot in the SofA 
  */  
  public Legal(JCas jcas, int begin, int end) {
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
  //* Feature: category

  /** getter for category - gets Category
   * @generated
   * @return value of the feature 
   */
  public String getCategory() {
    if (Legal_Type.featOkTst && ((Legal_Type)jcasType).casFeat_category == null)
      jcasType.jcas.throwFeatMissing("category", "edu.columbia.incite.uima.api.types.obo.Legal");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Legal_Type)jcasType).casFeatCode_category);}
    
  /** setter for category - sets Category 
   * @generated
   * @param v value to set into the feature 
   */
  public void setCategory(String v) {
    if (Legal_Type.featOkTst && ((Legal_Type)jcasType).casFeat_category == null)
      jcasType.jcas.throwFeatMissing("category", "edu.columbia.incite.uima.api.types.obo.Legal");
    jcasType.ll_cas.ll_setStringValue(addr, ((Legal_Type)jcasType).casFeatCode_category, v);}    
   
    
  //*--------------*
  //* Feature: subcategory

  /** getter for subcategory - gets Subcategory
   * @generated
   * @return value of the feature 
   */
  public String getSubcategory() {
    if (Legal_Type.featOkTst && ((Legal_Type)jcasType).casFeat_subcategory == null)
      jcasType.jcas.throwFeatMissing("subcategory", "edu.columbia.incite.uima.api.types.obo.Legal");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Legal_Type)jcasType).casFeatCode_subcategory);}
    
  /** setter for subcategory - sets Subcategory 
   * @generated
   * @param v value to set into the feature 
   */
  public void setSubcategory(String v) {
    if (Legal_Type.featOkTst && ((Legal_Type)jcasType).casFeat_subcategory == null)
      jcasType.jcas.throwFeatMissing("subcategory", "edu.columbia.incite.uima.api.types.obo.Legal");
    jcasType.ll_cas.ll_setStringValue(addr, ((Legal_Type)jcasType).casFeatCode_subcategory, v);}    
  }

    