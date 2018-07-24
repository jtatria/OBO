

/* First created by JCasGen Mon Jun 18 18:20:05 CLT 2018 */
package edu.columbia.incite.uima.api.types.obo;

import org.apache.uima.jcas.JCas; 
import org.apache.uima.jcas.JCasRegistry;
import org.apache.uima.jcas.cas.TOP_Type;

import org.apache.uima.jcas.cas.StringArray;


/** Session metadata
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * XML source: /home/jta/src/local/obo/obo-java/target/jcasgen/typesystem.xml
 * @generated */
public class Session extends OBOSegment {
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = JCasRegistry.register(Session.class);
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
  protected Session() {/* intentionally empty block */}
    
  /** Internal - constructor used by generator 
   * @generated
   * @param addr low level Feature Structure reference
   * @param type the type of this Feature Structure 
   */
  public Session(int addr, TOP_Type type) {
    super(addr, type);
    readObject();
  }
  
  /** @generated
   * @param jcas JCas to which this Feature Structure belongs 
   */
  public Session(JCas jcas) {
    super(jcas);
    readObject();   
  } 

  /** @generated
   * @param jcas JCas to which this Feature Structure belongs
   * @param begin offset to the begin spot in the SofA
   * @param end offset to the end spot in the SofA 
  */  
  public Session(JCas jcas, int begin, int end) {
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
  //* Feature: proc_dupes

  /** getter for proc_dupes - gets 
   * @generated
   * @return value of the feature 
   */
  public StringArray getProc_dupes() {
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_dupes == null)
      jcasType.jcas.throwFeatMissing("proc_dupes", "edu.columbia.incite.uima.api.types.obo.Session");
    return (StringArray)(jcasType.ll_cas.ll_getFSForRef(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dupes)));}
    
  /** setter for proc_dupes - sets  
   * @generated
   * @param v value to set into the feature 
   */
  public void setProc_dupes(StringArray v) {
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_dupes == null)
      jcasType.jcas.throwFeatMissing("proc_dupes", "edu.columbia.incite.uima.api.types.obo.Session");
    jcasType.ll_cas.ll_setRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dupes, jcasType.ll_cas.ll_getFSRef(v));}    
    
  /** indexed getter for proc_dupes - gets an indexed value - 
   * @generated
   * @param i index in the array to get
   * @return value of the element at index i 
   */
  public String getProc_dupes(int i) {
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_dupes == null)
      jcasType.jcas.throwFeatMissing("proc_dupes", "edu.columbia.incite.uima.api.types.obo.Session");
    jcasType.jcas.checkArrayBounds(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dupes), i);
    return jcasType.ll_cas.ll_getStringArrayValue(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dupes), i);}

  /** indexed setter for proc_dupes - sets an indexed value - 
   * @generated
   * @param i index in the array to set
   * @param v value to set into the array 
   */
  public void setProc_dupes(int i, String v) { 
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_dupes == null)
      jcasType.jcas.throwFeatMissing("proc_dupes", "edu.columbia.incite.uima.api.types.obo.Session");
    jcasType.jcas.checkArrayBounds(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dupes), i);
    jcasType.ll_cas.ll_setStringArrayValue(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dupes), i, v);}
   
    
  //*--------------*
  //* Feature: proc_does

  /** getter for proc_does - gets 
   * @generated
   * @return value of the feature 
   */
  public StringArray getProc_does() {
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_does == null)
      jcasType.jcas.throwFeatMissing("proc_does", "edu.columbia.incite.uima.api.types.obo.Session");
    return (StringArray)(jcasType.ll_cas.ll_getFSForRef(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_does)));}
    
  /** setter for proc_does - sets  
   * @generated
   * @param v value to set into the feature 
   */
  public void setProc_does(StringArray v) {
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_does == null)
      jcasType.jcas.throwFeatMissing("proc_does", "edu.columbia.incite.uima.api.types.obo.Session");
    jcasType.ll_cas.ll_setRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_does, jcasType.ll_cas.ll_getFSRef(v));}    
    
  /** indexed getter for proc_does - gets an indexed value - 
   * @generated
   * @param i index in the array to get
   * @return value of the element at index i 
   */
  public String getProc_does(int i) {
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_does == null)
      jcasType.jcas.throwFeatMissing("proc_does", "edu.columbia.incite.uima.api.types.obo.Session");
    jcasType.jcas.checkArrayBounds(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_does), i);
    return jcasType.ll_cas.ll_getStringArrayValue(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_does), i);}

  /** indexed setter for proc_does - sets an indexed value - 
   * @generated
   * @param i index in the array to set
   * @param v value to set into the array 
   */
  public void setProc_does(int i, String v) { 
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_does == null)
      jcasType.jcas.throwFeatMissing("proc_does", "edu.columbia.incite.uima.api.types.obo.Session");
    jcasType.jcas.checkArrayBounds(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_does), i);
    jcasType.ll_cas.ll_setStringArrayValue(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_does), i, v);}
   
    
  //*--------------*
  //* Feature: proc_dirs

  /** getter for proc_dirs - gets 
   * @generated
   * @return value of the feature 
   */
  public StringArray getProc_dirs() {
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_dirs == null)
      jcasType.jcas.throwFeatMissing("proc_dirs", "edu.columbia.incite.uima.api.types.obo.Session");
    return (StringArray)(jcasType.ll_cas.ll_getFSForRef(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dirs)));}
    
  /** setter for proc_dirs - sets  
   * @generated
   * @param v value to set into the feature 
   */
  public void setProc_dirs(StringArray v) {
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_dirs == null)
      jcasType.jcas.throwFeatMissing("proc_dirs", "edu.columbia.incite.uima.api.types.obo.Session");
    jcasType.ll_cas.ll_setRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dirs, jcasType.ll_cas.ll_getFSRef(v));}    
    
  /** indexed getter for proc_dirs - gets an indexed value - 
   * @generated
   * @param i index in the array to get
   * @return value of the element at index i 
   */
  public String getProc_dirs(int i) {
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_dirs == null)
      jcasType.jcas.throwFeatMissing("proc_dirs", "edu.columbia.incite.uima.api.types.obo.Session");
    jcasType.jcas.checkArrayBounds(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dirs), i);
    return jcasType.ll_cas.ll_getStringArrayValue(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dirs), i);}

  /** indexed setter for proc_dirs - sets an indexed value - 
   * @generated
   * @param i index in the array to set
   * @param v value to set into the array 
   */
  public void setProc_dirs(int i, String v) { 
    if (Session_Type.featOkTst && ((Session_Type)jcasType).casFeat_proc_dirs == null)
      jcasType.jcas.throwFeatMissing("proc_dirs", "edu.columbia.incite.uima.api.types.obo.Session");
    jcasType.jcas.checkArrayBounds(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dirs), i);
    jcasType.ll_cas.ll_setStringArrayValue(jcasType.ll_cas.ll_getRefValue(addr, ((Session_Type)jcasType).casFeatCode_proc_dirs), i, v);}
  }

    