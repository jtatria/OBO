

/* First created by JCasGen Mon Jun 18 18:20:05 CLT 2018 */
package edu.columbia.incite.uima.api.types.obo;

import org.apache.uima.jcas.JCas; 
import org.apache.uima.jcas.JCasRegistry;
import org.apache.uima.jcas.cas.TOP_Type;

import org.apache.uima.jcas.cas.FSArray;


/** Trial accounts
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * XML source: /home/jta/src/local/obo/obo-java/target/jcasgen/typesystem.xml
 * @generated */
public class TrialAccount extends Section {
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = JCasRegistry.register(TrialAccount.class);
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
  protected TrialAccount() {/* intentionally empty block */}
    
  /** Internal - constructor used by generator 
   * @generated
   * @param addr low level Feature Structure reference
   * @param type the type of this Feature Structure 
   */
  public TrialAccount(int addr, TOP_Type type) {
    super(addr, type);
    readObject();
  }
  
  /** @generated
   * @param jcas JCas to which this Feature Structure belongs 
   */
  public TrialAccount(JCas jcas) {
    super(jcas);
    readObject();   
  } 

  /** @generated
   * @param jcas JCas to which this Feature Structure belongs
   * @param begin offset to the begin spot in the SofA
   * @param end offset to the end spot in the SofA 
  */  
  public TrialAccount(JCas jcas, int begin, int end) {
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
  //* Feature: charges

  /** getter for charges - gets Charges in this trial
   * @generated
   * @return value of the feature 
   */
  public FSArray getCharges() {
    if (TrialAccount_Type.featOkTst && ((TrialAccount_Type)jcasType).casFeat_charges == null)
      jcasType.jcas.throwFeatMissing("charges", "edu.columbia.incite.uima.api.types.obo.TrialAccount");
    return (FSArray)(jcasType.ll_cas.ll_getFSForRef(jcasType.ll_cas.ll_getRefValue(addr, ((TrialAccount_Type)jcasType).casFeatCode_charges)));}
    
  /** setter for charges - sets Charges in this trial 
   * @generated
   * @param v value to set into the feature 
   */
  public void setCharges(FSArray v) {
    if (TrialAccount_Type.featOkTst && ((TrialAccount_Type)jcasType).casFeat_charges == null)
      jcasType.jcas.throwFeatMissing("charges", "edu.columbia.incite.uima.api.types.obo.TrialAccount");
    jcasType.ll_cas.ll_setRefValue(addr, ((TrialAccount_Type)jcasType).casFeatCode_charges, jcasType.ll_cas.ll_getFSRef(v));}    
    
  /** indexed getter for charges - gets an indexed value - Charges in this trial
   * @generated
   * @param i index in the array to get
   * @return value of the element at index i 
   */
  public Charge getCharges(int i) {
    if (TrialAccount_Type.featOkTst && ((TrialAccount_Type)jcasType).casFeat_charges == null)
      jcasType.jcas.throwFeatMissing("charges", "edu.columbia.incite.uima.api.types.obo.TrialAccount");
    jcasType.jcas.checkArrayBounds(jcasType.ll_cas.ll_getRefValue(addr, ((TrialAccount_Type)jcasType).casFeatCode_charges), i);
    return (Charge)(jcasType.ll_cas.ll_getFSForRef(jcasType.ll_cas.ll_getRefArrayValue(jcasType.ll_cas.ll_getRefValue(addr, ((TrialAccount_Type)jcasType).casFeatCode_charges), i)));}

  /** indexed setter for charges - sets an indexed value - Charges in this trial
   * @generated
   * @param i index in the array to set
   * @param v value to set into the array 
   */
  public void setCharges(int i, Charge v) { 
    if (TrialAccount_Type.featOkTst && ((TrialAccount_Type)jcasType).casFeat_charges == null)
      jcasType.jcas.throwFeatMissing("charges", "edu.columbia.incite.uima.api.types.obo.TrialAccount");
    jcasType.jcas.checkArrayBounds(jcasType.ll_cas.ll_getRefValue(addr, ((TrialAccount_Type)jcasType).casFeatCode_charges), i);
    jcasType.ll_cas.ll_setRefArrayValue(jcasType.ll_cas.ll_getRefValue(addr, ((TrialAccount_Type)jcasType).casFeatCode_charges), i, jcasType.ll_cas.ll_getFSRef(v));}
  }

    