

/* First created by JCasGen Mon Jun 18 18:20:05 CLT 2018 */
package edu.columbia.incite.uima.api.types.obo;

import org.apache.uima.jcas.JCas; 
import org.apache.uima.jcas.JCasRegistry;
import org.apache.uima.jcas.cas.TOP_Type;

import org.apache.uima.jcas.cas.AnnotationBase;


/** Criminal charge
 * Updated by JCasGen Mon Jun 18 18:20:05 CLT 2018
 * XML source: /home/jta/src/local/obo/obo-java/target/jcasgen/typesystem.xml
 * @generated */
public class Charge extends AnnotationBase {
  /** @generated
   * @ordered 
   */
  @SuppressWarnings ("hiding")
  public final static int typeIndexID = JCasRegistry.register(Charge.class);
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
  protected Charge() {/* intentionally empty block */}
    
  /** Internal - constructor used by generator 
   * @generated
   * @param addr low level Feature Structure reference
   * @param type the type of this Feature Structure 
   */
  public Charge(int addr, TOP_Type type) {
    super(addr, type);
    readObject();
  }
  
  /** @generated
   * @param jcas JCas to which this Feature Structure belongs 
   */
  public Charge(JCas jcas) {
    super(jcas);
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
  //* Feature: chargeId

  /** getter for chargeId - gets Criminal Charge Id
   * @generated
   * @return value of the feature 
   */
  public String getChargeId() {
    if (Charge_Type.featOkTst && ((Charge_Type)jcasType).casFeat_chargeId == null)
      jcasType.jcas.throwFeatMissing("chargeId", "edu.columbia.incite.uima.api.types.obo.Charge");
    return jcasType.ll_cas.ll_getStringValue(addr, ((Charge_Type)jcasType).casFeatCode_chargeId);}
    
  /** setter for chargeId - sets Criminal Charge Id 
   * @generated
   * @param v value to set into the feature 
   */
  public void setChargeId(String v) {
    if (Charge_Type.featOkTst && ((Charge_Type)jcasType).casFeat_chargeId == null)
      jcasType.jcas.throwFeatMissing("chargeId", "edu.columbia.incite.uima.api.types.obo.Charge");
    jcasType.ll_cas.ll_setStringValue(addr, ((Charge_Type)jcasType).casFeatCode_chargeId, v);}    
   
    
  //*--------------*
  //* Feature: defendant

  /** getter for defendant - gets Defendant name
   * @generated
   * @return value of the feature 
   */
  public Person getDefendant() {
    if (Charge_Type.featOkTst && ((Charge_Type)jcasType).casFeat_defendant == null)
      jcasType.jcas.throwFeatMissing("defendant", "edu.columbia.incite.uima.api.types.obo.Charge");
    return (Person)(jcasType.ll_cas.ll_getFSForRef(jcasType.ll_cas.ll_getRefValue(addr, ((Charge_Type)jcasType).casFeatCode_defendant)));}
    
  /** setter for defendant - sets Defendant name 
   * @generated
   * @param v value to set into the feature 
   */
  public void setDefendant(Person v) {
    if (Charge_Type.featOkTst && ((Charge_Type)jcasType).casFeat_defendant == null)
      jcasType.jcas.throwFeatMissing("defendant", "edu.columbia.incite.uima.api.types.obo.Charge");
    jcasType.ll_cas.ll_setRefValue(addr, ((Charge_Type)jcasType).casFeatCode_defendant, jcasType.ll_cas.ll_getFSRef(v));}    
   
    
  //*--------------*
  //* Feature: offence

  /** getter for offence - gets Offence description
   * @generated
   * @return value of the feature 
   */
  public Offence getOffence() {
    if (Charge_Type.featOkTst && ((Charge_Type)jcasType).casFeat_offence == null)
      jcasType.jcas.throwFeatMissing("offence", "edu.columbia.incite.uima.api.types.obo.Charge");
    return (Offence)(jcasType.ll_cas.ll_getFSForRef(jcasType.ll_cas.ll_getRefValue(addr, ((Charge_Type)jcasType).casFeatCode_offence)));}
    
  /** setter for offence - sets Offence description 
   * @generated
   * @param v value to set into the feature 
   */
  public void setOffence(Offence v) {
    if (Charge_Type.featOkTst && ((Charge_Type)jcasType).casFeat_offence == null)
      jcasType.jcas.throwFeatMissing("offence", "edu.columbia.incite.uima.api.types.obo.Charge");
    jcasType.ll_cas.ll_setRefValue(addr, ((Charge_Type)jcasType).casFeatCode_offence, jcasType.ll_cas.ll_getFSRef(v));}    
   
    
  //*--------------*
  //* Feature: verdict

  /** getter for verdict - gets Verdict description
   * @generated
   * @return value of the feature 
   */
  public Verdict getVerdict() {
    if (Charge_Type.featOkTst && ((Charge_Type)jcasType).casFeat_verdict == null)
      jcasType.jcas.throwFeatMissing("verdict", "edu.columbia.incite.uima.api.types.obo.Charge");
    return (Verdict)(jcasType.ll_cas.ll_getFSForRef(jcasType.ll_cas.ll_getRefValue(addr, ((Charge_Type)jcasType).casFeatCode_verdict)));}
    
  /** setter for verdict - sets Verdict description 
   * @generated
   * @param v value to set into the feature 
   */
  public void setVerdict(Verdict v) {
    if (Charge_Type.featOkTst && ((Charge_Type)jcasType).casFeat_verdict == null)
      jcasType.jcas.throwFeatMissing("verdict", "edu.columbia.incite.uima.api.types.obo.Charge");
    jcasType.ll_cas.ll_setRefValue(addr, ((Charge_Type)jcasType).casFeatCode_verdict, jcasType.ll_cas.ll_getFSRef(v));}    
  }

    